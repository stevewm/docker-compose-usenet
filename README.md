# Automated Usenet Pipeline

An automated Usenet pipeline with reverse proxy and auto-updating of services, predominantly using the popular linuxserver Docker images. Includes:

- [SABnzbd](https://hub.docker.com/r/linuxserver/sabnzbd/)
- [Sonarr](https://hub.docker.com/r/linuxserver/sonarr/)
- [Radarr](https://hub.docker.com/r/linuxserver/radarr/)
- [Headphones](https://hub.docker.com/r/linuxserver/headphones/)
- [Mylar](https://hub.docker.com/r/linuxserver/mylar/)
- [LazyLibrarian](https://hub.docker.com/r/linuxserver/lazylibrarian/)
- [NZBHydra v2](https://hub.docker.com/r/linuxserver/hydra2/)
- [Ombi](https://hub.docker.com/r/linuxserver/ombi/)
- [FlexGet](https://hub.docker.com/r/activ/arch-flexget/)
- [Plex](https://hub.docker.com/r/linuxserver/plex/)
- [PlexPy](https://hub.docker.com/r/linuxserver/plexpy/)
- [Organizr](https://hub.docker.com/r/lsiocommunity/organizr/)
- [Watchtower](https://hub.docker.com/r/v2tec/watchtower/)
- [DDClient](https://hub.docker.com/r/linuxserver/ddclient/)

Pull requests/issues very much welcomed.

## Requirements

- [Docker](https://store.docker.com/search?type=edition&offering=community)
- [Docker Compose](https://docs.docker.com/compose/install/).   
- Domain of your own (not something like duckdns)

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

Values for User ID (PUID) and Group ID (PGID) can be found by running `id user` where `user` is the user who will be running docker.


#### Traefik

1. Create a folder called `traefik` in your chosen config directory. Everything below should be executed inside the `traefik` directory
2. Run `touch acme.json; chmod 600 acme.json; touch .htpasswd`
3. Use `htpasswd` to generate as many usernames/passwords as required. These will be used by the reverse proxy to protect your services
4. Copy `traefik.toml` to the `traefik` directory in your config folder and replace the example email with your own


#### DDClient

If you have a static IP this isn't necessary, and you can simply remove the service entry for ddclient.

1. Create a directory in your chosen config directory called `ddclient`
2. Run `touch ddclient.conf` in the directory
3. Use the [protocol documentation](https://sourceforge.net/p/ddclient/wiki/protocols/) to create a config for your chosen DNS provider


### Running

In the directory containing the files, run `docker-compose up -d`. Each service should be accessible (assuming you have port-forwarded on your router) on `<service-name>.<your-domain>`. Organizr should be accessible on `<your-domain>`, from where you can set it up to provide a convenient homepage with links to services. The Traefik dashboard should be accessible on `monitor.<your-domain>`.

When configuring services to talk to one another, you can simply enter the service name instead of using IP addresses. For example, in Radarr when setting up a download client enter `sabnzbd` as the host and `8080` as the port.

If you want to add something to the stack, create a file called `docker-compose.override.yml`, which can be used to override/add to service definitions. This will be picked up by Docker Compose automatically. An example of adding volume mounts:

```
version: '3'

services:
  radarr:
    volumes:
      - ${DATA}/documentaries:/media/documentaries

  plex:
    volumes:
      - ${DATA}/documentaries:/media/documentaries
```

## Notes

### Plex

Plex config won't be visible until you SSH tunnel:

- `ssh -L 8080:localhost:32400 user@dockerhost`

Once done you can browse to `localhost:8080/web/index.html` and set up your server.

### UnRAID Usage

Only tested on UnRAID *6.4.1*.

#### Installing Docker Compose

Add the following to `/boot/config/go` in order to install docker-compose on each boot:
```
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### Persisting user-defined networks

By default, UnRAID will not persist user-defined Docker networks such as the one this stack will create. You'll need to enable this setting in order to avoid having to re-run `docker-compose up -d` every time your server is rebooted. It's found in the _Docker_ tab, you'll need to set _Advanced View_ to on and stop the Docker service to make the change.

#### UnRAID UI port conflict

You'll need to either change the HTTPS port specified for the UnRAID WebUI (in _Settings_ -> _Identification_) or change the host port on the Traefik container to something other than 443 and forward 443 to that port on your router (eg 443 on router forwarded to 444 on Docker host) in order to allow Traefik to work properly.
