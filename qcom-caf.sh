#!/bin/bash -xe

source $(readlink -f `dirname $0`)/config.sh

mkdir -p caf
cd caf

repo init -u git://caf-mirror.jpto.mycompany.net/$CAF_MANIFEST -b release -m caf_$AU_VERSION.xml --reference=$REPO_MIRROR
repo sync -j4 -c

[ $SKIP_PUSH == "true" ] && exit 0

repo forall -c 'echo $REPO_PROJECT; for br in `git branch -r --contains $REPO_LREV | grep "\scaf/$BRANCH"` ; do git push $GERRIT_PUSH_URL/$REPO_PROJECT refs/remotes/$br:refs/heads/$br ; done'
