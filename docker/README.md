# Docker Deployment for GPW Tracker Ocelot

## Prepare Docker Image
Run the command from the root directory of this repository.
```shell
docker build --no-cache -t gpw-ocelot:latest -f docker/Dockerfile.debug .
```

Here are three docker configurations for build:
1. `Dockerfile` for production
2. `Dockerfile.debug` for local development. It defines `__DEBUG_BUILD__` so that clients from local networks are allowed for test purpose
3. `Dockderfile.dev` prepares a pure linux environment (without building ocelot) for develop

## Start the container
1. Deploy `Gazelle` firstly by following instructions here [Gazelle Setup-Development-Environmen](https://git.kshare.club:9443/Idiots/GPW/Gazelle/-/blob/dev/docs/Setup-Development-Environment.md)
   
   1a. Remove the expose of port `34000` in file `docker-compose.yml`
   
   1b. Create `classes/confige.env.php` and define `ENV_OMDB_API_KEY`, `ENV_DOUBAN_API_URL`, `ENV_TMDB_API_KEY` according to [wiki](https://git.kshare.club:9443/Idiots/Wiki/-/wikis/Key)
   
   1c. Create `classes/config.php` based on `classes/config.template.php` and modify `MemcachedServers` to `array('host' => 'gpw-memcached', 'port' => 11211, 'buckets' => 1),`

2. The container can be started using the previously built image `gpw-ocelot:latest`. We use `gazelle` as parent here 
   so that the containers under the same parent `gazelle` can communicate with each other under the same network.
```shell
docker-compose -p gazelle up -d
```

## Testing Ocelot
1. Register as a user from start page `http://localhost:9000/`
2. Upload a torrent (may need to restart the `gpw-ocelot` container to reload torrents from database if `gpw-web` is started with tracker disabled)
3. Send `announce` request for testing, here is an example:
```shell
curl 'http://127.0.0.1:34000/<YOUR PASSKEY>/announce?info_hash=<TORRENT INFO HASH>&peer_id=-DE203s-TQaEVc.-mzuO&port=32777&uploaded=0&downloaded=0&left=0&corrupt=0&key=449DBE8D&event=completed&numwant=200&compact=1&no_peer_id=1&supportcrypto=1&redundant=0'  --output temp
```
