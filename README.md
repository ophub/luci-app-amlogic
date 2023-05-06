# luci-app-amlogic / Amlogic Service

View Chinese description  |  [查看中文说明](README.cn.md)

This supports online management of Amlogic S9xxx series (such as X96, HK1, H96 etc.), Allwinner (VPlus), and Rockchip (BeikeYun, Chainedbox-L1-Pro, FastRhino-R66S/R68S, Radxa-5B/E25, Hinlink-H66K/H68K) boxes, and it also supports using OpenWrt installed on Armbian system KVM virtual machines. The current features include `installing OpenWrt to EMMC`, `manually uploading upgrade/online downloading updated` OpenWrt firmware or kernel version, `backing up/restoring firmware configuration`, `snapshot management`, and `custom firmware/kernel download sites`.

To use OpenWrt system and `luci-app-amlogic` plugins in the box, some [required packages](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/make-openwrt/documents/README.md#1011-openwrt-required-options) are needed. Please add them according to the instructions when customizing the compilation of OpenWrt. When using the one-click script `manual installation` in OpenWrt that has not compiled `luci-app-amlogic`, if there is a prompt for missing dependencies, please install the dependencies first according to the log prompt (`System` > `Software Package` > `Refresh List` > `Search for Corresponding Software Package` > `Install`), and then`retry`.

## Manual Installation

- If the plugin is not available in the OpenWrt you are using, you can also install it manually. Log in to any directory of the OpenWrt system using SSH or run the one-click installation command in the `System Menu` → `TTYD Terminal` to automatically download and install the plugin.

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

## Plugin compilation

```yaml
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# You can compile this plugin separately
make package/luci-app-amlogic/compile V=99

# Or integrate this plugin when compiling the full OpenWrt
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic ----> save
make V=99
```

## Custom Configuration

- Supports OpenWrt firmware packaged by [flippy](https://github.com/unifreq/openwrt_packit) and [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) scripts. The download addresses of `OpenWrt firmware` and `kernel` files in the `Online Download Update` section of the plugin support customization to your own github.com repository. The configuration information is saved in the [/etc/config/amlogic](luci-app-amlogic/root/etc/config/amlogic) file. When compiling OpenWrt firmware, you can directly modify the relevant values in this file to specify them:

```yaml
# 1. Set the download repository for OpenWrt files
sed -i "s|amlogic_firmware_repo.*|amlogic_firmware_repo 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2. Set the keyword for tags in Releases
sed -i "s|ARMv8|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3. Set the suffix for OpenWrt files in Releases
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4. Set the download path for OpenWrt kernel
sed -i "s|amlogic_kernel_path.*|amlogic_kernel_path 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- When compiling OpenWrt, you can make the above 4 modifications to achieve customization. You can also login to the OpenWrt system and modify these settings in `System` → `Amlogic Service` settings.

## Plugin Settings Description

There are 4 items for plugin settings: OpenWrt firmware download address, kernel download address, version branch selection, and others.

### OpenWrt Firmware Download Contains Three Options

1. OpenWrt firmware download repository: Fill in the repository where you compile OpenWrt on GitHub (or other compilers), such as `https://github.com/breakings/OpenWrt`. The plugin welcomes the `OpenWrt Compiler author` button on the homepage to link to the website filled here (automatically update the link based on the website filled) to facilitate everyone to find the firmware compilation author for communication and learning.

2. Keyword for tags in Releases: To distinguish from other x86, R2S and other firmware, ensure that this keyword can be used to find the corresponding OpenWrt firmware.

3. Suffix of OpenWrt files: Supported formats are `.img.gz` / `.img.xz` / `.7z`. However, `.img` is not supported because it is too large and downloads too slowly.

- When naming the `OpenWrt` firmware in Releases, please include `SOC model` and `kernel version`: openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, for example: openwrt_`s905d`_n1_R21.8.6_k`5.15.25`-flippy-62+o.7z. Supported `SOC` are: `s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`. Supported `kernel versions` include `5.10.xxx`, `5.15.xxx`, etc.

### Kernel Download Address as an Option

- OpenWrt kernel download repository: You can fill in the complete path `https://github.com/breakings/OpenWrt` or `breakings/OpenWrt`. The plugin will automatically download the universal kernel from [kernel_stable](https://github.com/breakings/OpenWrt/releases/tag/kernel_stable) in Releases and the rk3588 dedicated kernel from [kernel_rk3588](https://github.com/breakings/OpenWrt/releases/tag/kernel_rk3588).

### Version branch selection as an option

- Set version branch: It defaults to the current branch of the OpenWrt firmware. You can freely choose other branches or customize branches, such as `5.10`, `5.15`, etc. When `[Online Download Update]` for `OpenWrt` and `Kernel`, they will be downloaded and updated based on the branch you selected.

### Other options

- Keep configuration on update: Modify according to needs. If checked, the current configuration will be preserved when updating firmware.

- Automatically write bootloader: Recommended to check, has many features.

- Set file system type: Set the file system type of the shared partition (`/mnt/mmcblk*p4`) during installation of OpenWrt (default is ext4). This setting only applies when installing OpenWrt from scratch and will not change the file type of the current shared partition when updating the kernel or firmware.

### Default settings description

- The download services for the default OpenWrt firmware ([Plugin Full Version](https://github.com/breakings/OpenWrt/releases/tag/ARMv8) | [Selected Plugin Mini Version](https://github.com/breakings/OpenWrt/releases/tag/armv8_mini) | [Flippy Share Version](https://github.com/breakings/OpenWrt/releases/tag/flippy_openwrt)) and [kernel](https://github.com/breakings/OpenWrt/releases/tag/kernel_stable) are provided and supported by [breakings](https://github.com/breakings/OpenWrt), who is an active and enthusiastic manager in the Flippy community, familiar with OpenWrt compilation and knowledgeable about the installation and use of various series of boxes supported by `Flippy`. For any issues encountered during the compilation and use of OpenWrt, you can consult the community or provide feedback on his Github page.

- After the update cycle of the kernel ends, it will be deprecated and other versions of the kernel can be selected in `Plugin Settings`. Some kernels do not have complete firmware, so you can change the kernel branch in `Plugin Settings` and select the corresponding version branch in the download address.

## Plugin Usage Instructions

The plugin has 6 functions: Install OpenWrt, manually upload updates, download updates online, backup firmware configuration, plugin settings, and CPU settings.

1. Install OpenWrt: Select your device from the `Select Device Model` list and click `Install` to write the firmware from TF/SD/USB to the device's built-in eMMC.

2. Manually Upload Updates: Click the `Select File` button, select the local `OpenWrt kernel (upload all kernel files)` or `OpenWrt firmware (compressed firmware recommended)` and upload it. After uploading is complete, the corresponding `Change OpenWrt Kernel` or `Update OpenWrt Firmware` button will appear at the bottom of the page based on the uploaded content, which can be clicked to update (the system will automatically restart after the update is complete).

3. Download Updates Online: Clicking the `Only Update Box Plugin` button will update the `luci-app-amlogic` to the latest version; clicking the `Only Update System Kernel` button will download the corresponding kernel according to the kernel branch selected in `Plugin Settings`; clicking the `Full System Update` button will download the latest firmware from the download site selected in `Plugin Settings`.

4. Backup Firmware Configuration: Click the `Download Backup` button to back up the OpenWrt configuration information of the current device to the local computer (this backup file can be uploaded and used in `Manually Upload Updates`, which is used to restore the system configuration); clicking the `Create Snapshot`, `Restore Snapshot` and `Delete Snapshot` buttons can manage snapshots accordingly. The snapshot will record all configuration information under the `/etc` directory in the current OpenWrt system, making it easy to restore to the current configuration state with one click in the future. Its function is similar to that of `Download Backup`, but it is saved only in the current system and cannot be downloaded for use.

5. Plugin Settings: Set information such as kernel download address for the plugin, see `Plugin Settings Description` for relevant introduction.

6. CPU Settings: Set the scheduling strategy of the CPU (default settings recommended), which can be set according to needs.

Note: Some functions such as `Install OpenWrt` and `CPU Settings` will be automatically hidden if they are not applicable based on the device and environment.

## KVM Virtual Machine Usage Instructions

For boxes with excess performance, you can first install the [Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) system and then install the KVM virtual machine to achieve multi-system use. The compilation of the OpenWrt system can use the [mk_qemu-aarch64_img.sh](https://github.com/unifreq/openwrt_packit/blob/master/mk_qemu-aarch64_img.sh) script developed by [unifreq](https://github.com/unifreq/openwrt_packit), and its installation and usage instructions are detailed in the [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md) document. The OpenWrt qemu firmware for `Online Download Update` in the plugin is supported by [breakings](https://github.com/breakings/OpenWrt).

The usage method of the plugin in KVM virtual machine is the same as that of installing and using OpenWrt directly on the box.

## Plugin Interface

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738300-2981e589-ef33-46e0-9af3-55e6e5dd67c0.gif)

## Borrow

- Resources such as kernel and scripts come from [unifreq](https://github.com/unifreq).
- Features such as file upload and download are borrowed from [luci-app-filetransfer](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-filetransfer).
- The CPU settings function is borrowed from [luci-app-cpufreq](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-cpufreq).

## Links

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## License

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
