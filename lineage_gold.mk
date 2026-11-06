#
# Copyright (C) 2026 The Evolution X Project
# SPDX-License-Identifier: Apache-2.0
#

TARGET_REQUIRES_HIDL_CAS_HAL := false

# Inherit dari produk dasar AOSP
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit device makefile
$(call inherit-product, device/xiaomi/gold/device.mk)

# Inherit konfigurasi Evolution X (berada di vendor/lineage/)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Informasi Perangkat
PRODUCT_NAME := lineage_gold
PRODUCT_DEVICE := gold
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 2312DRAABI

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# Tipe Build & Maintainer Info
EVO_BUILD_TYPE := Unofficial
EVO_MAINTAINER := Asnalstan
TARGET_UNOFFICIAL_BUILD_ID := Asnalstan

# Properti Maintainer dan Link Donasi
PRODUCT_PRODUCT_PROPERTIES += \
    ro.evolution.maintainer=Asnalstan \
    ro.evolution.donate_url=https://t.me/ServerHive_bot?start=dev_KEXEQ2 \
    ro.evolution.support_url=https://t.me/ServerHive_bot?start=dev_KEXEQ2

# Audio panel
TARGET_EXCLUDES_AUDIOFX := true
