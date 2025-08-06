# Ansible GPG Vault

Set defaults in `ansible.cfg`

```
[defaults]
vault_password_file=vault/vault-open.sh
```


Create an new vault key

```
export KEYID=<your-key-id>
pwgen -n 128 -C | head -n1 | gpg --armor --recipient $KEYID -e -o vault/vault-key.gpg
```


View an ansible vault

```
ansible-vault --vault-password-file=vault/vault-open.sh view /path/to/an/encrypted/vault/file.yml
```



Adding an encrypted file

```
ansible-vault create vault/$HOSTNAME.yml
```


changing the gpg keys used to encrypt the vault password

```
gpg -d vault/vault-key.gpg | gpg -e --trust-model always -r "XXXXXXXX" -r "XXXXXXXY" -o vault/vault-key.gpg.new
```


Viewing encrypted fields

```
yq -r .some_variable prod/group_vars/all.yml | ansible-vault decrypt
```
