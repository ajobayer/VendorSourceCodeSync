#!/bin/bash -xe

source $(readlink -f `dirname $0`)/config.sh

mkdir -p ref
cd ref

repo init -u $GERRIT_FETCH_URL/platform/manifest -b $REF_BRANCH --reference=$REPO_MIRROR
repo sync -j4 -c

wget http://grease.jpto.mycompany.net/binaries/outgoing/$BRANCH/prebuilt_CDR005_$AU_VERSION.tar.gz

cd vendor/qcom/proprietary/prebuilt_HY11/
git fetch origin
git reset --hard origin/$REF_BRANCH
cd -

rm -rf vendor/qcom/proprietary/prebuilt_HY11/*
tar xf prebuilt_CDR005_$AU_VERSION.tar.gz
cd vendor/qcom/proprietary/prebuilt_HY11/
git add -A
git commit -m "Imported HY11 from $AU_VERSION

Source: CDR005/$BRANCH/
prebuilt_CDR005_$AU_VERSION.tar.gz
"

[ $SKIP_PUSH == "true" ] && exit 0

#git push $GERRIT_PUSH_URL/platform/vendor/qcom-proprietary/prebuilt-hy11 HEAD:refs/heads/$REF_BRANCH
