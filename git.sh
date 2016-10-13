#!/bin/bash -xe

source=$1
[ -z "$source" ] && exit 1
shift
target=$1
[ -z "$target" ] && exit 1
shift
refspec=$1
[ -z "$refspec" ] && exit 1
shift
push_args=$@

here=`dirname $(readlink -f $0)`
proxy=$here/proxy

if [ ! -e repo ]; then
  GIT_PROXY_COMMAND=$proxy/socks-gw \
      GIT_SSH=$proxy/socks-ssh \
      HTTP_PROXY=http://proxy.global.mycompany.net:8080/ \
      HTTPS_PROXY=https://proxy.global.mycompany.net:8080/ \
      git clone $source repo
  cd repo
else
  cd repo
  GIT_PROXY_COMMAND=$proxy/socks-gw \
      GIT_SSH=$proxy/socks-ssh \
      HTTP_PROXY=http://proxy.global.mycompany.net:8080/ \
      HTTPS_PROXY=https://proxy.global.mycompany.net:8080/ \
      git fetch
fi

git remote | grep somc || git remote add somc $target
git push $push_args somc $refspec
