
# luci-app-amlogic

Provide luci operation support for Amlogic STB. The current functions include `install OpenWrt to EMMC`, `Manually Upload Updates / Download Updates Online to update the OpenWrt firmware or kernel`, `Backup / Restore firmware config` and `Custom firmware / kernel download site`, etc.

为 Amlogic 系列盒子提供 luci 操作支持。目前的功能有 `安装 OpenWrt 至 EMMC`，`手动上传升级/在线下载更新 OpenWrt 固件或内核版本`，`备份/恢复固件配置` 及 `自定义固件/内核下载站点`等功能。

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

## Custom config / 自定义配置

- Supports OpenWrt firmware packaged by [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) and [flippy](https://github.com/unifreq/openwrt_packit) related scripts. The online update file download url of `OpenWrt firmware` and `kernel` can be customized as your own github.com repository. An example of OpenWrt's github.com download URL: [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt/releases), an example of a kernel download URL: [amlogic-s9xxx/amlogic -kernel](https://github.com/ophub/amlogic-s9xxx-openwrt/tree/main/amlogic-s9xxx/amlogic-kernel) . The config information is stored in the [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) file. When the OpenWrt firmware is compiled, you can directly modify the relevant values in this file to specify:

- 支持 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 和 [flippy](https://github.com/unifreq/openwrt_packit) 相关脚本打包的 OpenWrt 固件。插件里 `在线下载更新` 中的 `OpenWrt 固件` 及 `内核` 文件的下载地址支持自定义为自己的 github.com 的仓库。其中 OpenWrt 的 github.com 下载地址举例： [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt/releases) ，内核下载地址举例：[amlogic-s9xxx/amlogic-kernel](https://github.com/ophub/amlogic-s9xxx-openwrt/tree/main/amlogic-s9xxx/amlogic-kernel) 。配置信息保存在 [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) 文件中。OpenWrt 固件编译时可以直接修改这个文件里的相关值来进行指定：


```shell
# 1.Set the download repository of the OpenWrt files to your github.com （OpenWrt 文件的下载仓库）
sed -i "s|ophub/amlogic-s9xxx-openwrt|USERNAME/REPOSITORY|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2.Set the download path of the kernel in your github.com repository （OpenWrt 内核的下载路径）
sed -i "s|amlogic-s9xxx/amlogic-kernel|ROOTDIR/KERNEL|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3.Modify the keywords of Tags in your github.com Releases （Releases 里 Tags 的关键字）
sed -i "s|s9xxx_lede|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4.Modify the suffix of the OPENWRT files in your github.com Releases （Releases 里 OpenWrt 文件的后缀）
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- Tips: When compiling OpenWrt on github.com, modify the above 4 points to realize customization. The above information can also be modified in the settings of the plug-in after log in to the openwrt `System` → `Amlogic Service`.

- 提示：当你在 github.com 编译 OpenWrt 时，修改以上 4 点即可实现自定义。以上信息也可以登录 OpenWrt 系统后，在 `系统` → `晶晨宝盒` 的设置中修改。

## Manual install / 手动安装

- If the OpenWrt you are using does not have this plugin, you can also install it manually. Use SSH to log in to any directory of OpenWrt system, Or in the `System menu` → `TTYD terminal`, Run the onekey install command to automatically download and install this plugin.

- 如果你正在使用的 OpenWrt 没有这个插件，也可以手动安装。使用 SSH 登录 OpenWrt 系统的任意目录，或者在 `系统菜单` → `TTYD 终端` 里，运行一键安装命令，即可自动下载安装本插件。

```yaml
curl -fsSL git.io/luci-app-amlogic | bash
```

## Screenshot / 截图

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/125813243-7a91ae65-2091-41cb-bb2b-848e19d7473a.gif)

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
