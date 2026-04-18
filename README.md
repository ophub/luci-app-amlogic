<div align="center">
    <img src="https://github.com/user-attachments/assets/9df399cc-9a81-48a6-91ab-d56056b82338" alt="luci-app-amlogic" />
</div>

# luci-app-amlogic / Amlogic Service

[English Instructions](README.md) | [中文说明](README.cn.md)

This plugin supports online management of Amlogic S9xxx series (X96, HK1, H96, etc.), Allwinner (V-Plus Cloud), and Rockchip (BeikeYun, Chainedbox-L1-Pro, FastRhino-R66S/R68S, Radxa-5B/E25) boxes. It also supports usage within OpenWrt installed in KVM virtual machines running on the Armbian system. Current features include `installing OpenWrt to eMMC`, `manually uploading/updating online` OpenWrt firmware or kernel versions, `backup/restore OpenWrt configuration`, `snapshot management`, and `customizing firmware/kernel download site`, etc.

Running the OpenWrt system with the Amlogic Service plugin on the box requires certain [required software packages](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.md#1011-required-openwrt-options). When performing a `custom OpenWrt compilation`, please add them according to the instructions. When using the one-click script for `manual installation` in OpenWrt without the Amlogic Service plugin pre-compiled, if prompted about missing dependencies, please install them according to the log prompt (`System` > `Software Packages` > `Refresh List` > `Search for the corresponding package` > `Install`), then `retry`.

## Manual Installation

- If the OpenWrt you are currently using does not have this plugin, you can also install it manually. Log in to the OpenWrt system via SSH and navigate to any directory, or open `System Menu` → `TTYD Terminal`, then run the following one-click installation command to automatically download and install this plugin.

```yaml
curl -fsSL ophub.org/luci-app-amlogic | bash
```
or
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

- This plugin supports OpenWrt firmware packaged by [flippy](https://github.com/unifreq/openwrt_packit) and [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) related scripts. The download URLs for `OpenWrt firmware` and `kernel` files in the plugin's `Online Download Update` feature can be customized to point to your own GitHub repository. Configuration information is saved in the [/etc/config/amlogic](luci-app-amlogic/root/etc/config/amlogic) file. During OpenWrt firmware compilation, you can directly modify the relevant values in this file:

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

- When compiling OpenWrt, modifying the above 4 items enables customization. These settings can also be modified after logging into the OpenWrt system via `System` → `Amlogic Box`.

## Plugin Settings Explanation

The plugin settings consist of 4 categories: OpenWrt firmware download, kernel download, version branch selection, and miscellaneous options.

### OpenWrt firmware download contains three options

1. OpenWrt firmware download repository: Enter the GitHub repository where you compile OpenWrt (or another contributor's repository), such as: `https://github.com/breakingbadboy/OpenWrt`. The `OpenWrt Compiler author` button on the plugin's homepage will link to the URL entered here (the link updates automatically), making it easy for users to locate the firmware author for discussion and collaboration.

2. Tags keyword in Releases: This keyword must distinguish the firmware from other architectures such as x86, R2S, etc., ensuring that the corresponding OpenWrt firmware can be accurately located.

3. OpenWrt file suffix: Supported formats include `.img.gz`, `.img.xz`, and `.7z`. The `.img` format is not supported due to its large file size and slow download speed.

- When naming `OpenWrt` firmware files in Releases, please include the `SoC model` and `kernel version`: openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, for example: openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z. Supported `SoC` models include: `s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`. Supported `kernel versions` include `5.10.xxx`, `5.15.xxx`, etc.

### Kernel download address contains two options

- Kernel Download Repository: You can enter the full URL `https://github.com/ophub/kernel` or the shorthand `ophub/kernel`.

- Kernel Download Tags: Allows you to specify which tag to download kernel files from in the kernel repository's Releases, such as [kernel_flippy](https://github.com/ophub/kernel/releases/tag/kernel_flippy), [kernel_stable](https://github.com/ophub/kernel/releases/tag/kernel_stable), [kernel_rk3588](https://github.com/ophub/kernel/releases/tag/kernel_rk3588), and [kernel_rk35xx](https://github.com/ophub/kernel/releases/tag/kernel_rk35xx), etc. When specified, the plugin will download exclusively from the designated tag; if left empty, the plugin will automatically select the most suitable tag based on the current OpenWrt system configuration.

### Version branch selection is one option

- Set version branch: Defaults to the branch of the current OpenWrt firmware. You can freely choose other branches or customize the branch, such as `5.10`, `5.15`, etc. The `OpenWrt` and `Kernel` `[Online Download Update]` operations will download and update based on the selected branch.

### Other options

- Preserve configuration on update: Adjust as needed. When enabled, the current configuration will be retained during firmware updates.

- Automatically write bootloader: Recommended to enable, as it provides enhanced compatibility and boot support.

- Set file system type: Configures the file system type for the shared partition (/mnt/mmcblk*p4) during OpenWrt installation (default: ext4). This setting only applies to fresh OpenWrt installations and will not alter the file system type of the existing shared partition during kernel or firmware updates.

### Default Settings Description

- The default OpenWrt firmware download service for this plugin ( [Comprehensive Version](https://github.com/breakingbadboy/OpenWrt/releases/tag/ARMv8) | [Mini Version](https://github.com/breakingbadboy/OpenWrt/releases/tag/armv8_mini) | [Flippy Shared Version](https://github.com/breakingbadboy/OpenWrt/releases/tag/flippy_openwrt) ) is supported by [breakingbadboy](https://github.com/breakingbadboy/OpenWrt). He is a core maintainer in the Flippy community, highly experienced in OpenWrt compilation, and proficient in the installation and configuration of various ARM devices. If you encounter any issues during OpenWrt compilation or usage, feel free to consult the community or submit feedback on his GitHub page.

- The default OpenWrt kernel for the plugin is provided by [https://github.com/ophub/kernel](https://github.com/ophub/kernel). Among them, kernels under the [kernel_flippy](https://github.com/ophub/kernel/releases/tag/kernel_flippy) tag are stable mainline kernels compiled and shared by developer [flippy](https://github.com/unifreq). For the [kernel_rk3588](https://github.com/ophub/kernel/releases/tag/kernel_rk3588) and [kernel_rk35xx](https://github.com/ophub/kernel/releases/tag/kernel_rk35xx) tags, kernels with `flippy` in their names are Rockchip-specific kernels provided by the same developer, while the rest are compiled by [ophub/kernel](https://github.com/ophub/kernel). Kernels under the [kernel_stable](https://github.com/ophub/kernel/releases/tag/kernel_stable) tag are stable mainline kernels compiled by [ophub/kernel](https://github.com/ophub/kernel), and [kernel_h6](https://github.com/ophub/kernel/releases/tag/kernel_h6) is the dedicated kernel for Allwinner `H6 (TQC-A01)` devices.

- Kernels will be deprecated once they reach the end of their lifecycle (EOL). When this occurs, you can select an alternative supported kernel version in the `Plugin Settings` to continue using the service. If certain kernel versions lack a corresponding complete firmware, you can also change the kernel branch in the `Plugin Settings` to match an available version from the download source.


## Plugin User Instructions

The plugin provides 6 functions: Install OpenWrt, Manual Upload Update, Online Download Update, Firmware Configuration Backup, Plugin Settings, and CPU Settings.

1. Install OpenWrt: Select your device from the `Select Device Model` list and click `Install` to write the firmware from TF/SD/USB to the device's built-in eMMC storage.

2. Manual Upload Update: Click the `Choose File` button to select a local `OpenWrt Kernel (upload the complete set of kernel files)` or `OpenWrt Firmware (compressed format recommended)` and upload it. Once the upload completes, the corresponding `Replace OpenWrt Kernel` or `Update OpenWrt Firmware` button will appear at the bottom of the page. Click to proceed with the update (the system will reboot automatically upon completion).

3. Online Download Update: Click the `Update Box Plugin Only` button to update the Amlogic Box plugin to the latest version; click `Update System Kernel Only` to download the corresponding kernel according to the kernel branch selected in `Plugin Settings`; click `Full System Update` to download the latest firmware based on the download site set in `Plugin Settings`. Click the `Rescue Original System Kernel` button to copy the currently running kernel to the target disk, facilitating recovery when a kernel update fails and the OpenWrt system cannot boot. For example, you can boot OpenWrt from a USB drive to rescue the system on eMMC, with cross-rescue support among `eMMC/NVME/sdX` devices.

4. Backup Firmware Configuration: Click the `Open List` button to edit the backup list; click the `Download Backup` button to back up the current device's OpenWrt configuration to your local machine; click the `Upload Backup` button to upload backup configuration files and restore the system configuration. Click `Create Snapshot`, `Restore Snapshot`, and `Delete Snapshot` to manage snapshots. Snapshots capture all configuration data under the `/etc` directory of the current OpenWrt system, enabling one-click restoration to the saved state in the future. This feature is similar to `Download Backup`, but snapshots are stored on the device only and cannot be downloaded.

5. Plugin Settings: Set the kernel download address and other information of the plugin, for details, see the relevant introduction in `Plugin Settings Instructions`.

6. CPU Settings: Set the scheduling policy of the CPU (recommended to use the default settings), which can be set according to needs.

Note: Certain functions such as `Install OpenWrt` and `CPU Settings` will be automatically hidden based on device type and operating environment.

## KVM Virtual Machine User Instructions

For boxes with surplus processing power, you can first install the [Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) system, then set up KVM virtual machines to run multiple systems simultaneously. The OpenWrt system image can be built using the [mk_qemu-aarch64_img.sh](https://github.com/unifreq/openwrt_packit/blob/master/mk_qemu-aarch64_img.sh) script developed by [unifreq](https://github.com/unifreq/openwrt_packit), with installation and usage instructions detailed in the [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md) document. The OpenWrt QEMU firmware available via `Online Download Update` is provided by [breakingbadboy](https://github.com/breakingbadboy/OpenWrt).

The plugin operates identically in a KVM virtual machine as it does when OpenWrt is installed directly on the box.

## Compilation Instructions for OpenWrt System

Step 1: Compile the Rootfs file: Using the OpenWrt source code, select the `Arm SystemReady (EFI) compliant` option under `Target System`, select `64-bit (armv8) machines` under `Subtarget`, select `Generic EFI Boot` under `Target Profile`, and add the [required software packages](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.md#1011-required-openwrt-options) to compile the OpenWrt `rootfs.tar.gz` file.

Step 2: Package device-specific OpenWrt firmware: Use the scripts from [flippy](https://github.com/unifreq/openwrt_packit) or [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) to package device-specific OpenWrt firmware. Refer to the respective repositories for detailed usage instructions.

## Plugin Interface

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738300-2981e589-ef33-46e0-9af3-55e6e5dd67c0.gif)

## Acknowledgement

- Kernel and script resources are from [unifreq](https://github.com/unifreq)
- File upload and download functions were inspired by [luci-app-filetransfer](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-filetransfer)
- CPU settings function was inspired by [luci-app-cpufreq](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-cpufreq)

## Links

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakingbadboy/OpenWrt](https://github.com/breakingbadboy/OpenWrt)

## License

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
