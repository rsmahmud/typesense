# docker build --file $PROJECT_DIR/docker/development.Dockerfile --tag typesense/typesense-development:latest $PROJECT_DIR/docker
# 
# $ docker push typesense/typesense-development:latest

FROM typesense/ubuntu-10-04-gcc:6.4.0

ENV PATH /usr/local/gcc-6.4.0/bin/:$PATH
ENV LD_LIBRARY_PATH /usr/local/gcc-6.4.0/lib64

RUN apt-get install -y python-software-properties \
	&& add-apt-repository ppa:git-core/ppa \
	&& apt-get update \
	&& apt-get install -y \
	zlib1g-dev \
	liblist-compare-perl \
	libidn11 \
	git

ADD https://cmake.org/files/v3.15/cmake-3.15.2-Linux-x86_64.tar.gz /opt/cmake-3.15.2-Linux-x86_64.tar.gz
RUN tar -C /opt -xvzf /opt/cmake-3.15.2-Linux-x86_64.tar.gz
RUN cp -r /opt/cmake-3.15.2-Linux-x86_64/* /usr

ADD https://launchpad.net/ubuntu/+archive/primary/+files/snappy_1.1.3.orig.tar.gz /opt/snappy_1.1.3.orig.tar.gz
RUN tar -C /opt -xf /opt/snappy_1.1.3.orig.tar.gz
RUN mkdir /opt/snappy-1.1.3/build && cd /opt/snappy-1.1.3/build && ../configure && make -j8 && make install

ADD https://github.com/unicode-org/icu/releases/download/release-61-1/icu4c-61_1-src.tgz /opt/icu4c-61_1-src.tgz
RUN tar -C /opt -xf /opt/icu4c-61_1-src.tgz
RUN cd /opt/icu/source && echo "#define U_DISABLE_RENAMING 1" >> common/unicode/uconfig.h && \
    echo "#define U_STATIC_IMPLEMENTATION 1" >> common/unicode/uconfig.h && \
    echo "#define U_USING_ICU_NAMESPACE 0" >> common/unicode/uconfig.h
RUN cd /opt/icu/source && ./runConfigureICU Linux --disable-samples --disable-tests --enable-static \
    --disable-shared --disable-renaming && make -j8 && make install

ADD https://openssl.org/source/openssl-1.1.1d.tar.gz /opt/openssl-1.1.1d.tar.gz
RUN tar -C /opt -xvzf /opt/openssl-1.1.1d.tar.gz
RUN cd /opt/openssl-1.1.1d && sh ./config --prefix=/usr/local --openssldir=/usr/local zlib
RUN make -C /opt/openssl-1.1.1d depend
RUN make -C /opt/openssl-1.1.1d -j8
RUN make -C /opt/openssl-1.1.1d install

ADD https://github.com/curl/curl/releases/download/curl-7_65_3/curl-7.65.3.tar.gz /opt/curl-7.65.3.tar.gz
RUN tar -C /opt -xf /opt/curl-7.65.3.tar.gz
RUN cd /opt/curl-7.65.3 && LIBS="-ldl -lpthread" ./configure --disable-shared --with-ssl=/usr/local \
--without-ca-bundle --without-ca-path && make -j8 && make install

ENV CC /usr/local/gcc-6.4.0/bin/gcc
ENV CXX /usr/local/gcc-6.4.0/bin/g++
