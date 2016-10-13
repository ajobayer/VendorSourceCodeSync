#!/bin/bash -xe

source $(readlink -f `dirname $0`)/config.sh

mkdir -p grease
cd grease

manifest_name=$(echo $AU_VERSION | grep -o '\([0-9]\{2\}\.\)\{3\}[0-9]\{3\}\.[0-9]\{3\}$').xml

repo init -u git://grease.jpto.mycompany.net/platform/manifest -b $BRANCH -m $manifest_name --reference=$REPO_MIRROR
repo sync -j4 -c

[ $SKIP_PUSH == "true" ] && exit 0

repo forall -c 'echo $REPO_PROJECT; for br in `git branch -r --contains $REPO_LREV | grep "\sgrease/.*/$BRANCH"` ; do git push $GERRIT_PUSH_URL/$REPO_PROJECT refs/remotes/$br:refs/heads/$br ; done'

