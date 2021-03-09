#!/bin/bash

pushd /node

export AKASH_HOME="${PWD?}"


# This fails immediately, but creates the node keys
akash init "${AKASH_MONIKER:-unknown}"

set -xe

# export bech addresses on http.
#
# note: should be unnecessary. rpc/status has:
#
# - node-id in `.node_info.id`
# - validator address in `.validator_info.address`,
#   but it is in hex and `akash keys parse` is broken (again).

if test -n "$ENABLE_ID_SERVER" ; then
  mkdir web
  akash tendermint show-node-id   > web/node-id.txt
  akash tendermint show-validator > web/validator-pubkey.txt
  pushd web
  # Run a web server so that the file can be retrieved
  python3 -m http.server 8080 &
  popd
fi

curl -s "${GENESIS_URL?}" > config/genesis.json

cat config.toml | python3 -u ./patch_config_toml.py > config/config.toml

# Copy over all the other filesthat the node needs
cp -v app.toml config/

# Run the node for real now 
exec akash start
