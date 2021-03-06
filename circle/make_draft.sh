#!/bin/sh
set -ex
wget -q https://github.com/aktau/github-release/releases/download/v0.6.2/linux-amd64-github-release.tar.bz2
tar jxvf linux-amd64-github-release.tar.bz2
GITHUB_RELEASE=`pwd`/bin/linux/amd64/github-release

upload()
{
  NAME=$1
  FILE=$2
  $GITHUB_RELEASE upload --user $CIRCLE_PROJECT_USERNAME --repo $CIRCLE_PROJECT_REPONAME --tag $CIRCLE_TAG --name \"$NAME\" --file $FILE
}

make_zip()
{
  OLDDIR=`pwd`
  ARCH=$1
  cp -r release/electron-mattermost-$ARCH /tmp/electron-mattermost-$CIRCLE_TAG-$ARCH
  cd /tmp
  zip -9 -r electron-mattermost-$CIRCLE_TAG-$ARCH.zip electron-mattermost-$CIRCLE_TAG-$ARCH
  cd $OLDDIR
}

make_tar_gz()
{
  OLDDIR=`pwd`
  ARCH=$1
  cp -r release/electron-mattermost-$ARCH /tmp/electron-mattermost-$CIRCLE_TAG-$ARCH
  cd /tmp
  tar zcvf electron-mattermost-$CIRCLE_TAG-$ARCH.tar.gz electron-mattermost-$CIRCLE_TAG-$ARCH
  cd $OLDDIR
}

deploy()
{
  ARCH=$1
  ARCHIVE_FORMAT=$2
  case "$ARCHIVE_FORMAT" in
    "zip" ) make_zip $ARCH ;;
    "tar.gz" ) make_tar_gz $ARCH ;;
    "*" ) echo "Invalid ARCHIVE_FORMAT: $ARCHIVE_FORMAT" && exit 1 ;;
  esac
  FILE=electron-mattermost-$CIRCLE_TAG-$ARCH.$ARCHIVE_FORMAT
  upload "$FILE" /tmp/$FILE
}

$GITHUB_RELEASE release --user $CIRCLE_PROJECT_USERNAME --repo $CIRCLE_PROJECT_REPONAME --tag $CIRCLE_TAG --draft

deploy win32 zip
deploy win64 zip
deploy osx tar.gz
deploy linux-ia32 tar.gz
deploy linux-x64 tar.gz
