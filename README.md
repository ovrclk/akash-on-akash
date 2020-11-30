# Akash On Akash

This project allows you to run an Akash node on the Akash network. It is currently configured for the Q4 2020 Edgenet.

# How to use this project

Download the file `sdl/deployment.yaml' from this project. Edit the file and find the line like

```
      - ENC_KEY=
```

Create a secret password to be used for this node. Edit the line like this 

```
      - ENC_KEY=mysecret
```

Next create a deployment on the Akash edgenet

```
TODO - copy steps from elsewhere
```

Query the order

```
TODO - copy steps
```

Send the manifest to the provider that won

```
TODO - copy steps
```

To find the provider's public host name run 

```
akash "./cache" provider status --provider "akash1psl4djcj9l5gysjys3mf685pxhc0am2f072deq"
```

This should return a large amount of output including a line like

```
"cluster-public-hostname": "example.test"
```

Here the cluster hostname is "example.test", this value is different in your deployment.


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

You can also download the node secrets that were created when the node started up. In the result of getting the lease status there
is a `uris` section. In this example the hostname is `jyc2hf8tk8tzmarfk3jsjk.kind.localhost`. The hostname is different for your deployment.
You can download the encrypted archive by going to 

```
http://jyc2hf8tk8tzmarfk3jsjk.kind.localhost/node.7z
```

This file can be opened with whatever archive tool your prefer or with the [official 7Zip client](https://www.7-zip.org/download.html).
Whenever you are prompted for the password set it to whatever you set the `ENC_KEY` line at the start to.
