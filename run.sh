#!/bin/bash
set -xe

moniker=$(dd if=/dev/urandom bs=10 count=1| base32)
chain_id=$(dd if=/dev/urandom bs=10 count=1 | base32)
pushd /node

akash init --chain-id "${chain_id?}" --home "${PWD?}" "${moniker?}"

GENESIS_PATH="${PWD?}/config/genesis.json"
CHAIN_TOKEN_DENOM='uakt'
cp "${GENESIS_PATH?}" "${GENESIS_PATH?}.orig"
cat "${GENESIS_PATH?}.orig" | \
 jq -rM "(..|objects|select(has(\"denom\"))).denom           |= \"${CHAIN_TOKEN_DENOM?}\"" | \
 jq -rM "(..|objects|select(has(\"bond_denom\"))).bond_denom |= \"${CHAIN_TOKEN_DENOM?}\"" | \
 jq -rM "(..|objects|select(has(\"mint_denom\"))).mint_denom |= \"${CHAIN_TOKEN_DENOM?}\"" > \
 "${GENESIS_PATH?}"

key_name='validator'

akash --home "${PWD?}" keys add --keyring-backend "test" "${key_name?}"

CHAIN_MIN_DEPOSIT=10000000
CHAIN_ACCOUNT_DEPOSIT=100000000

k=$(akash --home "${PWD?}" keys show --keyring-backend "test" "${key_name?}" | grep 'address\:' | cut -d ':' -f 2 | xargs echo)

akash add-genesis-account --home "${PWD?}" "${k?}" "${CHAIN_MIN_DEPOSIT?}${CHAIN_TOKEN_DENOM?}"
akash gentx validator --keyring-backend "test" --home "${PWD?}" --amount "${CHAIN_MIN_DEPOSIT?}${CHAIN_TOKEN_DENOM?}" "--chain-id=${chain_id?}"
akash --home "${PWD?}" collect-gentxs

# Node is ready to run 
exec akash start --home "${PWD?}" --rpc.laddr 'tcp://0.0.0.0:26657'


