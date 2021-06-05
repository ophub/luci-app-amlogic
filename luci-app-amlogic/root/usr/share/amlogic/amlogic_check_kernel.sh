#!/bin/bash

# Set a fixed value
EMMC_NAME=$(lsblk | grep -oE '(mmcblk[0-9])' | sort | uniq)
KERNEL_DOWNLOAD_PATH="/mnt/${EMMC_NAME}p4"
TMP_CHECK_DIR="/tmp/amlogic"
START_LOG=${TMP_CHECK_DIR}"/amlogic_check_kernel.log"
LOG_FILE=${TMP_CHECK_DIR}"/amlogic.log"
TMP_CHECK_SERVER_FILE=${TMP_CHECK_DIR}"/amlogic_check_server_kernel_file.txt"
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
[[ -d ${KERNEL_DOWNLOAD_PATH} ]] || mkdir -p ${KERNEL_DOWNLOAD_PATH}
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
    CONFIG_CHECK_URL=$(uci get amlogic.config.amlogic_check_url 2>/dev/null)
    [[ ! -z "${CONFIG_CHECK_URL}" ]] || tolog "02.01 Invalid kernel download address." "1"
    rm -f "${TMP_CHECK_SERVER_FILE}" >/dev/null 2>&1 && sync
    wget -c "${CONFIG_CHECK_URL}" -O "${TMP_CHECK_SERVER_FILE}" >/dev/null 2>&1 && sync
    [[ -s ${TMP_CHECK_SERVER_FILE} ]] || tolog "02.02 Invalid kernel detection file." "1"

    source ${TMP_CHECK_SERVER_FILE} 2>/dev/null
    SERVER_KERNEL_URL=${amlogic_kernel_url}
    [[ ! -z "${SERVER_KERNEL_URL}" ]] || tolog "02.03 The custom kernel download address is invalid." "1"

    # 03. Version comparison
    tolog "03. Compare versions."
    MAIN_LINE_V=$(echo "${CURRENT_KERNEL_V}" | cut -d '.' -f2)
    if [[ "${MAIN_LINE_V}" -gt "0" ]]; then
        case "${MAIN_LINE_V}" in
            10) SERVER_KERNEL_VERSION=${amlogic_kernel_0510_version}
                SERVER_KERNEL_BOOT=${amlogic_kernel_0510_boot}
                SERVER_KERNEL_DTB=${amlogic_kernel_0510_dtb}
                SERVER_KERNEL_MODULES=${amlogic_kernel_0510_modules}
                ;;
            11) SERVER_KERNEL_VERSION=${amlogic_kernel_0511_version}
                SERVER_KERNEL_BOOT=${amlogic_kernel_0511_boot}
                SERVER_KERNEL_DTB=${amlogic_kernel_0511_dtb}
                SERVER_KERNEL_MODULES=${amlogic_kernel_0511_modules}
                ;;
            12) SERVER_KERNEL_VERSION=${amlogic_kernel_0512_version}
                SERVER_KERNEL_BOOT=${amlogic_kernel_0512_boot}
                SERVER_KERNEL_DTB=${amlogic_kernel_0512_dtb}
                SERVER_KERNEL_MODULES=${amlogic_kernel_0512_modules}
                ;;
            13) SERVER_KERNEL_VERSION=${amlogic_kernel_0513_version}
                SERVER_KERNEL_BOOT=${amlogic_kernel_0513_boot}
                SERVER_KERNEL_DTB=${amlogic_kernel_0513_dtb}
                SERVER_KERNEL_MODULES=${amlogic_kernel_0513_modules}
                ;;
             *) SERVER_KERNEL_VERSION=${amlogic_kernel_0504_version}
                SERVER_KERNEL_BOOT=${amlogic_kernel_0504_boot}
                SERVER_KERNEL_DTB=${amlogic_kernel_0504_dtb}
                SERVER_KERNEL_MODULES=${amlogic_kernel_0504_modules}
                ;;
        esac
        SERVER_KERNEL_VERSION_CODE=${SERVER_KERNEL_VERSION/.TF/}
        tolog "03.01 current version: ${CURRENT_KERNEL_V}, Latest version: ${SERVER_KERNEL_VERSION_CODE}"
        sleep 3
    else
        tolog "03.02 Failed to check kernel version." "1"
    fi

    if [[ "${CURRENT_KERNEL_V}" == "${SERVER_KERNEL_VERSION_CODE}" ]]; then
        tolog "03.03 The same version, no need to update." "1"
        sleep 5
        tolog ""
    else
        tolog "03.04 Automatically download the latest kernel."

        # Download boot file
        wget -c "${SERVER_KERNEL_URL}/${SERVER_KERNEL_VERSION}/${SERVER_KERNEL_BOOT}" -O "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_BOOT}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" && -s "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_BOOT}" ]]; then
            tolog "03.05 ${SERVER_KERNEL_BOOT} complete."
        else
            tolog "03.06 The boot file failed to download." "1"
        fi
        sleep 3

        # Download dtb file
        wget -c "${SERVER_KERNEL_URL}/${SERVER_KERNEL_VERSION}/${SERVER_KERNEL_DTB}" -O "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_DTB}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" && -s "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_DTB}" ]]; then
            tolog "03.07 ${SERVER_KERNEL_DTB} complete."
        else
            tolog "03.08 The dtb file failed to download." "1"
        fi
        sleep 3

        # Download modules file
        wget -c "${SERVER_KERNEL_URL}/${SERVER_KERNEL_VERSION}/${SERVER_KERNEL_MODULES}" -O "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_MODULES}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" && -s "${KERNEL_DOWNLOAD_PATH}/${SERVER_KERNEL_MODULES}" ]]; then
            tolog "03.09 ${SERVER_KERNEL_MODULES} complete."
        else
            tolog "03.10 The modules file failed to download." "1"
        fi
        sleep 3
    fi

    tolog "04 The kernel is ready, you can update."
    sleep 3

    rm -rf ${TMP_CHECK_SERVER_FILE} >/dev/null 2>&1 && sync
    #echo '<a href="javascript:;" onclick="return amlogic_kernel(this)">Update</a>' >$START_LOG
    echo '<input type="button" class="cbi-button cbi-button-reload" value="Update" onclick="return amlogic_kernel(this)"/>' >$START_LOG

    exit 0

