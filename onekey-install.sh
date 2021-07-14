#!/bin/bash
#=================================================================================================================
# https://github.com/ophub/luci-app-amlogic
# Description: Support install OpenWrt to EMMC, update the OpenWrt firmware or kernel, and backup/restore config.
#=================================================================================================================

# Set a fixed value
TMP_CHECK_DIR="/root"
rm -f ${TMP_CHECK_DIR}/*.ipk && sync

# Log function
tolog() {
    echo -e "${1}"
    [[ -z "${2}" ]] || exit 1
}

    # 02. Check the version on the server
    tolog "01. Query server version information."
    SERVER_PLUGIN_VERSION=$(curl -i -s "https://api.github.com/repos/ophub/luci-app-amlogic/releases" | grep "tag_name" | head -n 1 | grep -oE "[0-9]{1,3}.[0-9]{1,3}-[0-9]+")
    [ -n "${SERVER_PLUGIN_VERSION}" ] || tolog "02.01 Failed to get the version on the server." "1"
    tolog "01.01 Latest version: ${SERVER_PLUGIN_VERSION}"
    sleep 3

    tolog "02. Automatically download the latest plugin."
    SERVER_PLUGIN_URL="https://github.com/ophub/luci-app-amlogic/releases/download"
    SERVER_PLUGIN_FILE_IPK="luci-app-amlogic_${SERVER_PLUGIN_VERSION}_all.ipk"
    SERVER_PLUGIN_FILE_I18N="luci-i18n-amlogic-zh-cn_${SERVER_PLUGIN_VERSION}_all.ipk"
    SERVER_PLUGIN_FILE_LIBFS="luci-lib-fs_1.0-1_all.ipk"

    # Download plugin ipk file
    wget -c "${SERVER_PLUGIN_URL}/${SERVER_PLUGIN_VERSION}/${SERVER_PLUGIN_FILE_IPK}" -O "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE_IPK}" >/dev/null 2>&1 && sync
    if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE_IPK}" ]]; then
        tolog "02.01 ${SERVER_PLUGIN_FILE_IPK} complete."
    else
        tolog "02.01 The plugin file failed to download." "1"
    fi
    sleep 3

    # Download plugin i18n file
    wget -c "${SERVER_PLUGIN_URL}/${SERVER_PLUGIN_VERSION}/${SERVER_PLUGIN_FILE_I18N}" -O "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE_I18N}" >/dev/null 2>&1 && sync
    if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE_I18N}" ]]; then
        tolog "02.02 ${SERVER_PLUGIN_FILE_I18N} complete."
    else
        tolog "02.02 The plugin i18n failed to download." "1"
    fi
    sleep 3

    # Download plugin lib-fs file
    wget -c "${SERVER_PLUGIN_URL}/${SERVER_PLUGIN_VERSION}/${SERVER_PLUGIN_FILE_LIBFS}" -O "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE_LIBFS}" >/dev/null 2>&1 && sync
    if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE_LIBFS}" ]]; then
        tolog "02.03 ${SERVER_PLUGIN_FILE_LIBFS} complete."
    else
        tolog "02.03 The plugin i18n failed to download." "1"
    fi
    sleep 3

    # Automatic install
    tolog "03. Start automatic installation."
    opkg --force-reinstall install ${TMP_CHECK_DIR}/*.ipk >/dev/null 2>&1
    rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* >/dev/null 2>&1
    rm -f ${TMP_CHECK_DIR}/*.ipk 2>/dev/null && sync
    tolog "03.01 The plugin has been installed successfully."
    tolog "03.02 Please login to OpenWrt -> system -> Amlogic Service."

    exit 0

