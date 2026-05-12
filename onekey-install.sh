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
# Branch Selection: Auto-detected by default (Lua LuCI → lua branch, JS LuCI → js branch).
#                   Reads amlogic_plugin_branch from /etc/config/amlogic if no -b parameter.
#                   Use the '-b' parameter to override. Supported values: lua, js, javascript, main.
# Commands:
#          curl -fsSL ophub.org/luci-app-amlogic | bash
#          curl -fsSL ophub.org/luci-app-amlogic | bash -s -- -b lua
#          curl -fsSL ophub.org/luci-app-amlogic | bash -s -- -b js
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
# Set the default branch suffix (empty = Lua version, "-js" = JavaScript version)
# Will be auto-detected in parse_args if not specified by -b parameter
branch_suffix=""
# Whether branch was manually specified via -b
branch_manual=""
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
            branch_manual="${2,,}" # Convert to lowercase
            shift 2
            ;;
        *)
            shift
            ;;
        esac
    done

    # If not specified via -b, try reading from UCI config
    if [[ -z "${branch_manual}" ]]; then
        branch_manual="$(uci get amlogic.config.amlogic_plugin_branch 2>/dev/null | tr '[:upper:]' '[:lower:]' | xargs)"
    fi

    # Normalize branch aliases: js/javascript/main → js_request; lua → lua_request; * → auto-detect
    local is_js_request=""
    local is_lua_request=""
    case "${branch_manual}" in
    js | javascript | main)
        is_js_request="1"
        ;;
    lua)
        is_lua_request="1"
        ;;
    *)
        # Empty or unknown value → fall through to auto-detect
        ;;
    esac

    # Resolve final branch_suffix based on request + system capability
    if [[ -n "${is_js_request}" ]]; then
        # JS was requested, verify system supports it
        if [[ -f "/www/luci-static/resources/luci.js" ]]; then
            branch_suffix="-js"
            process_msg "01. JS branch selected, JS LuCI confirmed."
        else
            branch_suffix=""
            process_msg "01. Warning: JS LuCI not found, falling back to Lua branch."
        fi
    elif [[ -n "${is_lua_request}" ]]; then
        branch_suffix=""
        process_msg "01. Lua branch selected."
    else
        # No valid branch specified anywhere, auto-detect from system
        if [[ -f "/www/luci-static/resources/luci.js" ]]; then
            branch_suffix="-js"
            process_msg "01. Detected JS LuCI, auto-selecting JS branch."
        else
            branch_suffix=""
            process_msg "01. Detected Lua LuCI, auto-selecting Lua branch."
        fi
    fi
}

query_version() {
    process_msg "02. Start querying plugin version..."

    # Fetch all release tags once
    releases_html="$(curl -fsSL -m 10 https://github.com/ophub/luci-app-amlogic/releases)"

    # Select matching tags based on branch suffix
    if [[ "${branch_suffix}" == "-js" ]]; then
        # Match tags ending with -js (e.g. 3.1.301-js)
        latest_version="$(
            echo "${releases_html}" |
                grep -oE 'expanded_assets/[0-9]+\.[0-9]+\.[0-9]+-js' |
                sed 's|expanded_assets/||g' |
                sort -urV | head -n 1
        )"
    else
        # Match tags with digits only, no suffix (e.g. 3.1.301) → Lua version
        latest_version="$(
            echo "${releases_html}" |
                grep -oE 'expanded_assets/[0-9]+\.[0-9]+\.[0-9]+' |
                sed 's|expanded_assets/||g' |
                grep -v -- '-' |
                sort -urV | head -n 1
        )"
    fi
    if [[ -z "${latest_version}" ]]; then
        process_msg "02.01 Query failed, please try again." "1"
    else
        process_msg "02.01 Latest version: ${latest_version}"
        sleep 2
    fi
}

download_plugin() {
    process_msg "03. Start downloading the latest plugin from tag: [ ${latest_version} ]..."

    # Delete other ipk files
    rm -f ${tmp_dir}/*.ipk ${tmp_dir}/*.apk

    # Check if the package manager is opkg or apk
    package_manager=""
    if command -v opkg >/dev/null 2>&1; then
        package_manager="ipk"
    elif command -v apk >/dev/null 2>&1; then
        package_manager="apk"
    else
        process_msg "03.01 No supported package manager found. Please install opkg or apk." "1"
    fi
    process_msg "03.01 Package manager: ${package_manager}"

    # Set the plugin download path
    download_repo="https://github.com/ophub/luci-app-amlogic/releases/download"

    # Intelligent File Discovery
    plugin_file_name=""
    lang_file_list=""

    # Use GitHub API with 'jq' to find package files
    if command -v jq >/dev/null 2>&1; then
        process_msg "03.02 Querying GitHub API for release assets..."
        api_url="https://api.github.com/repos/ophub/luci-app-amlogic/releases/tags/${latest_version}"

        # Fetch all asset names from the API
        asset_list="$(curl -fsSL -m 15 "${api_url}" | jq -r '.assets[].name' | xargs)"

        if [[ -n "${asset_list}" ]]; then
            # Discover exact filenames using regular expressions from the asset list
            plugin_file_name="$(echo "${asset_list}" | tr ' ' '\n' | grep -oE "^luci-app-amlogic.*${package_manager}$" | head -n 1)"
            lang_file_list=($(echo "${asset_list}" | tr ' ' '\n' | grep -oE "^luci-i18n-amlogic.*${package_manager}$"))
        else
            process_msg "03.02 Failed to fetch data from GitHub API." "1"
        fi
    else
        process_msg "03.02 jq not found, Aborting." "1"
    fi

    # Validation: main plugin is required; language packs are optional
    if [[ -z "${plugin_file_name}" ]]; then
        process_msg "03.03 Could not discover plugin(.${package_manager}) in the release. Aborting." "1"
    fi

    process_msg "03.03 Found plugin file: ${plugin_file_name}"
    process_msg "03.04 Found language file: $(echo ${lang_file_list[@]} | xargs)"

    # Download the main plugin file
    plugin_full_url="${download_repo}/${latest_version}/${plugin_file_name}"
    process_msg "03.05 Downloading main plugin [ ${plugin_file_name} ]..."
    curl -fsSL "${plugin_full_url}" -o "${tmp_dir}/${plugin_file_name}"
    [[ "${?}" -ne "0" ]] && process_msg "03.05 Plugin [ ${plugin_file_name} ] download failed." "1"

    # Download language packs
    for langfile in "${lang_file_list[@]}"; do
        lang_full_url="${download_repo}/${latest_version}/${langfile}"
        process_msg "03.06 Downloading language pack [ ${langfile} ]..."
        curl -fsSL "${lang_full_url}" -o "${tmp_dir}/${langfile}"
        [[ "${?}" -ne "0" ]] && process_msg "03.06 Language pack [ ${langfile} ] download failed." "1"
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
    process_msg "04. Start installing plugins..."

    # Detect the PKG_RELEASE of the newly downloaded package to determine branch:
    #   release 2 = JS version (main branch)
    #   release 1 = Lua version (lua branch)
    new_release=""
    if [[ "${package_manager}" == "ipk" ]]; then
        _ipk_file="$(ls ${tmp_dir}/luci-app-amlogic_*.ipk 2>/dev/null | head -n 1)"
        new_release="$(echo "${_ipk_file}" | grep -oE '\-r[0-9]+_' | grep -oE '[0-9]+')"
    elif [[ "${package_manager}" == "apk" ]]; then
        _apk_file="$(ls ${tmp_dir}/luci-app-amlogic_*.apk 2>/dev/null | head -n 1)"
        new_release="$(echo "${_apk_file}" | grep -oE '\-r[0-9]+[-~]' | grep -oE '[0-9]+')"
    fi

    # Detect the PKG_RELEASE of the currently installed package
    cur_release=""
    if [[ "${package_manager}" == "ipk" ]]; then
        _raw="$(opkg list-installed 2>/dev/null | grep '^luci-app-amlogic ' | awk '{print $3}' | cut -d'-' -f2)"
        cur_release="${_raw#r}"
    elif [[ "${package_manager}" == "apk" ]]; then
        cur_release="$(apk list --installed 2>/dev/null | grep '^luci-app-amlogic-' | awk '{print $1}' | cut -d'-' -f5 | sed 's/^r//')"
    fi

    # When switching branches (r1<->r2), remove the old package first so that
    # opkg/apk registers all new files correctly.
    # NOTE: plain 'opkg remove' does NOT remove dependency packages (curl, jq, etc.);
    #       only --autoremove would do that. This is intentionally NOT used here.
    if [[ -n "${cur_release}" && -n "${new_release}" && "${cur_release}" != "${new_release}" ]]; then
        process_msg "04.01 Branch switch detected (r${cur_release} -> r${new_release}), removing old package first..."
        if [[ "${package_manager}" == "ipk" ]]; then
            opkg remove luci-app-amlogic --force-depends 2>/dev/null || true
        elif [[ "${package_manager}" == "apk" ]]; then
            apk del luci-app-amlogic 2>/dev/null || true
        fi
        process_msg "04.01 Old package removed (dependencies kept)."
    fi

    # Install the new package
    if [[ "${package_manager}" == "ipk" ]]; then
        process_msg "04.02 Installing with opkg..."
        opkg --force-reinstall --force-downgrade install ${tmp_dir}/*.ipk
        [[ "${?}" -ne "0" ]] && process_msg "04.02 Installation failed." "1"
    elif [[ "${package_manager}" == "apk" ]]; then
        process_msg "04.02 Installing with apk..."
        apk add --force-overwrite --allow-untrusted ${tmp_dir}/*.apk
        [[ "${?}" -ne "0" ]] && process_msg "04.02 Installation failed." "1"
    fi

    # Delete cache file and leftover config conflict files
    rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null
    rm -f /etc/config/amlogic.apk-new /etc/config/amlogic.ipk-old /etc/config/amlogic-opkg 2>/dev/null
    rm -f ${tmp_dir}/*.ipk ${tmp_dir}/*.apk

    # Cross-branch cleanup: remove files from the other branch to avoid conflicts.
    # new_release was already detected above before installation.
    if [[ "${new_release}" == "2" ]]; then
        process_msg "04.03 JS version installed, removing leftover Lua frontend files..."
        rm -f /usr/lib/lua/luci/controller/amlogic.lua 2>/dev/null
        rm -rf /usr/lib/lua/luci/model/cbi/amlogic 2>/dev/null
        rm -rf /usr/lib/lua/luci/view/amlogic 2>/dev/null
    elif [[ "${new_release}" == "1" ]]; then
        process_msg "04.03 Lua version installed, removing leftover JS frontend files..."
        rm -f /usr/share/rpcd/ucode/luci.amlogic 2>/dev/null
        rm -f /www/luci-static/resources/view/amlogic/*.js 2>/dev/null
        rm -f /usr/share/luci/menu.d/luci-app-amlogic.json 2>/dev/null
    fi

    # Update plugin branch in UCI config to match what was actually installed.
    # Always overwrite so that branch switches (Lua<->JS) are reflected correctly.
    # Guard: only write when new_release was successfully detected; if detection
    # failed (empty string) we must not silently overwrite a valid 'main' config.
    if [[ -n "${new_release}" ]]; then
        if [[ "${new_release}" == "2" ]]; then
            uci set amlogic.config.amlogic_plugin_branch='main' 2>/dev/null
        else
            uci set amlogic.config.amlogic_plugin_branch='lua' 2>/dev/null
        fi
        uci commit amlogic 2>/dev/null
    fi

    process_msg "04.04 The plugin has been installed successfully, Path: System -> Amlogic Service."
}

parse_args "${@}"
query_version
download_plugin
install_plugin

exit 0
