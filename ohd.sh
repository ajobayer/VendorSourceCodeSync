#!/bin/bash -xe

export manifest=$1
export branch=$2
export remote=$3
export bringup=$4
if [ -n "$REPO_MIRROR" ] ; then
  args="--reference=$REPO_MIRROR"
fi

if [ -z $manifest ]; then
  export manifest=platform/manifest
fi
if [ -z $branch ]; then
  export branch=klp-release
fi
if [ -z $remote ]; then
  export remote=ohd
fi

echo "
Manifest: $manifest
Branch:   $branch
Remote:   $remote
Bringup:  $bringup"

export https_proxy=https://xsjpsoft06@proxy.global.mycompany.net:8080
export http_proxy=http://xsjpsoft06@proxy.global.mycompany.net:8080

repo init -u https://partner-android.googlesource.com/$manifest -b $branch --groups=all $args --no-repo-verify
repo sync -d -j4
if [ "$SKIP_PUSH" != "true" ]; then
  repo forall -c 'echo $REPO_PROJECT ; git push git://review.mycompany.net/$REPO_PROJECT refs/remotes/$remote/$branch:refs/heads/$remote/$branch 2>&1'
fi

echo "---- Updating branch $remote/$branch ----"
cd .repo/manifests
git remote | grep semc || git remote add semc git://review.mycompany.net/$manifest
git push semc origin/$branch:refs/heads/$remote/$branch
sleep 30
git fetch --all
git branch -r | grep semc/semc/$remote/$branch || git push semc origin/$branch:refs/heads/semc/$remote/$branch
cd ../../
echo "---- Updating branch semc/$remote/$branch ----"
repo init -u git://review.mycompany.net/$manifest -b semc/$remote/$branch --groups=all $args
cd .repo/manifests
sha1_before=$(git rev-list --max-count=1 HEAD)
git merge -s recursive -X theirs origin/$remote/$branch
sha1=$(git rev-list --max-count=1 HEAD)
sed -i "/revision=\"$remote\//! s/revision=\"\(\(.\+-release\)\|\(builds\)\)/revision=\"$remote\/\1/g" default.xml
if [ "$sha1_before" == "$sha1" ] ; then
  [ -z "`git diff`" ] || git commit -a -m "Adapted revision for internal use"
else
  [ -z "`git diff`" ] || git commit -a --no-edit --amend
fi
sha1=$(git rev-list --max-count=1 HEAD)
cp default.xml new.xml
cd ../../
repo init -b semc/$remote/$branch -m new.xml --groups=all --reference=$repo_reference && repo sync -d -j4
cd .repo/manifests

git push semc $sha1:refs/heads/semc/$remote/$branch
sleep 30
git fetch --all
cd ../../
repo init -u git://review.mycompany.net/$manifest -b semc/$remote/$branch --groups=all $args && repo sync -d -j4

repo manifest -r -o static_manifest.xml
echo $sha1 > manifest_revision

if [ -z "$bringup" ]; then
    exit 0
fi
repo init -u git://review.mycompany.net/$manifest -b $bringup $args && repo sync -d -j4
repo forall -p -c '
repo start $bringup . && \
git reset --hard m/$bringup > /dev/null && \
git log --oneline -1 m/semc/$remote/$branch > /dev/null 2>&1 && \
[ ! -e platform.zip ] && \
git rebase m/semc/$remote/$branch && \
[ -n "$(git log --oneline  m/semc/$remote/$branch..HEAD)" ] && \
echo "Pushing..." && git push origin +HEAD:refs/heads/$bringup'
cd .repo/manifests
git merge -s recursive -X theirs --no-commit origin/semc/$remote/$branch
#TODO

