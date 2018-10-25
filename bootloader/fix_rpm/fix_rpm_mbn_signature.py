#!/usr/bin/env python
import sys
import os
import hashlib
from hexdump import hexdump
from elftools.elf.elffile import ELFFile
import struct
import tempfile
from Crypto.Util.number import bytes_to_long, long_to_bytes

def parse_cert_chain(cert_chain):
  with tempfile.NamedTemporaryFile() as cert:
    with tempfile.NamedTemporaryFile() as cert_parsed:
      cert.write(cert_chain)
      cert.flush()
      os.system("openssl x509 -in %s -inform DER -text > %s" % (cert.name, cert_parsed.name))
      tcert = open(cert_parsed.name).read()
      print filter(lambda x: "Subject" in x, tcert.split("\n"))
      mod = tcert.split("Modulus:")[1].split("Exponent")[0]
      mod = mod.replace(" ", "").replace(":", "").replace("\n", "")
      mod = bytes_to_long(mod.decode("hex"))
  return mod

def load_mbn_file(fn):
  elffile = ELFFile(open(fn))
  allhash = ""
  segs = []
  for i, seg in enumerate(elffile.iter_segments()):
    d = seg.data()
    print(len(d))
    if i == 1:
      """
      // struct to store hash segment header
      typedef struct
      {
        unsigned header_vsn_num;      // Header version number
        unsigned image_id;            // Identifies the type of image this header represents
        unsigned image_src;           // Location of image in flash
        unsigned image_dest_ptr;      // Pointer to location to store image in RAM
        unsigned image_size;          // Size of complete image in bytes
        unsigned code_size;           // Size of code region of image in bytes
        unsigned signature_ptr;       // Pointer to images attestation signature
        unsigned signature_size;      // Size of the attestation signature in bytes
        unsigned cert_chain_ptr;      // Pointer to the certificates associated with the image
        unsigned cert_chain_size;     // Size of the attestation chain in bytes
      } mi_boot_image_header_type;
      """
      #hexdump(d)
      image_dest_ptr = struct.unpack("I", d[3*4:4*4])[0]
      signature_ptr, signature_size, cert_chain_ptr, cert_chain_size = struct.unpack("IIII", d[6*4:10*4])
      signature_ptr -= image_dest_ptr - 0x28
      cert_chain_ptr -= image_dest_ptr - 0x28
      header = d[:0x28]
      hash_chunk = d[0x28:signature_ptr]
      signature = d[signature_ptr:signature_ptr+signature_size]
      cert_chain = d[cert_chain_ptr:cert_chain_ptr+cert_chain_size]
      hexdump(header)

      allhash += "\x00"*0x20
    else:
      if i == 3:
        print "PATCH"
        #o = struct.pack("<HH", 2700, 2900)
        #n = struct.pack("<HH", 2500, 3000)
        o = struct.pack("<HH", 0xb22, 0xc1c)
        n = struct.pack("<HH", 0xa8c, 0xce4)
        idx = d.find(o)
        print hex(idx)
        d = d[:idx] + n + d[idx+4:]
        #d = d.replace(o, n)
      allhash += hashlib.sha256(d).digest()
    segs.append(d)
  hexdump(allhash)
  hexdump(hash_chunk)
  if allhash != hash_chunk:
    print "WARNING: data changed"

  return header, allhash, signature, cert_chain, segs

fn = sys.argv[1]

#header, hash_chunk, signature, cert_chain = load_mbn_file("dragonboard/emmc_appsboot.mbn")
header, new_hash_chunk, signature, cert_chain, segs = load_mbn_file(fn)
#with open("got_chain.DER", "wb") as f:
  #f.write(cert_chain[cert_chain.find("\x30\x82", 0x200):])
  #f.write(cert_chain[0x4a7:])

mod = parse_cert_chain(cert_chain)
sig = bytes_to_long(signature)
p = long_to_bytes(pow(sig, 3, mod))
print "rsa"
hexdump("\x00"+p)
ghash = p[-0x20:]
print("out")
stp0 = hashlib.sha256(header+new_hash_chunk).digest()
stp1 = hashlib.sha256("\x36"*7 + "\x3c" + stp0).digest()
datasign = hashlib.sha256("\x5c"*8 + stp1).digest()
hexdump(datasign)

with tempfile.NamedTemporaryFile() as dataToSign:
  os.system("openssl pkeyutl -sign -inkey cert/atte_key.PEM -in %s -out /tmp/blahblah 2>/dev/null" % dataToSign.name)
  new_signature = open("/tmp/blahblah").read()

new_cert_chain = open("cert/atte.DER").read() + open("cert/root.DER").read()
new_cert_chain += "\xff" * (len(cert_chain) - len(new_cert_chain))

"""
tmp = open(fn).read()
tmp = tmp.replace(hash_chunk, new_hash_chunk)
tmp = tmp.replace(signature, new_signature)
tmp = tmp.replace(cert_chain, new_cert_chain)
o = struct.pack("<HH", 2700, 2900)
n = struct.pack("<HH", 2700, 3300)
tmp = tmp.replace(o, n)
open(fn+".patched", "wb").write(tmp)
"""

with open(fn+".patched", "wb") as f:
  f.write(segs[0])
  f.write("\x00"*(0x1000-len(segs[0])))
  nseg1 = header+new_hash_chunk+new_signature+new_cert_chain
  f.write(nseg1)
  f.write("\x00"*(0x2000-len(nseg1)))
  f.write(segs[2])
  f.write(segs[3])

