#!/bin/bash

# Set a fixed value
EMMC_NAME=$(lsblk | grep -oE '(mmcblk[0-9])' | sort | uniq)
KERNEL_DOWNLOAD_PATH="/mnt/${EMMC_NAME}p4"
TMP_CHECK_DIR="/tmp/amlogic"
START_LOG="${TMP_CHECK_DIR}/amlogic_check_kernel.log"
LOG_FILE="${TMP_CHECK_DIR}/amlogic.log"
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
    CURRENT_KERNEL_V=$(ls /lib/modules/  2>/dev/null | grep -oE '^[1-9].[0-9]{1,2}.[0-9]+')
    tolog "01.01 current version: ${CURRENT_KERNEL_V}"
    sleep 3

    # 02. Download server version documentation
    tolog "02. Start checking the kernel version."
    SERVER_FIRMWARE_URL=$(uci get amlogic.config.amlogic_firmware_repo 2>/dev/null)
    [[ ! -z "${SERVER_FIRMWARE_URL}" ]] || tolog "02.01 The custom kernel download repo is invalid." "1"
    SERVER_KERNEL_PATH=$(uci get amlogic.config.amlogic_kernel_path 2>/dev/null)
    [[ ! -z "${SERVER_KERNEL_PATH}" ]] || tolog "02.02 The custom kernel download path is invalid." "1"

    SERVER_KERNEL_URL="https://api.github.com/repos/${SERVER_FIRMWARE_URL}/contents/${SERVER_KERNEL_PATH}"

    # 03. Version comparison
    tolog "03. Compare versions."
    MAIN_LINE_M=$(echo "${CURRENT_KERNEL_V}" | cut -d '.' -f1)
    MAIN_LINE_V=$(echo "${CURRENT_KERNEL_V}" | cut -d '.' -f2)
    MAIN_LINE_S=$(echo "${CURRENT_KERNEL_V}" | cut -d '.' -f3)
    MAIN_LINE="${MAIN_LINE_M}.${MAIN_LINE_V}"

    # Check the version on the server
    LATEST_VERSION=$(curl -s "${SERVER_KERNEL_URL}" | grep "name" | grep -oE "${MAIN_LINE}.[0-9]+"  | sed -e "s/${MAIN_LINE}.//g" | sort -n | sed -n '$p')
    #LATEST_VERSION="124"
    [[ ! -z "${LATEST_VERSION}" ]] || tolog "03.01 Failed to get the version on the server." "1"
    tolog "03.02 current version: ${CURRENT_KERNEL_V}, Latest version: ${MAIN_LINE}.${LATEST_VERSION}"
    sleep 3

    if [[ "${LATEST_VERSION}" -le "${MAIN_LINE_S}" ]]; then
        tolog "03.02 Already the latest version, no need to update." "1"
        sleep 5
        tolog ""
    else
        tolog "03.03 Automatically download the latest kernel."
        sleep 3

        # Delete other residual kernel files
        rm -f ${KERNEL_DOWNLOAD_PATH}/boot-*.tar.gz && sync
        rm -f ${KERNEL_DOWNLOAD_PATH}/dtb-amlogic-*.tar.gz && sync
        rm -f ${KERNEL_DOWNLOAD_PATH}/modules-*.tar.gz && sync

        # Download boot file
        SERVER_KERNEL_BOOT="$(curl -s "${SERVER_KERNEL_URL}/${MAIN_LINE}.${LATEST_VERSION}" | grep "download_url" | grep -o "https.*/boot-.*.tar.gz" | head -n 1)"
        SERVER_KERNEL_BOOT_NAME="${SERVER_KERNEL_BOOT##*/}"
        SERVER_KERNEL_BOOT_NAME="${SERVER_KERNEL_BOOT_NAME//%2B/+}"
        wget -c "${SERVER_KERNEL_BOOT}" -O "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_BOOT_NAME}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" ]]; then
            tolog "03.04 The boot file complete."
        else
            tolog "03.05 The boot file failed to download." "1"
        fi
        sleep 3

        # Download dtb file
        SERVER_KERNEL_DTB="$(curl -s "${SERVER_KERNEL_URL}/${MAIN_LINE}.${LATEST_VERSION}" | grep "download_url" | grep -o "https.*/dtb-amlogic-.*.tar.gz" | head -n 1)"
        SERVER_KERNEL_DTB_NAME="${SERVER_KERNEL_DTB##*/}"
        SERVER_KERNEL_DTB_NAME="${SERVER_KERNEL_DTB_NAME//%2B/+}"
        wget -c "${SERVER_KERNEL_DTB}" -O "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_DTB_NAME}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" ]]; then
            tolog "03.06 The dtb file complete."
        else
            tolog "03.07 The dtb file failed to download." "1"
        fi
        sleep 3

        # Download modules file
        SERVER_KERNEL_MODULES="$(curl -s "${SERVER_KERNEL_URL}/${MAIN_LINE}.${LATEST_VERSION}" | grep "download_url" | grep -o "https.*/modules-.*.tar.gz" | head -n 1)"
        SERVER_KERNEL_MODULES_NAME="${SERVER_KERNEL_MODULES##*/}"
        SERVER_KERNEL_MODULES_NAME="${SERVER_KERNEL_MODULES_NAME//%2B/+}"
        wget -c "${SERVER_KERNEL_MODULES}" -O "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_MODULES_NAME}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" ]]; then
            tolog "03.08 The modules file complete."
        else
            tolog "03.09 The modules file failed to download." "1"
        fi
        sleep 3
    fi

    tolog "04 The kernel is ready, you can update."
    sleep 3

    #echo '<a href="javascript:;" onclick="return amlogic_kernel(this)">Update</a>' >$START_LOG
    tolog '<input type="button" class="cbi-button cbi-button-reload" value="Update" onclick="return amlogic_kernel(this)"/>'

    exit 0

