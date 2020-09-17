#!/usr/bin/env python3
import sys
import os
import json
import hashlib
import requests

def sha256_checksum(filename, block_size=65536):
  sha256 = hashlib.sha256()
  with open(filename, 'rb') as f:
    for block in iter(lambda: f.read(block_size), b''):
      sha256.update(block)
  return sha256.hexdigest()

def download(url, fhash, finalname):
  try:
    assert sha256_checksum(finalname).lower() == fhash.lower()
    print("already downloaded %s" % url)
    return
  except Exception:
    pass

  print("downloading %s with hash %s" % (url, fhash))
  os.system("curl -O %s" % url)
  fn = url.split("/")[-1]
  assert sha256_checksum(fn).lower() == fhash.lower()
  print("hash check pass")
  os.system("rm -f %s; ln -s %s %s" % (finalname, fn, finalname))

if __name__ == "__main__":
  try:
    if os.getenv("CLEAN_USR") == "1":
      ota_json_download_url = os.getenv("NEOS_BASE_FOR_USR")
      print("Fetching NEOS base for /usr from system image")
    else:
      ota_json_download_url = os.getenv("NEOS_BASE_FOR_DASHCAM")
      print("Fetching NEOS base for dashcam slipstream")
    up = requests.get(ota_json_download_url).json()
  except Exception:
    print("Couldn't fetch current NEOS OTA image!")
    raise
  download(up['ota_url'], up['ota_hash'], "ota-signed-latest.zip")
  download(up['recovery_url'], up['recovery_hash'], "recovery.img")
