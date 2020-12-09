# Akash On Akash

This project allows you to run an Akash node on the Akash network. It is currently configured for the Q4 2020 Edgenet.

# How to use this project

Download the file [`sdl/deployment.yaml'](sdl/deployment.yaml) from this project.

Next create a deployment on the Akash edgenet

```
akash tx deployment create sdl/deployment.yml --from $KEY_NAME --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID -y
```

Query the order

```
akash query market lease list --owner $ACCOUNT_ADDRESS --node $AKASH_NODE --state active
```

Send the manifest to the provider that won

```
akash provider send-manifest deploy.yml --node $AKASH_NODE --dseq $DSEQ --oseq $OSEQ --gseq $GSEQ --owner $ACCOUNT_ADDRESS --provider $PROVIDER
```

Wait for the deployment to come online. Then get the lease status to find the RPC port for the deployment

```
akash provider lease-status --owner $OWNER --provider $PROVIDER --dseq $DSEQ --gseq $GSEQ --oseq $OSEQ
```

This returns output like this 

```
{
  "services": {
    "akash": {
      "name": "akash",
      "available": 1,
      "total": 1,
      "uris": [
        "jyc2hf8tk8tzmarfk3jsjk.kind.localhost"
      ],
      "observed-generation": 0,
      "replicas": 0,
      "updated-replicas": 0,
      "ready-replicas": 0,
      "available-replicas": 0
    }
  },
  "forwarded-ports": {
    "akash": [
      {
        "port": 26656,
        "externalPort": 32204,
        "proto": "TCP",
        "available": 1,
        "name": "akash"
      },
      {
        "port": 26657,
        "externalPort": 32407,
        "proto": "TCP",
        "available": 1,
        "name": "akash"
      }
    ]
  }
}
```

In the section `forwarded-ports` you can see that port 32407 (this number is different in your deployment) is forwarded to port 26657, 
which is the RPC interface. Now you can query the node to confirm it is up. The public hostname & the port are combined in the 
command below.

```
akash status --node tcp://example.test:32407
```

You can also download the `node-id` and `validator-pubkey` values that were created when the node started up.
In the result of getting the lease status there is a `uris` section.
In this example the hostname is `jyc2hf8tk8tzmarfk3jsjk.kind.localhost`.
The hostname is different for your deployment.  You can download the values by using the following:

```
curl http://jyc2hf8tk8tzmarfk3jsjk.kind.localhost/node-id.txt
curl http://jyc2hf8tk8tzmarfk3jsjk.kind.localhost/validator-pubkey.txt
```

# Local Testing

## Build docker image

```sh
make build
```

## Run local instance

```sh
./test.sh
```

See the [`env/edgenet`](env/) for local environment settings.

# Releasing

Make a tag that starts with a `v`, ex:

```sh
git tag -m "gr8 pupdates" v100.0.0
```
