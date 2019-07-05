package com.brentvatne.exoplayer;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

public class ReactExoplayerModule extends ReactContextBaseJavaModule {

    private ReactExoplayerView reactExoplayerInstance;
    private ReactExoplayerViewManager manager;

    public ReactExoplayerModule(ReactApplicationContext reactContext, ReactExoplayerViewManager manager) {
        super(reactContext);
        if (manager != null) {
            this.manager = manager;
            reactExoplayerInstance = manager.getReactExoplayerInstance();
        }

    }

    @Override
    public String getName() {
        return "VideoManager";
    }

    @ReactMethod
    public void save(ReadableMap options, Promise promise) {
        if (reactExoplayerInstance == null && manager != null) {
            reactExoplayerInstance = manager.getReactExoplayerInstance();
        }
        if (reactExoplayerInstance != null) {
            reactExoplayerInstance.save(options, promise);
        } else {
            promise.reject("No exoplayer instance");
        }
    }
}