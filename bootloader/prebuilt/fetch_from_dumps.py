#!/usr/bin/env python
import os
import sys
import struct
import xml.etree.ElementTree as ET
from hexdump import hexdump

# adb exec-out 'dd bs=268435456 if=/dev/block/sda 2&> /dev/null | gzip' | gunzip | pv > sda

SECTOR_SIZE = 4096

if __name__ == "__main__":
  os.system("mkdir -p dumps")
  os.system("cp patch.xml dumps/")
  os.system("cp prog_ufs_firehose_8996_ddr.elf dumps/")
  tree = ET.parse('rawprogram_template.xml')
  root = tree.getroot()

  lookup = {}
  goodchild = []
  for child in root:
    if child.attrib['label'] in ['PrimaryGPT', 'BackupGPT']:
      #child.set('filename', os.path.join("dumps", child.attrib['filename']))
      goodchild.append(child)
      continue
    if child.attrib['label'] in ['system', 'cache', 'vendor', 'userdata']:
      continue
    # not in package?
    if child.attrib['filename'] in ['adspso.bin', 'BTFM.bin', 'NON-HLOS.bin']:
      continue
    assert child.attrib['SECTOR_SIZE_IN_BYTES'] == "4096"
    assert child.attrib['file_sector_offset'] == "0"
    assert child.attrib['readbackverify'] == "false"
    assert child.attrib['partofsingleimage'] == "false"
    assert child.attrib['sparse'] == "false"

    #print child.tag, child.attrib
    print child.attrib['label'], child.attrib['filename']
    lookup[child.attrib['label']] = child.attrib['filename']

  # add back the GPTs
  root.clear()
  for child in goodchild:
    root.append(child)

  toxml = []

  for partition_number, partition_file in enumerate(["sda", "sdb", "sdc", "sdd", "sde", "sdf"]):
    print("parsing %s" % partition_file)
    try:
      f = open(os.path.join(sys.argv[1], partition_file), "rb")
    except IOError:
      print "OPEN %s FAILED" % partition_file
      continue

    # 6 sectors
    gpt_main = f.read(24576)
    with open(os.path.join("dumps", "gpt_main%d.bin" % partition_number), "wb") as g:
      g.write(gpt_main)

    # 5 sectors
    f.seek(-20480, os.SEEK_END)
    gpt_backup = f.read(20480)
    with open(os.path.join("dumps", "gpt_backup%d.bin" % partition_number), "wb") as g:
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
      print "  %s%d = %s -- 0x%x-0x%x" % (partition_file, i, name, start, end)

      # **** full recovery ****
      #if name not in lookup and name not in ['boot', 'recovery', 'system', 'userdata', 'cache']:
      #  lookup[name] = name+".dump"

      if name in lookup:
        print "    writing file %s" % lookup[name]
        fn = os.path.join("dumps", lookup[name])
        with open(fn, "wb") as g:
          f.seek(start*SECTOR_SIZE)
          g.write(f.read((end-start+1)*SECTOR_SIZE))
        # we built this

        if lookup[name] in ['emmc_appsboot.mbn']:
          tfn = '../'+lookup[name]
        else:
          tfn = lookup[name]
        toxml.append({
          'SECTOR_SIZE_IN_BYTES': '4096',
          'file_sector_offset': '0',
          'filename': tfn,
          'label': name,
          'num_partition_sectors': str(end-start+1),
          'partofsingleimage': 'false',
          'physical_partition_number': str(partition_number),
          'readbackverify': 'false',
          'size_in_KB': "%.1f" % (start*SECTOR_SIZE/1024),
          'sparse': 'false',
          'start_byte_hex': '0x%x' % (start*SECTOR_SIZE),
          'start_sector': str(start)
        })
        del lookup[name]

      ptr += 0x80
      i += 1

    f.close()
    
  assert lookup == {}

  # add in written files
  for x in toxml:
    ele = ET.Element("program")
    for k,d in x.items():
      ele.set(k, d)
    root.append(ele)
    
  tree.write('dumps/rawprogram.xml')
  with open("dumps/patch.xml", "wb") as g:
    g.write('<patches></patches>')

