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
# Branch Selection: The 'JavaScript (main)' branch is downloaded by default.
#                   Use the '-b' parameter to specify other branches (e.g., 'lua').
# Commands:
#          curl -fsSL ophub.org/luci-app-amlogic | bash
#          curl -fsSL ophub.org/luci-app-amlogic | bash -s -- -b lua
#          curl -fsSL ophub.org/luci-app-amlogic | bash -s -- -b main
#
#==================================== Functions list ====================================
#
# process_msg      : Output process message
# parse_args       : Parse command-line arguments
# query_version    : Query the latest version
# download_plugin  : Download plug-in
# install_plugin   : Install plug-in
#
#============================ Set make environment variables ============================
#
# Set the plugin download directory
tmp_dir="/root"
# Set the default branch suffix (empty = JavaScript version, "lua" = Lua version)
branch_suffix=""
#
#========================================================================================

process_msg() {
    echo -e "${1}"
    [[ -n "${2}" && "${2}" -eq "1" ]] && exit 1
}

parse_args() {
    while [[ "${#}" -gt "0" ]]; do
        case "${1}" in
        -b | --branch)
            [[ "${2}" == "lua" ]] && branch_suffix="-lua"
            shift 2
            ;;
        *)
            shift
            ;;
        esac
    done
}

query_version() {
    process_msg "01. Start querying plugin version..."

    # Fetch all release tags once
    releases_html="$(curl -fsSL -m 10 https://github.com/ophub/luci-app-amlogic/releases)"

    # Select matching tags based on branch suffix
    if [[ "${branch_suffix}" == "-lua" ]]; then
        # Match tags ending with -lua (e.g. 3.1.301-lua)
        latest_version="$(
            echo "${releases_html}" |
                grep -oE 'expanded_assets/[0-9]+\.[0-9]+\.[0-9]+-lua' |
                sed 's|expanded_assets/||g' |
                sort -urV | head -n 1
        )"
    else
        # Match tags with digits only, no suffix (e.g. 3.1.301)
        latest_version="$(
            echo "${releases_html}" |
                grep -oE 'expanded_assets/[0-9]+\.[0-9]+\.[0-9]+' |
                sed 's|expanded_assets/||g' |
                grep -v -- '-' |
                sort -urV | head -n 1
        )"
    fi
    if [[ -z "${latest_version}" ]]; then
        process_msg "01.01 Query failed, please try again." "1"
    else
        process_msg "01.01 Latest version: ${latest_version}"
        sleep 2
    fi
}

download_plugin() {
    process_msg "02. Start downloading the latest plugin from tag: [ ${latest_version} ]..."

    # Delete other ipk files
    rm -f ${tmp_dir}/*.ipk ${tmp_dir}/*.apk

    # Check if the package manager is opkg or apk
    package_manager=""
    if command -v opkg >/dev/null 2>&1; then
        package_manager="ipk"
    elif command -v apk >/dev/null 2>&1; then
        package_manager="apk"
    else
        process_msg "02.01 No supported package manager found. Please install opkg or apk." "1"
    fi
    process_msg "02.01 Package manager: ${package_manager}"

    # Set the plugin download path
    download_repo="https://github.com/ophub/luci-app-amlogic/releases/download"

    # Intelligent File Discovery
    plugin_file_name=""
    lang_file_list=""

    # Use GitHub API with 'jq' to find package files
    if command -v jq >/dev/null 2>&1; then
        process_msg "02.02 Querying GitHub API for release assets..."
        api_url="https://api.github.com/repos/ophub/luci-app-amlogic/releases/tags/${latest_version}"

        # Fetch all asset names from the API
        asset_list="$(curl -fsSL -m 15 "${api_url}" | jq -r '.assets[].name' | xargs)"

        if [[ -n "${asset_list}" ]]; then
            # Discover exact filenames using regular expressions from the asset list
            plugin_file_name="$(echo "${asset_list}" | tr ' ' '\n' | grep -oE "^luci-app-amlogic.*${package_manager}$" | head -n 1)"
            lang_file_list=($(echo "${asset_list}" | tr ' ' '\n' | grep -oE "^luci-i18n-amlogic.*${package_manager}$"))
        else
            process_msg "02.02 Failed to fetch data from GitHub API." "1"
        fi
    else
        process_msg "02.02 jq not found, Aborting." "1"
    fi

    # Validation
    if [[ -z "${plugin_file_name}" || "${#lang_file_list[@]}" -eq "0" ]]; then
        process_msg "02.03 Could not discover plugin(.${package_manager}) in the release. Aborting." "1"
    fi

    process_msg "02.03 Found plugin file: ${plugin_file_name}"
    process_msg "02.04 Found language file: $(echo ${lang_file_list[@]} | xargs)"

    # Download the main plugin file
    plugin_full_url="${download_repo}/${latest_version}/${plugin_file_name}"
    process_msg "02.05 Downloading main plugin [ ${plugin_file_name} ]..."
    curl -fsSL "${plugin_full_url}" -o "${tmp_dir}/${plugin_file_name}"
    [[ "${?}" -ne "0" ]] && process_msg "02.05 Plugin [ ${plugin_file_name} ] download failed." "1"

    # Download language packs
    for langfile in "${lang_file_list[@]}"; do
        lang_full_url="${download_repo}/${latest_version}/${langfile}"
        process_msg "02.06 Downloading language pack [ ${langfile} ]..."
        curl -fsSL "${lang_full_url}" -o "${tmp_dir}/${langfile}"
        [[ "${?}" -ne "0" ]] && process_msg "02.06 Language pack [ ${langfile} ] download failed." "1"
    done

    # The .apk filename is preceded by a tilde (~) instead of a dot (.).
    for file in ${tmp_dir}/*.apk; do
        [[ -f "${file}" ]] || continue
        base_name="$(basename "${file}")"
        new_name="$(echo "${base_name}" | sed -E 's/\.([a-f0-9]{7}\.apk)/~\1/')"
        if [[ "${base_name}" != "${new_name}" ]]; then
            mv -f "${file}" "${tmp_dir}/${new_name}" || true
        fi
    done

    sync && sleep 2
}

install_plugin() {
    process_msg "03. Start installing plugins..."

    # Force plug-in reinstallation
    if [[ "${package_manager}" == "opkg" ]]; then
        process_msg "03.01 Installing with opkg..."
        opkg --force-reinstall install ${tmp_dir}/*.ipk
    elif [[ "${package_manager}" == "apk" ]]; then
        process_msg "03.01 Installing with apk..."
        apk add --force-overwrite --allow-untrusted ${tmp_dir}/*.apk
    fi

    # Delete cache file and leftover config conflict files
    rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null
    rm -f /etc/config/amlogic.apk-new /etc/config/amlogic.ipk-old 2>/dev/null
    rm -f ${tmp_dir}/*.ipk ${tmp_dir}/*.apk

    # Cross-branch cleanup: remove files from the other branch to avoid conflicts.
    # Detect the PKG_RELEASE of the newly installed package:
    #   release 2 = JS version  -> remove Lua frontend files
    #   release 1 = Lua version -> remove JS frontend files
    new_release=""
    if [[ "${package_manager}" == "opkg" ]]; then
        _raw="$(opkg list-installed | grep '^luci-app-amlogic ' | awk '{print $3}' | cut -d'-' -f2)"
        new_release="${_raw#r}"
    elif [[ "${package_manager}" == "apk" ]]; then
        new_release="$(apk list --installed 2>/dev/null | grep '^luci-app-amlogic-' | awk '{print $1}' | cut -d'-' -f5 | sed 's/^r//')"
    fi

    if [[ "${new_release}" == "2" ]]; then
        process_msg "03.02 JS version installed, removing leftover Lua frontend files..."
        rm -f /usr/lib/lua/luci/controller/amlogic.lua 2>/dev/null
        rm -rf /usr/lib/lua/luci/model/cbi/amlogic 2>/dev/null
        rm -rf /usr/lib/lua/luci/view/amlogic 2>/dev/null
    elif [[ "${new_release}" == "1" ]]; then
        process_msg "03.02 Lua version installed, removing leftover JS frontend files..."
        rm -f /usr/share/rpcd/ucode/luci.amlogic 2>/dev/null
        rm -f /www/luci-static/resources/view/amlogic/*.js 2>/dev/null
        rm -f /usr/share/luci/menu.d/luci-app-amlogic.json 2>/dev/null
    fi

    process_msg "03.03 The plugin has been installed successfully, Path: System -> Amlogic Service."
}

parse_args "${@}"
query_version
download_plugin
install_plugin

exit 0
