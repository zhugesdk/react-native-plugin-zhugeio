package com.zhuge.reactnativezhuge.utils;

import android.app.Activity;
import android.view.View;

import java.lang.ref.SoftReference;

public class RNViewUtils {

    private static SoftReference mSoftCurrentActivityReference;
    private static String currentTitle;
    private static String currentScreenName;
    private static String currentUrl;
    public static boolean isScreenVisiable = false;

    public static View getTouchViewByTag(int viewTag) {
        try {
            Activity currentActivity = getCurrentActivity();
            if (currentActivity != null) {
                return currentActivity.findViewById(viewTag);
            }
        } catch (Exception ignored) {

        }
        return null;
    }

    public static void saveScreenAndTitleAndUrl(String screenName, String title, String url) {
        currentScreenName = screenName;
        currentTitle = title;
        currentUrl = url;
    }

    public static String getTitle() {
        return currentTitle;
    }

    public static String getUrl() {
        return currentUrl;
    }

    public static String getScreenName() {
        return currentScreenName;
    }


    public static void setScreenVisiable(boolean isVisiable) {
        isScreenVisiable = isVisiable;
    }

    public static void setCurrentActivity(Activity currentActivity) {
        clearCurrentActivityReference();
        mSoftCurrentActivityReference = new SoftReference(currentActivity);
    }

    public static Activity getCurrentActivity() {
        if (mSoftCurrentActivityReference == null) {
            return null;
        }
        return (Activity) mSoftCurrentActivityReference.get();
    }

    public static void clearCurrentActivityReference() {
        if (mSoftCurrentActivityReference != null) {
            mSoftCurrentActivityReference.clear();
            mSoftCurrentActivityReference = null;
        }
    }
}
