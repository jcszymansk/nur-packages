#!/usr/bin/env sh

for plat in "linux-x64" "darwin" "linux-arm64" "darwin-arm64" "linux-armhf"; do
  file=latest-${plat}.json
  curl -Ss -o ${file}.tmp https://update.code.visualstudio.com/api/update/${plat}/insider/latest
  if [ "$?" = "0" ]; then
    mv -f ${file}.tmp ${file}
  fi
done;
