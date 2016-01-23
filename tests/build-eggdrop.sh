#!/bin/bash

set -ex

wget -L http://www.eggheads.org/redirect.php?url=ftp://ftp.eggheads.org/pub/eggdrop/source/1.6/eggdrop1.6.21.tar.gz
tar xvf eggdrop1.6.21.tar.gz
cd eggdrop1.6.21
./configure
make config
make
make install

# Link bmotion in to eggdrop scripts dir
cd ~/eggdrop/scripts
ln -s $TRAVIS_BUILD_DIR bmotion

# Copy bmotion config in
cd bmotion
mkdir local
cd local
cp $TRAVIS_BUILD_DIR/tests/settings.tcl .

# Copy eggdrop config in
cd ~/eggdrop
cp $TRAVIS_BUILD_DIR/tests/eggdrop-test.conf .
