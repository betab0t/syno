# https://www.hackcyom.com/2024/01/rwctf-lets-party-in-the-house-wu/
from pwn import *
import zlib
import sys
f = open(sys.argv[1],'rb')
  
header = f.read(0x7e)
num_sub_headers = u16(header[0x7c:])
  
prescript_len = u32(f.read(4))
prescript = zlib.decompress(f.read(prescript_len))
postscript_len = u32(f.read(4))
postscript = zlib.decompress(f.read(postscript_len))
  
ff = open('pre-script.sh','wb')
ff.write(prescript)
ff.close()
ff = open('post-script.sh','wb')
ff.write(postscript)
ff.close()
  
def read_sub_header(i):
    sub_header = f.read(0x48)
    name, subscript_len, image_len = sub_header[:0x40], u32(sub_header[0x40:0x44]), u32(sub_header[0x44:])
    subscript = zlib.decompress(f.read(subscript_len))
    image = zlib.decompress(f.read(image_len))
    ff = open(f'ex-script{i}','wb')
    ff.write(subscript)
    ff.close()
    ff = open(f'image{i}','wb')
    ff.write(image)
    ff.close()
  
for i in range(num_sub_headers):
    read_sub_header(i)


