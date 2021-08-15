#!/bin/bash

# Made by Fernando "maroto"
# Run anything in the filesystem right before being "mksquashed"

script_path=$(readlink -f ${0%/*})
work_dir=work

# Adapted from AIS. An excellent bit of code!
arch_chroot(){
    arch-chroot $script_path/${work_dir}/x86_64/airootfs /bin/bash -c "${1}"
}  

do_merge(){

arch_chroot "

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
usermod -s /usr/bin/bash root
cp -aT /etc/skel/ /root/
chmod 700 /root
useradd -m -p \"\" -g users -G 'sys,rfkill,wheel' -s /bin/bash liveuser


chmod 755 /etc/sudoers.d
mkdir -p /media
chmod 755 /media
chmod 440 /etc/sudoers.d/g_wheel
chown 0 /etc/sudoers.d
chown 0 /etc/sudoers.d/g_wheel
chown root:root /etc/sudoers.d
chown root:root /etc/sudoers.d/g_wheel
chmod 755 /etc
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
systemctl enable NetworkManager.service vboxservice vmtoolsd.service vmware-vmblock-fuse.service systemd-timesyncd
systemctl set-default multi-user.target

cp -rf /usr/share/mkinitcpio/hook.preset /etc/mkinitcpio.d/linux.preset
sed -i 's?%PKGBASE%?linux?' /etc/mkinitcpio.d/linux.preset


sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"$|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 nowatchdog\"|' /etc/default/grub
sed -i 's?GRUB_DISTRIBUTOR=.*?GRUB_DISTRIBUTOR=\"HeeraOs\"?' /etc/default/grub
sed -i 's?\#GRUB_THEME=.*?GRUB_THEME=\/boot\/grub\/themes\/HeeraOS\/theme.txt?g' /etc/default/grub
echo 'GRUB_DISABLE_SUBMENU=y' >> /etc/default/grub
rm /boot/grub/grub.cfg
chmod -R 700 /root
chown root:root -R /root
chown root:root -R /etc/skel

chsh -s /bin/bash"
}

#################################
########## STARTS HERE ##########
#################################

do_merge
