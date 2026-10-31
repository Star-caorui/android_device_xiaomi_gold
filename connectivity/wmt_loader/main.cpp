/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "wmt_loader"

#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/stringprintf.h>
#include <android-base/unique_fd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <chrono>
#include <cstdlib>
#include <string>
#include <thread>

using android::base::GetProperty;
using android::base::SetProperty;
using android::base::StringPrintf;
using android::base::unique_fd;

namespace {

constexpr char kWmtDetectDev[] = "/dev/wmtdetect";

constexpr char kChipIdProp[] = "persist.vendor.connsys.chipid";
constexpr char kAdieChipIdProp[] = "vendor.connsys.adie.chipid";
constexpr char kDriverReadyProp[] = "vendor.connsys.driver.ready";

constexpr uid_t kAidShell = 2000;
constexpr gid_t kAidSystem = 1000;

// connectivity/common/common_detect/wmt_detect.h in the kernel modules
constexpr unsigned kIocMagic = 'w';
#define COMBO_IOCTL_SET_CHIP_ID _IOW(kIocMagic, 1, int)
#define COMBO_IOCTL_GET_SOC_CHIP_ID _IOR(kIocMagic, 3, int)
#define COMBO_IOCTL_DO_MODULE_INIT _IOR(kIocMagic, 4, int)
#define COMBO_IOCTL_MODULE_CLEANUP _IOR(kIocMagic, 5, int)
#define COMBO_IOCTL_GET_ADIE_CHIP_ID _IOR(kIocMagic, 9, int)
#define COMBO_IOCTL_CONNSYS_SOC_HW_INIT _IOR(kIocMagic, 10, int)

unique_fd OpenDetectDev() {
    while (true) {
        unique_fd fd(TEMP_FAILURE_RETRY(open(kWmtDetectDev, O_RDWR | O_NOCTTY)));
        if (fd.ok()) return fd;
        PLOG(WARNING) << "Can't open " << kWmtDetectDev;
        std::this_thread::sleep_for(std::chrono::milliseconds(300));
    }
}

int GetChipId(int fd) {
    int chip_id = strtoul(GetProperty(kChipIdProp, "").c_str(), nullptr, 16);
    if (chip_id > 0) return chip_id;

    chip_id = ioctl(fd, COMBO_IOCTL_GET_SOC_CHIP_ID, 0);
    if (chip_id > 0) SetProperty(kChipIdProp, StringPrintf("0x%04x", chip_id));
    return chip_id;
}

bool InitDriver(int fd) {
    if (int ret = ioctl(fd, COMBO_IOCTL_CONNSYS_SOC_HW_INIT, 0); ret != 0) {
        LOG(ERROR) << "SoC hardware init failed: " << ret;
        return false;
    }

    int chip_id = GetChipId(fd);
    if (chip_id <= 0) {
        LOG(ERROR) << "Invalid chip id " << chip_id;
        return false;
    }
    LOG(INFO) << StringPrintf("Chip id 0x%04x", chip_id);

    ioctl(fd, COMBO_IOCTL_SET_CHIP_ID, chip_id);

    if (int ret = ioctl(fd, COMBO_IOCTL_MODULE_CLEANUP, chip_id); ret != 0) {
        LOG(ERROR) << "Module cleanup failed: " << ret;
        return false;
    }
    if (int ret = ioctl(fd, COMBO_IOCTL_DO_MODULE_INIT, chip_id); ret != 0) {
        LOG(ERROR) << "Module init failed: " << ret;
        return false;
    }

    int adie_id = ioctl(fd, COMBO_IOCTL_GET_ADIE_CHIP_ID, 0);
    if (adie_id == -1) {
        LOG(ERROR) << "Invalid A-die chip id";
        return false;
    }
    SetProperty(kAdieChipIdProp, StringPrintf("0x%04x", adie_id));
    return true;
}

}  // namespace

int main() {
    if (GetProperty(kDriverReadyProp, "") == "yes") {
        LOG(INFO) << "The driver is already ready";
        return 0;
    }

    {
        unique_fd fd = OpenDetectDev();
        if (!InitDriver(fd.get())) return EXIT_FAILURE;
    }

    for (const char* path : {"/proc/driver/wmt_dbg", "/proc/driver/wmt_aee"}) {
        if (chown(path, kAidShell, kAidSystem) != 0) PLOG(ERROR) << "Can't chown " << path;
    }

    if (!SetProperty(kDriverReadyProp, "yes")) {
        LOG(ERROR) << "Can't set " << kDriverReadyProp;
        return EXIT_FAILURE;
    }
    return 0;
}
