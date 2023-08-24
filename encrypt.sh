#!/usr/bin/env bash

set -ue -o pipefail

PGP_RECIPIENT="containers2@approvers.dev"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <files...>"
  exit 1
fi

base_dir=$(
  cd "$(dirname "$0")"
  pwd
)
pubkey_file="$base_dir/pubkey.pem"

temp_gpg_dir=$(mktemp -d)
trap 'rm -rf "$temp_gpg_dir"' EXIT

gpg --homedir "$temp_gpg_dir" --quiet --batch --import "$pubkey_file"

for encrypt_file in "$@"; do
  gpg --homedir "$temp_gpg_dir" --quiet --batch --yes --encrypt --recipient "$PGP_RECIPIENT" --trust-model always --armor --output "$encrypt_file.secret" "$encrypt_file"
  rm -f "$encrypt_file"
done
