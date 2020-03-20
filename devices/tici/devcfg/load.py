#!/usr/bin/env python3
import sys
from elftools.elf.elffile import ELFFile
from hexdump import hexdump
import struct

e = ELFFile(open("devcfg.mbn" if len(sys.argv) == 1 else sys.argv[1], "rb"))

# segment 0 = ELF header
# segment 1 = cert
# segment 2 = cert

ss = e.get_segment(2)
print(dir(ss))

la = ss.header['p_vaddr']
print(hex(la))

d = ss.data()
#hexdump(d)

#for i in range(0, len(d), 4):
for i in range(0, 0x100, 4):
  aa = struct.unpack("I", d[i:i+4])[0] - la
  if aa >= 0 and aa < len(d):
    ss = d[aa:aa+0x100].split(b"\x00")[0]
    print(hex(i), hex(aa), ss)

def g32(i):
  return struct.unpack("I", d[i:i+4])[0]

def gs(i):
  return d[i:i+0x100].split(b"\x00")[0]

print("****** 0x40 table ******")
off = g32(0x40) - la
table_length = g32(off)
tbl = d[off:off+table_length]
hexdump(tbl[0:0x20])

s1 = tbl[g32(off+4):g32(off+8)]
s2 = tbl[g32(off+8):g32(off+0xc)]
ee = tbl[g32(off+0xc):]

print(hex(len(s1)), s1)
print(hex(len(s2)), s2)
#hexdump(ee)

sidx = {}
for i in range(0, len(ee), 4):
  ret = struct.unpack("I", ee[i:i+4])[0]
  if ret>>16 == 0x1280:
    idx = struct.unpack("I", ee[i+4:i+8])[0]
    ts = s1[ret&0xFFFF:(ret&0xFFFF)+0x100].split(b"\x00")[0]
    print(ts)
    sidx[idx] = ts
  else:
    print(hex(ret))
  

print("****** 0x48 table ******")
# the "0x48" table
# 0x10 entries
off = g32(0x48) - la
cnt = 0
while 1:
  l,a = struct.unpack("QQ", d[off:off+0x10])
  if l == 0:
    break
  print(hex(cnt), "" if cnt not in sidx else sidx[cnt], l,hex(a-la))
  cnt += 1
  off += 0x10
  if l < 0x100:
    hexdump(d[a-la:a-la+l])
  else:
    print("TOO BIG TO PRINT")

"""
# the "0x58" table
# 0x28 length entries
# number of entries in "0x50"
print("****** 0x58 table ******")
cnt = g32(0x50)
off = g32(0x58) - la
for i in range(cnt):
  a = struct.unpack("Q", d[off:off+8])[0] - la
  print(hex(a), gs(a))
  hexdump(d[off+8:off+0x28])
  off += 0x28
"""

