import json
import urllib
import urllib.request
import toml
import sys
import base64
import os
import random
import subprocess

def select_subset(values, amount):
  i = random.randint(0, len(values) - 1)
  chosen = set() 
  cnt = 0
  result = []

  while cnt < amount:
    v = values[i]
    i += 1
    if i == len(values):
      i = 0

    if not v in chosen:
      chosen.add(v)
      result.append(v)
   
    cnt += 1
  return result

moniker = str(base64.b32encode(os.urandom(10)), 'ASCII')
num_seeds = int(os.environ.get('NUM_SEEDS', '4'))
timeout = float(os.environ.get('HTTP_TIMEOUT', '30.0'))
state_sync_enable = int(os.environ.get('STATE_SYNC', '1')) > 0

seeds_url = os.environ['SEEDS_URL']
sync_url = os.environ['SYNC_URL']

sys.stderr.write("Fetching: %s\n" % (seeds_url,))
with urllib.request.urlopen(seeds_url, timeout = timeout) as response:
  seeds_data = str(response.read(), 'UTF-8')
seeds = [y for y in (x.strip() for x in seeds_data.split("\n")) if len(y) != 0 ]

data = toml.load(sys.stdin)
data['moniker'] = moniker
seeds_str = ','.join(select_subset(seeds, num_seeds))
data['p2p']['seeds'] = seeds_str

sync_servers = []
if state_sync_enable:
  sys.stderr.write("Fetching: %s\n" % (sync_url,))
  with urllib.request.urlopen(sync_url, timeout = timeout) as response:
    sync_data = str(response.read(), 'UTF-8')

  sync_servers = [y for y in (x.strip() for x in sync_data.split("\n")) if len(y) != 0]
  random.shuffle(sync_servers)
  trust_height = None
  trust_hash = None
  for sync_server in sync_servers:
    sys.stderr.write("Querying RPC server for latest block: %s\n" % (sync_server,))
    cmd = 'akash'
    args = ['', 'query', 'block', '--node','tcp://%s' % (sync_server,)]
    with open('/tmp/blocks.json', 'w') as fout:
      proc = subprocess.Popen(executable = cmd, args = args, stdin = subprocess.DEVNULL, stdout = fout, shell = False)

      retcode = proc.wait()
    if retcode == 0:
      with open('/tmp/blocks.json') as fin:
        blocks_data = json.load(fin)
      last_commit = blocks_data.get('block', {}).get('last_commit', {})
      trust_height = last_commit.get('height')
      trust_hash = last_commit.get('block_id', {}).get('hash')
    if trust_hash is not None and trust_height is not None:
      break

  if trust_hash is None or trust_height is None:
    sys.stderr.write("Could not query an RPC node to get current blockchain height\n")
    sys.exit(1)

  sync_servers_str = ','.join('http://%s' % (x,) for x in sync_servers)

  data['statesync'] = {
    'enable': True,
    'rpc_servers': sync_servers_str,
    'trust_height': trust_height,
    'trust_hash':  trust_hash,
    'trust_period': "168h0m0s"
  }
else:
  data['statesync'] = {'enable': False}


toml.dump(data, sys.stdout)
