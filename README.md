![logo](https://i.niupic.com/images/2021/09/01/9u0P.png)

# luci-app-amlogic / Amlogic Service

View Chinese description  |  [查看中文说明](README.cn.md)

Supports management of Amlogic s9xxx, Allwinner (V-Plus Cloud), and Rockchip (BeikeYun, Chainedbox L1 Pro) boxes. The current functions include `install OpenWrt to EMMC`, `Manually Upload Updates / Download Updates Online to update the OpenWrt firmware or kernel`, `Backup / Restore firmware config`, `Snapshot management` and `Custom firmware / kernel download site`, etc.

## Depends

- [luci-lib-fs](https://github.com/ophub/luci-app-amlogic/tree/main/luci-lib-fs)

Tip: It is included when compiling with [coolsnowwolf/lean](https://github.com/coolsnowwolf/lede/tree/master/package/lean/luci-lib-fs) or [Lienol/openwrt](https://github.com/Lienol/openwrt/tree/main/package/lean/luci-lib-fs) source code. There is no need to add this dependency separately. When using other source code libraries, please check whether they are missing.

## Plugin compilation

```yaml
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# This plugin can be compiled separately
make package/luci-app-amlogic/compile V=99

# Or integrate this plugin when fully compiling OpenWrt
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic ----> save
make V=99
```

## Manual install

- If the OpenWrt you are using does not have this plugin, you can also install it manually. Use SSH to log in to any directory of OpenWrt system, Or in the `System menu` → `TTYD terminal`, Run the onekey install command to automatically download and install this plugin.

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

## Custom config

- Supports OpenWrt firmware packaged by [flippy](https://github.com/unifreq/openwrt_packit) and [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) related scripts. The online update file download url of `OpenWrt firmware` and `kernel` can be customized as your own github.com repository. The config information is stored in the [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) file. When the OpenWrt firmware is compiled, you can directly modify the relevant values in this file to specify:

```shell
# 1.Set the download repository of the OpenWrt files to your github.com
sed -i "s|https.*/OpenWrt|https://github.com/USERNAME/REPOSITORY|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2.Set the keywords of Tags in your github.com Releases
sed -i "s|ARMv8|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3.Set the suffix of the OPENWRT files in your github.com Releases
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4.Set the download path of the kernel in your github.com repository
sed -i "s|opt/kernel|https://github.com/USERNAME/REPOSITORY/KERNELPATH|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- When compiling OpenWrt, modify the above 4 points to realize customization. The above information can also be modified in the settings of the plug-in after log in to the openwrt `System` → `Amlogic Service`.

## Plugin setup instructions

Plug-in settings 4 items: OpenWrt firmware download URL, kernel download URL, whether to keep the configuration when update, whether to automatically enter the main line U-BOOT when install and update.

#### The firmware download contains three options

1. OpenWrt firmware download address: Fill in the repository of your OpenWrt compilation on github (or other compiler's repository), such as `https://github.com/breakings/OpenWrt`. The first button of the plug-in welcome homepage `OpenWrt Author website` will link to the website filled in here (Automatically update the link according to the filled website), so that everyone can find the author of the firmware for communication and learning.

2. Keywords of Tags in Releases: to be able to distinguish other x86, R2S and other firmware, such as in [ophub/op/releases](https://github.com/ophub/op/releases) There are many firmwares for different routers, The OpenWrt firmware belonging to the Agmlgic series can be found by including the keyword `s9xxx_lede`.

3. OpenWrt file suffix: the supported formats are `.img.gz` / `.img.xz` / `.7z`. But .img is not supported, because it is too large to download and slow.

- When naming the `OpenWrt` firmware in Releases, please include `SOC model` and `kernel version` : openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, for example: openwrt_ `s905d`_ n1_R21.8.6_k`5.4.138`-flippy-62+o.7z. The supported `SOC` are: `s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`. The supported `kernel version` are `5.4.xxx`, `5.10.xxx`, `5.12.xxx`, `5.13.xxx`, etc.

#### The download of the kernel contains an option

- Download path of OpenWrt kernel: You can fill in the full path `https://github.com/breakings/OpenWrt/tree/main/opt/kernel`. If it is in the same repository as the OpenWrt firmware, the path can also be abbreviated `opt/kernel`. It can also independently point to the kernel storage path in any repository  `https://github.com/ophub/flippy-kernel/tree/main/library`. The kernel files can be stored in the specified path in the form of a folder or a list.

#### Other options

- Keep configuration updates: Modify as needed. If checked, the current configuration will be retained when the firmware is updated.

- Automatically write bootloader: It is recommended to check, there are many features.

#### Description of default settings

- The default [OpenWrt](https://github.com/breakings/OpenWrt/releases/tag/ARMv8) firmware and [kernel](https://github.com/breakings/OpenWrt/tree/main/opt/kernel) download service of the plug-in is supported by `breakings`. He is an active and enthusiastic manager of the Flippy community, familiar with OpenWrt compilation, and familiar with the installation and use of various boxes supported by `Flippy`, Recommended Use.

## Screenshot

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/131235491-b20060de-ae4d-4047-959f-bf4c09b49a6f.gif)

## Borrow

- Upload functions by luci-app-filetransfer
- Log viewing and version query functions by Vernesong
- Kernel and scripts by Flippy

## Acknowledgments

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [Lienol/openwrt](https://github.com/Lienol/openwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## License
- [LICENSE](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE) © OPHUB

