# Redmi Note 13 5G/13R Pro/POCO X6 Neo 5G (gold/iron) Device Tree

Device tree for LineageOS 24.0 (Android 17). It is checked out at `device/xiaomi/gold`.

| | |
| --- | --- |
| Releases, what works, tested models | [lineageos-gold](https://github.com/Star-caorui/lineageos-gold#readme) |
| Known issues, what is untested or not done | [ISSUES.md](https://github.com/Star-caorui/lineageos-gold/blob/main/ISSUES.md) |
| How to build | [local_manifests](https://github.com/Star-caorui/local_manifests/tree/lineage-24.0#readme) |
| Kernel and modules | Built by LineageOS's `build_kernel` from [android_kernel_xiaomi_gold_manifest](https://github.com/Star-caorui/android_kernel_xiaomi_gold_manifest#readme) (the sources, Google's GKI builds, and how the modules compare with stock's) |
| Proprietary files | [android_vendor_xiaomi_gold](https://github.com/Star-caorui/android_vendor_xiaomi_gold/tree/lineage-24.0#readme) |

## Origin

Forked from [Dhterech's tree](https://github.com/Dhterech/android_device_xiaomi_gold) at `6c5bdc8` and maintained on its own since: [our commits](https://github.com/Star-caorui/android_device_xiaomi_gold/compare/6c5bdc8...lineage-24.0).

## Scripts

| Script | What it fills |
| --- | --- |
| `extract-files.py` | `vendor/xiaomi/gold`, kept as [android_vendor_xiaomi_gold](https://github.com/Star-caorui/android_vendor_xiaomi_gold/tree/lineage-24.0#regenerating), from the stock package |
| `patches/apply.sh lineage` (or `pixelos`) | Commits that ROM's platform patches below onto the synced projects; run it after every `repo sync`. A patch that is already in the sources is skipped and named, and one that does not apply stops it |

## Platform patches

`patches/<rom>/<project path>/` holds what the build changes outside this tree, applied on top of that ROM's projects as they are synced.

LineageOS (`patches/lineage/`):

| Project | Patch | From |
| --- | --- | --- |
| `lineage-sdk` | LineageSettingsProvider: Notify key URI on delete | Ours, under review: [508379](https://review.lineageos.org/c/LineageOS/android_lineage-sdk/+/508379) |
| `packages/apps/Updater` | Updater: Draw the banner pattern once | Ours, under review: [508380](https://review.lineageos.org/c/LineageOS/android_packages_apps_Updater/+/508380) |
| `packages/modules/Bluetooth` | a2dp: Skip audio context reconfig for SW codecs | Ours, under review: [508408](https://review.lineageos.org/c/LineageOS/android_packages_modules_Bluetooth/+/508408) |
| `external/setupcompat` | partnerconfig: Stop looking up a missing partner provider on every call (the setup wizard's language list stuttered without Google's setup wizard) | Ours, not sent upstream |
| `system/core` | fastbootd: Always return false for GetDeviceLockStatus() | Mashopy's, from [Nothing-2A](https://github.com/Nothing-2A/android_system_core/commit/0d5990a96c5e6a404887f5575c5d00bcbbaaef74), for LKs patched with fenrir |
| `system/fs/fs_mgr` | libfs_avb: Allow LKs patched with fenrir to boot on AOSP | Mashopy's, from [Nothing-2A](https://github.com/Nothing-2A/android_system_core/commit/8ff6e7a68523c3b870d8dcd5713c71ea15b43dd2) |

PixelOS (`patches/pixelos/`):

| Project | Patch | From |
| --- | --- | --- |
| `packages/modules/Bluetooth` | a2dp: Skip audio context reconfig for SW codecs | Ours, under review on LineageOS: [508408](https://review.lineageos.org/c/LineageOS/android_packages_modules_Bluetooth/+/508408) |
| `system/fs/fs_mgr` | libfs_avb: Allow LKs patched with fenrir to boot on AOSP | Mashopy's, as for LineageOS; PixelOS's fastbootd already allows fenrir |
| `vendor/custom` | envsetup: Add build_kernel function for Pixel OOT kernel build; Allow skipping OOT kernel build; Don't wipe module lists that aren't generated | Michael Bestas's and R0rt1z2's, cherry-picked from LineageOS's android_vendor_lineage: PixelOS's build/envsetup.sh calls `build_kernel`, which its copy of LineageOS's envsetup.sh predates |

## Kernel modules

`modules/` lists which vendor modules go into the vendor ramdisk and `vendor_dlkm`, and which of them load and in what order. They started as stock's (OS3.0.5.0.VNQMIXM); `modules.load.vendor` also loads `wmt_drv.ko`, which the Wi-Fi, Bluetooth, GPS and FM drivers depend on, and no longer names Millet's modules.

## Credits

| Who | For what |
| --- | --- |
| [Dhterech](https://github.com/Dhterech/android_device_xiaomi_gold) | The tree this one was forked from |
| xiaomi-mt6833-dev/device_xiaomi_mt6833-common, aeronruless (Telegram), linastorvaldz (GitHub) | Dhterech's tree is based on their work |
| mt6897-devs/device_xiaomi_duchamp, LineageOS/android_device_xiaomi_rosemary | Dhterech's references |
| claxten10's [mt6833-devs/android_device_xiaomi_gold](https://github.com/mt6833-devs/android_device_xiaomi_gold) | The tree Dhterech's is built on |

Our commits follow other trees in places. Each one says so in its message.

| Followed | In what |
| --- | --- |
| cristidclxvi's [android_device_xiaomi_camellia](https://github.com/cristidclxvi/android_device_xiaomi_camellia) | How double tap to wake is switched, and two Wi-Fi settings |
| LineageOS's [android_device_motorola_mt6768-common](https://github.com/LineageOS/android_device_motorola_mt6768-common) | The stock AIDL audio service, the IMS files, the mtkpower stubs, the GNSS declarations, the power hint for games, and the seven changes for LineageOS 24.0 by Nolen Johnson, Michael Bestas, Nicholas Lim, Elias Gheeraert, Mashopy and Giovanni Ricca |
| LineageOS's android_device_motorola_mt6879-common, android_device_xiaomi_rosemary and android_device_xiaomi_mt6768-common, and crDroid's android_device_xiaomi_everpal | What to take from the stock images and how |
| LineageOS's android_device_motorola_lamu | Building against a prebuilt kernel's headers |
| bengris32 | His patch for Motorola's ImsService, which ours repeats on this device's build of the app |
| Dhterech's [android_kernel_xiaomi_gold](https://github.com/Dhterech/android_kernel_xiaomi_gold) | Loading `wmt_drv.ko` from the vendor module list |

## License

```
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
```
