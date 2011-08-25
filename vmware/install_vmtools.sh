# Centos: http://lists.centos.org/pipermail/centos-virt/2008-February/000203.html
#yum install perl

echo "tell vmware to 'Install VMWare Tools' via the GUI menu item"

# TODO: wait for a user to click "enter" or something

# everything must be done via sudo

mkdir -p /mnt/cdrom
mount /dev/cdrom /mnt/cdrom
cp /mnt/cdrom/VMwareTools-*.tar.gz /tmp
cd /tmp
umount /mnt/cdrom/
rmdir /mnt/cdrom
tar xfz VMwareTools-*.tar.gz
cd vmware-tools-distrib/
./vmware-install.pl --default
