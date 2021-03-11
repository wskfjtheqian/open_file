package com.exgou.open_file;

import android.net.Uri;

import java.util.HashMap;

public class FileInfo {

    final String path;
    final String name;
    final String uri;
    final long size;
    final byte[] bytes;

    public FileInfo(String path, String name, long size, byte[] bytes, String uri) {
        this.path = path;
        this.name = name;
        this.size = size;
        this.bytes = bytes;
        this.uri = uri;
    }

    public static class Builder {
        private String uri;
        private String path;
        private String name;
        private long size;
        private byte[] bytes;

        public Builder withPath(String path) {
            this.path = path;
            return this;
        }

        public Builder withName(String name) {
            this.name = name;
            return this;
        }

        public Builder withSize(long size) {
            this.size = size;
            return this;
        }

        public Builder withData(byte[] bytes) {
            this.bytes = bytes;
            return this;
        }

        public Builder withUri(String uri) {
            this.uri = uri;
            return this;
        }

        public FileInfo build() {
            return new FileInfo(this.path, this.name, this.size, this.bytes, this.uri);
        }
    }


    public HashMap<String, Object> toMap() {
        final HashMap<String, Object> data = new HashMap<>();
        data.put("path", path);
        data.put("name", name);
        data.put("size", size);
        data.put("bytes", bytes);
        data.put("uri", uri);
        return data;
    }
}