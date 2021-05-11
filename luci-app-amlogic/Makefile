#
# Current name: luci-app-amlogic
# Description: Provide services such as instal/update/backup/kernel replacement for Amlogic STB
# Modify: https://github.com/ophub/luci-app-amlogic
# Borrow: luci-app-filetransfer, etc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-amlogic
PKG_VERSION:=0.01.01
PKG_RELEASE:=beta
PKG_DATE:=20210501

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for Amlogic
	PKGARCH:=all
	DEPENDS:=+luci-lib-fs +block-mount +blkid +parted +dosfstools +e2fsprogs +lsblk +pv +resize2fs +tune2fs +losetup +uuidgen
	MAINTAINER:=ophub
endef

define Package/$(PKG_NAME)/description
	Provide services for Amlogic S9xxx STB
endef

define Package/$(PKG_NAME)/install
	$(CP) $(PKG_BUILD_DIR)/root/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/amlogic.po $(1)/usr/lib/lua/luci/i18n/amlogic.zh-cn.lmo
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
