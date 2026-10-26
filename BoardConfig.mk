#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/gold

# Virtual A/B
AB_OTA_UPDATER := true
# The device the update package is for. The tools would otherwise take the first
# ro.product.device they find in the partitions' properties, and product's is stock's
# missi; recovery says gold on every unit.
TARGET_OTA_ASSERT_DEVICE := gold
AB_OTA_PARTITIONS := \
    dtbo \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vendor \
    vendor_dlkm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55

# boot/vendor_boot image
AB_OTA_PARTITIONS += \
    boot \
    vendor_boot

BOARD_RAMDISK_USE_LZ4 := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true

# The bootloader loads the ramdisks of vendor_boot and never the one in boot.
# bootimg.mk lays the two images out as stock does.
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/bootimg.mk

BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864

BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2

# The addresses are stock's vendor_boot header's, as unpack_bootimg.py prints them.
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_OFFSET := 0x40080000
BOARD_RAMDISK_OFFSET := 0x51100000
BOARD_KERNEL_TAGS_OFFSET := 0x47c80000
BOARD_DTB_OFFSET := 0x47c80000

BOARD_MKBOOTIMG_ARGS := \
    --header_version $(BOARD_BOOT_HEADER_VERSION) \
    --pagesize $(BOARD_KERNEL_PAGESIZE) \
    --base $(BOARD_KERNEL_BASE) \
    --kernel_offset $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) \
    --dtb_offset $(BOARD_DTB_OFFSET)

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := gold
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 440
TARGET_USES_VULKAN := true

# Kernel: LineageOS's build_kernel builds it with android_kernel_xiaomi_gold_manifest, as lamu's,
# into gold-kernels: the vendor modules, the device tree blob and its overlay from source, and
# Google's GKI build, the kernel image and the GKI modules of system_dlkm.
TARGET_KERNEL_DEVICE := mgk_64_k66
TARGET_KERNEL_DIR := $(DEVICE_PATH)-kernels
TARGET_KERNEL_PLATFORM_SOURCE := xiaomi_gold
TARGET_KERNEL_VERSION := 6.6

BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_PREBUILT_KERNEL := $(TARGET_KERNEL_DIR)/$(BOARD_KERNEL_IMAGE_NAME)
TARGET_PREBUILT_KERNEL_HEADERS := $(TARGET_KERNEL_DIR)/kernel-uapi-headers.tar.gz
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(TARGET_KERNEL_DIR)
BOARD_PREBUILT_DTBOIMAGE := $(TARGET_KERNEL_DIR)/dtbo.img

BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(TARGET_KERNEL_DIR)/system_dlkm.modules.load 2>/dev/null))
BOARD_SYSTEM_KERNEL_MODULES := $(addprefix $(TARGET_KERNEL_DIR)/,$(BOARD_SYSTEM_KERNEL_MODULES_LOAD))

GOLD_MODULES := $(DEVICE_PATH)/modules
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(GOLD_MODULES)/modules.load.vendor))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(GOLD_MODULES)/modules.load.vendor_ramdisk))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(GOLD_MODULES)/modules.load.recovery))

# The touchscreen drivers are only in vendor_dlkm on stock, which recovery
# does not mount. A copy goes into the vendor ramdisk, with the two modules
# they need there, and init.recovery.mt6833.rc loads them.
GOLD_RECOVERY_TOUCH_MODULES := \
    mt6359p-accdet.ko \
    hq_notifier.ko \
    xiaomi_touch.ko \
    focaltech_tp.ko \
    gt9916r.ko

BOARD_VENDOR_KERNEL_MODULES := $(addprefix $(TARGET_KERNEL_DIR)/,$(strip $(shell cat $(GOLD_MODULES)/modules.list.vendor_dlkm)))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(addprefix $(TARGET_KERNEL_DIR)/,$(sort \
    $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD) \
    $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD) \
    $(GOLD_RECOVERY_TOUCH_MODULES)))

# Partitions
BOARD_SUPER_PARTITION_SIZE := 9126805504

BOARD_USES_METADATA_PARTITION := true

# The group is stock's one group in its update payload. mi_ext, stock's last dynamic partition,
# holds only MIUI's additions and is not built.
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 9116319744
BOARD_MAIN_PARTITION_LIST := \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vendor \
    vendor_dlkm

BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs

BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext

# Platform
TARGET_BOARD_PLATFORM := mt6833
BOARD_SHIPPING_API_LEVEL := 30

# Props
TARGET_VENDOR_PROP += $(DEVICE_PATH)/prop/vendor.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/prop/product.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/prop/system_ext.prop

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/fstab.mt6833

# SEPolicy
include device/mediatek/sepolicy_vndr/SEPolicy.mk
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public

# SPL
BOOT_SECURITY_PATCH := 2026-02-01
VENDOR_SECURITY_PATCH := 2026-02-01

# vintf
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    hardware/xiaomi/vintf/xiaomi_framework_compatibility_matrix.xml \
    hardware/mediatek/vintf/mediatek_framework_compatibility_matrix.xml \
    $(DEVICE_PATH)/configs/vintf/dolby_framework_compatibility_matrix.xml

# WiFi
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_FW_PATH_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_FW_PATH_STA := "STA"
WIFI_DRIVER_FW_PATH_AP := "AP"
WIFI_DRIVER_FW_PATH_P2P := "P2P"
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_STATE_ON := "1"
WIFI_DRIVER_STATE_OFF := "0"
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true

# Reserve space for gapps
include vendor/lineage/config/BoardConfigReservedSize.mk

# Verified Boot
AB_OTA_PARTITIONS += \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor

# Chained as stock's: vbmeta holds dtbo, vendor_boot and the dlkm partitions and chains boot,
# vbmeta_system and vbmeta_vendor, at stock's rollback index locations and with its rollback
# indexes, 0.
# The key is AOSP's 4096-bit test key, which this device's builds have always been signed with:
# KeyMint binds every key to the top vbmeta's public key, so another one would leave an updated
# phone unable to read its data.
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem

# Verity is off: with it on, an update would also compute the hash trees of the partitions it
# writes on the phone, which makes incremental updates much slower.
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag

# Stock's hash trees are SHA-256; AOSP's default is SHA-1.
$(foreach p,ODM_DLKM PRODUCT SYSTEM SYSTEM_DLKM SYSTEM_EXT VENDOR VENDOR_DLKM, \
    $(eval BOARD_AVB_$(p)_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256))

BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ROLLBACK_INDEX := 0
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_VBMETA_SYSTEM := product system system_ext
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 4

# Inherit the proprietary files
include vendor/xiaomi/gold/BoardConfigVendor.mk
