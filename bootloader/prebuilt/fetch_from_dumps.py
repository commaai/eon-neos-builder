#!/usr/bin/env python
import os
import sys
import struct
import xml.etree.ElementTree as ET
from hexdump import hexdump

# adb exec-out 'dd bs=268435456 if=/dev/block/sda | gzip' | gunzip | pv > sda

SECTOR_SIZE = 4096

if __name__ == "__main__":
  tree = ET.parse('rawprogram_template.xml')
  root = tree.getroot()

  lookup = {}
  for child in root:
    if child.attrib['label'] in ['PrimaryGPT', 'BackupGPT']:
      continue
    if child.attrib['label'] in ['system', 'cache', 'vendor', 'userdata']:
      continue
    #print child.tag, child.attrib
    print child.attrib['label'], child.attrib['filename']
    lookup[child.attrib['label']] = child.attrib['filename']


  for i, fn in enumerate(["sda", "sdb", "sdc", "sdd", "sde", "sdf"]):
    print("parsing %s" % fn)
    try:
      f = open(os.path.join(sys.argv[1], fn), "rb")
    except IOError:
      print "OPEN %s FAILED" % fn
      continue

    # 6 sectors
    gpt_main = f.read(24576)
    with open("gpt_main%d.bin" % i, "wb") as g:
      g.write(gpt_main)

    # 5 sectors
    f.seek(-20480, os.SEEK_END)
    gpt_backup = f.read(20480)
    with open("gpt_backup%d.bin" % i, "wb") as g:
      g.write(gpt_backup)

    ptr = 0x1000
    start, end, flags = struct.unpack("<QQQ", gpt_main[ptr+0x20:ptr+0x38])
    print "%x %x %x" % (start, end, flags)

    ptr = 0x2000
    i = 1
    #while gpt_main[ptr+0x38] != "\x00":
    while gpt_main[ptr:ptr+0x10] != "\x00"*0x10:
      name = gpt_main[ptr+0x38:ptr+0x80][::2].strip('\x00')
      start, end, flags = struct.unpack("<QQQ", gpt_main[ptr+0x20:ptr+0x38])
      print "  %s%d = %s -- 0x%x-0x%x" % (fn, i, name, start, end)

      if name in lookup:
        print "    writing file %s" % lookup[name]
        with open(lookup[name], "wb") as g:
          f.seek(start*SECTOR_SIZE)
          g.write(f.read((end-start+1)*SECTOR_SIZE))

        del lookup[name]

      ptr += 0x80
      i += 1

    f.close()
    
  print(lookup)      

