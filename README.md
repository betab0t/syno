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

## References

* https://www.synacktiv.com/en/publications/exploiting-a-blind-format-string-vulnerability-in-modern-binaries-a-case-study-from

* https://www.synacktiv.com/sites/default/files/2024-10/bc500-p2o_2023_0.pdf

* https://www.hackcyom.com/2024/01/rwctf-lets-party-in-the-house-wu/

* https://archive.synology.com/download/Firmware/Camera/TC500


