package com.abhi.shikhon;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/** JavaScript থেকে "ভিডিও চলছে" সার্ভিস চালু/বন্ধ করার সেতু। */
@CapacitorPlugin(name = "KeepAlive")
public class KeepAlivePlugin extends Plugin {

    public static volatile boolean active = false;

    @PluginMethod
    public void start(PluginCall call) {
        Context c = getContext();
        try {
            if (Build.VERSION.SDK_INT >= 33
                    && c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                    && getActivity() != null) {
                getActivity().requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, 4711);
            }
            Intent i = new Intent(c, KeepAliveService.class);
            if (Build.VERSION.SDK_INT >= 26) c.startForegroundService(i);
            else c.startService(i);
            active = true;
            call.resolve();
        } catch (Exception e) {
            call.reject(String.valueOf(e.getMessage()));
        }
    }

    @PluginMethod
    public void stop(PluginCall call) {
        active = false;
        try {
            getContext().stopService(new Intent(getContext(), KeepAliveService.class));
        } catch (Exception ignored) {
        }
        call.resolve();
    }
}
