#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)

from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/xiaomi/gold',
    'hardware/mediatek',
    'hardware/mediatek/libion_mtk',
    'hardware/mediatek/libmtkperf_client',
    'hardware/xiaomi',
]

# The codec service and MediaTek's codec libraries are Android 15 binaries. Classes in the
# Codec2 support libraries changed size in Android 16, so these keep the stock copies of
# those libraries, which proprietary-files.txt installs as <name>-v35.so.
codec2_stock_libs = (
    'libcodec2',
    'libcodec2_aidl',
    'libcodec2_hal_common',
    'libcodec2_hidl@1.0',
    'libcodec2_hidl@1.1',
    'libcodec2_hidl@1.2',
    'libcodec2_hidl_plugin',
    'libcodec2_soft_common',
    'libcodec2_vndk',
    'libsfplugin_ccodec_utils',
    'libstagefright_aidl_bufferpool2',
    'libstagefright_bufferpool@2.0.1',
    'libstagefright_bufferqueue_helper',
    'libstagefright_foundation',
)


def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None


# The video call interface library exists in both system_ext and vendor.
lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    'vendor.mediatek.hardware.videotelephony-V1-ndk': lib_fixup_vendor_suffix,
}


def codec2_fixup() -> blob_fixup:
    fixup = blob_fixup()
    for lib in codec2_stock_libs:
        fixup = fixup.replace_needed(f'{lib}.so', f'{lib}-v35.so')
    return fixup


blob_fixups: blob_fixups_user_type = {

    # Stock's AIDL audio service converts between framework and HAL types with the Android 15
    # layout of the conversion library, so it gets stock's copy under another name.
    ('vendor/bin/hw/android.hardware.audio.service-aidl.mediatek',
     'vendor/lib64/hw/android.hardware.soundtrigger3-impl.so'): blob_fixup()
        .replace_needed('libaudio_aidl_conversion_common_ndk.so',
                        'libaudio_aidl_conversion_common_ndk_prebuilt.so'),

    # MediaTek's Bluetooth audio interface is built from hardware/mediatek. These were built
    # against its V1 together with version 3 of the common audio types, which the source
    # pairs with V3.
    ('vendor/lib64/android.hardware.bluetooth.audio-impl-mediatek.so',
     'vendor/lib64/libbluetooth_audio_session_aidl_mtk.so'): blob_fixup()
        .replace_needed('vendor.mediatek.hardware.bluetooth.audio-V1-ndk.so',
                        'vendor.mediatek.hardware.bluetooth.audio-V3-ndk.so'),

    # Dolby's effect is an Android 15 binary as well and converts types the same way.
    'vendor/lib64/soundfx/libswdapaidl.so': blob_fixup()
        .replace_needed('libaudio_aidl_conversion_common_ndk.so',
                        'libaudio_aidl_conversion_common_ndk_prebuilt.so'),

    # These two create ALooper and ABuffer objects themselves, so they keep the stock copy
    # of the library that defines them.
    ('vendor/lib64/libdlbdsservice.so',
     'vendor/lib64/libdlbpreg.so'): blob_fixup()
        .replace_needed('libstagefright_foundation.so',
                        'libstagefright_foundation-v35.so'),

    'vendor/lib64/android.hardware.audio.core-impl-mediatek.so': blob_fixup()
        .add_needed('libaudioutils_shim.so')
        .replace_needed('libaudio_aidl_conversion_common_ndk.so',
                        'libaudio_aidl_conversion_common_ndk_prebuilt.so'),

    # Stock's IMS stack
    'system_ext/lib64/libimsma.so': blob_fixup()
        .replace_needed('libsink.so', 'libsink-mtk.so'),

    # libsink still calls the Android 15 AudioTrack constructor; the compatibility library has it.
    'system_ext/lib64/libsink-mtk.so': blob_fixup()
        .add_needed('libaudioclient_shim.so'),

    'system_ext/priv-app/ImsService/ImsService.apk': blob_fixup()
        .apktool_patch('blob-patches/ImsService'),

    'system_ext/priv-app/MtkTelephonyAssist/MtkTelephonyAssist.apk': blob_fixup()
        .apktool_patch('blob-patches/MtkTelephonyAssist'),

    'vendor/lib64/hw/fingerprint.fpc.default.so': blob_fixup()
        .binary_regex_replace(
            br'fingerprint\.fpc\x00',
            b'fingerprint\x00\x00\x00\x00\x00',
        ),

    'vendor/lib64/hw/fingerprint.goodix.default.so': blob_fixup()
        .binary_regex_replace(
            br'fingerprint\.goodix\x00',
            b'fingerprint\x00\x00\x00\x00\x00\x00\x00\x00',
        ),

    'vendor/lib64/libgoodixhwfingerprint.so': blob_fixup()
        .replace_needed('libvendor.xiaomi.hardware.fx.tunnel@1.0.so', 'vendor.xiaomi.hardware.fx.tunnel@1.0.so'),

    # MediaTek's navigation library is installed as libmnl_mtk, because the platform now has
    # a libmnl of its own (the netlink library).
    'vendor/bin/mnld': blob_fixup()
        .replace_needed(
            'android.hardware.sensors-V2-ndk.so',
            'android.hardware.sensors-V3-ndk.so',
        )
        .replace_needed('libmnl.so', 'libmnl_mtk.so'),

    ('vendor/lib64/libcam.utils.sensorprovider.so',
     'vendor/lib64/libaalservice.so'): blob_fixup()
        .replace_needed(
            'android.hardware.sensors-V2-ndk.so',
            'android.hardware.sensors-V3-ndk.so',
        ),

    # The stock service links V3 of the KeyMint interface and also
    # lib_android_keymaster_keymint_utils, which is built here against V4. Soong refuses a
    # module that depends on two versions of one AIDL interface, so the service gets stock's
    # own V3 library, which proprietary-files.txt installs under this name.
    'vendor/bin/hw/android.hardware.security.keymint@3.0-service.mitee': blob_fixup()
        .replace_needed(
            'android.hardware.security.keymint-V3-ndk.so',
            'android.hardware.security.keymint-V3-ndk-prebuilt.so',
        ),

    # From device_xiaomi_duchamp
    'vendor/lib64/libmtkcam_hal_aidl_common.so': blob_fixup()
        .replace_needed('android.hardware.camera.common-V2-ndk.so', 'android.hardware.camera.common-V1-ndk.so'),

    # worst patching spree you will see in your life
    ('vendor/lib/hw/mapper.mediatek.so',
     'vendor/lib64/hw/mapper.mediatek.so',
     'vendor/lib/egl/libGLES_mali.so',
     'vendor/lib64/egl/libGLES_mali.so',
     'vendor/bin/hw/android.hardware.graphics.allocator-V2-service-mediatek',
     'vendor/lib64/vendor.mediatek.hardware.camera.isphal-V1-ndk.so',
     'vendor/lib64/hw/android.hardware.graphics.allocator-V2-mediatek.so',
     'vendor/lib64/vendor.mediatek.hardware.pq_aidl-V4-ndk.so',
     'vendor/lib64/vendor.mediatek.hardware.pq_aidl-V2-ndk.so',
     'vendor/lib/vendor.mediatek.hardware.pq_aidl-V2-ndk.so',
     'vendor/lib64/libmtkcam_grallocutils.so',
     'vendor/lib64/libcodec2_fsr.so',
     'vendor/lib/libgpud.so',
     'vendor/lib64/libgpud.so'): blob_fixup()
        .replace_needed('android.hardware.graphics.common-V5-ndk.so', 'android.hardware.graphics.common-V7-ndk.so'),

    # From android_device_xiaomi_rosemary
    ('vendor/lib64/libMiVideoFilter.so'): blob_fixup()
        .clear_symbol_version('AHardwareBuffer_allocate')
        .clear_symbol_version('AHardwareBuffer_describe')
        .clear_symbol_version('AHardwareBuffer_lock')
        .clear_symbol_version('AHardwareBuffer_lockPlanes')
        .clear_symbol_version('AHardwareBuffer_release')
        .clear_symbol_version('AHardwareBuffer_unlock'),

    'vendor/lib/libvcodec_oal.so': blob_fixup()
        .clear_symbol_version('__aeabi_memcpy')
        .clear_symbol_version('__aeabi_memset')
        .clear_symbol_version('__gnu_Unwind_Find_exidx'),

    # libtinyxml
    ('vendor/lib64/libsilkybrightnesscore.so',
     'vendor/lib64/hw/vendor.mediatek.hardware.pq_aidl-impl.so',
     'vendor/lib64/hw/hwcomposer.mt6833.so',
     'vendor/lib64/libpqxmlparser.so',
     'vendor/lib64/hw/audio.primary.mt6833.so',
     'vendor/lib64/hw/android.hardware.audio.effect.aidl-impl-mediatek.so',
     'vendor/lib64/librt_extamp_intf.so'): blob_fixup()
        .replace_needed(
            'libtinyxml2.so',
            'libtinyxml2-v34.so',
        ),

    # Apple clients cannot join a WPA3 hotspot while the driver checks the PMKID itself
    'vendor/firmware/wifi.cfg': blob_fixup()
        .add_line_if_missing('SapCheckPmkidInDriver 0'),

    # BT_VND_OP_USERIAL_CLOSE takes no parameter, and the HAL passes nullptr, but this
    # library reads a flag from it before closing the UART. Use 0 (a normal close)
    # instead: ldrb w0, [x19] -> mov w0, wzr
    'vendor/lib64/libbt-vendor.so': blob_fixup()
        .binary_regex_replace(
            b'\x3c\x00\x00\x94\x60\x02\x40\x39\x5a\x00\x00\x94',
            b'\x3c\x00\x00\x94\xe0\x03\x1f\x2a\x5a\x00\x00\x94',
        ),

    # hardware/xiaomi's sensors HAL exposes the pick-up sensor as the standard pick-up
    # gesture, but only knows it under this type name
    'vendor/lib64/hw/sensors.mt6833.so': blob_fixup()
        .binary_regex_replace(
            br'xiaomi\.sensor\.pick_up\x00',
            b'xiaomi.sensor.pickup\x00\x00',
        ),

    ('vendor/bin/hw/android.hardware.media.c2-mediatek',
     'vendor/lib64/libcodec2_mtk_c2store.so',
     'vendor/lib64/libcodec2_vpp_fa_plugin.so',
     'vendor/lib64/libcodec2_vpp_mi_plugin.so',
     'vendor/lib64/libcodec2_vpp_qt_plugin.so',
     'vendor/lib64/libcodec2_vpp_rs_plugin.so',
     'vendor/lib64/vpp_hdrmeta_handler_plugin.so',
     *(f'vendor/lib64/{lib}-v35.so' for lib in codec2_stock_libs)): codec2_fixup(),

    # MediaTek's libformatter is installed as libformatter_mtk, because the platform now has
    # a library called libformatter of its own.
    ('vendor/lib64/libcodec2_mtk_vdec.so',
     'vendor/lib64/libcodec2_mtk_venc.so'): codec2_fixup()
        .replace_needed('libformatter.so', 'libformatter_mtk.so'),

    # The crash handler runs inside the codec service and needs these two system calls.
    # Without them the service is killed halfway through reporting a crash and no
    # tombstone is written.
    'vendor/etc/seccomp_policy/android.hardware.media.c2@1.2-mediatek-seccomp-policy': blob_fixup()
        .add_line_if_missing('sysinfo: 1')
        .add_line_if_missing('uname: 1'),

    # mtk pq
    'vendor/lib64/vendor.mediatek.hardware.pq_aidl-V7-ndk.so': blob_fixup()
        .replace_needed('android.hardware.graphics.common-V4-ndk.so',
        'android.hardware.graphics.common-V7-ndk.so')


}  # fmt: skip

module = ExtractUtilsModule(
    'gold',
    'xiaomi',
    add_firmware_proprietary_file=True,
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
