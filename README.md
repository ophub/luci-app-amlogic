
# luci-app-amlogic / 晶晨宝盒

Provide luci operation support for Amlogic STB. The current functions include `install OpenWrt to EMMC`, `Manually Upload Updates / Download Updates Online to update the OpenWrt firmware or kernel`, `Backup / Restore firmware config`, `Snapshot management` and `Custom firmware / kernel download site`, etc.

为 Amlogic 系列盒子提供 luci 操作支持。目前的功能有 `安装 OpenWrt 至 EMMC`，`手动上传升级/在线下载更新 OpenWrt 固件或内核版本`，`备份/恢复固件配置`，`快照管理` 及 `自定义固件/内核下载站点`等功能。

## Depends / 依赖

- [luci-lib-fs](https://github.com/ophub/luci-app-amlogic/tree/main/luci-lib-fs)

Tip: It is included when compiling with [coolsnowwolf/lean](https://github.com/coolsnowwolf/lede/tree/master/package/lean/luci-lib-fs) or [Lienol/openwrt](https://github.com/Lienol/openwrt/tree/main/package/lean/luci-lib-fs) source code. There is no need to add this dependency separately. When using other source code libraries, please check whether they are missing.

提示：当使用 [coolsnowwolf/lean](https://github.com/coolsnowwolf/lede/tree/master/package/lean/luci-lib-fs) 或 [Lienol/openwrt](https://github.com/Lienol/openwrt/tree/main/package/lean/luci-lib-fs) 的源码库进行 OpenWrt 编译时，无须单独添加此依赖。当使用其他源码库时请自行检查是否缺少。

## Compile / 编译

```yaml
# Add luci-app-amlogic （添加插件）
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# This plugin can be compiled separately （可以单独编译此插件）
make package/luci-app-amlogic/compile V=99

# Or integrate this plugin when fully compiling OpenWrt （或者在完整编译 OpenWrt 时集成此插件）
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic ----> save
make V=99
```

## Manual install / 手动安装

- If the OpenWrt you are using does not have this plugin, you can also install it manually. Use SSH to log in to any directory of OpenWrt system, Or in the `System menu` → `TTYD terminal`, Run the onekey install command to automatically download and install this plugin.

- 如果你正在使用的 OpenWrt 没有这个插件，也可以手动安装。使用 SSH 登录 OpenWrt 系统的任意目录，或者在 `系统菜单` → `TTYD 终端` 里，运行一键安装命令，即可自动下载安装本插件。

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

## Custom config / 自定义配置

- Supports OpenWrt firmware packaged by [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) and [flippy](https://github.com/unifreq/openwrt_packit) related scripts. The online update file download url of `OpenWrt firmware` and `kernel` can be customized as your own github.com repository. The config information is stored in the [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) file. When the OpenWrt firmware is compiled, you can directly modify the relevant values in this file to specify:

- 支持 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 和 [flippy](https://github.com/unifreq/openwrt_packit) 相关脚本打包的 OpenWrt 固件。插件里 `在线下载更新` 中的 `OpenWrt 固件` 及 `内核` 文件的下载地址支持自定义为自己的 github.com 的仓库。配置信息保存在 [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) 文件中。OpenWrt 固件编译时可以直接修改这个文件里的相关值来进行指定：


```shell
# 1.Set the download repository of the OpenWrt files to your github.com （OpenWrt 文件的下载仓库）
sed -i "s|https.*/amlogic-s9xxx-openwrt|https://github.com/USERNAME/REPOSITORY|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2.Set the keywords of Tags in your github.com Releases （Releases 里 Tags 的关键字）
sed -i "s|s9xxx_lede|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3.Set the suffix of the OPENWRT files in your github.com Releases （Releases 里 OpenWrt 文件的后缀）
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4.Set the download path of the kernel in your github.com repository （OpenWrt 内核的下载路径）
sed -i "s|https.*/library|https://github.com/USERNAME/REPOSITORY/KERNELPATH|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- Tips: When compiling OpenWrt, modify the above 4 points to realize customization. The above information can also be modified in the settings of the plug-in after log in to the openwrt `System` → `Amlogic Service`.

- 提示：当你在编译 OpenWrt 时，修改以上 4 点即可实现自定义。以上信息也可以登录 OpenWrt 系统后，在 `系统` → `晶晨宝盒` 的设置中修改。

## Plugin setup instructions / 插件设置说明

Plug-in settings 4 items: OpenWrt firmware download URL, kernel download URL, whether to keep the configuration when update, whether to automatically enter the main line U-BOOT when install and update.

#### The firmware download contains three options

1. OpenWrt firmware download address: It can be the full path of the repository `https://github.com/ophub/amlogic-s9xxx-openwrt` or the abbreviation of the repository without domain name `ophub/amlogic-s9xxx-openwrt`

2. Keywords of Tags in Releases: to be able to distinguish other x86, R2S and other firmware, such as in [ophub/op/releases](https://github.com/ophub/op/releases) There are many firmwares for different routers, The OpenWrt firmware belonging to the Agmlgic series can be found by including the keyword `s9xxx_lede`.

3. OpenWrt file suffix: the supported formats are `.img.gz` / `.img.xz` / `.7z`. But .img is not supported, because it is too large to download and slow.

- When naming the `OpenWrt` firmware in Releases, please include `SOC model` and `kernel version` : openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, for example: openwrt_ `s905d`_ n1_R21.8.6_k`5.4.138`-flippy-62+o.7z. The supported `SOC` are: `s905x3`, `s905x2`, `s905x`, `s905d`, `s912`, `s922x`. The supported `kernel version` are `5.4.xxx`, `5.10.xxx`, `5.12.xxx`, `5.13.xxx`, etc.

#### The download of the kernel contains an option

- Download path of OpenWrt kernel: You can fill in the full path `https://github.com/ophub/amlogic-s9xxx-openwrt/tree/main/amlogic-s9xxx/amlogic-kernel`. If it is in the same repository as the OpenWrt firmware, the path can also be abbreviated `amlogic-s9xxx/amlogic-kernel`. It can also independently point to the kernel storage path in any repository  `https://github.com/ophub/flippy-kernel/tree/main/library`. The kernel files can be stored in the specified path in the form of a folder or a list. It is recommended to use the kernel library path maintained for a long time by [breakings](https://github.com/breakings/OpenWrt/tree/main/opt/kernel).

#### Other options

- Keep configuration updates: Modify as needed. If checked, the current configuration will be retained when the firmware is updated.

- Automatically write bootloader: It is recommended to check, there are many features.

插件设置 4 项内容：OpenWrt 固件下载地址、内核下载地址、更新时是否保留配置、安装与更新时是否自动输入主线 U-BOOT。

####  固件下载包含三个选项

1. OpenWrt 固件下载地址：可以是仓库的完整路径 `https://github.com/ophub/amlogic-s9xxx-openwrt` 或者是不含域名的仓库简写 `ophub/amlogic-s9xxx-openwrt`

2. Releases 里 Tags 的关键字：要可以区分其他 x86，R2S 等固件，如在 [ophub/op/releases](https://github.com/ophub/op/releases) 里有很多不同路由器的固件，可以使用包含 `s9xxx_lede` 关键词找到属于 Agmlgic 系列的 OpenWrt 固件。

3. OpenWrt 文件的后缀：支持的格式有 `.img.gz` / `.img.xz` / `.7z` 。但是不支持 .img，因为太大下载太慢。

- 在 Releases 里的 `OpenWrt` 固件命名时请包含 `SOC型号` 和 `内核版本` ：openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz，例如：openwrt_ `s905d`_ n1_R21.8.6_k`5.4.138`-flippy-62+o.7z。支持的 `SOC` 有：`s905x3`、`s905x2`、`s905x`、`s905d`、`s912`、`s922x`。支持的`内核版本`有 `5.4.xxx`、`5.10.xxx`、`5.12.xxx`、`5.13.xxx` 等。

#### 内核的下载包含一个选项

- OpenWrt 内核的下载路径：可以填写完整路径 `https://github.com/ophub/amlogic-s9xxx-openwrt/tree/main/amlogic-s9xxx/amlogic-kernel` 。如果和 OpenWrt 固件是同仓库的情况下，也可以简写路径 `amlogic-s9xxx/amlogic-kernel` 。也可以独立指向到任意仓库中内核存放路径 `https://github.com/ophub/flippy-kernel/tree/main/library`。内核文件支持以文件夹或列表的形式存储在指定的路径下。推荐使用由 [breakings](https://github.com/breakings/OpenWrt/tree/main/opt/kernel) 长期维护的内核库路径。

#### 其他选项

- 保留配置更新：根据需要进行修改，如果勾选，在更新固件固件时将保留当前配置。

- 自动写入 bootloader：推荐勾选，有很多特性。

## Screenshot / 截图

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/127464473-056eb275-c2ec-4623-bd2f-d310acf63ccf.gif)

## Borrow / 借鉴

- Upload functions by luci-app-filetransfer
- Log viewing and version query functions by Vernesong
- Kernel and scripts by Flippy

- 文件上传下载等功能来自 luci-app-filetransfer
- 日志查看和版本查询等功能来自 Vernesong
- 内核及脚本等资源来自 Flippy

## Acknowledgments

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [Lienol/openwrt](https://github.com/Lienol/openwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)

## License / 许可
- [LICENSE](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE) © OPHUB
