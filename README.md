
# luci-app-amlogic

Provide luci operation support for Amlogic STB. The current functions include `install OpenWrt to EMMC`, `Manually Upload Updates / Download Updates Online to update the OpenWrt firmware or kernel`, `Backup / Restore firmware config` and `Custom firmware / kernel download site`, etc.

为 Amlogic 系列盒子提供 luci 操作支持。目前的功能有 `安装 OpenWrt 至 EMMC`，`手动上传升级/在线下载更新 OpenWrt 固件或内核版本`，`备份/恢复固件配置` 及 `自定义固件/内核下载站点`等功能。

## Depends / 依赖

- [luci-lib-fs](https://github.com/ophub/luci-app-amlogic/tree/main/luci-lib-fs)

Tip: It is included when compiling with [coolsnowwolf/lean](https://github.com/coolsnowwolf/lede/tree/master/package/lean/luci-lib-fs) or [Lienol/openwrt](https://github.com/Lienol/openwrt/tree/main/package/lean/luci-lib-fs) source code. There is no need to add this dependency separately. When using other source code libraries, please check whether they are missing.

提示：当使用 [coolsnowwolf/lean](https://github.com/coolsnowwolf/lede/tree/master/package/lean/luci-lib-fs) 或 [Lienol/openwrt](https://github.com/Lienol/openwrt/tree/main/package/lean/luci-lib-fs) 的源码库进行 OpenWrt 编译时，无须单独添加此依赖。当使用其他源码库时请自行检查是否缺少。

## Compile / 编译

```yaml
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# Compile package only
make package/luci-app-amlogic/compile V=99

# Compile
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic..... LuCI support for Amlogic S9xxx STB ----> save
make V=99
```

## Manual install / 手动安装

- Use SSH to log in to any directory of OpenWrt system, such as `cd /root`, and then run the onekey install command to automatically download and install this plugin.

- 使用 SSH 登录 OpenWrt 系统的任意目录，如 `cd /root`，然后运行一键安装命令，即可自动下载安装本插件。

```yaml
wget git.io/luci-app-amlogic -O ./amlogic.sh && chmod +x amlogic.sh && ./amlogic.sh
```

## Config / 配置

- The online update file download url of `OpenWrt firmware` and `kernel` can be customized as your own repository, and the config information is stored in the [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) file of the OpenWrt system. When the firmware is compiled, directly modify the value in this file to realize the setting of custom OpenWrt firmware and kernel download address. An example of OpenWrt's github.com download URL: [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt/releases), an example of a kernel download URL: [amlogic-s9xxx/amlogic -kernel](https://github.com/ophub/amlogic-s9xxx-openwrt/tree/main/amlogic-s9xxx/amlogic-kernel)

- Supports OpenWrt firmware packaged by [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) and [flippy](https://github.com/unifreq/openwrt_packit) scripts. 

- It is recommended to use [flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions) for packaging when using the `flippy` script to package on `Github Actions`. The packaging scripts of the Flippy repository are completely used, without any script modification, and only intelligent Action application development is carried out, making the packaging operation easier and more personalized.

- 插件里 `在线下载更新` 中的 `OpenWrt 固件` 及 `内核` 文件的下载地址支持自定义为自己的仓库，配置信息保存在 OpenWrt 系统的 [/etc/config/amlogic](https://github.com/ophub/luci-app-amlogic/blob/main/luci-app-amlogic/root/etc/config/amlogic) 文件中。固件编译时直接修改这个文件里的值，可实现自定义 OpenWrt 固件及内核下载地址的设置。其中 OpenWrt 的 github.com 下载地址举例： [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt/releases) ，内核下载地址举例：[amlogic-s9xxx/amlogic-kernel](https://github.com/ophub/amlogic-s9xxx-openwrt/tree/main/amlogic-s9xxx/amlogic-kernel)

- 支持 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 和 [flippy](https://github.com/unifreq/openwrt_packit) 脚本打包的 OpenWrt 固件。

- 如果你使用 `Flippy` 脚本在 `Github Actions` 打包，推荐你了解下 [flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions) ，完全使用 Flippy 原站的打包脚本，未做任何脚本修改，仅进行了智能化 Action 应用开发，让打包操作变得更加简单化和个性化。


## Screenshot / 截图

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/121277810-f9ebd800-c903-11eb-9bf4-7c2b11f9a1d3.gif)

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
