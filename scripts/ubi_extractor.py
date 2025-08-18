# https://www.hackcyom.com/2024/01/rwctf-lets-party-in-the-house-wu/
import ctypes
import os
import sys

class ubi_ec_hdr(ctypes.BigEndianStructure):
    _pack_ = 1
    _fields_ = [
        ('magic', ctypes.c_uint32),
        ('version', ctypes.c_uint8),
        ('padding1', ctypes.c_uint8 * 3),
        ('ec', ctypes.c_uint64),
        ('vid_hdr_offset', ctypes.c_uint32),
        ('data_offset', ctypes.c_uint32),
        ('image_seq', ctypes.c_uint32),
        ('padding2', ctypes.c_uint8 * 32),
        ('hdr_crc', ctypes.c_uint32),
    ]
  
class sqsh_super_block(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ('magic', ctypes.c_uint32),
        ('inode_count', ctypes.c_uint32),
        ('mod_time', ctypes.c_uint32),
        ('block_size', ctypes.c_uint32),
        ('frag_count', ctypes.c_uint32),
        ('compressor', ctypes.c_uint16),
        ('block_log', ctypes.c_uint16),
        ('flags', ctypes.c_uint16),
        ('id_count', ctypes.c_uint16),
        ('version_major', ctypes.c_uint16),
        ('version_minor', ctypes.c_uint16),
        ('root_inode', ctypes.c_uint64),
        ('bytes_used', ctypes.c_uint64),
        ('id_table', ctypes.c_uint64),
        ('xattr_table', ctypes.c_uint64),
        ('inode_table', ctypes.c_uint64),
        ('dir_table', ctypes.c_uint64),
        ('frag_table', ctypes.c_uint64),
        ('export_table', ctypes.c_uint64),
    ]
  
started = False
_path = sys.argv[1]
blocksize = 0x20000
with open(_path, 'rb') as f, open('./hsqs', 'wb') as f2:
    for i in range(os.path.getsize(_path)//blocksize):
        f.seek(blocksize*i)
        hdr = ubi_ec_hdr.from_buffer(bytearray(f.read(0x40)))
        f.seek(blocksize*i+hdr.data_offset)
        if not started and f.peek(4)[:4] == b'hsqs':
            started = True
        if started:
            f2.write(f.read(blocksize-hdr.data_offset))


