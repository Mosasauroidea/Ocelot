FROM debian:stable-slim

COPY . /srv
WORKDIR /srv

# Uncomment the next two lines if you encounter network issues with debian.org.
# RUN sed -i 's/deb.debian.org/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's/security.debian.org/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install --no-install-recommends -y --allow-unauthenticated \
        build-essential \
        automake \
        cmake \
        default-libmysqlclient-dev \
        libboost-iostreams-dev \
        libboost-system-dev \
        libev-dev \
        libjemalloc-dev \
        libmysql++-dev \
        default-libmysqlclient-dev \
        mariadb-client \
        pkg-config \
        git \
        libgoogle-glog-dev
RUN ./configure CXXFLAGS=-D__DEBUG_BUILD__ --with-mysql-lib=/usr/lib/x86_64-linux-gnu/ \
        --with-ev-lib=/usr/lib/x86_64-linux-gnu/ \
        --with-boost-libdir=/usr/lib/x86_64-linux-gnu/ \
        --with-glog-lib=/usr/lib/x86_64-linux-gnu/
RUN make
RUN apt-get purge -y \
        build-essential \
        cmake \
        pkg-config 
RUN apt-get autoremove -y \
    && apt-get clean -y 
RUN rm -rf /var/lib/apt/lists/* 

ENTRYPOINT [ "/bin/bash", "/srv/entrypoint.sh" ]
