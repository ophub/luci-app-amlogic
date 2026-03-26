<div align="center">
    <img src="https://github.com/user-attachments/assets/455ec33b-5a00-4881-9bb4-10d4aba42e89" alt="luci-app-amlogic" />
</div>

# luci-app-amlogic / 晶晨宝盒

[English Instructions](README.md) | [中文说明](README.cn.md)

支持对晶晨 S9xxx 系列（X96、HK1、H96 等）、全志（微加云）以及瑞芯微（贝壳云、我家云、电犀牛 R66S/R68S、瑞莎 5B/E25）的盒子进行在线管理，也支持在 Armbian 系统的 KVM 虚拟机中安装的 OpenWrt 里使用。目前的功能包括`安装 OpenWrt 至 EMMC`、`手动上传升级/在线下载更新` OpenWrt 固件或内核版本、`备份/恢复固件配置`、`快照管理`以及`自定义固件/内核下载站点`等。

在盒子中使用 OpenWrt 系统及晶晨宝盒插件，需要一些[必选软件包](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.cn.md#1011-openwrt-必选项)的支持，在`自定义编译 OpenWrt`时，请根据说明添加。在未集成晶晨宝盒插件的 OpenWrt 中使用一键脚本`手动安装`时，如果提示缺少依赖，请根据日志提示先安装依赖（`系统` > `软件包` > `刷新列表` > `搜索对应的软件包` > `安装`），然后`再重试`。

## 手动安装

- 如果您正在使用的 OpenWrt 没有此插件，也可以手动安装。通过 SSH 登录 OpenWrt 系统并进入任意目录，或在 `系统菜单` → `TTYD 终端` 中，运行以下一键安装命令即可自动完成插件的下载与安装。

```yaml
curl -fsSL ophub.org/luci-app-amlogic | bash
```
或者
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

- 本插件支持由 [flippy](https://github.com/unifreq/openwrt_packit) 和 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 相关脚本打包的 OpenWrt 固件。插件中`在线下载更新`功能的 `OpenWrt 固件`及`内核`文件下载地址支持自定义为您自己的 GitHub 仓库。配置信息保存在 [/etc/config/amlogic](luci-app-amlogic/root/etc/config/amlogic) 文件中。编译 OpenWrt 固件时，可直接修改该文件中的相关值进行配置：

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

- 编译 OpenWrt 时，修改以上 4 项即可实现自定义。上述信息也可在登录 OpenWrt 系统后，通过 `系统` → `晶晨宝盒` 的设置界面进行修改。

## 插件设置说明

插件设置包含 4 项内容：OpenWrt 固件下载地址、内核下载地址、版本分支选择、其他。

###  OpenWrt 固件下载包含三个选项

1. OpenWrt 固件下载仓库：填写您在 GitHub 上编译 OpenWrt 的仓库地址（或其他编译者的仓库），如：`https://github.com/breakingbadboy/OpenWrt` 。插件首页的 `OpenWrt Compiler author` 按钮将链接至此处填写的地址（链接随填写内容自动更新），便于用户找到固件编译者进行交流与学习。

2. Releases 里 Tags 的关键字：该关键字需能区分 x86、R2S 等其他架构的固件，确保通过此关键字可准确找到对应的 OpenWrt 固件。

3. OpenWrt 文件的后缀：支持的格式包括 `.img.gz`、`.img.xz` 和 `.7z`，不支持 `.img` 格式（因文件体积过大，下载速度慢）。

- 在 Releases 中为 `OpenWrt` 固件命名时，请包含 `SoC 型号`和`内核版本`：openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz，例如：openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z。支持的 `SoC` 包括：`s905x3`、`s905x2`、`s905x`、`s905w`、`s905d`、`s922x`、`s912`、`l1pro`、`beikeyun`、`vplus`。支持的`内核版本`包括 `5.10.xxx`、`5.15.xxx` 等。

### 内核下载为两个选项

- OpenWrt 内核下载仓库：可填写完整路径 `https://github.com/breakingbadboy/OpenWrt` 或简写为 `breakingbadboy/OpenWrt`。

- 自定义内核下载 Tag：允许您指定从内核仓库 Releases 中下载特定 Tag 的内核文件，例如 [kernel_stable](https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable)、[kernel_rk3588](https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_rk3588) 和 [kernel_rk35xx](https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_rk35xx) 等。设置后，插件将从指定的 Tag 精确下载；若留空，插件将根据当前 OpenWrt 系统信息自动匹配最合适的 Tag 进行下载。

### 版本分支选择为一个选项

- 设置版本分支：默认为当前 OpenWrt 固件所用的分支。您可以自由选择其他分支，也可以自定义分支，如 `5.10`、`5.15` 等。执行 `OpenWrt` 和`内核`的`[在线下载更新]`时，将根据所选分支进行下载与更新。

### 其他选项

- 保留配置更新：根据需要进行修改。勾选后，更新固件时将保留当前配置。

- 自动写入 bootloader：推荐勾选，可提供更好的兼容性和启动支持。

- 设置文件系统类型：设置安装 OpenWrt 时共享分区（/mnt/mmcblk*p4）的文件系统类型（默认为 ext4）。此设置仅在全新安装 OpenWrt 时生效，更新内核或固件时不会更改当前共享分区的文件系统类型。

### 默认设置说明

- 插件默认的 OpenWrt 固件（ [插件高大全版](https://github.com/breakingbadboy/OpenWrt/releases/tag/ARMv8) | [精选插件mini版](https://github.com/breakingbadboy/OpenWrt/releases/tag/armv8_mini) | [flippy分享版](https://github.com/breakingbadboy/OpenWrt/releases/tag/flippy_openwrt) ）与 [内核](https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable) 下载服务由 [breakingbadboy](https://github.com/breakingbadboy/OpenWrt) 提供支持，他是 Flippy 社区中活跃且热心的管理者，熟悉 OpenWrt 编译，精通 `Flippy` 所支持的各系列盒子的安装与使用。关于 OpenWrt 编译及使用中遇到的问题，可前往社区咨询或在其 GitHub 页面反馈。

- 内核在更新周期结束后将被弃用，届时可在`插件设置`中选择其他版本的内核继续使用。部分内核版本可能没有对应的完整固件，可在`插件设置`中更改内核分支，选择下载地址中对应的版本分支。

## 插件使用说明

插件提供 6 项功能：安装 OpenWrt、手动上传更新、在线下载更新、备份固件配置、插件设置、CPU 设置。

1. 安装 OpenWrt：在`选择设备型号`列表中选择您的设备，点击`安装`即可将固件从 TF/SD/USB 写入设备内置的 eMMC。

2. 手动上传更新：点击`选择文件`按钮，选择本地的 `OpenWrt 内核（需上传全套内核文件）`或 `OpenWrt 固件（推荐上传压缩格式）`并上传。上传完成后，页面下方将根据所上传的内容显示对应的`更换 OpenWrt 内核`或`更新 OpenWrt 固件`按钮，点击即可执行更新（更新完成后系统将自动重启）。

3. 在线下载更新：点击`仅更新宝盒插件`按钮，可将晶晨宝盒插件更新至最新版本；点击`仅更新系统内核`将根据`插件设置`中选择的内核分支下载对应的内核；点击`完整更新全系统`将根据`插件设置`中的下载站点下载最新固件；点击`救援原系统内核`按钮，会将当前设备正在使用的内核复制到目标磁盘，便于在内核更新失败导致 OpenWrt 系统无法启动时实施救援。例如，可从 USB 启动 OpenWrt 系统救援 eMMC 中的系统，支持在 `eMMC/NVME/sdX` 设备之间相互救援。

4. 备份固件配置：点击`打开列表`按钮可编辑备份列表；点击`下载备份`按钮可将当前设备中 OpenWrt 的配置信息备份到本地；点击`上传备份`按钮可上传备份的配置文件以恢复系统配置。点击`创建快照`、`还原快照`和`删除快照`按钮可对快照进行相应管理。快照会记录当前 OpenWrt 系统中 `/etc` 目录下的全部配置信息，便于日后一键恢复至当前配置状态。其作用与`下载备份`类似，但仅保存在当前系统中，不支持下载。

5. 插件设置：设置插件的内核下载地址等信息，详见 `插件设置说明` 的相关介绍。

6. CPU 设置：设置 CPU 的调度策略（推荐使用默认设置），可根据需要进行设置。

注意：`安装 OpenWrt` 和 `CPU 设置`等部分功能会根据设备类型及运行环境的差异自动隐藏不适用的选项。

## KVM 虚拟机使用说明

对于性能较强的盒子，可先安装 [Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) 系统，再通过 KVM 虚拟机实现多系统并行使用。OpenWrt 系统镜像可使用 [unifreq](https://github.com/unifreq/openwrt_packit) 开发的 [mk_qemu-aarch64_img.sh](https://github.com/unifreq/openwrt_packit/blob/master/mk_qemu-aarch64_img.sh) 脚本进行制作，其安装与使用说明详见 [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md) 文档。插件`在线下载更新`中的 OpenWrt QEMU 固件由 [breakingbadboy](https://github.com/breakingbadboy/OpenWrt) 提供支持。

插件在 KVM 虚拟机中的使用方法与在盒子中直接使用 OpenWrt 时相同。

## OpenWrt 系统的编译说明

第一步，编译 Rootfs 文件：使用 OpenWrt 源码进行编译，在 `Target System` 中选择 `Arm SystemReady (EFI) compliant`，在 `Subtarget` 中选择 `64-bit (armv8) machines`，在 `Target Profile` 中选择 `Generic EFI Boot`，并添加[必选软件包](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.cn.md#1011-openwrt-必选项)，即可编译生成 OpenWrt 的 `rootfs.tar.gz` 文件。

第二步，打包不同设备的 OpenWrt 专用固件：使用 [flippy](https://github.com/unifreq/openwrt_packit) 或 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 的脚本均可为不同设备打包 OpenWrt 专用固件。详细使用说明请参阅相关仓库。

## 插件界面

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738345-31dd85cf-5e43-444e-a624-f21a28be2a7c.gif)

## 借鉴

- 内核及脚本等资源来源于 [unifreq](https://github.com/unifreq)
- 文件上传下载等功能借鉴了 [luci-app-filetransfer](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-filetransfer)
- CPU 设置功能借鉴了 [luci-app-cpufreq](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-cpufreq)

## 链接

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakingbadboy/OpenWrt](https://github.com/breakingbadboy/OpenWrt)

## 许可

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
