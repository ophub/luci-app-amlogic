# luci-app-amlogic / 晶晨宝盒

查看英文说明 | [View English description](README.md)

支持对晶晨 s9xxx 系列（X96, HK1, H96等），全志（微加云），以及瑞芯微（贝壳云，我家云，电犀牛R66S/R68S，瑞莎5B/E25）的盒子进行在线管理，也支持在 Armbian 系统的 KVM 虚拟机中安装的 OpenWrt 里使用。目前的功能有 `安装 OpenWrt 至 EMMC`，`手动上传升级/在线下载更新` OpenWrt 固件或内核版本，`备份/恢复固件配置`，`快照管理` 及 `自定义固件/内核下载站点`等功能。

在盒子中使用 OpenWrt 系统及晶晨宝盒插件，需要一些[必选软件包](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.cn.md#1011-openwrt-必选项)的支持，在`自定义编译 OpenWrt`时，请根据说明添加。在未编译晶晨宝盒的 OpenWrt 中使用一键脚本`手动安装`时，如果提示有缺少的依赖，请根据日志提示先安装依赖（`系统` > `软件包` > `刷新列表` > `搜索对应的软件包` > `安装`），然后`再重试`。

## 手动安装

- 如果你正在使用的 OpenWrt 没有这个插件，也可以手动安装。使用 SSH 登录 OpenWrt 系统的任意目录，或者在 `系统菜单` → `TTYD 终端` 里，运行一键安装命令，即可自动下载安装本插件。

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

## 插件编译

```shell
# 添加插件
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# 可以单独编译此插件
make package/luci-app-amlogic/compile V=99

# 或者在完整编译 OpenWrt 时集成此插件
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic ----> save
make V=99
```

## 自定义配置

- 支持 [flippy](https://github.com/unifreq/openwrt_packit) 和 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 相关脚本打包的 OpenWrt 固件。插件里 `在线下载更新` 中的 `OpenWrt 固件` 及 `内核` 文件的下载地址支持自定义为自己的 github.com 的仓库。配置信息保存在 [/etc/config/amlogic](luci-app-amlogic/root/etc/config/amlogic) 文件中。OpenWrt 固件编译时可以直接修改这个文件里的相关值来进行指定：

```shell
# 1.设置OpenWrt 文件的下载仓库
sed -i "s|amlogic_firmware_repo.*|amlogic_firmware_repo 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2.设置 Releases 里 Tags 的关键字
sed -i "s|ARMv8|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3.设置 Releases 里 OpenWrt 文件的后缀
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4.设置 OpenWrt 内核的下载路径
sed -i "s|amlogic_kernel_path.*|amlogic_kernel_path 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- 当你在编译 OpenWrt 时，修改以上 4 点即可实现自定义。以上信息也可以登录 OpenWrt 系统后，在 `系统` → `晶晨宝盒` 的设置中修改。

## 插件设置说明

插件设置 4 项内容：OpenWrt 固件下载地址、内核下载地址、版本分支选择、其他。

###  OpenWrt 固件下载包含三个选项

1. OpenWrt 固件下载仓库：填写您在 github 编译 OpenWrt 的仓库（或其他编译者的仓库），如：`https://github.com/breakings/OpenWrt` 。插件欢迎首页的 `OpenWrt Compiler author` 按钮将链接至此处填写的网站（根据填写的网站自动更新链接），方便大家找到固件编译作者进行交流学习。

2. Releases 里 Tags 的关键字：要可以区分其他 x86，R2S 等固件，确保可以使用此关键字找到相应的 OpenWrt 固件。

3. OpenWrt 文件的后缀：支持的格式有 `.img.gz` / `.img.xz` / `.7z` 。但是不支持 .img，因为太大下载太慢。

- 在 Releases 里的 `OpenWrt` 固件命名时请包含 `SOC型号` 和 `内核版本` ：openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz，例如：openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z。支持的 `SOC` 有：`s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`。支持的`内核版本`有 `5.10.xxx`、`5.15.xxx` 等。

### 内核下载地址为一个选项

- OpenWrt 内核下载仓库：可以填写完整路径 `https://github.com/breakings/OpenWrt` 或简写为 `breakings/OpenWrt` 。插件将自动从 Github.com 的 Releases 里下载对应 tags 的内核。例如从 [kernel_stable](https://github.com/breakings/OpenWrt/releases/tag/kernel_stable) 里下载通用内核，从 [kernel_rk3588](https://github.com/breakings/OpenWrt/releases/tag/kernel_rk3588) 里下载 rk3588 专用内核，从 [kernel_rk35xx](https://github.com/breakings/OpenWrt/releases/tag/kernel_rk35xx) 里下载 rk35xx 专用内核等。
- 自定义内核下载 Tags：可以在 `OpenWrt` 系统的 `/etc/flippy-openwrt-release` 文件中添加 `KERNEL_TAGS='xxx'` 指定内核下载的固定 Tags。如果进行了指定，插件将自动从 Releases 中指定的 `kernel_xxx` 里下载内核。例如当指定 `KERNEL_TAGS='flippy'` 时将自动从`kernel_flippy` 里下载内核。在进行自定义设置时，要确保内核下载仓库里有这个 Tags。

### 版本分支选择为一个选项

- 设置版本分支：默认为当前 OpenWrt 固件的分支，你可以自由选择其他分支，也可以自定义分支，如 `5.10`，`5.15` 等。`OpenWrt` 和 `内核` `[在线下载更新]` 时，将根据你选择的分支进行下载与更新。

### 其他选项

- 保留配置更新：根据需要进行修改，如果勾选，在更新固件固件时将保留当前配置。

- 自动写入 bootloader：推荐勾选，有很多特性。

- 设置文件系统类型：设置安装 OpenWrt 时共享分区 (/mnt/mmcblk*p4) 的文件系统类型（默认 ext4）。此项设置只针对全新安装 OpenWrt 时有效，更新内核和更新固件时不会再改变当前共享分区的文件类型。

### 默认设置说明

- 插件默认的 OpenWrt 固件（ [插件高大全版](https://github.com/breakings/OpenWrt/releases/tag/ARMv8) | [精选插件mini版](https://github.com/breakings/OpenWrt/releases/tag/armv8_mini) | [flippy分享版](https://github.com/breakings/OpenWrt/releases/tag/flippy_openwrt) ）与 [内核](https://github.com/breakings/OpenWrt/releases/tag/kernel_stable) 下载服务由 [breakings](https://github.com/breakings/OpenWrt) 提供支持，他是 Flippy 社群活跃且热心的管理者，熟悉 OpenWrt 编译，通晓 `Flippy` 提供支持的各系列盒子的安装和使用，关于 OpenWrt 的编译及使用中碰到的问题等，可以进社群咨询或到他的 Github 中反馈。

- 内核在更新周期结束后将弃用，可在 `插件设置` 里 `任选其他版本` 的内核使用。部分内核没有完整固件，可在 `插件设置` 中更改内核分支，选择下载地址中对应的版本分支。

## 插件使用说明

插件有 6 项功能：安装 OpenWrt，手动上传更新，在线下载更新，备份固件配置，插件设置，CPU 设置。

1. 安装 OpenWrt：在 `选择设备型号` 列表里选择你的设备，点击 `安装` 即可将固件从 TF/SD/USB 写入设备自带的 eMMC 里。

2. 手动上传更新：点击 `选择文件` 按钮，选择本地的 `OpenWrt 内核（把全套内核文件都上传）` 或 `OpenWrt 固件（推荐上传压缩格式的固件）` 并上传，上传完成后页面下方将根据上传的内容出现对应的 `更换 OpenWrt 内核` 或 `更新 OpenWrt 固件` 按钮，点击即可更新（更新完成后将自动重启）。

3. 在线下载更新：点击 `仅更新宝盒插件` 按钮，可以把晶晨宝盒插件更新至最新版本；点击 `仅更新系统内核` 将根据 `插件设置` 中选择的内核分支下载对应的内核；点击 `完整更新全系统` 将根据 `插件设置` 中的下载站点下载最新固件；点击 `救援原系统内核` 按钮，会把当前设备正在使用的内核复制到目标磁盘里，方便在内核更新失败造成 OpenWrt 系统无法启动时实施救援，例如从 USB 启动 OpenWrt 系统，救援 eMMC 里的系统，支持在 `eMMC/NVME/sdX` 设备里相互救援。

4. 备份固件配置：点击 `打开列表` 按钮，可以编辑备份列表；点击 `下载备份` 按钮，可以把当前设备中 OpenWrt 的配置信息备份到本地；点击 `上传备份` 按钮，可以将备份的配置文件上传，恢复系统配置。点击 `创建快照`，`还原快照` 和 `删除快照` 按钮可以对快照进行相应管理。快照会记录当前 OpenWrt 系统中 `/etc` 目录下的全部配置信息，方便以后一键恢复至当前配置状态，作用和 `下载备份` 类似，仅保存在当前系统中，不支持下载使用。

5. 插件设置：设置插件的内核下载地址等信息，详见 `插件设置说明` 的相关介绍。

6. CPU 设置：设置 CPU 的调度策略（推荐使用默认设置），可根据需要进行设置。

注意：`安装 OpenWrt` 和 `CPU 设置` 等部分功能会根据设备及环境的不同自动隐藏不适用的功能。

## KVM 虚拟机使用说明

对于性能过剩的盒子，可以先安装 [Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) 系统，再安装 KVM 虚拟机实现多系统使用。其中 OpenWrt 系统的编译可以使用 [unifreq](https://github.com/unifreq/openwrt_packit) 开发的 [mk_qemu-aarch64_img.sh](https://github.com/unifreq/openwrt_packit/blob/master/mk_qemu-aarch64_img.sh) 脚本进行制作，其安装与使用说明详见 [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md) 文档。插件中 `在线下载更新` 的 OpenWrt qemu 固件由 [breakings](https://github.com/breakings/OpenWrt) 提供支持。

插件在 KVM 虚拟机中的使用方法和在盒子中直接安装使用 OpenWrt 的方法相同。

## OpenWrt 系统的编译说明

第一步，编译 Rootfs 文件：使用 OpenWrt 源码，在 `Target System` 里选择 `Arm SystemReady (EFI) compliant` 选项，在 `Subtarget` 里选择 `64-bit (armv8) machines` 选项，在 `Target Profile` 里选择 `Generic EFI Boot` 选项，并添加 [必选软件包](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.cn.md#1011-openwrt-必选项) 即可编译 OpenWrt 的 `rootfs.tar.gz` 文件。

第二步，打包不同设备的 OpenWrt 专用固件：使用 [flippy](https://github.com/unifreq/openwrt_packit) 或者 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 的脚本均可打包不同设备的 OpenWrt 专用固件。具体使用说明可在相关仓库中查看。

## 插件界面

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738345-31dd85cf-5e43-444e-a624-f21a28be2a7c.gif)

## 借鉴

- 内核及脚本等资源来自 [unifreq](https://github.com/unifreq)
- 文件上传下载等功能借鉴了 [luci-app-filetransfer](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-filetransfer)
- CPU 设置功能借鉴了 [luci-app-cpufreq](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-cpufreq)

## 链接

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## 许可

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
