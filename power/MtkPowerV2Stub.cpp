/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <string>

#include <utils/RefBase.h>

namespace vendor::mediatek::hardware::power::V2_0 {

class IPower : public android::RefBase {
  public:
    static android::sp<IPower> getService(const std::string& serviceName, bool getStub);
};

android::sp<IPower> IPower::getService(const std::string&, bool) {
    return nullptr;
}

}  // namespace vendor::mediatek::hardware::power::V2_0
