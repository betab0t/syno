# https://www.synacktiv.com/sites/default/files/2025-01/blind_fmtstr.pdf
FROM scratch
ADD ./firmware/Synology_TC500_1.1.2_0416/rootfs.tar.gz /
CMD ["/bin/busybox", "sh"]

