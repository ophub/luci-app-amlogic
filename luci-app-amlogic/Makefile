#
# Description: Provide services such as install to EMMC, Update Firmware or Kernel, Backup and Recovery Config for Amlogic STB.
# Borrow: luci-app-filetransfer, Vernesong, Flippy etc.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:= LuCI support for Amlogic S9xxx STB
LUCI_DEPENDS:=@aarch64 +luci-lib-fs +block-mount +blkid +parted +dosfstools +e2fsprogs +lsblk +pv +resize2fs +tune2fs +losetup +uuidgen
PKG_NAME:=luci-app-amlogic
PKG_MAINTAINER:=ophub <https://github.com/ophub/luci-app-amlogic>
PKG_VERSION:=1.8
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

