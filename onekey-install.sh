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
# Set the plugin download directory
tmp_dir="/root"
#
#========================================================================================

process_msg() {
    echo -e "${1}"
    [[ -n "${2}" && "${2}" -eq "1" ]] && exit 1
}

query_version() {
    process_msg "01. Start querying plugin version..."

    # Get the latest version
    latest_version="$(
        curl -fsSL -m 10 \
            https://github.com/ophub/luci-app-amlogic/releases |
            grep -oE 'expanded_assets/[0-9]+.[0-9]+.[0-9]+(-[0-9]+)?' | sed 's|expanded_assets/||g' |
            sort -urV | head -n 1
    )"
    if [[ -z "${latest_version}" ]]; then
        process_msg "01.01 Query failed, please try again." "1"
    else
        process_msg "01.01 Latest version: ${latest_version}"
        sleep 2
    fi
}

download_plugin() {
    process_msg "02. Start downloading the latest plugin..."

    # Delete other ipk files
    rm -f ${tmp_dir}/*.ipk 2>/dev/null

    # Set the plugin download path
    download_repo="https://github.com/ophub/luci-app-amlogic/releases/download"
    plugin_file="${download_repo}/${latest_version}/luci-app-amlogic_${latest_version}_all.ipk"
    language_file="${download_repo}/${latest_version}/luci-i18n-amlogic-zh-cn_${latest_version}_all.ipk"

    # Download the plug-in's ipk file
    curl -fsSL "${plugin_file}" -o "${tmp_dir}/luci-app-amlogic_${latest_version}_all.ipk"
    if [[ "${?}" -eq "0" ]]; then
        process_msg "02.01 Plugin downloaded successfully."
    else
        process_msg "02.01 Plugin download failed." "1"
    fi

    # Download the plug-in's i18n file
    curl -fsSL "${language_file}" -o "${tmp_dir}/luci-i18n-amlogic-zh-cn_${latest_version}_all.ipk"
    if [[ "${?}" -eq "0" ]]; then
        process_msg "02.02 Language pack downloaded successfully."
    else
        process_msg "02.02 Language pack download failed." "1"
    fi

    sync && sleep 2
}

install_plugin() {
    process_msg "03. Start installing plugins..."

    # Force plug-in reinstallation
    opkg --force-reinstall install ${tmp_dir}/*.ipk

    # Delete cache file
    rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null
    rm -f ${tmp_dir}/*.ipk

    process_msg "03.01 The plugin has been installed successfully, Path: System -> Amlogic Service."
}

query_version
download_plugin
install_plugin

exit 0
