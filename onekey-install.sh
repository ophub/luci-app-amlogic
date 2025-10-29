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
    rm -f ${tmp_dir}/*.ipk ${tmp_dir}/*.apk

    # Check if the package manager is opkg or apk
    package_manager=""
    if command -v opkg >/dev/null 2>&1; then
        package_manager="ipk"
    elif command -v apk >/dev/null 2>&1; then
        package_manager="apk"
    else
        process_msg "No supported package manager found. Please install opkg or apk." "1"
    fi
    process_msg "package_manager: ${package_manager}"

    # Set the plugin download path
    download_repo="https://github.com/ophub/luci-app-amlogic/releases/download"

    # Intelligent File Discovery
    plugin_file_name=""
    lang_file_name=""

    # Method 1: Use GitHub API if 'jq' is installed (Preferred Method)
    if command -v jq >/dev/null 2>&1; then
        process_msg "Using GitHub API with jq to find package files."
        api_url="https://api.github.com/repos/ophub/luci-app-amlogic/releases/tags/${latest_version}"

        # Fetch all asset names from the API
        asset_list="$(curl -fsSL -m 15 "${api_url}" | jq -r '.assets[].name' | xargs)"

        if [[ -n "${asset_list}" ]]; then
            # Discover exact filenames using regular expressions from the asset list
            plugin_file_name="$(echo "${asset_list}" | tr ' ' '\n' | grep -oE "^luci-app-amlogic.*${package_manager}$" | head -n 1)"
            lang_file_name="$(echo "${asset_list}" | tr ' ' '\n' | grep -oE "^luci-i18n-amlogic-zh-cn.*${package_manager}$" | head -n 1)"
        else
            process_msg "Warning: Failed to fetch data from GitHub API." "1"
        fi
    else
        process_msg "jq not found, Aborting." "1"
    fi

    # Validation and Download
    if [[ -z "${plugin_file_name}" || -z "${lang_file_name}" ]]; then
        process_msg "Could not discover plugin(.${package_manager}) in the release. Aborting." "1"
    fi

    process_msg "02.01 Found plugin file: ${plugin_file_name}"
    process_msg "02.02 Found language file: ${lang_file_name}"

    plugin_full_url="${download_repo}/${latest_version}/${plugin_file_name}"
    lang_full_url="${download_repo}/${latest_version}/${lang_file_name}"

    # Download the main plugin file
    process_msg "02.03 Downloading main plugin..."
    curl -fsSL "${plugin_full_url}" -o "${tmp_dir}/${plugin_file_name}"
    if [[ "${?}" -ne "0" ]]; then
        process_msg "02.03 Plugin download failed." "1"
    fi

    # Download the language pack
    process_msg "02.04 Downloading language pack..."
    curl -fsSL "${lang_full_url}" -o "${tmp_dir}/${lang_file_name}"
    if [[ "${?}" -ne "0" ]]; then
        process_msg "02.04 Language pack download failed." "1"
    fi

    sync && sleep 2
}

install_plugin() {
    process_msg "03. Start installing plugins..."

    # Force plug-in reinstallation
    if [[ "${package_manager}" == "opkg" ]]; then
        opkg --force-reinstall install ${tmp_dir}/*.ipk
    elif [[ "${package_manager}" == "apk" ]]; then
        apk add --force-overwrite --allow-untrusted ${tmp_dir}/*.apk
    fi

    # Delete cache file
    rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null
    rm -f ${tmp_dir}/*.ipk ${tmp_dir}/*.apk

    process_msg "03.01 The plugin has been installed successfully, Path: System -> Amlogic Service."
}

query_version
download_plugin
install_plugin

exit 0
