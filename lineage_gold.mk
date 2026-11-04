#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# base_vendor.mk adds the HIDL CAS service, which FCM level 8 deprecates, to
# devices that launched with API 33 or lower, and reads this when it is inherited.
# Without it the AIDL service in com.android.hardware.cas is installed instead.
TARGET_REQUIRES_HIDL_CAS_HAL := false

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/xiaomi/gold/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_gold
PRODUCT_DEVICE := gold
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 13 5G

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi


# The Dolby app is the audio effects panel
TARGET_EXCLUDES_AUDIOFX := true

# Launcher overlay
PRODUCT_PACKAGES += \
    LauncherOverlayGold

# PalapaOS Redesign UI Properties
PRODUCT_PRODUCT_PROPERTIES += \
    ro.palapa.edition=Majapahit Edition \
    ro.palapa.os.name=Palapa OS \
    ro.palapa.os.version=Majapahit \
    ro.wowo.edition=Majapahit Edition \
    ro.wowo.os.name=Palapa OS \
    ro.wowo.os.version=Majapahit \
    ro.shinkai.maintainer=Asnalstan

PRODUCT_SYSTEM_PROPERTIES += \
    ro.product.marketname=Redmi Note 13 5G \
    ro.crdroid.version=13.0

# Leica Camera
$(call inherit-product-if-exists, vendor/xiaomi/camera/camera.mk)

