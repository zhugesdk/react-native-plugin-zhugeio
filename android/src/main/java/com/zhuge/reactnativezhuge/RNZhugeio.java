package com.zhuge.reactnativezhuge;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.zhuge.analysis.stat.ZhugeSDK;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Set;

/**
 * 将Zhuge SDK 方法暴露至React native
 * Created by Jiaokang on 2018/2/27.
 */

public class RNZhugeio extends ReactContextBaseJavaModule {

    private static final String TAG = "RNZhugeio";
    private static final String MODULE_NAME = "Zhugeio";

    public RNZhugeio(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @ReactMethod
    public void init(String appkey, String channel) {
        ZhugeParam param = new ZhugeParam.Builder()
        .appKey(appkey)
        .appChannel(channel)
        .build();
        ZhugeSDK.getInstance().initWithParam(getReactApplicationContext(),param);
    }

    @ReactMethod
    public void openLog() {
        ZhugeSDK.getInstance().openLog();
    }

    @ReactMethod
    public void openDebug() {
        ZhugeSDK.getInstance().openDebug();
    }

    @ReactMethod
    public void setUploadURL(String url, String backupUrl) {
        ZhugeSDK.getInstance().setUploadURL(url, backupUrl);
    }

    @ReactMethod
    public void identify(String uid, ReadableMap pro) {
        debug("identify " + uid);
        HashMap<String, Object> properties = null;
        if (pro != null) {
            properties = pro.toHashMap();
        } else {
            properties = new HashMap<>();
        }
        ZhugeSDK.getInstance().identify(null, uid, properties);
    }

    @ReactMethod
    public void track(String name, ReadableMap pro) {
        debug("track " + name);
        HashMap<String, Object> properties = null;
        if (pro != null) {
            properties = pro.toHashMap();
        } else {
            properties = new HashMap<>();
        }
        ZhugeSDK.getInstance().track(null, name, properties);
    }

    @ReactMethod
    public void trackRevenue(ReadableMap pro) {
        debug("track revenue");
        HashMap<String, Object> properties = null;
        if (pro != null) {
            properties = pro.toHashMap();
        } else {
            properties = new HashMap<>();
        }
        ZhugeSDK.getInstance().trackRevenue(null, properties);
    }

    @ReactMethod
    public void startTrack(String name) {
        debug("startTrack " + name);
        ZhugeSDK.getInstance().startTrack(name);
    }

    @ReactMethod
    public void endTrack(String name, ReadableMap pro) {
        debug("endTrack : " + name);
        JSONObject properties = null;
        if (pro != null) {
            HashMap<String, Object> map = pro.toHashMap();
            Set<String> keySet = map.keySet();
            properties = new JSONObject();
            try {
                for (String key : keySet) {
                    properties.put(key, map.get(key));
                }
            } catch (Exception e) {
                Log.e(TAG, "convert map to json error", e);
            }
        }
        ZhugeSDK.getInstance().endTrack(name, properties);
    }

    @ReactMethod
    public void setUtm(ReadableMap utm) {
        JSONObject info = new JSONObject();
        if (utm != null) {
            HashMap<String, Object> map = utm.toHashMap();
            Set<String> keySet = map.keySet();
            try {
                for (String key : keySet) {
                    info.put(key, map.get(key));
                }
            } catch (Exception e) {
                Log.e(TAG, "convert map to json error", e);
            }
        }
        ZhugeSDK.getInstance().setUtm(info);
    }

    @Override
    public String getName() {
        return MODULE_NAME;
    }

    private void debug(String info) {
        Log.d(TAG, info);
    }
}