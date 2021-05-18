#
# Current name: luci-app-amlogic
# Description: Provide services such as instal/update/backup/kernel replacement for Amlogic STB
# Modify: https://github.com/ophub/luci-app-amlogic
# Borrow: luci-app-filetransfer, Vernesong, Flippy etc.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:= LuCI support for Amlogic S9xxx STB
LUCI_DEPENDS:=@aarch64 +luci-lib-fs +block-mount +blkid +parted +dosfstools +e2fsprogs +lsblk +pv +resize2fs +tune2fs +losetup +uuidgen
PKG_VERSION:=1
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

