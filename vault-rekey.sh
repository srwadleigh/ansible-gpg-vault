#!/bin/sh

DATE=$(date "+%Y%m%d-%s")
TARGET="vault/vault-key.gpg" # default target file
KEYFILE="vault/vault-users" # read users keys from a file
#KEYS="XXX" # read keys from here, overridden by KEYFILE

check_input()
{
  if [ -z "$KEYS" ]; then
    if [ -z "$1" ]; then
      echo >&2 "supply at least one key ID"
      exit 1
    fi
  fi

}

if [ -f "$KEYFILE" ]; then
    KEYS="$(cat $KEYFILE | tr '\n' ' ')"
fi 

if [ -f "$1" ]; then
  TARGET=$1
  check_input "$2"
  shift
else
  if [ -f "$TARGET" ]; then
    check_input "$1"
  else
    echo >&2 "default target not found: $TARGET"
    exit 2
  fi 
fi

# backup existing vault
mv "$TARGET" "$TARGET-$DATE"

# build key list
# loop twice once for the array and once for the flat var to maintain sh compat
for KEY in $KEYS; do KEY_LIST=$KEY_LIST"-r $KEY "; done
for KEY in "$@"; do KEY_LIST=$KEY_LIST"-r $KEY "; done

# rekey target file, ignore shellcheck globbing/word splitting warning
gpg -q -d "$TARGET-$DATE" | gpg -q -e --trust-model always "$KEY_LIST" -o "$TARGET"

# verification
#md5sum "$TARGET-$DATE"
#md5sum "$TARGET"
