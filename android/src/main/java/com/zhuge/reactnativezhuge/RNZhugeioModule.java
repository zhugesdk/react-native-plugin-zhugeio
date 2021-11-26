package com.zhuge.reactnativezhuge;


import android.util.Log;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.zhuge.reactnativezhuge.utils.RNUtils;
import com.zhuge.reactnativezhuge.utils.RNViewUtils;

import org.json.JSONObject;

public class RNZhugeioModule extends ReactContextBaseJavaModule{

    public RNZhugeioModule(ReactApplicationContext reactContext) {
        super(reactContext);
        try{
            reactContext.addLifecycleEventListener(new ZhugeDataLifecycleListener());
        }catch(Exception e){

        }
    }

    private static final String MODULE_NAME = "RNZhugeioModule";
    private static final String TAG = "ZGDataModule";

    /**
     * 返回一个字符串名字，这个名字在 JavaScript (RN)端标记这个模块。
     */
    @Override
    public String getName() {
        return MODULE_NAME;
    }

    @ReactMethod
    public void trackViewClick(int viewId) {
        RNAgent.trackViewClick(viewId);
    }

    @ReactMethod
    public void trackViewScreen(ReadableMap params) {
        try{
            if (params != null) {
                JSONObject jsonParams = RNUtils.convertToJSONObject(params);
                JSONObject properties = null;
                if(jsonParams.has("zhugeioparams")){
                    properties = jsonParams.optJSONObject("zhugeioparams");
                }
                String url = null;
                if(jsonParams.has("zhugeiourl")){
                    url = jsonParams.getString("zhugeiourl");
                }
                if(url == null){
                    return;
                }
                RNAgent.trackViewScreen(url, properties,true);
            }
        }catch(Exception e){
            Log.e(TAG,e.getMessage());
        }
    }

    @ReactMethod
    public void saveViewProperties(int viewId, boolean clickable, ReadableMap viewProperties) {
        RNAgent.saveViewProperties(viewId, clickable, viewProperties);
    }

    class ZhugeDataLifecycleListener implements LifecycleEventListener {
        public void onHostResume() {
            RNViewUtils.setScreenVisiable(true);
            RNViewUtils.setCurrentActivity(getCurrentActivity());
        }

        public void onHostPause() {
            RNViewUtils.setScreenVisiable(false);
            RNViewUtils.clearCurrentActivityReference();
        }

        public void onHostDestroy() {

        }
    }
}
