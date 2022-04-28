#!/bin/bash
#================================================================================
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# This file is a part of the luci-app-amlogic plugin
# https://github.com/ophub/luci-app-amlogic
#
# Description: Install luci-app-amlogic plugin for OpenWrt on amlogic s9xxx boxs
# Copyright (C) 2021- https://github.com/unifreq/openwrt_packit
# Copyright (C) 2021- https://github.com/ophub/luci-app-amlogic
#
# Command: curl -fsSL git.io/luci-app-amlogic | bash
#================================================================================

# Set a fixed value
TMP_CHECK_DIR="/root"
github_api_plugin="${TMP_CHECK_DIR}/github_api_plugin"
rm -f ${TMP_CHECK_DIR}/*.ipk && sync

# Log function
tolog() {
    echo -e "${1}"
    [[ -z "${2}" ]] || exit 1
}

# 01. Check the version on the server
tolog "01. Query server version information."

curl -s "https://api.github.com/repos/ophub/luci-app-amlogic/releases" >${github_api_plugin} && sync
sleep 1

server_plugin_version=$(cat ${github_api_plugin} | grep "tag_name" | awk -F '"' '{print $4}' | tr " " "\n" | sort -rV | head -n 1)
[ -n "${server_plugin_version}" ] || tolog "01.01 Failed to get the version on the server." "1"
tolog "01.01 Latest version: ${server_plugin_version}"
sleep 3

tolog "02. Check the latest plug-in download address."

server_plugin_url="https://github.com/ophub/luci-app-amlogic/releases/download"
server_plugin_file_ipk="$(cat ${github_api_plugin} | grep -E "browser_.*${server_plugin_version}.*" | grep -oE "luci-app-amlogic_.*.ipk" | head -n 1)"
server_plugin_file_i18n="$(cat ${github_api_plugin} | grep -E "browser_.*${server_plugin_version}.*" | grep -oE "luci-i18n-amlogic-zh-cn_.*.ipk" | head -n 1)"

if [[ -n "${server_plugin_file_ipk}" && -n "${server_plugin_file_i18n}" ]]; then
    tolog "02.01 Start downloading the latest plugin..."
else
    tolog "02.01 No available plugins found!" "1"
fi

# Download plugin ipk file
wget -c "${server_plugin_url}/${server_plugin_version}/${server_plugin_file_ipk}" -O "${TMP_CHECK_DIR}/${server_plugin_file_ipk}" >/dev/null 2>&1 && sync
if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${server_plugin_file_ipk}" ]]; then
    tolog "02.02 ${server_plugin_file_ipk} complete."
else
    tolog "02.02 The plugin file failed to download." "1"
fi
sleep 3

# Download plugin i18n file
wget -c "${server_plugin_url}/${server_plugin_version}/${server_plugin_file_i18n}" -O "${TMP_CHECK_DIR}/${server_plugin_file_i18n}" >/dev/null 2>&1 && sync
if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${server_plugin_file_i18n}" ]]; then
    tolog "02.03 ${server_plugin_file_i18n} complete."
else
    tolog "02.03 The plugin i18n failed to download." "1"
fi
sleep 3

# Automatic install
tolog "03. Start automatic installation."
opkg --force-reinstall install ${TMP_CHECK_DIR}/*.ipk >/dev/null 2>&1
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* >/dev/null 2>&1
rm -f ${TMP_CHECK_DIR}/*.ipk 2>/dev/null && sync
rm -f ${github_api_plugin} 2>/dev/null && sync
tolog "03.01 The plugin has been installed successfully."
tolog "03.02 Please login to OpenWrt -> system -> Amlogic Service."

exit 0
