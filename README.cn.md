# luci-app-amlogic / 晶晨宝盒

查看英文说明 | [View English description](README.md)

支持对晶晨 s9xxx 系列（斐讯N1、HK1等），全志（微加云），以及瑞芯微（贝壳云、我家云）的盒子进行在线管理。目前的功能有 `安装 OpenWrt 至 EMMC`，`手动上传升级/在线下载更新 OpenWrt 固件或内核版本`，`备份/恢复固件配置`，`快照管理` 及 `自定义固件/内核下载站点`等功能。

## 手动安装

- 如果你正在使用的 OpenWrt 没有这个插件，也可以手动安装。使用 SSH 登录 OpenWrt 系统的任意目录，或者在 `系统菜单` → `TTYD 终端` 里，运行一键安装命令，即可自动下载安装本插件。

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

## 插件编译

```yaml
# 添加插件
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# 可以单独编译此插件
make package/luci-app-amlogic/compile V=99

# 或者在完整编译 OpenWrt 时集成此插件
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic ----> save
make V=99
```

## 自定义配置

- 支持 [flippy](https://github.com/unifreq/openwrt_packit) 和 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 相关脚本打包的 OpenWrt 固件。插件里 `在线下载更新` 中的 `OpenWrt 固件` 及 `内核` 文件的下载地址支持自定义为自己的 github.com 的仓库。配置信息保存在 [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) 文件中。OpenWrt 固件编译时可以直接修改这个文件里的相关值来进行指定：

```yaml
# 1.设置OpenWrt 文件的下载仓库
sed -i "s|https.*/OpenWrt|https://github.com/USERNAME/REPOSITORY|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2.设置 Releases 里 Tags 的关键字
sed -i "s|ARMv8|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3.设置 Releases 里 OpenWrt 文件的后缀
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4.设置 OpenWrt 内核的下载路径
sed -i "s|opt/kernel|https://github.com/USERNAME/REPOSITORY/KERNELPATH|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- 当你在编译 OpenWrt 时，修改以上 4 点即可实现自定义。以上信息也可以登录 OpenWrt 系统后，在 `系统` → `晶晨宝盒` 的设置中修改。

## 插件设置说明

插件设置 4 项内容：OpenWrt 固件下载地址、内核下载地址、版本分支选择、其他。

####  OpenWrt 固件下载包含三个选项

1. OpenWrt 固件下载地址：填写您在 github 编译 OpenWrt 的仓库（或其他编译者的仓库），如：`https://github.com/breakings/OpenWrt` 。插件欢迎首页的 `OpenWrt Compiler author` 按钮将链接至此处填写的网站（根据填写的网站自动更新链接），方便大家找到固件编译作者进行交流学习。

2. Releases 里 Tags 的关键字：要可以区分其他 x86，R2S 等固件，确保可以使用此关键字找到相应的 OpenWrt 固件。

3. OpenWrt 文件的后缀：支持的格式有 `.img.gz` / `.img.xz` / `.7z` 。但是不支持 .img，因为太大下载太慢。

- 在 Releases 里的 `OpenWrt` 固件命名时请包含 `SOC型号` 和 `内核版本` ：openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz，例如：openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z。支持的 `SOC` 有：`s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`。支持的`内核版本`有 `5.10.xxx`、`5.15.xxx` 等。

#### 内核下载地址为一个选项

- OpenWrt 内核的下载路径：可以填写完整路径 `https://github.com/breakings/OpenWrt/tree/main/opt/kernel` 。如果和 OpenWrt 固件是同仓库的情况下，也可以简写路径 `opt/kernel` 。也可以独立指向到任意仓库中内核存放路径 `https://github.com/ophub/kernel/tree/main/pub/stable` 。内核文件支持以文件夹或列表的形式存储在指定的路径下。

#### 版本分支选择为一个选项

- 设置版本分支：默认为当前 OpenWrt 固件的分支，你可以自由选择其他分支，也可以自定义分支，如 `5.10`，`5.15` 等。`OpenWrt` 和 `内核` `[在线下载更新]` 时，将根据你选择的分支进行下载与更新。

#### 其他选项

- 保留配置更新：根据需要进行修改，如果勾选，在更新固件固件时将保留当前配置。

- 自动写入 bootloader：推荐勾选，有很多特性。

- 设置文件系统类型：设置安装 OpenWrt 时共享分区 (/mnt/mmcblk*p4) 的文件系统类型（默认 ext4）。此项设置只针对全新安装 OpenWrt 时有效，更新内核和更新固件时不会再改变当前共享分区的文件类型。

#### 默认设置说明

- 插件默认的 OpenWrt 固件（ [插件高大全版](https://github.com/breakings/OpenWrt/releases/tag/ARMv8) | [精选插件mini版](https://github.com/breakings/OpenWrt/releases/tag/armv8_mini) | [flippy分享版](https://github.com/breakings/OpenWrt/releases/tag/flippy_openwrt) ）与 [内核](https://github.com/breakings/OpenWrt/tree/main/opt/kernel) 下载服务由 [breakings](https://github.com/breakings/OpenWrt) 提供支持，他是 Flippy 社群活跃且热心的管理者，熟悉 OpenWrt 编译，通晓 `Flippy` 提供支持的各系列盒子的安装和使用，关于 OpenWrt 的编译及使用中碰到的问题等，可以进社群咨询或到他的 Github 中反馈。

## 插件界面

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738345-31dd85cf-5e43-444e-a624-f21a28be2a7c.gif)

## 借鉴

- 文件上传下载等功能来自 luci-app-filetransfer
- CPU 设置功能来自 luci-app-cpufreq
- 内核及脚本等资源来自 unifreq

## 鸣谢

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## 许可

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
