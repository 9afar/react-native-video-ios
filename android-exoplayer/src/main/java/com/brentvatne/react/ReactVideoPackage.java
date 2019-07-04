package com.brentvatne.react;

import com.brentvatne.exoplayer.ReactExoplayerViewManager;
import com.brentvatne.exoplayer.ReactExoplayerModule;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.Collections;
import java.util.List;
import java.util.Arrays;

public class ReactVideoPackage implements ReactPackage {

    private ReactExoplayerViewManager manager;

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        if (manager == null) {
            manager = new ReactExoplayerViewManager(reactContext);
        }
        return Arrays.<NativeModule>asList(
            new ReactExoplayerModule(reactContext, manager)
        );

    }

    // Deprecated RN 0.47	
    public List<Class<? extends JavaScriptModule>> createJSModules() {	
        return Collections.emptyList();	
    }	


    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        if (manager == null) {
            manager = new ReactExoplayerViewManager(reactContext);
        }
        return Collections.<ViewManager>singletonList(manager);
    }
}
