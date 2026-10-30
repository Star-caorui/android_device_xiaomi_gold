$(call inherit-product, hardware/mediatek/configs/properties/vendor_logtag.mk)

# hardware/mediatek's file sets the same, but an inherited file is read only after this one.
ifeq (eng,$(TARGET_BUILD_VARIANT))
VENDOR_LOG_LEVEL := I
else
VENDOR_LOG_LEVEL := S
endif

PRODUCT_VENDOR_PROPERTIES += \
    persist.log.tag.EccNumberPreference=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.EccNumberSource=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RILMUXD=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcCapa=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcCdmaSimRequest=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcCdmaSimUrc=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcCommSimOpReq=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcCommSimReq=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcCommSimUrc=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcDcCommon=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcDcPdnManager=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcDcReqHandler=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcDcUtility=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcEccNumberUrcHandler=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcEmbmsReq=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcEmbmsUrc=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcGsmSimRequest=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcGsmSimUrc=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcImsCtlReqHdl=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcImsCtlUrcHdl=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcNwHdlr=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcNwRTReqHdlr=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcNwReqHdlr=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcOemHandler=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcOpRadioReq=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcPhbReq=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcPhbUrc=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcRadioReq=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcRatSwHdlr=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RmcWp=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RTC_DAC=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcCapa=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcCommSimCtrl=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcDC=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcEccNumberController=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcEmbmsAt=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcEmbmsUtil=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcIms=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcImsConference=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcImsConfigController=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcImsDialog=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcModeCont=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcNwCtrl=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcPhb=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcRadioCont=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcRatSwCtrl=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.RtcWp=$(VENDOR_LOG_LEVEL) \
    persist.log.tag.Smart5gService=$(VENDOR_LOG_LEVEL)
