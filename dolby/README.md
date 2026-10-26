# Dolby settings app

The settings app for stock's Dolby processing. It is Paranoid Android's app (`dolby/` in
[AOSPA/android_hardware_xiaomi](https://github.com/AOSPA/android_hardware_xiaomi), also carried
by Evolution X's `hardware_xiaomi`), taken on 2026-10-12 from Halcyon's tree for the Redmi Note 14 5G
([halcyonlv/device_xiaomi_beryl](https://github.com/halcyonlv/device_xiaomi_beryl)).

It lives in this tree because those `hardware_xiaomi` repositories cannot be synced next to
LineageOS's `hardware/xiaomi`: both define the same modules.

Changes here:

| Commit | Change |
| --- | --- |
| 19bd1fd | Settings entry in the Audio group, without an icon; no launcher entry |
| 8b92396 | No stereo widening, which stock's effect ignores; Voice selects profile 3, as stock's tuning numbers it |
| 4708962 | The spatializer gets the current profile and graphic equalizer |
| 031edf7 | Privileged permission allowlist for `MODIFY_DEFAULT_AUDIO_EFFECTS` |
