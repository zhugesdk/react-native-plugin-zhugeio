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

    private static final String TAG ="RNZhugeio";

    public RNZhugeio(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @ReactMethod
    public void init(){
        ZhugeSDK.getInstance().init(getReactApplicationContext());
    }

    @ReactMethod
    public void openLog(){
        ZhugeSDK.getInstance().openLog();
    }

    @ReactMethod
    public void openDebug(){
        ZhugeSDK.getInstance().openDebug();
    }

    @ReactMethod
    public void setUploadURL(String url,String backupUrl){
        ZhugeSDK.getInstance().setUploadURL(url,backupUrl);
    }

    @ReactMethod
    public void identify(String uid , ReadableMap pro){
        HashMap<String, Object> properties = null;
        if (pro != null){
            properties = pro.toHashMap();
        }
        ZhugeSDK.getInstance().identify(null,uid,properties);
    }

    @ReactMethod
    public void track(String name, ReadableMap pro){
        HashMap<String, Object> properties = null;
        if (pro != null){
            properties = pro.toHashMap();
        }
        ZhugeSDK.getInstance().track(null,name,properties);
    }

    @ReactMethod
    public void startTrack(String name){
        ZhugeSDK.getInstance().startTrack(name);
    }

    @ReactMethod
    public void endTrack(String name, ReadableMap pro){
        JSONObject properties = null;
        if (pro != null){
            HashMap<String, Object> map = pro.toHashMap();
            Set<String> keySet = map.keySet();
            properties = new JSONObject();
            try {
                for (String key : keySet){
                    properties.put(key,map.get(key));
                }
            }catch (Exception e){
                Log.e(TAG,"convert map to json error",e);
            }
        }
        ZhugeSDK.getInstance().endTrack(name,properties);
    }

    @Override
    public void initialize() {
        super.initialize();
    }

    @Override
    public String getName() {
        return "Zhugeio";
    }
}
