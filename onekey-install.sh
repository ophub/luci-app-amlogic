#!/bin/bash
#========================================================================================
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# This file is a part of the luci-app-amlogic plugin
# https://github.com/ophub/luci-app-amlogic
#
# Description: Install luci-app-amlogic plugin for OpenWrt
# Copyright (C) 2021- https://github.com/unifreq/openwrt_packit
# Copyright (C) 2021- https://github.com/ophub/luci-app-amlogic
#
# Command: curl -fsSL git.io/luci-app-amlogic | bash
#
#==================================== Functions list ====================================
#
# process_msg      : Output process message
# query_version    : Query the latest version
# download_plugin  : Download plug-in
# install_plugin   : Install plug-in
#
#============================ Set make environment variables ============================
#
# Set a fixed value
tmp_dir="/root"
github_api_file="${tmp_dir}/github_api_file"
#
#========================================================================================

process_msg() {
    echo -e "${1}"
    [[ -z "${2}" ]] || exit 1
}

query_version() {
    process_msg "01. Query server version information."

    # Delete other ipk files
    rm -f ${github_api_file}

    # Call API interface to query plug-in information
    curl -s "https://api.github.com/repos/ophub/luci-app-amlogic/releases" >${github_api_file}
    sleep 1

    # Query the latest version
    plugin_version="$(cat ${github_api_file} | grep "tag_name" | awk -F '"' '{print $4}' | tr " " "\n" | sort -rV | head -n 1)"
    [[ -n "${plugin_version}" ]] || process_msg "01.01 Failed to get the version on the server." "1"
    process_msg "01.01 Latest version: ${plugin_version}"
}

download_plugin() {
    process_msg "02. Check the latest plug-in download address."

    # Delete other ipk files
    rm -f ${tmp_dir}/*.ipk

    # Get the plug-in download address
    plugin_url="https://github.com/ophub/luci-app-amlogic/releases/download"
    main_file="$(cat ${github_api_file} | grep -E "browser_.*${plugin_version}.*" | grep -oE "luci-app-amlogic_.*.ipk" | head -n 1)"
    language_file="$(cat ${github_api_file} | grep -E "browser_.*${plugin_version}.*" | grep -oE "luci-i18n-amlogic-zh-cn_.*.ipk" | head -n 1)"
    if [[ -n "${main_file}" && -n "${language_file}" ]]; then
        process_msg "02.01 Start downloading the latest plugin..."
    else
        process_msg "02.01 No available plug-in found!" "1"
    fi

    # Download the plug-in's ipk file
    wget "${plugin_url}/${plugin_version}/${main_file}" -O "${tmp_dir}/${main_file}"
    if [[ "${?}" -eq "0" && -s "${tmp_dir}/${main_file}" ]]; then
        process_msg "02.02 ${main_file} complete."
    else
        process_msg "02.02 The plugin file failed to download." "1"
    fi

    # Download the plug-in's i18n file
    wget "${plugin_url}/${plugin_version}/${language_file}" -O "${tmp_dir}/${language_file}"
    if [[ "${?}" -eq "0" && -s "${tmp_dir}/${language_file}" ]]; then
        process_msg "02.03 ${language_file} complete."
    else
        process_msg "02.03 The plugin i18n failed to download." "1"
    fi
}

install_plugin() {
    process_msg "03. Start automatic installation."

    # Force plug-in reinstallation
    opkg --force-reinstall install ${tmp_dir}/*.ipk

    # Delete cache file
    rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null
    rm -f ${tmp_dir}/*.ipk
    rm -f ${github_api_file}

    process_msg "03.01 The plugin has been installed successfully, Path: System -> Amlogic Service."
}

query_version
download_plugin
install_plugin

exit 0
