# luci-app-amlogic / Amlogic Service

View Chinese description  |  [查看中文说明](README.cn.md)

This plugin supports online management of Amlogic S9xxx series (X96, HK1, H96, etc.), Allwinner (V-Plus Cloud), and Rockchip (BeikeYun, Chainedbox-L1-Pro, FastRhino-R66S/R68S, Radxa-5B/E25) boxes. It also works in OpenWrt installed in the KVM virtual machine of the Armbian system. Current features include `install OpenWrt to EMMC`, `manually uploading/updating online` OpenWrt firmware or kernel versions, `backup/restore OpenWrt configuration`, `snapshot management`, and `customizing firmware/kernel download site`, etc.

Using the OpenWrt system and Amlogic box plugin in the box requires the support of some [required software packages](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.md#1011-required-openwrt-options). When `custom compiling OpenWrt`, please add it according to the instructions. When using the one-click script for `manual installation` in OpenWrt without compiling Amlogic's box, if there is a prompt for missing dependencies, please install the dependencies according to the log prompt (`System` > `Software Packages` > `Refresh List` > `Search for the corresponding package` > `Install`), then `retry`.

## Manual Installation

- If the OpenWrt you are currently using does not have this plugin, you can also install it manually. Use SSH to log in to any directory of the OpenWrt system, or in `System Menu` → `TTYD Terminal`, run the one-click installation command to automatically download and install this plugin.

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

## Plugin Compilation

```shell
# Add the plugin
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# You can compile this plugin separately
make package/luci-app-amlogic/compile V=99

# Or integrate this plugin during the full compilation of OpenWrt
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic ----> save
make V=99
```

## Custom Configuration

- It supports OpenWrt firmware packaged by [flippy](https://github.com/unifreq/openwrt_packit) and [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) related scripts. The download addresses of `OpenWrt firmware` and `kernel` files in `online download update` of the plugin can be customized as your own github.com repository. Configuration information is saved in the [/etc/config/amlogic](luci-app-amlogic/root/etc/config/amlogic) file. During the compilation of OpenWrt firmware, you can directly modify the related values in this file:

```shell
# 1. Set the download repository of OpenWrt files
sed -i "s|amlogic_firmware_repo.*|amlogic_firmware_repo 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2. Set the keyword of Tags in Releases
sed -i "s|ARMv8|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3. Set the suffix of OpenWrt file in Releases
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4. Set the download path of OpenWrt kernel
sed -i "s|amlogic_kernel_path.*|amlogic_kernel_path 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- When you are compiling OpenWrt, modifying the above 4 points can achieve customization. You can also modify the above information after logging into the OpenWrt system, in `System` → `Amlogic Box` settings.

## Plugin Settings Explanation

The plugin settings consist of 4 elements: OpenWrt firmware download address, kernel download address, version branch selection, and others.

### OpenWrt firmware download contains three options

1. OpenWrt firmware download repository: Fill in your repository on github where you compile OpenWrt (or other compiler's repository), such as: `https://github.com/breakings/OpenWrt`. The `OpenWrt Compiler author` button on the plugin's welcome homepage will link to the website filled in here (automatically updates the link according to the filled website), making it easy for everyone to find the firmware compiler for exchange and learning.

2. Tags keywords in Releases: It needs to distinguish other x86, R2S, etc. firmwares, and ensure that this keyword can find the corresponding OpenWrt firmware.

3. Suffix of OpenWrt file: Supported formats include `.img.gz` / `.img.xz` / `.7z`. However, .img is not supported because it is too large and slow to download.

- When naming the `OpenWrt` firmware in Releases, please include `SOC model` and `kernel version`: openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, for example: openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z. Supported `SOC` includes: `s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`. Supported `kernel versions` include `5.10.xxx`, `5.15.xxx`, etc.

### Kernel download address is one option

- OpenWrt Kernel Download Repository: You can provide the full path `https://github.com/breakings/OpenWrt` or the shorthand `breakings/OpenWrt`. The plugin will automatically download kernels corresponding to specific tags from Releases on Github.com. For instance, it will download the universal kernel from [kernel_stable](https://github.com/breakings/OpenWrt/releases/tag/kernel_stable), the rk3588 specialized kernel from [kernel_rk3588](https://github.com/breakings/OpenWrt/releases/tag/kernel_rk3588), and the rk35xx specialized kernel from [kernel_rk35xx](https://github.com/breakings/OpenWrt/releases/tag/kernel_rk35xx), among others.
- Custom Kernel Download Tags: You can add `KERNELTAGS='xxx'` to the `/etc/flippy-openwrt-release` file in the OpenWrt system to specify the fixed Tags for kernel downloads. If specified, the plugin will automatically download kernels from the designated `kernel_xxx` in Releases. For example, when `KERNELTAGS='flippy'` is specified, kernels will be automatically downloaded from `kernel_flippy`. When making custom settings, ensure that this Tag exists in the kernel download repository.

### Version branch selection is one option

- Set version branch: The default is the branch of the current OpenWrt firmware. You can freely choose other branches or customize the branch, such as `5.10`, `5.15`, etc. The `OpenWrt` and `Kernel` `[Online Download Update]` will download and update according to the branch you selected.

### Other options

- Keep configuration update: Modify as needed. If checked, the current configuration will be retained when updating the firmware.

- Automatically write bootloader: Recommended to be checked, it has many features.

- Set file system type: Set the file system type of the shared partition (/mnt/mmcblk*p4) when installing OpenWrt (default is ext4). This setting only applies to fresh installations of OpenWrt, and will not change the file type of the current shared partition when updating the kernel and firmware.

### Default Settings Explanation

- The default OpenWrt firmware ([Plugin Full Version](https://github.com/breakings/OpenWrt/releases/tag/ARMv8) | [Selected Plugins Mini Version](https://github.com/breakings/OpenWrt/releases/tag/armv8_mini) | [Flippy Shared Version](https://github.com/breakings/OpenWrt/releases/tag/flippy_openwrt)) and [Kernel](https://github.com/breakings/OpenWrt/releases/tag/kernel_stable) download service are provided by [breakings](https://github.com/breakings/OpenWrt), who is an active and enthusiastic manager in the Flippy community, familiar with OpenWrt compilation, and proficient in the installation and use of various series of boxes supported by `Flippy`. For issues encountered in the compilation and use of OpenWrt, you can consult in the community or give feedback on his Github.

- The kernel will be deprecated after the update cycle, and you can choose to use the kernel of `any other version` in the `plugin settings`. Some kernels do not have a complete firmware, you can change the kernel branch in the `plugin settings` and choose the version branch corresponding to the download address.


## Plugin User Instructions

The plugin has 6 functions: Install OpenWrt, Manual Upload Update, Online Download Update, Firmware Configuration Backup, Plugin Settings, and CPU Settings.

1. Install OpenWrt: Select your device from the `Select Device Model` list, and click `Install` to write the firmware from TF/SD/USB into the built-in eMMC of the device.

2. Manual Upload Update: Click the `Choose File` button, select the local `OpenWrt Kernel (upload the full set of kernel files)` or `OpenWrt Firmware (recommended to upload compressed firmware)`, and upload. Once the upload is complete, the corresponding `Replace OpenWrt Kernel` or `Update OpenWrt Firmware` button will appear at the bottom of the page, click to update (the system will automatically reboot after the update).

3. Online Download Update: Click the `Update Box Plugin Only` button to update the Amlogic Box plugin to the latest version; click `Update System Kernel Only` to download the corresponding kernel according to the kernel branch selected in `Plugin Settings`; click `Full System Update` to download the latest firmware based on the download site set in `Plugin Settings`. Clicking the `Rescue the original system kernel` button will copy the kernel currently in use on the device to the target disk. This facilitates rescue operations in case a kernel update fails and the OpenWrt system cannot start. For example, it allows for booting the OpenWrt system from a USB drive to rescue the system on the eMMC, supporting mutual rescue among `eMMC/NVME/sdX` devices.

4. Backup Firmware Configuration: Click the `Open List` button to edit the backup list; click the `Download Backup` button to backup the OpenWrt configuration information from the current device to local; click the `Upload Backup` button to upload the backup configuration files and restore the system configuration. Click `Create Snapshot`, `Restore Snapshot` and `Delete Snapshot` buttons to manage the snapshot accordingly. Snapshots will record all configuration information in the `/etc` directory of the current OpenWrt system, which is convenient for one-click restore to the current configuration status in the future. This function is similar to `Download Backup`, but only saves in the current system and does not support download use.

5. Plugin Settings: Set the kernel download address and other information of the plugin, for details, see the relevant introduction in `Plugin Settings Instructions`.

6. CPU Settings: Set the scheduling policy of the CPU (recommended to use the default settings), which can be set according to needs.

Note: `Install OpenWrt` and `CPU Settings` and other functions will automatically hide inapplicable functions depending on the device and environment.

## KVM Virtual Machine User Instructions

For overpowered boxes, you can first install the [Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) system, then install the KVM virtual machine to achieve multi-system use. The compilation of the OpenWrt system can use the [mk_qemu-aarch64_img.sh](https://github.com/unifreq/openwrt_packit/blob/master/mk_qemu-aarch64_img.sh) script developed by [unifreq](https://github.com/unifreq/openwrt_packit), and its installation and use instructions are detailed in the [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md) document. The OpenWrt qemu firmware in `Online Download Update` is supported by [breakings](https://github.com/breakings/OpenWrt).

The method of using the plugin in the KVM virtual machine is the same as the method of directly installing and using OpenWrt in the box.

## Compilation Instructions for OpenWrt System

Step 1: Compile the Rootfs file for OpenWrt: Use the OpenWrt source code and select `Arm SystemReady (EFI) compliant` option in `Target System`, select `64-bit (armv8) machines` option in `Subtarget`, select `Generic EFI Boot` option in `Target Profile`, and add the [required software packages](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.md#1011-required-openwrt-options) to compile the `rootfs.tar.gz` file for OpenWrt.

Step 2: Package the dedicated OpenWrt firmware for different devices: You can use the scripts from [flippy](https://github.com/unifreq/openwrt_packit) or [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) to package the dedicated OpenWrt firmware for different devices. Please refer to the respective repositories for detailed usage instructions.

## Plugin Interface

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738300-2981e589-ef33-46e0-9af3-55e6e5dd67c0.gif)

## Acknowledgement

- Kernel and scripts resources are from [unifreq](https://github.com/unifreq)
- File upload and download functions were inspired by [luci-app-filetransfer](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-filetransfer)
- CPU settings function was inspired by [luci-app-cpufreq](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-cpufreq)

## Links

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## License

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
