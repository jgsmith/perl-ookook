#! /bin/sh

starman --listen 127.0.0.1:5000 --workers 3 --preload-app ookook.psgi
