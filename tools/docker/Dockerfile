FROM ubuntu:14.04
MAINTAINER James Seward <james@jamesoff.net>
RUN apt-get update && apt-get install -y git python tcl-dev gcc telnet make wget
RUN useradd -m bmotion
RUN su -c "cd /home/bmotion && mkdir src && cd src \
	&& wget ftp://ftp.eggheads.org/pub/eggdrop/source/1.6/eggdrop1.6.21.tar.bz2 \
	&& tar xf eggdrop1.6.21.tar.bz2 \
	&& cd eggdrop1.6.21 \
	&& ./configure --with-tcllib=/usr/lib/x86_64-linux-gnu/libtcl8.6.so --with-tclinc=/usr/include/tcl8.6/tcl.h \
	&& make config \
	&& make \
	&& make install" \
	bmotion
CMD ["/bin/bash"]
