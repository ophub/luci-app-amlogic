
# luci-app-amlogic

Provide luci operation support for Amlogic STB. The current functions include `install OpenWrt to EMMC`, `update the OpenWrt firmware or kernel`, and `backup/restore config`.

为 Amlogic 系列盒子提供 luci 操作支持。目前的功能有 `安装 OpenWrt 至 EMMC`，`升级 OpenWrt 固件或内核版本`，`备份/恢复个性化配置`。

## Depends / 依赖

- [luci-lib-fs](https://github.com/ophub/luci-app-amlogic/tree/main/luci-lib-fs)

Tip: It is included when compiling with [coolsnowwolf/lean](https://github.com/coolsnowwolf/lede/tree/master/package/lean/luci-lib-fs) or [Lienol/openwrt](https://github.com/Lienol/openwrt/tree/21.02/package/lean/luci-lib-fs) source code. There is no need to add this dependency separately. When using other source code libraries, please check whether they are missing.

提示：当使用 [coolsnowwolf/lean](https://github.com/coolsnowwolf/lede/tree/master/package/lean/luci-lib-fs) 或 [Lienol/openwrt](https://github.com/Lienol/openwrt/tree/21.02/package/lean/luci-lib-fs) 的源码库进行 OpenWrt 编译时，无须单独添加此依赖。当使用其他源码库时请自行检查是否缺少。

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

- It is recommended to use the above compilation method to integrate during OpenWrt firmware compilation. The plug-in can be installed manually if it is not integrated in the OpenWrt firmware. First download the three ipk files of the latest plug-in in [Releases](https://github.com/ophub/luci-app-amlogic/releases), Upload these 3 ipk files to any directory in the OpenWrt system (such as `/tmp/upload/`), and then enter the following command to install (The directory `/tmp/upload/` in the following command should be replaced with the actual directory where the plug-in is located according to the actual situation): 

- 推荐使用上面的编译方法，在 OpenWrt 固件编译时集成。如果当前 OpenWrt 固件中未集成的也可以手动安装本插件。首先在 [Releases](https://github.com/ophub/luci-app-amlogic/releases) 中下载最新插件的 3 个 ipk 文件，并将此 3 个压缩包上传至 OpenWrt 系统的任意目录（如 `/tmp/upload/`），然后输入以下安装命令进行安装（下面命令中的目录 `/tmp/upload/` 请根据实际情况替换为插件压缩包所在的实际目录）：

```yaml
opkg --force-reinstall install /tmp/upload/*.ipk
```

## Screenshot / 截图

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/121277810-f9ebd800-c903-11eb-9bf4-7c2b11f9a1d3.gif)


## Config / 配置

The online update file download url of `OpenWrt firmware` and `kernel` can be customized as your own repository, and the config information is stored in the `/etc/config/amlogic` file of the OpenWrt system. Supports OpenWrt firmware packaged by [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) and [flippy](https://github.com/unifreq/openwrt_packit) scripts. It is recommended to use [flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions) for packaging when using the `flippy` script to package on `Github Actions`, which is simple and efficient.

插件里 `在线下载更新` 中的 `OpenWrt 固件` 及 `内核` 文件的下载地址支持自定义为自己的仓库，配置信息保存在 OpenWrt 系统的 `/etc/config/amlogic` 文件中。支持 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 和 [flippy](https://github.com/unifreq/openwrt_packit) 脚本打包的 OpenWrt 固件，使用 `flippy` 脚本在 `Github Actions` 打包时推荐使用 [flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions) 进行打包，简单高效。

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
- [tuanqing/mknop](https://github.com/tuanqing/mknop)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)

## License / 许可
- [LICENSE](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE) © OPHUB
