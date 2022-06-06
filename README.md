# Ocelot

Ocelot is a BitTorrent tracker written in C++, forked from [WhatCD/Ocelot](https://github.com/WhatCD/Ocelot). It supports requests over TCP and can track IPv4/IPv6 peers.

## New Features

* Support ipv6 protocol
* Discount on torrents, such as 100%, 50%, 30% free, which is supported by traditional tracker
* Statistics of users' uploaded/downloaded volume size, last seed time, etc.
* Fixed some issues

## Ocelot Compile-time Dependencies

* [GCC/G++](http://gcc.gnu.org/) (4.7+ required; 4.8.1+ recommended)
* [Boost](http://www.boost.org/) (1.55.0+ required)
* [libev](http://software.schmorp.de/pkg/libev.html) (required)
* [MySQL++](http://tangentsoft.net/mysql++/) (3.2.0+ required)
* [TCMalloc](http://goog-perftools.sourceforge.net/doc/tcmalloc.html) (optional, but strongly recommended)

## Installation

The Gazelle installation guides include instructions for installing Ocelot as a part of the Gazelle project.

### Standalone Installation

* Create the following tables according to the Gazelle database schema, i.e. `gazelle.sql`:
     - `torrents`
     - `users_freeleeches`
     - `users_main`
     - `xbt_client_whitelist`
     - `xbt_files_users`
     - `xbt_snatched`
     - `users_freetorrents`
     - `users_torrents`

* Edit `ocelot.conf`(copied from template `ocelot.conf.dist`) to your liking.

* Build Ocelot:
```shell
apt-get update

apt-get install --no-install-recommends -y \
build-essential \
automake \
cmake \
default-libmysqlclient-dev \
libboost-iostreams-dev \
libboost-system-dev \
libev-dev \
libjemalloc-dev \
libmysql++-dev \
pkg-config

./configure --with-mysql-lib=/usr/lib/x86_64-linux-gnu/ \
--with-ev-lib=/usr/lib/x86_64-linux-gnu/ \
--with-boost-libdir=/usr/lib/x86_64-linux-gnu/

make && make install
```

* Run Ocelot:
```shell
./ocelot
```
If the service is to run in production, [systemd](https://wiki.ubuntu.com/systemd) is recommended to manage it.


### Running Ocelot in Container

* Prepare Docker Image

  Run these commands from the root directory of this repository.
```shell
docker build --no-cache -t gpw-ocelot:latest -f docker/Dockerfile .
```
  If this is to deploy in production, remove `CXXFLAGS=-D__DEBUG_BUILD__` which is for testing purpose,
such as allowing peer connections from local networks

* Start the containers

  - Deploy `Gazelle` firstly by following instructions [GazellePW Getting Started](https://github.com/Mosasauroidea/GazellePW/blob/main/docs/Getting-Started.md)
  - The container can be started using the previously built image `gpw-ocelot:latest`. We use `gazelle` as parent here
     so that the containers under the same parent `gazelle` can communicate with each other under the same network. 
```shell    
docker compose -p gazelle up -d
```

## Testing Ocelot

Note: The following instructions are assumed that `GazellePW`(`gpw-web`) and `Ocelot`(`gpw-ocelot`) have already been running in `container` mode.

* Register as a user from start webpage `http://localhost:9000`
  
* Upload a torrent (may need to restart the `gpw-ocelot` container to reload torrents from database if `gpw-web` is started with tracker disabled)

* Send `announce` request for testing, here is an example:
```shell
curl 'http://127.0.0.1:34000/<YOUR PASSKEY>/announce?info_hash=<TORRENT INFO HASH ENCODED>&peer_id=-DE203s-TQaEVc.-mzuO&port=32777&uploaded=0&downloaded=0&left=0&corrupt=0&key=449DBE8D&event=completed&numwant=200&compact=1&no_peer_id=1&supportcrypto=1&redundant=0'  --output temp
```
### Run-time options:

* `-c <path/to/ocelot.conf>` - Path to config file. If unspecified, the current working directory is used.
* `-v` - Print queue status every time a flush is initiated.

### Signals

* `SIGHUP` - Reload config
* `SIGUSR1` - Reload torrent list, user list and client whitelist
