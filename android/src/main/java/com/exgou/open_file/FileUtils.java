package com.exgou.open_file;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.storage.StorageManager;
import android.provider.DocumentsContract;
import android.provider.OpenableColumns;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.annotation.Nullable;

import java.io.*;
import java.lang.reflect.Array;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Random;

public class FileUtils {

    private static final String TAG = "FilePickerUtils";
    private static final String PRIMARY_VOLUME_NAME = "primary";

    public static String[] getMimeTypes(final ArrayList<String> allowedExtensions) {

        if (allowedExtensions == null || allowedExtensions.isEmpty()) {
            return null;
        }

        final ArrayList<String> mimes = new ArrayList<>();

        for (int i = 0; i < allowedExtensions.size(); i++) {
            final String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(allowedExtensions.get(i));
            if (mime == null) {
                Log.w(TAG, "Custom file type " + allowedExtensions.get(i) + " is unsupported and will be ignored.");
                continue;
            }

            mimes.add(mime);
        }
        Log.d(TAG, "Allowed file extensions mimes: " + mimes);
        return mimes.toArray(new String[0]);
    }

    public static String getFileName(Uri uri, final Context context) {
        String result = null;

        try {

            if (uri.getScheme().equals("content")) {
                Cursor cursor = context.getContentResolver().query(uri, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null);
                try {
                    if (cursor != null && cursor.moveToFirst()) {
                        result = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                    }
                } finally {
                    cursor.close();
                }
            }
            if (result == null) {
                result = uri.getPath();
                int cut = result.lastIndexOf('/');
                if (cut != -1) {
                    result = result.substring(cut + 1);
                }
            }
        } catch (Exception ex) {
            Log.e(TAG, "Failed to handle file name: " + ex.toString());
        }

        return result;
    }

    public static boolean clearCache(final Context context) {
        try {
            final File cacheDir = new File(context.getCacheDir() + "/file_picker/");
            final File[] files = cacheDir.listFiles();

            if (files != null) {
                for (final File file : files) {
                    file.delete();
                }
            }
        } catch (final Exception ex) {
            Log.e(TAG, "There was an error while clearing cached files: " + ex.toString());
            return false;
        }
        return true;
    }

    public static FileInfo openFileInfo(final Context context, final Uri uri) {
        final FileInfo.Builder fileInfo = new FileInfo.Builder();
        long size = 0;
        String path = "";
        String fileName = "";
        try {
            if (uri.getScheme().equals("content")) {
                Cursor cursor = context.getContentResolver().query(uri, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null);
                try {
                    if (cursor != null && cursor.moveToFirst()) {
                        path = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                        size = cursor.getLong(cursor.getColumnIndex(OpenableColumns.SIZE));
                    }
                } finally {
                    cursor.close();
                }
            }
//            if (result == null) {
//                result = uri.getPath();
//                int cut = result.lastIndexOf('/');
//                if (cut != -1) {
//                    result = result.substring(cut + 1);
//                }
//            }
        } catch (Exception ex) {
            Log.e(TAG, "Failed to handle file name: " + ex.toString());
        }

        fileInfo
                .withPath(path)
                .withName(fileName)
                .withSize(size)
                .withUri(uri.toString());
        return fileInfo.build();
    }


    public static void openFileInfo(final Context context, final Uri uri, final Long id) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                Log.e(TAG, "run: openFileStream", null);
                HttpURLConnection connection = null;
                InputStream in = null;
                OutputStream out = null;
                try {
                    in = context.getContentResolver().openInputStream(uri);

                    URL url = new URL("http://127.0.0.1:9560?id=" + id);
                    connection = (HttpURLConnection) url.openConnection();
                    connection.setRequestMethod("POST");
                    connection.setConnectTimeout(15000);
                    connection.setReadTimeout(60000);
                    connection.setDoOutput(true);
                    connection.setRequestProperty("accept", "*/*");
                    connection.setRequestProperty("connection", "Keep-Alive");
                    connection.setRequestProperty("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
                    connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

                    out = connection.getOutputStream();
                    byte[] buffer = new byte[1024];
                    int len = in.read(buffer);
                    while (len != -1) {
                        out.write(buffer, 0, len);
                        len = in.read(buffer);
                    }
                    out.flush();
                    if (connection.getResponseCode() == 200) {
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (null != in) {
                            in.close();
                        }
                    } catch (Exception e) {
                    }
                    try {
                        if (null != out) {
                            out.close();
                        }
                    } catch (Exception e) {
                    }
                    connection.disconnect();
                }
            }
        }).start();
    }

    @Nullable
    public static String getFullPathFromTreeUri(@Nullable final Uri treeUri, Context con) {
        if (treeUri == null) {
            return null;
        }

        String volumePath = getVolumePath(getVolumeIdFromTreeUri(treeUri), con);
        FileInfo.Builder fileInfo = new FileInfo.Builder();

        if (volumePath == null) {
            return File.separator;
        }

        if (volumePath.endsWith(File.separator))
            volumePath = volumePath.substring(0, volumePath.length() - 1);

        String documentPath = getDocumentPathFromTreeUri(treeUri);

        if (documentPath.endsWith(File.separator))
            documentPath = documentPath.substring(0, documentPath.length() - 1);

        if (documentPath.length() > 0) {
            if (documentPath.startsWith(File.separator)) {
                return volumePath + documentPath;
            } else {
                return volumePath + File.separator + documentPath;
            }
        } else {
            return volumePath;
        }
    }


    @SuppressLint("ObsoleteSdkInt")
    private static String getVolumePath(final String volumeId, Context context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) return null;
        try {
            StorageManager mStorageManager =
                    (StorageManager) context.getSystemService(Context.STORAGE_SERVICE);
            Class<?> storageVolumeClazz = Class.forName("android.os.storage.StorageVolume");
            Method getVolumeList = mStorageManager.getClass().getMethod("getVolumeList");
            Method getUuid = storageVolumeClazz.getMethod("getUuid");
            Method getPath = storageVolumeClazz.getMethod("getPath");
            Method isPrimary = storageVolumeClazz.getMethod("isPrimary");
            Object result = getVolumeList.invoke(mStorageManager);

            final int length = Array.getLength(result);
            for (int i = 0; i < length; i++) {
                Object storageVolumeElement = Array.get(result, i);
                String uuid = (String) getUuid.invoke(storageVolumeElement);
                Boolean primary = (Boolean) isPrimary.invoke(storageVolumeElement);

                // primary volume?
                if (primary && PRIMARY_VOLUME_NAME.equals(volumeId))
                    return (String) getPath.invoke(storageVolumeElement);

                // other volumes?
                if (uuid != null && uuid.equals(volumeId))
                    return (String) getPath.invoke(storageVolumeElement);
            }
            // not found.
            return null;
        } catch (Exception ex) {
            return null;
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private static String getVolumeIdFromTreeUri(final Uri treeUri) {
        final String docId = DocumentsContract.getTreeDocumentId(treeUri);
        final String[] split = docId.split(":");
        if (split.length > 0) return split[0];
        else return null;
    }


    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private static String getDocumentPathFromTreeUri(final Uri treeUri) {
        final String docId = DocumentsContract.getTreeDocumentId(treeUri);
        final String[] split = docId.split(":");
        if ((split.length >= 2) && (split[1] != null)) return split[1];
        else return File.separator;
    }

}