#!/usr/bin/env python3
from elftools.elf.elffile import ELFFile
from hexdump import hexdump
import struct

e = ELFFile(open("devcfg.mbn", "rb"))

# segment 0 = ELF header
# segment 1 = cert
# segment 2 = cert

ss = e.get_segment(2)
print(dir(ss))

la = ss.header['p_vaddr']
print(hex(la))

d = ss.data()
#hexdump(d)

"""
for i in range(0, len(d), 4):
  aa = struct.unpack("I", d[i:i+4])[0] - la
  if aa >= 0 and aa < len(d):
    ss = d[aa:aa+0x100].split(b"\x00")[0]
    print(hex(i), hex(aa), ss)

"""

off = struct.unpack("I", d[0x48:0x48+4])[0] - la
while 1:
  l,a = struct.unpack("QQ", d[off:off+0x10])
  if l == 0:
    break
  print(l,a)
  off += 0x10

  hexdump(d[a-la:a-la+l])


