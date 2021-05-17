#!/bin/bash

# Set a fixed value
TMP_CHECK_DIR="/tmp/amlogic"
START_LOG=${TMP_CHECK_DIR}"/amlogic_check_plugin.log"
LOG_FILE=${TMP_CHECK_DIR}"/amlogic.log"
TMP_CHECK_SERVER_FILE=${TMP_CHECK_DIR}"/amlogic_check_server_plugin_file.txt"
KERNEL_DOWNLOAD_PATH="/tmp/upload"
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
[[ -d ${TMP_CHECK_DIR} ]] || mkdir -p ${TMP_CHECK_DIR}

# Log function
tolog() {
    echo -e "${1}" >$START_LOG
    echo -e "${LOGTIME} ${1}" >>$LOG_FILE
    [[ -z "${2}" ]] || exit 1
}

    # 01. Query local version information
    tolog "01. Query version information."
    CURRENT_PLUGIN_V=$(uci get amlogic.config.amlogic_plugin_version 2>/dev/null)
    tolog "01.01 current version: ${CURRENT_PLUGIN_V}"
    sleep 3

    # 02. Download server version documentation
    tolog "02. Start checking the plugin version."
    CONFIG_PLUGIN_URL=$(uci get amlogic.config.amlogic_plugin_url 2>/dev/null)
    [[ ! -z "${CONFIG_PLUGIN_URL}" ]] || tolog "02.01 Invalid plugin download address." "1"
    rm -f "${TMP_CHECK_SERVER_FILE}" >/dev/null 2>&1 && sync
    curl -sL --connect-timeout 10 --retry 2 --retry-all-errors "${CONFIG_PLUGIN_URL}" -o "${TMP_CHECK_SERVER_FILE}" >/dev/null 2>&1 && sync
    [[ -s ${TMP_CHECK_SERVER_FILE} ]] || tolog "02.02 Invalid plugin detection file." "1"

    source ${TMP_CHECK_SERVER_FILE} 2>/dev/null
    SERVER_PLUGIN_URL=${amlogic_plugin_url}
    [[ ! -z "${SERVER_PLUGIN_URL}" ]] || tolog "02.03 The custom plugin download address is invalid." "1"
    SERVER_PLUGIN_VERSION=${amlogic_plugin_version}
    [[ ! -z "${SERVER_PLUGIN_VERSION}" ]] || tolog "02.04 The custom plugin version is invalid." "1"
    SERVER_PLUGIN_FILE=${amlogic_plugin_file}
    [[ ! -z "${SERVER_PLUGIN_FILE}" ]] || tolog "02.05 The custom plugin file is invalid." "1"

    # 03. Version comparison
    tolog "03 current version: ${CURRENT_PLUGIN_V}, Latest version: ${SERVER_PLUGIN_VERSION}"
    sleep 3

    if [[ "${CURRENT_PLUGIN_V}" == "${SERVER_PLUGIN_VERSION}" ]]; then
        tolog "03.01 The same version, no need to update." "1"
        sleep 5
        tolog ""
    else
        tolog "03.02 Automatically download the latest plugin."
        # Download plugin file
        curl -sL --connect-timeout 10 --retry 2 --retry-all-errors "${SERVER_PLUGIN_URL}/${SERVER_PLUGIN_VERSION}/${SERVER_PLUGIN_FILE}" -o "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${SERVER_PLUGIN_FILE}" ]]; then
            tolog "03.03 ${SERVER_PLUGIN_FILE} complete."
        else
            tolog "03.04 The plugin file failed to download." "1"
        fi
        sleep 3
    fi

    # 04. Move to the ${KERNEL_DOWNLOAD_PATH} directory to prepare for the update kernel
    gzip -df ${TMP_CHECK_DIR}/*.gz && sync
    mv -f ${TMP_CHECK_DIR}/*.ipk ${KERNEL_DOWNLOAD_PATH} >/dev/null 2>&1 && sync
    tolog "04 The plug is ready, you can update."
    sleep 3

    rm -rf ${TMP_CHECK_SERVER_FILE} >/dev/null 2>&1
    echo '<a href=upload>Update</a>' >$START_LOG

    #luci.http.redirect(luci.dispatcher.build_url("admin", "system", "amlogic", "upload"))
