#!/bin/bash

# Set a fixed value
TMP_CHECK_DIR="/tmp/amlogic"
START_LOG=${TMP_CHECK_DIR}"/amlogic_check_kernel.log"
LOG_FILE=${TMP_CHECK_DIR}"/amlogic.log"
TMP_CHECK_SERVER_FILE=${TMP_CHECK_DIR}"/amlogic_check_server_kernel_file.txt"
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
    CURRENT_KERNEL_V=$(ls /lib/modules/  2>/dev/null | grep -oE '^[1-9].[0-9]{1,2}.[0-9]+')
    uci set amlogic.config.amlogic_kernel_version="${CURRENT_KERNEL_V}" 2>/dev/null
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
        wget -c "${SERVER_KERNEL_URL}/${SERVER_KERNEL_VERSION}/${SERVER_KERNEL_BOOT}" -O "${TMP_CHECK_DIR}/${SERVER_KERNEL_BOOT}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${SERVER_KERNEL_BOOT}" ]]; then
            tolog "03.05 ${SERVER_KERNEL_BOOT} complete."
        else
            tolog "03.06 The boot file failed to download." "1"
        fi
        sleep 3

        # Download dtb file
        wget -c "${SERVER_KERNEL_URL}/${SERVER_KERNEL_VERSION}/${SERVER_KERNEL_DTB}" -O "${TMP_CHECK_DIR}/${SERVER_KERNEL_DTB}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${SERVER_KERNEL_DTB}" ]]; then
            tolog "03.07 ${SERVER_KERNEL_DTB} complete."
        else
            tolog "03.08 The boot file failed to download." "1"
        fi
        sleep 3

        # Download modules file
        wget -c "${SERVER_KERNEL_URL}/${SERVER_KERNEL_VERSION}/${SERVER_KERNEL_MODULES}" -O "${TMP_CHECK_DIR}/${SERVER_KERNEL_MODULES}" >/dev/null 2>&1 && sync
        if [[ "$?" -eq "0" && -s "${TMP_CHECK_DIR}/${SERVER_KERNEL_MODULES}" ]]; then
            tolog "03.09 ${SERVER_KERNEL_MODULES} complete."
        else
            tolog "03.10 The modules file failed to download." "1"
        fi
        sleep 3
    fi

    # 04. Move to the ${KERNEL_DOWNLOAD_PATH} directory to prepare for the update kernel
    mv -f ${TMP_CHECK_DIR}/*.tar.gz ${KERNEL_DOWNLOAD_PATH} >/dev/null 2>&1 && sync
    tolog "04 The kernel is ready, you can update."
    sleep 3

    rm -rf ${TMP_CHECK_SERVER_FILE} >/dev/null 2>&1
    echo '<a href=upload>Update</a>' >$START_LOG

    #luci.http.redirect(luci.dispatcher.build_url("admin", "system", "amlogic", "upload"))
