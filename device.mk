#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/gold

# Enforce generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Inherit launch_with_vendor_ramdisk product
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Virtual A/B with compressed snapshots, as stock: its ro.virtual_ab.* properties are the
# Android 13 baseline's and threads=true, and its payload is compressed with gzip.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/android_t_baseline.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := gz
PRODUCT_VENDOR_PROPERTIES += ro.virtual_ab.compression.threads=true

# Project ID Quota
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Dalvik
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# Linker config
PRODUCT_VENDOR_LINKER_CONFIG_FRAGMENTS += \
    $(DEVICE_PATH)/configs/linker.config.json

# Device specific properties
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/sku,$(TARGET_COPY_OUT_PRODUCT)/etc/sku)

$(call inherit-product, $(DEVICE_PATH)/prop/vendor_logtag.mk)

# Vendor Binder service manager (required by MediaTek PQ)
PRODUCT_PACKAGES += \
    vndservicemanager

# Device uses high-density artwork where available
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Boot animation: LineageOS and PixelOS size it to the screen width
TARGET_SCREEN_WIDTH := 1080

# Dynamic Partitions
PRODUCT_BUILD_SUPER_PARTITION := false
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Virtual A/B
PRODUCT_PACKAGES += \
    android.hardware.boot-service.mediatek \
    android.hardware.boot-service.mediatek_recovery

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script \
    update_engine \
    update_engine_client \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES += \
    create_pl_dev \
    create_pl_dev.recovery

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 33

# Audio: the service, its effects factory and the sound trigger HAL are stock's AIDL ones.
# The effect libraries the factory loads are built from source.
PRODUCT_PACKAGES += \
    audio.bluetooth.default \
    audio_policy.stub

# Hands the call volume step to MediaTek's audio HAL, which does not follow the stream volume.
PRODUCT_PACKAGES += \
    MtkInCallService

# Translates the framework's key-value audio parameters, that one included, for the audio HAL.
# Stock's own translator cannot read what Android 17 sends it.
PRODUCT_PACKAGES += \
    android.hardware.audio.parameter_parser.service

PRODUCT_PACKAGES += \
    libaecsw \
    libagc1sw \
    libagc2sw \
    libbassboostsw \
    libbundleaidl \
    libdownmixaidl \
    libdynamicsprocessingaidl \
    libequalizersw \
    libextensioneffect \
    libhapticgeneratoraidl \
    libloudnessenhanceraidl \
    libnssw \
    libpreprocessingaidl \
    libpresetreverbsw \
    libreverbaidl \
    libvirtualizersw \
    libvisualizeraidl \
    libvolumesw

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/audio/,$(TARGET_COPY_OUT_VENDOR)/etc) \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth-service.mediatek

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

# Camera
PRODUCT_PACKAGES += \
    ApertureResGoldNoUWMGoldACn \
    ApertureResGoldNoUWMGoldAIn \
    ApertureResGoldNoUWMGoldCn \
    ApertureResGoldNoUWMIronPGl \
    ApertureResGoldUWMGoldIn \
    ApertureResGoldUWMIronGl

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml

# ConsumerIR
PRODUCT_PACKAGES += \
    android.hardware.ir-service.example

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml

# DRM (Clearkey)
PRODUCT_PACKAGES += \
    com.android.hardware.drm.clearkey

# Display
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/display/display_id_4627039422300187648.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/displayconfig/display_id_4627039422300187648.xml

# FastbootD
PRODUCT_PACKAGES += \
    android.hardware.fastboot-service.example_recovery

# FM radio
PRODUCT_PACKAGES += \
    FMRadio

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint-service.xiaomi

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

# FSTab
PRODUCT_PACKAGES += \
    fstab.mt6833 \
    fstab.mt6833.vendor_ramdisk

# GNSS
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

# Graphics
PRODUCT_PACKAGES += \
    android.hardware.memtrack-service.mediatek

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_3.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level-2024-03-01.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level-2024-03-01.xml

# Vendor libraries that apps may load: OpenCL
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/public.libraries.txt:$(TARGET_COPY_OUT_VENDOR)/etc/public.libraries.txt

# Dolby
PRODUCT_PACKAGES += \
    XiaomiDolby

# Hotword enrollment: the apps that hand a trained "Hey Google" model to the sound trigger HAL
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.mediatek \
    android.hardware.health-service.mediatek-recovery \
    vendor.lineage.health-service.default

# Charging control: writing 1 to input_suspend stops charging, 0 resumes it
$(call soong_config_set,lineage_health,charging_control_charging_path,/sys/class/power_supply/battery/input_suspend)
$(call soong_config_set,lineage_health,charging_control_charging_enabled,0)
$(call soong_config_set,lineage_health,charging_control_charging_disabled,1)
$(call soong_config_set_bool,lineage_health,charging_control_supports_bypass,false)

# Init
PRODUCT_PACKAGES += \
    init.mt6833.rc \
    init.project.rc \
    init.project.recovery.rc \
    init.recovery.mt6833.rc \
    ueventd.mtk.rc

# Charging
PRODUCT_PACKAGES += \
    init.batterysecret.rc

# Kernel module loading
PRODUCT_PACKAGES += \
    init.mtkgki.rc

# Keymint
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.0.vendor \
    android.hardware.security.keymint-V3-ndk.vendor \
    android.hardware.security.rkp-V3-ndk.vendor \
    android.hardware.security.secureclock-V1-ndk.vendor \
    android.hardware.security.sharedsecret-V1-ndk.vendor \
    lib_android_keymaster_keymint_utils.vendor \
    libcppbor_external.vendor \
    libkeymaster_messages.vendor \
    libkeymaster_portable.vendor \
    libkeymint.vendor \
    libtrusty.vendor

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml \
    frameworks/native/data/etc/android.software.device_id_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_id_attestation.xml

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light-service.lineage

# Media
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/media,$(TARGET_COPY_OUT_VENDOR)/etc)

# Overlays
# MediaTek's defaults first: hardware/mediatek picks the ones MT6833 takes, the telephony ones
# with the vendor RIL. Ours below carry only what gold does differently.
ENABLE_VENDOR_RIL_SERVICE := true
$(call inherit-product, hardware/mediatek/overlay/mssi.mk)

PRODUCT_PACKAGES += \
    SystemUIOverlayGold \
    FrameworksResOverlayGold \
    TetheringOverlayGold \
    NetworkStackOverlayGold \
    SettingsResOverlayGold \
    WifiOverlayGold

PRODUCT_PACKAGES += \
    NcmTetheringOverlay

PRODUCT_ENFORCE_RRO_TARGETS := *

# Power-off alarm
PRODUCT_PACKAGES += \
    PowerOffAlarm

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr

$(call soong_config_set,power_libperfmgr,mode_extension_lib,//$(DEVICE_PATH):libperfmgr-ext.gold)

PRODUCT_PACKAGES += \
    init.mt6833.power.rc

PRODUCT_PACKAGES += \
    libmtkperf_client_vendor \
    libpowerhalwrap_vendor \
    vendor.mediatek.hardware.mtkpower-service.stub

$(call soong_config_set_bool,libmtkperf_client,powerhalwrap_aidl,true)

# libperfmgr requires these profile names, but MT6833 has no Pixel
# /proc/vendor_sched/sched_qos interface; keep the vendor definitions no-op.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json \
    $(DEVICE_PATH)/configs/task_profiles.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json

# Radio
PRODUCT_PACKAGES += \
    init.modem.rc \
    android.hardware.telephony.ims.prebuilt.xml

# Turns on 5G NSA (EN-DC) where the modem keeps it off for a SIM.
PRODUCT_PACKAGES += \
    GoldNrDc

# MediaTek framework classes used by the proprietary radio stack.
$(call inherit-product, hardware/mediatek/frameworks/mediatek-frameworks.mk)

# IMS: the service, its helpers and the video call stack are taken from stock. The compatibility
# jar supplies a telephony class they still use.
$(call inherit-product, hardware/lineage/compat/frameworks/compat.mk)

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/permissions/privapp-permissions-com.mediatek.ims.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-com.mediatek.ims.xml \
    $(DEVICE_PATH)/configs/permissions/privapp-permissions-com.mediatek.telephony.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-com.mediatek.telephony.xml

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/sysconfig/com.mediatek.ims.config.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/com.mediatek.ims.config.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnel_migration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnel_migration.xml

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.xiaomi-multihal \
    android.hardware.sensors@2.0-subhal-impl-1.0 \
    sensors.dynamic_sensor_hal

PRODUCT_PACKAGES += \
    init.sensor_2_0.rc

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/hals.conf:$(TARGET_COPY_OUT_ODM)/etc/sensors/hals.conf \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.dynamic.head_tracker.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    hardware/google/interfaces \
    hardware/google/pixel/pixelstats \
    hardware/google/pixel/power-libperfmgr \
    hardware/google/pixel/thermal \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/mediatek \
    hardware/mediatek/libion_mtk \
    hardware/mediatek/libmtkperf_client \
    hardware/xiaomi

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.mediatek

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/thermal_info_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json

# USB
$(call soong_config_set_bool,mediatek_gadget,use_custom_usb_gadget_rc,true)

PRODUCT_PACKAGES += \
    android.hardware.usb-service.mediatek \
    android.hardware.usb.gadget-service.mediatek

PRODUCT_PACKAGES += \
    init.mt6833.usb.rc

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

# The touchscreen drivers ask for these when they start, also in recovery
PRODUCT_COPY_FILES += \
    $(foreach f,focaltech_ts_fw_CSOT.bin focaltech_ts_fw_CSOT_mask0x01.bin focaltech_ts_fw_TianMa.bin goodix_cfg_group.bin gt9916r_ts_fw_tm.bin, \
        vendor/xiaomi/gold/proprietary/vendor/firmware/$(f):$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/$(f))

# Verified boot
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# Vibrator
$(call soong_config_set_bool,mediatek_vibrator,supports_effects,true)

PRODUCT_PACKAGES += \
    android.hardware.vibrator-service.mediatek

# WiFi
$(call soong_config_set_bool,mediatek_wifi_hal,use_pre_baklava_qpr0_struct,true)

PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    wlan_assistant \
    wpa_supplicant \
    libwifi-hal-wrapper

PRODUCT_PACKAGES += \
    init.connectivity.common.rc \
    init_connectivity.rc

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/wifi/,$(TARGET_COPY_OUT_VENDOR)/etc/wifi) \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml

# Inherit the proprietary files
$(call inherit-product, vendor/xiaomi/gold/gold-vendor.mk)
