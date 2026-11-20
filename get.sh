#!/bin/bash
# N.O.A — установка одной командой на Linux (Debian/Ubuntu).
#   curl -fsSL https://raw.githubusercontent.com/bobbibob/noa-install/main/get.sh | bash
#   параметры установщика: ... | bash -s -- mynet --target local --port 3080
# Скачивается только архив релиза с github.com; целостность проверяется по SHA-256,
# при несовпадении установка не запускается. Токены и аккаунт GitHub не нужны.
set -eu
VER="v1.0.1"
SHA="98841a0a1a258e6c5a17b471b4bfe88d278d2ea88cb4a0b25e2ee7916b5c5784"
URL="${NOA_ARCHIVE:-https://github.com/bobbibob/noa-install/releases/download/$VER/noa.tar.gz}"
command -v curl >/dev/null 2>&1 || { echo "Нужен curl" >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { echo "Нужен sha256sum (coreutils)" >&2; exit 1; }
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
echo "N.O.A $VER: скачиваю архив..."
case "$URL" in http://*|https://*) curl -fsSL "$URL" -o "$D/noa.tar.gz" || { echo "Архив не скачался: $URL" >&2; exit 1; };;
  *) cp "$URL" "$D/noa.tar.gz";; esac
echo "$SHA  $D/noa.tar.gz" | sha256sum -c --quiet - || { echo "SHA-256 архива не совпадает — установка остановлена" >&2; exit 1; }
tar xzf "$D/noa.tar.gz" -C "$D"
[ -f "$D/noa/install.sh" ] || { echo "В архиве нет noa/install.sh" >&2; exit 1; }
SUDO=""; [ "$(id -u)" -eq 0 ] || SUDO="sudo"
if [ -r /dev/tty ] && ( : </dev/tty ) 2>/dev/null; then $SUDO sh "$D/noa/install.sh" "$@" </dev/tty; else $SUDO sh "$D/noa/install.sh" "$@" </dev/null; fi
