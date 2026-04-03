#!/bin/sh

VAULT_PATH=$(dirname "$(realpath "$0")")
VAULT_CMD="gpg --quiet --batch --use-agent --decrypt"
VAULT_KEY_FILE="../.vault/vault-key.gpg"

# define the password in a static env
# VAULT_KEY

if [ -n "$VAULT_KEY" ]; then
  echo "$VAULT_KEY"
else
  $VAULT_CMD "$VAULT_PATH/$VAULT_KEY_FILE"
fi
