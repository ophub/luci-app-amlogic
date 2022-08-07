# luci-app-amlogic / Amlogic Service

View Chinese description  |  [查看中文说明](README.cn.md)

Supports management of Amlogic s9xxx, Allwinner (V-Plus Cloud), and Rockchip (BeikeYun, Chainedbox L1 Pro) boxes. It is also supported for OpenWrt installed in a KVM virtual machine on Armbian systems. The current functions include `install OpenWrt to EMMC`, `Manually Upload Updates / Download Updates Online to update the OpenWrt firmware or kernel`, `Backup / Restore firmware config`, `Snapshot management` and `Custom firmware / kernel download site`, etc.

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

### The OpenWrt firmware download URL contains three options

1. OpenWrt firmware download address: Fill in the repository of your OpenWrt compilation on github (or other compiler's repository), such as `https://github.com/breakings/OpenWrt`. The `OpenWrt Compiler author` button on the plugin welcome home page will link to the website filled in here (Automatically update the link according to the filled website), so that everyone can find the author of the firmware for communication and learning.

2. Keywords of Tags in Releases: to be able to distinguish other x86, R2S and other firmware, Make sure that the corresponding OpenWrt firmware can be found using this keyword.

3. OpenWrt file suffix: the supported formats are `.img.gz` / `.img.xz` / `.7z`. But .img is not supported, because it is too large to download and slow.

- When naming the `OpenWrt` firmware in Releases, please include `SOC model` and `kernel version` : openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, for example: openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z. The supported `SOC` are: `s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`. The supported `kernel version` are `5.10.xxx`, `5.15.xxx`, etc.

### The kernel download URL is an option

- Download path of OpenWrt kernel: You can fill in the full path `https://github.com/breakings/OpenWrt/tree/main/opt/kernel`. If it is in the same repository as the OpenWrt firmware, the path can also be abbreviated `opt/kernel`. It can also independently point to the kernel storage path in any repository  `https://github.com/ophub/kernel/tree/main/pub/stable`. The kernel files can be stored in the specified path in the form of a folder or a list.

### The version branch selection as an option

- Set the version branch: the default is the branch of the current OpenWrt firmware, you can freely choose other branches, you can also customize the branch, such as `5.10`, `5.15`, etc. `OpenWrt` and the `Kernel` `[Online Download Update]` will be downloaded and updated according to the branch you choose.

### Other options

- Keep configuration updates: Modify as needed. If checked, the current configuration will be retained when the firmware is updated.

- Automatically write bootloader: It is recommended to check, there are many features.

- Set the file system type: Set the file system type of the shared partition (/mnt/mmcblk*p4) when install OpenWrt (Default ext4). This setting is only valid for a fresh install of OpenWrt, and the file type of the current shared partition will not be changed when update the kernel and OpenWrt firmware.

### Description of default settings

- The default OpenWrt firmware ( [Superset plugin version](https://github.com/breakings/OpenWrt/releases/tag/ARMv8) | [Featured plugin version](https://github.com/breakings/OpenWrt/releases/tag/armv8_mini) | [flippy share version](https://github.com/breakings/OpenWrt/releases/tag/flippy_openwrt) ) and [kernel](https://github.com/breakings/OpenWrt/tree/main/opt/kernel) download service of the plug-in is supported by [breakings](https://github.com/breakings/OpenWrt). He is an active and enthusiastic manager of the Flippy community, familiar with OpenWrt compilation, and familiar with the installation and use of various boxes supported by `Flippy`, Regarding the problems encountered in the compilation and use of OpenWrt, you can consult the community or his Github for feedback.

- The kernel will be deprecated after the update cycle is over, you can use the `optional other version` kernel in the `Plugin Settings`. Some kernels do not have complete firmware. You can change the kernel branch in the `Plugin Settings` and select the corresponding version branch in the download address.

## Instructions for using the plugin

The plugin has 6 functions: install OpenWrt, upload updates manually, download updates online, backup firmware configuration, plugin settings, CPU settings.

1. Install OpenWrt: Select your device in the `Select the device model` list, and click `Install` to write the firmware from TF/SD/USB to the eMMC that comes with the device.

2. Manually Upload Update: Click the `Select File` button, select the local `OpenWrt kernel (upload all the kernel files)` or `OpenWrt firmware (recommended to upload the firmware in compressed format)` and upload it. According to the uploaded content, the corresponding `Replace OpenWrt Kernel` or `Update OpenWrt firmware` button will appear, click to update (it will restart automatically after the update is completed).

3. Online Download Update: Click the `Only update Amlogic Service` button to update the Amlogic Service plugin to the latest version; click `Update system kernel only` to download the corresponding kernel according to the kernel branch selected in `Plugin Settings` ;Click `Complete system update` to download the latest firmware according to the download site in `Plugin Settings`.

4. Backup Firmware Config: Click the `Download Backup` button to backup the OpenWrt configuration information in the current device to the local (this backup file can be uploaded and used in `Manual upload update` to restore the system configuration); click `Create Snapshots`, `Restore Snapshot` and `Delete Snapshot` buttons can manage snapshots accordingly. The snapshot will record all the configuration information in the `/etc` directory of the current OpenWrt system, which is convenient to restore to the current configuration state with one click in the future.

5. Plugin Settings: Set the kernel download address of the Plugin and other information. For details, please refer to the relevant introduction in `Plugin Setting Instructions`.

6. CPU Settings: Set the CPU scheduling policy (default settings are recommended), which can be set as required.

Note: Some functions such as `Install OpenWrt` and `CPU Settings` will automatically hide inapplicable functions according to different devices and environments.

## KVM virtual machine usage instructions

For boxes with excess performance, you can install the [Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) system first, and then install the KVM virtual machine to achieve multi-system use. The compilation of the OpenWrt system can be done by using the [mk_qemu-aarch64_img.sh](https://github.com/unifreq/openwrt_packit/blob/master/mk_qemu-aarch64_img.sh) script developed by [unifreq](https://github.com/unifreq/openwrt_packit). Please refer to the [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md) document for installation and usage instructions. The OpenWrt qemu firmware for `Online Download Update` in the plugin is powered by [breakings](https://github.com/breakings/OpenWrt).

## Screenshot

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738300-2981e589-ef33-46e0-9af3-55e6e5dd67c0.gif)

## Borrow

- The Kernel and scripts etc by [unifreq](https://github.com/unifreq)
- The Upload file functions is borrowed from [luci-app-filetransfer](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-filetransfer)
- The CPU setting function is borrowed from [luci-app-cpufreq](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-cpufreq)

## Links

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## License

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
