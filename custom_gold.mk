#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# PixelOS: the same as lineage_gold.mk, with PixelOS's common configuration,
# which inherits LineageOS's.

# base_vendor.mk adds the HIDL CAS service, which FCM level 8 deprecates, to
# devices that launched with API 33 or lower, and reads this when it is inherited.
# Without it the AIDL service in com.android.hardware.cas is installed instead.
TARGET_REQUIRES_HIDL_CAS_HAL := false

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/xiaomi/gold/device.mk)

# Inherit some common PixelOS stuff.
$(call inherit-product, vendor/custom/config/common_full_phone.mk)

PRODUCT_NAME := custom_gold
PRODUCT_DEVICE := gold
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 2312DRAABG

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
