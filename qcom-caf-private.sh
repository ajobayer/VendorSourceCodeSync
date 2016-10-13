#!/bin/bash -xe

source $(readlink -f `dirname $0`)/config.sh

mkdir -p caf
cd caf

GIT_SSH=$(readlink -f `dirname $0`)/proxy/socks-ssh repo init -u ssh://git@git.codeaurora.org:9222/$CAF_MANIFEST -b release -m caf_$AU_VERSION.xml --reference=$REPO_MIRROR
GIT_SSH=$(readlink -f `dirname $0`)/proxy/socks-ssh repo sync -j4 -c

[ $SKIP_PUSH == "true" ] && exit 0

repo forall -c 'echo $REPO_PROJECT; for br in `git branch -r --contains $REPO_LREV | grep "\scaf/$BRANCH"` ; do git push $GERRIT_PUSH_URL/$REPO_PROJECT refs/remotes/$br:refs/heads/$br ; done'
