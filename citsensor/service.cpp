/*
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "citsensor-service"

#include <dlfcn.h>

#include <aidl/android/frameworks/sensorservice/BnEventQueueCallback.h>
#include <aidl/android/frameworks/sensorservice/ISensorManager.h>
#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>
#include <android/frameworks/sensorservice/1.0/IEventQueue.h>
#include <android/frameworks/sensorservice/1.0/ISensorManager.h>

namespace aidl_service = ::aidl::android::frameworks::sensorservice;
namespace aidl_sensors = ::aidl::android::hardware::sensors;

namespace android::frameworks::sensorservice::V1_0 {
namespace {

using ::android::hardware::hidl_handle;
using ::android::hardware::hidl_memory;
using ::android::hardware::hidl_vec;
using ::android::hardware::Return;
using ::android::hardware::Void;
using HidlCallback = IEventQueueCallback;
using HidlEvent = ::android::hardware::sensors::V1_0::Event;
using HidlSensorInfo = ::android::hardware::sensors::V1_0::SensorInfo;
using HidlSensorStatus = ::android::hardware::sensors::V1_0::SensorStatus;
using HidlSensorType = ::android::hardware::sensors::V1_0::SensorType;

constexpr char kManagerName[] = "android.frameworks.sensorservice.ISensorManager/default";
constexpr char kImplPath[] = "/vendor/lib64/hw/vendor.xiaomi.sensor.citsensorservice@1.1-impl.so";

HidlSensorInfo toHidl(const aidl_sensors::SensorInfo& in) {
    HidlSensorInfo out;
    out.sensorHandle = in.sensorHandle;
    out.name = in.name;
    out.vendor = in.vendor;
    out.version = in.version;
    out.type = static_cast<HidlSensorType>(in.type);
    out.typeAsString = in.typeAsString;
    out.maxRange = in.maxRange;
    out.resolution = in.resolution;
    out.power = in.power;
    out.minDelay = in.minDelayUs;
    out.fifoReservedEventCount = in.fifoReservedEventCount;
    out.fifoMaxEventCount = in.fifoMaxEventCount;
    out.requiredPermission = in.requiredPermission;
    out.maxDelay = in.maxDelayUs;
    out.flags = in.flags;
    return out;
}

HidlEvent toHidl(const aidl_sensors::Event& in) {
    using Payload = aidl_sensors::Event::EventPayload;
    HidlEvent out{};
    out.timestamp = in.timestamp;
    out.sensorHandle = in.sensorHandle;
    out.sensorType = static_cast<HidlSensorType>(in.sensorType);
    switch (in.payload.getTag()) {
        case Payload::Tag::scalar:
            out.u.scalar = in.payload.get<Payload::Tag::scalar>();
            break;
        case Payload::Tag::vec3: {
            const auto& v = in.payload.get<Payload::Tag::vec3>();
            out.u.vec3.x = v.x;
            out.u.vec3.y = v.y;
            out.u.vec3.z = v.z;
            out.u.vec3.status = static_cast<HidlSensorStatus>(v.status);
            break;
        }
        case Payload::Tag::vec4: {
            const auto& v = in.payload.get<Payload::Tag::vec4>();
            out.u.vec4.x = v.x;
            out.u.vec4.y = v.y;
            out.u.vec4.z = v.z;
            out.u.vec4.w = v.w;
            break;
        }
        case Payload::Tag::uncal: {
            const auto& v = in.payload.get<Payload::Tag::uncal>();
            out.u.uncal.x = v.x;
            out.u.uncal.y = v.y;
            out.u.uncal.z = v.z;
            out.u.uncal.x_bias = v.xBias;
            out.u.uncal.y_bias = v.yBias;
            out.u.uncal.z_bias = v.zBias;
            break;
        }
        case Payload::Tag::data: {
            const auto& v = in.payload.get<Payload::Tag::data>().values;
            for (size_t i = 0; i < v.size(); i++) out.u.data[i] = v[i];
            break;
        }
        default:
            break;
    }
    return out;
}

Result toResult(const ndk::ScopedAStatus& status) {
    if (status.isOk()) return Result::OK;
    return status.getExceptionCode() == EX_SERVICE_SPECIFIC
                   ? static_cast<Result>(status.getServiceSpecificError())
                   : Result::UNKNOWN_ERROR;
}

class EventCallback : public aidl_service::BnEventQueueCallback {
  public:
    explicit EventCallback(const sp<HidlCallback>& callback) : mCallback(callback) {}

    ndk::ScopedAStatus onEvent(const aidl_sensors::Event& event) override {
        mCallback->onEvent(toHidl(event));
        return ndk::ScopedAStatus::ok();
    }

  private:
    sp<HidlCallback> mCallback;
};

class EventQueue : public IEventQueue {
  public:
    explicit EventQueue(const std::shared_ptr<aidl_service::IEventQueue>& queue) : mQueue(queue) {}

    Return<Result> enableSensor(int32_t handle, int32_t periodUs, int64_t latencyUs) override {
        return toResult(mQueue->enableSensor(handle, periodUs, latencyUs));
    }

    Return<Result> disableSensor(int32_t handle) override {
        return toResult(mQueue->disableSensor(handle));
    }

  private:
    std::shared_ptr<aidl_service::IEventQueue> mQueue;
};

class SensorManager : public ISensorManager {
  public:
    SensorManager() {
        ndk::SpAIBinder binder(AServiceManager_waitForService(kManagerName));
        mManager = aidl_service::ISensorManager::fromBinder(binder);
        CHECK(mManager != nullptr) << "no " << kManagerName;
        // The stock code keeps the sensors it enabled for good: restart with system_server.
        mDeath = ndk::ScopedAIBinder_DeathRecipient(
                AIBinder_DeathRecipient_new([](void*) { LOG(FATAL) << "sensor manager died"; }));
        AIBinder_linkToDeath(binder.get(), mDeath.get(), nullptr);
    }

    Return<void> getSensorList(getSensorList_cb cb) override {
        std::vector<aidl_sensors::SensorInfo> list;
        Result result = toResult(mManager->getSensorList(&list));
        hidl_vec<HidlSensorInfo> out(list.size());
        for (size_t i = 0; i < list.size(); i++) out[i] = toHidl(list[i]);
        cb(out, result);
        return Void();
    }

    Return<void> getDefaultSensor(HidlSensorType type, getDefaultSensor_cb cb) override {
        aidl_sensors::SensorInfo info;
        Result result = toResult(
                mManager->getDefaultSensor(static_cast<aidl_sensors::SensorType>(type), &info));
        cb(toHidl(info), result);
        return Void();
    }

    Return<void> createAshmemDirectChannel(const hidl_memory&, uint64_t,
                                           createAshmemDirectChannel_cb cb) override {
        cb(nullptr, Result::INVALID_OPERATION);
        return Void();
    }

    Return<void> createGrallocDirectChannel(const hidl_handle&, uint64_t,
                                            createGrallocDirectChannel_cb cb) override {
        cb(nullptr, Result::INVALID_OPERATION);
        return Void();
    }

    Return<void> createEventQueue(const sp<IEventQueueCallback>& callback,
                                  createEventQueue_cb cb) override {
        std::shared_ptr<aidl_service::IEventQueue> queue;
        Result result = toResult(mManager->createEventQueue(
                ndk::SharedRefBase::make<EventCallback>(callback), &queue));
        cb(result == Result::OK ? new EventQueue(queue) : nullptr, result);
        return Void();
    }

  private:
    std::shared_ptr<aidl_service::ISensorManager> mManager;
    ndk::ScopedAIBinder_DeathRecipient mDeath;
};

}  // namespace

// hwservicemanager is gone and the platform serves this interface over AIDL only. Exported from the
// executable, this is what the stock library's own calls resolve to.
sp<ISensorManager> ISensorManager::getService(const std::string&, bool) {
    static sp<ISensorManager> manager = new SensorManager();
    return manager;
}

static void startStockService() {
    void* impl = dlopen(kImplPath, RTLD_NOW);
    CHECK(impl != nullptr) << dlerror();
    auto fetch = reinterpret_cast<void* (*)(const char*)>(
            dlsym(impl, "HIDL_FETCH_ICitSensorService"));
    CHECK(fetch != nullptr) << dlerror();
    // The constructor starts everything, and nothing here calls the interface.
    CHECK(fetch("default") != nullptr);
}

}  // namespace android::frameworks::sensorservice::V1_0

int main() {
    ABinderProcess_setThreadPoolMaxThreadCount(4);
    ABinderProcess_startThreadPool();
    android::frameworks::sensorservice::V1_0::startStockService();
    ABinderProcess_joinThreadPool();
    return 1;
}
