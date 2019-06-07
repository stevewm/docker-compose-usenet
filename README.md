# Automated Usenet Pipeline

[![Build Status](https://travis-ci.org/duhio/docker-compose-usenet.svg?branch=master)](https://travis-ci.org/duhio/docker-compose-usenet)

An automated Usenet media pipeline with reverse proxy and auto-updating of services, predominantly using the popular linuxserver Docker images. Includes:

- [SABnzbd](https://hub.docker.com/r/linuxserver/sabnzbd/) (can be replaced with NZBGet - see further down)
- [Sonarr](https://hub.docker.com/r/linuxserver/sonarr/)
- [Radarr](https://hub.docker.com/r/linuxserver/radarr/)
- [Lidarr](https://hub.docker.com/r/linuxserver/lidarr/)
- [Mylar](https://hub.docker.com/r/linuxserver/mylar/)
- [LazyLibrarian](https://hub.docker.com/r/linuxserver/lazylibrarian/)
- [NZBHydra v2](https://hub.docker.com/r/linuxserver/hydra2/)
- [Ombi](https://hub.docker.com/r/linuxserver/ombi/)
- [FlexGet](https://hub.docker.com/r/cpoppema/docker-flexget/)
- [Plex](https://hub.docker.com/r/linuxserver/plex/)
- [Tautulli (aka PlexPy)](https://hub.docker.com/r/linuxserver/tautulli/)
- [Heimdall](https://hub.docker.com/r/duhio/heimdall-https/)
- [Watchtower](https://github.com/containrrr/watchtower)
- [DDClient](https://hub.docker.com/r/linuxserver/ddclient/)

## Requirements

- [Docker](https://store.docker.com/search?type=edition&offering=community)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Domain of your own (usage of a free DDNS service such as DuckDNS is not advised or supported)

## Usage

### Setup

Using `example.env`, create a file called `.env` (in the directory you cloned the repo to) by populating the variables with your desired values (see key below).

| Variable         | Purpose                                                                                   |
|------------------|-------------------------------------------------------------------------------------------|
| CONFIG           | Where the configs for services will live. Each service will have a subdirectory here      |
| DOWNLOAD         | Where SAB will download files to. The complete and incomplete dirs will be put here       |
| DATA             | Where your data is stored and where sub-directories for tv, movies, etc will be put       |
| DOMAIN           | The domain you want to use for access to services from outside your network               |
| TZ               | Your timezone. [List here.](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) |
| HTPASSWD         | HTTP Basic Auth entries in HTPASSWD format ([generate here](http://www.htaccesstools.com/htpasswd-generator/))|

Values for User ID (PUID) and Group ID (PGID) can be found by running `id user` where `user` is the owner of the volume directories on the host.

#### Traefik

1. Create a folder called `traefik` in your chosen config directory. Everything below should be executed inside the `traefik` directory
2. Run `touch acme.json; chmod 600 acme.json`
3. Copy `traefik.toml` to the `traefik` directory in your config folder and replace the example email with your own

#### DDClient

If you have a static IP this isn't necessary, and you can simply remove the service entry for ddclient.

1. Create a directory in your chosen config directory called `ddclient`
2. Run `touch ddclient.conf` in the directory
3. Use the [protocol documentation](https://sourceforge.net/p/ddclient/wiki/protocols/) to create a config for your chosen DNS provider

### Running

In the directory containing the files, run `docker-compose up -d`. Each service should be accessible (assuming you have port-forwarded on your router) on `<service-name>.<your-domain>`. Heimdall should be accessible on `<your-domain>`, from where you can set it up to provide a convenient homepage with links to services. The Traefik dashboard should be accessible on `monitor.<your-domain>`.

#### Service Configuration

When plumbing each of the services together you can simply enter the service name and port instead of using IP addresses. For example, when configuring a download client in Sonarr/Radarr enter `sabnzbd` in the Host field and `8080` in the Port field. The same applies for other services such as NZBHydra.

#### Customisation

##### NZBGet

To use NZBGet instead of Sabnzbd, simply replace the `sabnzbd` service entry with the following:

```yaml
nzbget:
  image: linuxserver/nzbget:latest
  container_name: nzbget
  hostname: nzbget
  ports:
    - "6789:6789"
  volumes:
    - ${CONFIG}/nzbget:/config
    - ${DOWNLOAD}/complete:/downloads
    - ${DOWNLOAD}/incomplete:/incomplete-downloads
    - ${DOWNLOAD}/watch:/watch
  environment:
    - PGID
    - PUID
    - TZ
  labels:
    traefik.enable: "true"
    traefik.port: "6789"
    traefik.frontend.rule: "Host:nzbget.${DOMAIN}"
    traefik.frontend.auth.basic: "${HTPASSWD}"
    com.centurylinklabs.watchtower.enable: "true"
  restart: unless-stopped
```

##### Service customisation

To add a new volume mount or otherwise customise an existing service, create a file called `docker-compose.override.yml`.

For example, to add new volume mounts to existing services:

```yaml
version: '3'

services:
  radarr:
    volumes:
      - ${DATA}/documentaries:/media/documentaries

  plex:
    volumes:
      - ${DATA}/documentaries:/media/documentaries
```

You can also add new services to the stack using the same method. 

See the [docker-compose documentation](https://docs.docker.com/compose/extends/#adding-and-overriding-configuration) for more information.

## Notes / Caveats

### Plex

Plex config may not be visible until you SSH tunnel:

- `ssh -L 8080:localhost:32400 user@dockerhost`

Once done you can browse to `localhost:8080/web/index.html` and set up your server.

### UnRAID Usage

Only tested on UnRAID *6.4.1+*.

#### Installing Docker Compose

Add the following to `/boot/config/go` in order to install docker-compose on each boot:

```bash
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

#### Persisting user-defined networks

By default, UnRAID will not persist user-defined Docker networks such as the one this stack will create. You'll need to enable this setting in order to avoid having to re-run `docker-compose up -d` every time your server is rebooted. It's found in the _Docker_ tab, you'll need to set _Advanced View_ to On and stop the Docker service to make the change.

#### UnRAID UI port conflict

You'll need to either change the HTTPS port specified for the UnRAID WebUI (in _Settings_ -> _Identification_) or change the host port on the Traefik container to something other than 443 and forward 443 to that port on your router (eg 443 on router forwarded to 444 on Docker host) in order to allow Traefik to work properly.

## Help / Contributing

If you need assistance, please file an issue. Please do read the [existing closed issues](https://github.com/duhio/docker-compose-usenet/issues?q=is%3Aissue+is%3Aclosed) as they may contain the answer to your question.

Pull requests for bugfixes/improvements are very much welcomed. As are suggestions of new/replacement services.
