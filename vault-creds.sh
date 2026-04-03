#!/bin/bash
# examples: 
#   .vault/vault-creds.sh gen -o output_file.yml -n netbox_secret_key,netbox_superuser_password,netbox_db_password,netbox_redis_password
#   .vault/vault-creds.sh enc -i secret_string -n my_secret

usage()
{
    echo "usage: $(basename "$0") command args ...
    gen [-o <ouytput_file>]  [-n <name>,<name>,<name> ... ] "
    exit 1
}

message() 
{
    printf '\033[0;37m%s\033[0m\n' "$1"
}

error() 
{
    printf '\033[1;31m%s\033[0m\n' "$1"
    if [ -n "$2" ]; then
      exit "$2"
    fi
}

gen_credential() 
{
  pwgen -s 64
}

encrypt_credential() 
{
  ansible-vault encrypt_string "$2" --name "$1"
}

output_credential() 
{
  if [ -n "$OUTPUT_FILE" ]; then
    encrypt_credential "$1" "$2" >> "$OUTPUT_FILE"
    echo >> "$OUTPUT_FILE"
  else
    encrypt_credential "$1" "$2"
    echo
  fi
}

show_credential() 
{
  message "$1: $2"
}

ACTION=$1
shift 1;

while getopts ":o:i:n:c:" OPT ; do
    case $OPT in
        o) OUTPUT_FILE="$OPTARG";;
        i) INPUT_STRING="$OPTARG";;
        n) CREDENTIAL_NAMES="$OPTARG";;
        c) CREDENTIAL_LENGTH="$OPTARG";;
        \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
    esac
    case $OPTARG in
        -*) echo "Option $OPT needs a valid argument"
        exit 1
    ;;
    esac
done

#DATE="$(date +%Y%m%d-%SS)"
CREDENTIAL_NAMES="${CREDENTIAL_NAMES:-default}"
CREDENTIAL_NAMES="${CREDENTIAL_NAMES//,/ }"
CREDENTIAL_LENGTH="${CREDENTIAL_LENGTH:-64}"

case $ACTION in
    "gen")
      for NAME in $CREDENTIAL_NAMES
      do
        CREDENTIAL=$(gen_credential)
        show_credential "$NAME" "$CREDENTIAL"
        output_credential "$NAME" "$CREDENTIAL"
      done
    ;;

    "enc")
      NAME=$(echo "$CREDENTIAL_NAMES" | cut -d " " -f 1)
      if [ -n "$INPUT_STRING" ]; then
        show_credential "$NAME" "$INPUT_STRING"
        output_credential "$NAME" "$INPUT_STRING"
      fi
    ;;

    *)
        error "unknown action $ACTION"
        usage
    ;;
esac
