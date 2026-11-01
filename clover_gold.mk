TARGET_REQUIRES_HIDL_CAS_HAL := false
# Inherit from base products
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device configuration
$(call inherit-product, device/xiaomi/gold/device.mk)

# Clover configuration
$(call inherit-product, vendor/clover/config/common_full_phone.mk)

PRODUCT_NAME := clover_gold
PRODUCT_DEVICE := gold
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 13 5G

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

CLOVER_MAINTAINER := SillyMutemocha
WITH_GMS := true
