#!/bin/bash -xe

source $(readlink -f `dirname $0`)/config.sh

rm -rf cm_tools
git clone $GERRIT_FETCH_URL/semctools/cm_tools
cd ref
../cm_tools/tag-official-release.py -m .repo/manifest.xml $AU_VERSION
repo forall -c 'echo $REPO_PROJECT ; git push $GERRIT_PUSH_URL/$REPO_PROJECT $AU_VERSION'
cd .repo/manifests
cp grease/$AU_VERSION.xml default.xml
sed -i -e 's| revision="[0-9a-f]\+"||g' -e 's| remote="[a-z]\+"||g' -e "s|upstream=\"caf/$BRANCH.\+\"||g" -e '/fetch-original/d' default.xml
sed -i -e "0,/  <project/s|  <project|  <default remote=\"origin\" revision=\"refs/tags/$AU_VERSION\" sync-j=\"4\"/>\n\n  <project|" default.xml
git commit -a -m "default.xml: Updated to $AU_VERSION"
git push $GERRIT_PUSH_URL/platform/manifest HEAD:refs/heads/$REF_BRANCH
