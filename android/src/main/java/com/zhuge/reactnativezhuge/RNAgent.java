package com.zhuge.reactnativezhuge;

import android.text.TextUtils;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.facebook.react.bridge.ReadableMap;
import com.zhuge.analysis.deepshare.utils.Log;
import com.zhuge.analysis.stat.ZhugeSDK;
import com.zhuge.analysis.util.AutoConstants;
import com.zhuge.analysis.util.AutoTrackUtils;
import com.zhuge.reactnativezhuge.utils.RNUtils;
import com.zhuge.reactnativezhuge.utils.RNViewUtils;

import org.json.JSONObject;


public class RNAgent {
    private static final SparseArray<ZGViewProperties> viewPropertiesArray = new SparseArray<>();
    private static final String TAG = "RNAgent";
    private static final String KEY_PAGE_TITLE = "$page_title";
    private static final String KEY_SCREEN_NAME = "$screen_name";
    private static final String KEY_ELEMENT_TYPE = "$element_type";
    private static final String KEY_ELEMENT_CONTENT = "$element_content";
    private static final String KEY_URL = "$url";
    private static final String KEY_EID = "$eid";


    public static void trackViewScreen(String url, JSONObject properties,boolean isAuto){
        try{
            String screenName = url;
            if(properties == null){
                properties = new JSONObject();
            }
            if(properties.has(KEY_SCREEN_NAME)){
                screenName = properties.getString(KEY_SCREEN_NAME);
            }
            String title = screenName;
            if(properties.has(KEY_PAGE_TITLE)){
                title = properties.getString(KEY_PAGE_TITLE);
            }
            if(screenName != null){
                properties.put(KEY_SCREEN_NAME,screenName);
            }
            if(title != null){
                properties.put(KEY_PAGE_TITLE,title);
            }
            RNViewUtils.saveScreenAndTitleAndUrl(screenName,title,url);
            //关闭 AutoTrack
            if (isAuto && !ZhugeSDK.getInstance().isEnableAutoTrack()) {
                return;
            }
            properties.put(KEY_EID,"pv");
            properties.put(KEY_URL,url);
            ZhugeSDK.getInstance().autoTrackEvent(properties);
        }catch(Exception e){
            Log.e(TAG,e.getMessage());
        }
    }

    public static void trackViewClick(int viewId){
        //关闭 AutoTrack
        if (!ZhugeSDK.getInstance().isEnableAutoTrack()) {
            return;
        }
        try {
            View clickView = RNViewUtils.getTouchViewByTag(viewId);
            if (clickView != null) {
                JSONObject properties = new JSONObject();
                if(RNViewUtils.getTitle() != null){
                    properties.put(KEY_PAGE_TITLE,RNViewUtils.getTitle());
                }
                if(RNViewUtils.getScreenName() != null){
                    properties.put(KEY_SCREEN_NAME,RNViewUtils.getScreenName());
                }
                ZGViewProperties viewProperties = viewPropertiesArray.get(viewId);
                if(viewProperties != null && viewProperties.properties != null && viewProperties.properties.length() > 0){
                    if(viewProperties.properties.optBoolean("ignore", false)){
                        return;
                    }
                    viewProperties.properties.remove("ignore");
                    RNUtils.mergeJSONObject(viewProperties.properties, properties);
                }
                if (clickView instanceof TextView){
                    String content =  ((TextView) clickView).getText().toString();
                    properties.put(KEY_ELEMENT_CONTENT,content);
                } else if (clickView instanceof ViewGroup) {
                    StringBuilder stringBuilder = new StringBuilder();
                    String viewText = AutoTrackUtils.traverseView(stringBuilder, (ViewGroup) clickView);
                    if (!TextUtils.isEmpty(viewText)) {
                        viewText = viewText.substring(0, viewText.length() - 1);
                    }
                    properties.put(KEY_ELEMENT_CONTENT, viewText);
                }
                properties.put(KEY_ELEMENT_TYPE,"RNView");
                properties.put(KEY_URL,RNViewUtils.getUrl());
                properties.put(KEY_EID,"click");
                ZhugeSDK.getInstance().autoTrackEvent(properties);
            }
        } catch (Exception e) {
            Log.e(TAG,e.getMessage());
        }
    }

    public static void saveViewProperties(int viewId, boolean clickable, ReadableMap viewProperties) {
        if(clickable){
            viewPropertiesArray.put(viewId, new ZGViewProperties(clickable, viewProperties));
        }
    }

    public static void addView(View view,int index){
        ZGViewProperties properties = viewPropertiesArray.get(view.getId());
        if(properties != null){
            properties.setViewClickable(view);
        }
    }
}
