#!/usr/bin/env bash

set -Eeou pipefail

: "${DEBUG:=false}"
: "${EDITOR:=vi}"

function error {
  echo ERROR: "$@" >&2
  exit 1
}

function dbg {
  if "$DEBUG"; then
    echo DEBUG: "$@" >&2
  fi
}

function dbg_cmd {
  dbg "$@"
  "$@"
}

# If the script is installed by nix, the tools will be exact paths to the executables;
# if it's not, this will remove the @'s and hope the correct versions are in the PATH.
function unsubsted {
  if [[ "$1" =~ ^/ ]]; then
    echo "$1"
  else
    echo "${1//@/}"
  fi
}

MKTEMP=$(unsubsted @mktemp@)
BASENAME=$(unsubsted @basename@)
DIRNAME=$(unsubsted @dirname@)
REALPATH=$(unsubsted @realpath@)
SORT=$(unsubsted @sort@)
CAT=$(unsubsted @cat@)
RM=$(unsubsted @rm@)
HEAD=$(unsubsted @head@)
FIND=$(unsubsted @find@)
SHA1SUM=$(unsubsted @sha1sum@)
CUT=$(unsubsted @cut@)

AGE=$(unsubsted @age@)

ME="$("$BASENAME" "$0")"

function cmd_help {
  $CAT <<EOF
${ME}: manage age encrypted files in a directory tree

Usage: ${ME} [options] command [args]

Commands:
  cat <file>        Decrypt <file> and print it to stdout
  add <src> <dst>   Encrypt <src> and store it in <dst>
  edit <file>       Decrypt <file> to a temporary file and open it in an editor
  keys <dst>        Show the keys that would be used to encrypt <dst> (see below)
  rekey [<dst>]     Re-encrypt (see below)
  list [<dir>]      List all encrypted files (see below)
  help              Show this help message

Options:
  --identity <file>  Use <file> as the identity file (default: ~/.ssh/id_ed25519)

${ME} uses the age encryption tool to encrypt and decrypt files. It expects to find
a file named .agemaster in the directory tree where it is run, or in any parent
directory. This file should contain the public keys of the recipients of the
encrypted files. If a file named .agekey is found in the same directory as a file
to be encrypted, or in any parent directory up to the .agemaster file, it will be
used as an additional recipient. Additionally, for a file named <file> keys may
be specified in a file named .<file>.agekey in the same directory as <file>; if the
<file> has the extension .age, it will be removed before looking for the key file.

${ME} is meant mainly for use with agenix (https://github.com/ryantm/agenix), where the
master key (.agemaster) contains the public keys of repo managers, and the key files
(.agekey) contain the public keys of individual users or systems where the secrets
will be decrypted and used. It does not, however, require agenix to be used.

keys command will show the keys that would be used to encrypt a file, or, if <dst>
is a directory, a new file in that directory with no dedicated .<dst>.agekey file.

rekey command if called with no parameters will reencrypt all the files in the
entire directory tree rooted at the nearest .agemaster file up (or, if none is found,
the current directory). If a parameter is given and it's a directory, it will
reencrypt all the files in that directory tree. If it's a file, it will reencrypt
that file only.

list command will list all the files that would be reencrypted by rekey if called
with the same (lack of) parameters.
EOF
}


function error_cleanup {
  mess="$1"
  shift
  "$RM" -rf "$mess"
  error "$@"
}

# Search for a file named .agekey in the current directory or any parent directory
# until a .agemaster file is found or the root directory is reached. Return the contents
# of all the .agekey and .agemaster files found, concatenated with newlines between.
function search_up {
  local keys=""
  dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -s "${dir}/.agekey" ]; then
      keys+="$("$CAT" "${dir}/.agekey")"$'\n'
    fi
    if [ -s "${dir}/.agemaster" ]; then
      keys+=$("$CAT" "${dir}/.agemaster")$'\n'
      break
    fi
    dir=$("$DIRNAME" "$dir")
  done
  echo "$keys"
}

function find_keys {
  local keys=""
  dst="$("$REALPATH" "$1")"

  if [[ -d "$dst" ]]; then
    keys=$(dbg_cmd search_up "$dst")
  else
    # File-specific key: in the same directory as the file, named .<file>.agekey
    # if <file> has the extension .age appended, it is removed,
    # e.g. /path/to/file.txt.age -> /path/to/.file.txt.agekey
    # but also /path/to/file.txt -> /path/to/.file.txt.agekey
    dir=$("$DIRNAME" "$dst")
    file=$("$BASENAME" "$dst" .age)

    if [ -s "${dir}/.${file}.agekey" ]; then
      keys=$("$CAT" "${dir}/.${file}.agekey")$'\n'
    fi

    keys+=$(dbg_cmd search_up "$dir")
  fi

  unique=$(echo "$keys" | "$SORT" -u)

  if [ -z "$unique" ]; then
    error "No keys found for $dst"
  fi

  echo "$unique"
}

function check_identity {
  if [[ ! -s "$IDENTITY" || ! -r "$IDENTITY" ]]; then
    error "Identity file not found, empty or unreadable: $IDENTITY"
  fi
}

function encrypt_file {
  local keys src dst

  src="$1"
  dst="$2"

  keys="$(find_keys "$dst")"

  #dbg "$keys"

  # FIXME protect against overwriting the destination file in case of an error
  dbg_cmd "$AGE" --encrypt --recipients-file <(echo "$keys") -o "$dst" "$src"
}

function is_encrypted {
  file="$1"
  header=$("$HEAD" -n 1 "$file")
  if [[ "$header" == "-----BEGIN AGE ENCRYPTED FILE-----" ]]; then
    return 0
  elif [[ "$header" =~ ^age-encryption.org/[[:alnum:]]+$ ]]; then
    return 0
  else
    return 1
  fi
}

# Re-encrypt a file; this function is called internally only on encrypted files
function rekey_file {
  tmpdir="$1" # caller must create it for us and then remove
  file="$2"

  tmpfile="$(umask 077 && "$MKTEMP" -p "$tmpdir")"

  dbg_cmd "$AGE" --decrypt --identity "$IDENTITY" -o "$tmpfile" "$file" || \
    echo "Failed to decrypt $file, skipping" >&2

  encrypt_file "$tmpfile" "$file" || \
    echo "Failed to re-encrypt $file, skipping" >&2

}

function not_a_keyfile {
  file=$("$BASENAME" "$1")
  if [[ "$file" =~ ^\..*\.agekey$ || "$file" == ".agekey" || "$file" == ".agemaster" ]]; then
    return 1
  else
    return 0
  fi

}

function filter {
  while read -r line; do
    if "$@" "$line"; then
      echo "$line"
    fi
  done
}

function find_encrypted_files {
  # find files in the directory tree rooted at $1 without descending into .git
  # and without following symlinks
  "$FIND" "$1" -path '*/.git' -prune -o -type f -print | filter not_a_keyfile | filter is_encrypted
}

function find_rekey_dir {
  dir="$("$REALPATH" .)"
  def="$dir"

  while [ "$dir" != "/" ]; do
    if [ -s "${dir}/.agemaster" ]; then
      echo "$dir"
      return
    fi
    dir=$("$DIRNAME" "$dir")
  done

  echo "$def"

}

function find_rekey_files {

  if [ $# -eq 0 ]; then
    dir=$(find_rekey_dir)
    files=$(find_encrypted_files "$dir")
  else
    dst="$1"
    if [ -d "$dst" ]; then
      files=$(find_encrypted_files "$dst")
    elif [ -f "$dst" ]; then
      files="$dst"
    else
      error "Not a file or directory: $dst"
    fi
  fi

  echo "$files"

}

function cmd_rekey {
  local dir files dst
  check_identity

  if [ $# -gt 1 ]; then
    error "Usage: ${ME} rekey [<dst>]"
  fi

  files="$(find_rekey_files "$@")"$'\n'

  tmpdir="$(umask 077 && "$MKTEMP" -d)"

  dbg "$files"

  echo "$files" | while read -r file; do
    [[ -z "$file" ]] && continue
    dbg_cmd rekey_file "$tmpdir" "$file"
  done

}

function cmd_list {
  local dir files dst
  if [ $# -gt 1 ]; then
    error "Usage: ${ME} list [<dir>]"
  fi

  find_rekey_files "$@"
}

function cmd_keys {
  if [ $# -ne 1 ]; then
    error "Usage: ${ME} keys <file>"
  fi

  find_keys "$1"
}

function cmd_cat {
  if [ $# -ne 1 ]; then
    error "Usage: ${ME} cat <file>"
  fi

  check_identity

  dst="$1"

  is_encrypted "$dst" || error "Not an encrypted file: $dst"

  "$AGE" --decrypt --identity "$IDENTITY" "$dst"
}

function cmd_edit {
  if [ $# -ne 1 ]; then
    error "Usage: ${ME} edit <file>"
  fi

  dst="$1"

  if [ -e "$dst" ]; then
    is_encrypted "$dst" || error "Not an encrypted file: $dst"
  fi

  check_identity

  file="$("$BASENAME" "$dst" .age)"
  tmpd="$(umask 077 && "$MKTEMP" -d)"
  tmp="$tmpd/$file"
  if [[ -e "$dst" ]]; then
    "$AGE" --decrypt --identity "$IDENTITY" -o "$tmp" "$dst" || \
          error_cleanup "$tmpd" "Failed to decrypt $dst"
  else
    :> "$tmp"
  fi

  checksum_before=$("$SHA1SUM" "$tmp" | "$CUT" -d ' ' -f 1)
  "$EDITOR" "$tmp" || error_cleanup "$tmpd" "Editor exited with an error"
  checksum_after=$("$SHA1SUM" "$tmp" | "$CUT" -d ' ' -f 1)

  if [ "$checksum_before" != "$checksum_after" ]; then
    # Leave the plaintext file if encryption fails, so edits are not lost
    encrypt_file "$tmp" "$dst" || error "Failed to encrypt $dst, edited file is $tmp"
  fi
  "$RM" -rf "$tmpd"

}

function cmd_add {
  if [ $# -ne 2 ]; then
    error "Usage: ${ME} add <src> <dst>"
  fi

  src="$1"
  dst="$2"

  encrypt_file "$src" "$dst"
}

if [ $# -eq 0 ]; then
  cmd_help
  exit 1
fi

if [[ "$1" == "--identity" ]]; then
  shift
  IDENTITY="$1"
  shift
else
  IDENTITY="${HOME}/.ssh/id_ed25519"
fi

cmd="$1"
shift

case "$cmd" in
  keys | cat | edit | add | rekey | list | help)
    cmd_"$cmd" "$@"
    ;;
  default)
    cmd_help
    ;;
esac
