/*
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.udp0.betterr.aosp.nrdc;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.telephony.TelephonyManager;
import android.util.Log;

import java.util.List;

/**
 * Turns on 5G NSA (EN-DC) for every active SIM that has it off.
 *
 * MediaTek's RIL offers NR only when the modem has EN-DC on, and on some SIMs the modem keeps it
 * off. Stock's framework turns it on; nothing in LineageOS does. The modem keeps the setting, so
 * this changes something only the first time a SIM is seen with it off.
 */
public class NrDcReceiver extends BroadcastReceiver {
    private static final String TAG = "GoldNrDc";

    @Override
    public void onReceive(Context context, Intent intent) {
        List<SubscriptionInfo> subs =
                context.getSystemService(SubscriptionManager.class).getActiveSubscriptionInfoList();
        if (subs == null) {
            return;
        }
        TelephonyManager base = context.getSystemService(TelephonyManager.class);
        for (SubscriptionInfo info : subs) {
            int subId = info.getSubscriptionId();
            TelephonyManager tm = base.createForSubscriptionId(subId);
            try {
                if (tm.isNrDualConnectivityEnabled()) {
                    continue;
                }
                int result = tm.setNrDualConnectivityState(
                        TelephonyManager.NR_DUAL_CONNECTIVITY_ENABLE);
                Log.i(TAG, "Turned EN-DC on for subscription " + subId + ": result " + result);
            } catch (RuntimeException e) {
                // The radio is not ready yet, or does not support EN-DC.
                Log.w(TAG, "Could not check or turn on EN-DC for subscription " + subId, e);
            }
        }
    }
}
