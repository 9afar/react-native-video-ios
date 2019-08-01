package com.brentvatne.exoplayer;

import android.net.Uri;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.ReactApplicationContext;
//import com.brentvatne.exoplayer.ExoPlayerDownloadTracker;
import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.RenderersFactory;
import com.google.android.exoplayer2.offline.DownloadHelper;
import com.google.android.exoplayer2.offline.DownloadManager;
import com.google.android.exoplayer2.offline.DownloadProgress;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.offline.DefaultDownloadIndex;
import com.google.android.exoplayer2.offline.DefaultDownloaderFactory;
import com.google.android.exoplayer2.offline.DownloaderConstructorHelper;
import com.google.android.exoplayer2.upstream.cache.Cache;
import com.google.android.exoplayer2.upstream.cache.CacheDataSource;
import com.google.android.exoplayer2.upstream.cache.CacheDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory;
import com.google.android.exoplayer2.upstream.HttpDataSource;
import com.google.android.exoplayer2.upstream.FileDataSourceFactory;
import com.google.android.exoplayer2.upstream.cache.NoOpCacheEvictor;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;
import com.google.android.exoplayer2.database.DatabaseProvider;
import com.google.android.exoplayer2.database.ExoDatabaseProvider;
import com.google.android.exoplayer2.offline.ActionFileUpgradeUtil;
import com.google.android.exoplayer2.offline.DownloadRequest;
import com.google.android.exoplayer2.util.Log;
import com.google.android.exoplayer2.util.Util;
import com.google.android.exoplayer2.trackselection.MappingTrackSelector.MappedTrackInfo;
import com.google.android.exoplayer2.offline.DownloadService;
import com.google.android.exoplayer2.offline.DownloadCursor;
import com.google.android.exoplayer2.offline.Download;
import java.io.File;
import java.io.IOException;
import java.net.URI;

import android.os.Environment;
import android.widget.Toast;

import android.net.Uri;

import com.brentvatne.exoplayer.DataSourceUtil;


public class ReactExoplayerModule extends ReactContextBaseJavaModule implements DownloadHelper.Callback {

    private static final String TAG = "DemoApplication";
    private static final String DOWNLOAD_ACTION_FILE = "actions";
    private static final String DOWNLOAD_TRACKER_ACTION_FILE = "tracked_actions";
    private static final String DOWNLOAD_CONTENT_DIRECTORY = "downloads";

    private ReactExoplayerView reactExoplayerInstance;
    private ReactExoplayerViewManager manager;
    private ReactApplicationContext mContext = null;
    private DownloadManager downloadManager;
//    private ExoPlayerDownloadTracker downloadTracker;
    private File downloadDirectory;
    private Cache downloadCache;

    private ExoDatabaseProvider databaseProvider;
    private DataSource.Factory dataSourceFactory;

    private MappedTrackInfo mappedTrackInfo;

    private DownloadHelper downloadHelper = null;

    public ReactExoplayerModule(ReactApplicationContext reactContext, ReactExoplayerViewManager manager) {
        super(reactContext);
        mContext = reactContext;
        databaseProvider = new ExoDatabaseProvider(mContext);
        // A download cache should not evict media, so should use a NoopCacheEvictor.
        downloadDirectory = mContext.getFilesDir();
        downloadDirectory = new File(downloadDirectory.getAbsolutePath() + "rnvideos");
        downloadCache = DataSourceUtil.getDownloadCache(downloadDirectory, databaseProvider);

        // Create a factory for reading the data from the network.
        dataSourceFactory = DataSourceUtil.getDefaultDataSourceFactory(mContext, null, null);

        // Create the download manager.
        downloadManager = new DownloadManager(
                mContext,
                databaseProvider,
                downloadCache,
                dataSourceFactory);

        ExoPlayerDownloadService.setDownloadManager(downloadManager);
        try {
            DownloadService.start(mContext, ExoPlayerDownloadService.class);
        } catch (IllegalStateException e) {
            DownloadService.startForeground(mContext, ExoPlayerDownloadService.class);
        }

        // Optionally, setters can be called to configure the download manager.
//        downloadManager.setRequirements(requirements);
        downloadManager.setMaxParallelDownloads(3);
//        if (downloadManager == null) {
//            DefaultDownloadIndex downloadIndex = new DefaultDownloadIndex(getDatabaseProvider());
//            upgradeActionFile(
//                    DOWNLOAD_ACTION_FILE, downloadIndex, /* addNewDownloadsAsCompleted= */ false);
//            upgradeActionFile(
//                    DOWNLOAD_TRACKER_ACTION_FILE, downloadIndex, /* addNewDownloadsAsCompleted= */ true);
//            DownloaderConstructorHelper downloaderConstructorHelper =
//                    new DownloaderConstructorHelper(getDownloadCache(), buildHttpDataSourceFactory());
//            downloadManager =
//                    new DownloadManager(
//                            mContext, downloadIndex, new DefaultDownloaderFactory(downloaderConstructorHelper));
//            downloadTracker =
//                    new ExoPlayerDownloadTracker(/* context= */ mContext, buildDataSourceFactory(), downloadManager);
//        }

    }

    @Override
    public String getName() {
        return "VideoManager";
    }

    @ReactMethod
    public void save(ReadableMap options, Promise promise) {
        RenderersFactory renderersFactory =
                new DefaultRenderersFactory(mContext).setExtensionRendererMode(DefaultRenderersFactory.EXTENSION_RENDERER_MODE_OFF);
        Uri uri = Uri.parse("http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8");
        int type = Util.inferContentType(uri, null);
        downloadHelper = null;
        switch (type) {
            case C.TYPE_DASH:
                downloadHelper = DownloadHelper.forDash(uri, dataSourceFactory, renderersFactory);
                break;
            case C.TYPE_SS:
                downloadHelper = DownloadHelper.forSmoothStreaming(uri, dataSourceFactory, renderersFactory);
                break;
            case C.TYPE_HLS:
                downloadHelper = DownloadHelper.forHls(uri, dataSourceFactory, renderersFactory);
                break;
            case C.TYPE_OTHER:
                downloadHelper = DownloadHelper.forProgressive(uri);
                break;
            default:
                throw new IllegalStateException("Unsupported type: " + type);
        }
        downloadHelper.prepare(this);
//        DownloadRequest downloadRequest = downloadHelper.getDownloadRequest(Util.getUtf8Bytes("testVideo"));
//        DownloadService.sendAddDownload(
//                mContext, ExoPlayerDownloadService.class, downloadRequest, /* foreground= */ false);
    }

    @ReactMethod
    public void getDownloads(Promise promise) {
        ExoPlayerDownloadService service = ExoPlayerDownloadService.getInstance();
        if (service != null) {
            DownloadManager dm = service.getDownloadManager();
            if (dm != null) {
                dm.getDownloadIndex();
                DownloadCursor downloadCursor;
                try {
                    downloadCursor = dm.getDownloadIndex().getDownloads();
                    if (downloadCursor == null) {
                        throw new IOException("Unable to get download cursor");
                    }
                } catch (IOException e) {
                    promise.reject(e);
                    return;
                }

                WritableArray writableArray = new WritableNativeArray();

                while (downloadCursor.moveToNext()) {
                    Download download = downloadCursor.getDownload();
                    WritableMap downloadMap = new WritableNativeMap();
                    downloadMap.putInt("state", download.state);
                    downloadMap.putDouble("startTimeMs", download.startTimeMs);
                    downloadMap.putDouble("updateTimeMs", download.updateTimeMs);
                    downloadMap.putInt("stopReason", download.stopReason);
                    // Progress
                    WritableMap progressMap = new WritableNativeMap();
                    progressMap.putDouble("bytesDownloaded", download.getBytesDownloaded());
                    progressMap.putDouble("percentDownloaded", download.getPercentDownloaded());
                    downloadMap.putMap("progress", progressMap);
                    // Request
                    WritableMap requestMap = new WritableNativeMap();
                    requestMap.putString("customCacheKey", download.request.customCacheKey);
                    requestMap.putString("id", download.request.id);
                    // TODO: ? streamKeys?
                    requestMap.putString("type", download.request.type);
                    requestMap.putString("uri", download.request.uri.toString());
                    //
                    downloadMap.putMap("request", requestMap);

                    writableArray.pushMap(downloadMap);
                }

                promise.resolve(writableArray);

                return;
            } else {
                promise.reject("DOWNLOAD_MANAGER_NOT_FOUND", "A required download manager is not found");
            }
        } else {
            promise.reject("DOWNLOAD_SERVICE_NOT_FOUND", "A required download service is not found");
        }
    }

    // DownloadHelper.Callback implementation.

    @Override
    public void onPrepared(DownloadHelper helper) {
        startDownload();
        helper.release();
        mappedTrackInfo = helper.getMappedTrackInfo(/* periodIndex= */ 0);
        return;
//        if (helper.getPeriodCount() == 0) {
//            Log.d(TAG, "No periods found. Downloading entire stream.");
//            startDownload();
//            helper.release();
//            return;
//        }
//        mappedTrackInfo = helper.getMappedTrackInfo(/* periodIndex= */ 0);
//        if (!TrackSelectionDialog.willHaveContent(mappedTrackInfo)) {
//            Log.d(TAG, "No dialog content. Downloading entire stream.");
//            startDownload();
//            helper.release();
//            return;
//        }
//        trackSelectionDialog =
//                TrackSelectionDialog.createForMappedTrackInfoAndParameters(
//                        /* titleId= */ R.string.exo_download_description,
//                        mappedTrackInfo,
//                        /* initialParameters= */ DownloadHelper.DEFAULT_TRACK_SELECTOR_PARAMETERS,
//                        /* allowAdaptiveSelections =*/ false,
//                        /* allowMultipleOverrides= */ true,
//                        /* onClickListener= */ this,
//                        /* onDismissListener= */ this);
//        trackSelectionDialog.show(fragmentManager, /* tag= */ null);
    }

    @Override
    public void onPrepareError(DownloadHelper helper, IOException e) {
        Toast.makeText(
                mContext.getApplicationContext(), "downloadStartError", Toast.LENGTH_LONG)
                .show();
        Log.e(TAG, "Failed to start download", e);
    }

    private void startDownload() {
        startDownload(buildDownloadRequest());
    }

    private void startDownload(DownloadRequest downloadRequest) {
        DownloadService.sendAddDownload(
                mContext, ExoPlayerDownloadService.class, downloadRequest, /* foreground= */ false);
    }

    private DownloadRequest buildDownloadRequest() {
        return downloadHelper.getDownloadRequest(Util.getUtf8Bytes("testVideo.m3u8"));
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        downloadCache.release();
    }
}