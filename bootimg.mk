#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# The bootloader never loads boot.img's ramdisk, so the generic ramdisk goes into vendor_boot as
# stock's init_boot fragment. Soong refuses fragments other than "dlkm" and the Makefile resets
# the lists before reading device makefiles, so it is added here.
BOARD_VENDOR_RAMDISK_FRAGMENT.init_boot.PREBUILT := $(INSTALLED_RAMDISK_TARGET)
BOARD_VENDOR_RAMDISK_FRAGMENT.init_boot.MKBOOTIMG_ARGS := --ramdisk_type PLATFORM --ramdisk_name init_boot
INTERNAL_VENDOR_RAMDISK_FRAGMENTS += init_boot

gold_init_boot_fragment := \
    $(call build-prebuilt-vendor-ramdisk-fragment,init_boot,$(BOARD_VENDOR_RAMDISK_FRAGMENT.init_boot.PREBUILT))
INTERNAL_VENDOR_RAMDISK_FRAGMENT_TARGETS += $(gold_init_boot_fragment)
INTERNAL_VENDOR_RAMDISK_FRAGMENT_ARGS += \
    $(BOARD_VENDOR_RAMDISK_FRAGMENT.init_boot.MKBOOTIMG_ARGS) \
    --vendor_ramdisk_fragment $(gold_init_boot_fragment)
$(INSTALLED_VENDOR_BOOTIMAGE_TARGET): $(gold_init_boot_fragment)
