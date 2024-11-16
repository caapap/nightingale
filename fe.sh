#!/bin/bash

cp -f ./docker/initsql/a-n9e.sql n9e.sql

if [ ! -d "./pub" ]; then
    TAG=$(curl -sX GET https://api.github.com/repos/caapap/fe/releases/latest   | awk '/tag_name/{print $4;exit}' FS='[""]')
    if ! curl -o stellar-fe-${TAG}.zip -L https://github.com/caapap/fe/releases/download/${TAG}/stellar-fe-${TAG}.zip; then
        echo "failed to download stellar-fe-${TAG}.zip!"
        exit 1
    fi

    if ! unzip stellar-fe-${TAG}.zip; then
        echo "failed to untar stellar-fe-${TAG}.zip!"
        exit 2
    fi
fi

GOPATH=$(go env GOPATH)
GOPATH=${GOPATH:-/home/runner/go}

# Embed files into a go binary
# go install github.com/rakyll/statik
if ! $GOPATH/bin/statik -src=./pub -dest=./front; then
    echo "failed to embed files into a go binary!"
    exit 4
fi