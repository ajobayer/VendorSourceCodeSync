#!/bin/bash -xe

source $(readlink -f `dirname $0`)/config.sh

sha1=`git --git-dir=ref/vendor/qcom/proprietary/prebuilt_HY11/.git rev-list HEAD -1`

grease/vendor/qcom/proprietary/grease/utilities/join_manifests.sh caf/.repo/manifest.xml grease/.repo/manifest.xml > $AU_VERSION.xml
sed -i 's|fetch=|fetch=".." fetch-original=|g' $AU_VERSION.xml
sed -i "s|</manifest>|  <project name=\"platform/vendor/qcom-proprietary/prebuilt-hy11\" path=\"vendor/qcom/proprietary/prebuilt_HY11\" revision=\"$sha1\" remote=\"origin\" sync-c=\"true\" upstream=\"$REF_BRANCH\"/>\n</manifest>|" $AU_VERSION.xml
sed -i 's|<manifest>|<manifest>\n  <remote fetch=".." name="origin" review="http://review.mycompany.net"/>|' $AU_VERSION.xml
sed -i "s|upstream=\"$BRANCH|upstream=\"caf/$BRANCH|g" $AU_VERSION.xml

cp $AU_VERSION.xml ref/.repo/manifests/grease/
cd ref
repo init -m grease/$AU_VERSION.xml --reference=$REPO_MIRROR
repo sync -j4 -c
cd .repo/manifests
git add grease/$AU_VERSION.xml
git commit -m "Combined manifest for $AU_VERSION"
git push origin HEAD:refs/heads/$REF_BRANCH
