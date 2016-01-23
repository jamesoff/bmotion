#!/bin/bash

set -ex

wget -L http://www.eggheads.org/redirect.php?url=ftp://ftp.eggheads.org/pub/eggdrop/source/1.6/eggdrop1.6.21.tar.gz
tar xvf eggdrop1.6.21.tar.gz
cd eggdrop1.6.21
./configure
make config
make
make install

cd ~/eggdrop/scripts
ln -s $TRAVIS_BUILD_DIR bmotion
cd ~/eggdrop
cp $TRAVIS_BUILD_DIR/tests/eggdrop-test.conf .
