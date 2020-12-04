#!/bin/bash

pushd /node

# This fails immediately, but creates the node keys
akash start --home "${PWD?}"

set -xe

# Archive & encrypt the keys
mkdir web
7z a "-p${ENC_KEY?}" -mhe -t7z web/node.7z config/node_key.json config/priv_validator_key.json
pushd web
# Run a web server so that the file can be retrieved
python3 -m http.server 8080 &
popd

cat config.toml | python3 -u ./patch_config_toml.py > config/config.toml
# Copy over all the other filesthat the node needs
cp -v app.toml config/
cp -v genesis.json config/

# Run the node for real now 
exec akash start --home "${PWD?}" 


