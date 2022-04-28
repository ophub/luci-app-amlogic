# luci-app-amlogic / Amlogic Service

View Chinese description  |  [查看中文说明](README.cn.md)

Supports management of Amlogic s9xxx, Allwinner (V-Plus Cloud), and Rockchip (BeikeYun, Chainedbox L1 Pro) boxes. The current functions include `install OpenWrt to EMMC`, `Manually Upload Updates / Download Updates Online to update the OpenWrt firmware or kernel`, `Backup / Restore firmware config`, `Snapshot management` and `Custom firmware / kernel download site`, etc.

## Manual install

- If the OpenWrt you are using does not have this plugin, you can also install it manually. Use SSH to log in to any directory of OpenWrt system, Or in the `System menu` → `TTYD terminal`, Run the onekey install command to automatically download and install this plugin.

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

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

## Custom config

- Supports OpenWrt firmware packaged by [flippy](https://github.com/unifreq/openwrt_packit) and [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) related scripts. The online update file download url of `OpenWrt firmware` and `kernel` can be customized as your own github.com repository. The config information is stored in the [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) file. When the OpenWrt firmware is compiled, you can directly modify the relevant values in this file to specify:

```yaml
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

Plug-in settings 4 items: OpenWrt firmware download URL, kernel download URL, Version branch selection, Other.

#### The OpenWrt firmware download URL contains three options

1. OpenWrt firmware download address: Fill in the repository of your OpenWrt compilation on github (or other compiler's repository), such as `https://github.com/breakings/OpenWrt`. The `OpenWrt Compiler author` button on the plugin welcome home page will link to the website filled in here (Automatically update the link according to the filled website), so that everyone can find the author of the firmware for communication and learning.

2. Keywords of Tags in Releases: to be able to distinguish other x86, R2S and other firmware, Make sure that the corresponding OpenWrt firmware can be found using this keyword.

3. OpenWrt file suffix: the supported formats are `.img.gz` / `.img.xz` / `.7z`. But .img is not supported, because it is too large to download and slow.

- When naming the `OpenWrt` firmware in Releases, please include `SOC model` and `kernel version` : openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, for example: openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z. The supported `SOC` are: `s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`. The supported `kernel version` are `5.10.xxx`, `5.15.xxx`, etc.

#### The kernel download URL is an option

- Download path of OpenWrt kernel: You can fill in the full path `https://github.com/breakings/OpenWrt/tree/main/opt/kernel`. If it is in the same repository as the OpenWrt firmware, the path can also be abbreviated `opt/kernel`. It can also independently point to the kernel storage path in any repository  `https://github.com/ophub/kernel/tree/main/pub/stable`. The kernel files can be stored in the specified path in the form of a folder or a list.

#### The version branch selection as an option

- Set the version branch: the default is the branch of the current OpenWrt firmware, you can freely choose other branches, you can also customize the branch, such as `5.10`, `5.15`, etc. `OpenWrt` and the `Kernel` `[Online Download Update]` will be downloaded and updated according to the branch you choose.

#### Other options

- Keep configuration updates: Modify as needed. If checked, the current configuration will be retained when the firmware is updated.

- Automatically write bootloader: It is recommended to check, there are many features.

- Set the file system type: Set the file system type of the shared partition (/mnt/mmcblk*p4) when install OpenWrt (Default ext4). This setting is only valid for a fresh install of OpenWrt, and the file type of the current shared partition will not be changed when update the kernel and OpenWrt firmware.

#### Description of default settings

- The default OpenWrt firmware ( [Superset plugin version](https://github.com/breakings/OpenWrt/releases/tag/ARMv8) | [Featured plugin version](https://github.com/breakings/OpenWrt/releases/tag/armv8_mini) | [flippy share version](https://github.com/breakings/OpenWrt/releases/tag/flippy_openwrt) ) and [kernel](https://github.com/breakings/OpenWrt/tree/main/opt/kernel) download service of the plug-in is supported by [breakings](https://github.com/breakings/OpenWrt). He is an active and enthusiastic manager of the Flippy community, familiar with OpenWrt compilation, and familiar with the installation and use of various boxes supported by `Flippy`, Regarding the problems encountered in the compilation and use of OpenWrt, you can consult the community or his Github for feedback.

## Screenshot

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738300-2981e589-ef33-46e0-9af3-55e6e5dd67c0.gif)

## Borrow

- The Upload file functions by luci-app-filetransfer
- The CPU Settings functions by luci-app-cpufreq
- The Kernel and scripts etc by unifreq

## Acknowledgments

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## License

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
