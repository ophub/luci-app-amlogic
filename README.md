
# luci-app-amlogic

Provide luci operation support for Amlogic STB. The current functions include `install OpenWrt to EMMC`, `update the kernel`, and `backup/restore config`.

为 Amlogic 系列盒子提供 luci 操作支持。目前的功能有 `安装 OpenWrt 至 EMMC`，`升级内核版本`，`备份/恢复个性化配置`。

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

## Screenshot / 截图

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/118104028-30215f00-b40d-11eb-9612-6b3bb1742916.gif)

## Next version function / 下一版本功能预告

- Increase the online query service of the latest version of the kernel, and you can choose to upgrade online.
- 提供内核版本在线提醒和选择安装。

## Reference statement / 借鉴申明

This plug-in mainly integrates the file upload functions of luci-app-filetransfer, Used Flippy's kernel and scripts, Drawing on the source code of multiple plug-ins, etc. Thanks hereby.

本插件主要整合了 luci-app-filetransfer 的文件上传等功能，使用了 Flippy 的内核及脚本等，借鉴了多个插件的源码。特此鸣谢。

## Tip / 提示

The Luci operation is a visual operation of the execution of the script. In theory, the result is exactly the same as the result of the execution of the script. However, since it is currently in the testing period, please use it with caution.

Luci 操作是对执行脚本的可视化操作，理论上和执行脚本的结果是完全一样的，但鉴于当前属于测试期，请谨慎使用。

## Acknowledgments

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [Lienol/openwrt](https://github.com/Lienol/openwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [tuanqing/mknop](https://github.com/tuanqing/mknop)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)

## License

[LICENSE](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE) © OPHUB

