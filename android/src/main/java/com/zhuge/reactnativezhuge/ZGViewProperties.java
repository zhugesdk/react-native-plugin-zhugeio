package com.zhuge.reactnativezhuge;

import android.util.Log;
import android.view.View;
import android.widget.ScrollView;

import com.facebook.react.bridge.ReadableMap;
import com.zhuge.reactnativezhuge.utils.RNUtils;

import org.json.JSONObject;

public class ZGViewProperties {
    private  boolean clickable;
    public JSONObject properties;

    public ZGViewProperties(boolean clickable, ReadableMap params){
        this.clickable = clickable;
        this.properties = RNUtils.convertToJSONObject(params);
    }

    public void setViewClickable(View view){
        try{
            if(view != null){
                if(!(view instanceof ScrollView)){
                    view.setClickable(clickable);
                }
            }
        }catch (Exception e){
            Log.d("Zhuge","SAViewProperties clickable error:"+e.getMessage());
        }
    }
}
