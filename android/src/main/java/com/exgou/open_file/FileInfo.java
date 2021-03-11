package com.exgou.open_file;

import android.net.Uri;
import android.util.Log;

import java.util.HashMap;

public class FileInfo {
    final String path;
    final String name;
    final String uri;
    final Long lastModifiedDate;
    final long size;


    public FileInfo(String path, String name, long size, String uri, Long lastModifiedDate) {
        this.path = path;
        this.name = name;
        this.size = size;
        this.uri = uri;
        this.lastModifiedDate = lastModifiedDate;
    }

    public static class Builder {
        private String uri;
        private String path;
        private String name;
        private Long lastModifiedDate;
        private long size;

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

        public Builder withUri(String uri) {
            this.uri = uri;
            return this;
        }

        public Builder withLastModifiedDate(Long lastModifiedDate) {
            this.lastModifiedDate = lastModifiedDate;
            return this;
        }

        public FileInfo build() {
            return new FileInfo(this.path, this.name, this.size, this.uri, this.lastModifiedDate);
        }
    }


    public HashMap<String, Object> toMap() {
        final HashMap<String, Object> data = new HashMap<>();
        data.put("path", path);
        data.put("name", name);
        data.put("size", size);
        data.put("uri", uri);
        data.put("lastModifiedDate", lastModifiedDate);
        return data;
    }
}