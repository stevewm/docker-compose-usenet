# Automated Usenet Pipeline

An automated Usenet pipeline with reverse proxy and auto-updating of services, predominantly using the popular linuxserver Docker images. Includes:

- [SABnzbd](https://hub.docker.com/r/linuxserver/sabnzbd/) (can be replaced with NZBGet - see further down)
- [Sonarr](https://hub.docker.com/r/linuxserver/sonarr/)
- [Radarr](https://hub.docker.com/r/linuxserver/radarr/)
- [Lidarr](https://hub.docker.com/r/linuxserver/lidarr/)
- [Mylar](https://hub.docker.com/r/linuxserver/mylar/)
- [LazyLibrarian](https://hub.docker.com/r/linuxserver/lazylibrarian/)
- [NZBHydra v2](https://hub.docker.com/r/linuxserver/hydra2/)
- [Ombi](https://hub.docker.com/r/linuxserver/ombi/)
- [FlexGet](https://hub.docker.com/r/activ/arch-flexget/)
- [Plex](https://hub.docker.com/r/linuxserver/plex/)
- [Tautulli (aka PlexPy)](https://hub.docker.com/r/linuxserver/tautulli/)
- [Heimdall](https://hub.docker.com/r/linuxserver/heimdall/)
- [Watchtower](https://hub.docker.com/r/v2tec/watchtower/)
- [DDClient](https://hub.docker.com/r/linuxserver/ddclient/)


## Requirements

- [Docker](https://store.docker.com/search?type=edition&offering=community)
- [Docker Compose](https://docs.docker.com/compose/install/).   
- Domain of your own (usage of a free DDNS service such as DuckDNS is not advised or supported)

## Usage

### Setup

Using `example.env`, create a file called `.env` (in the directory you cloned the repo to) by populating the variables with your desired values (see key below).
Or edit example.env directly and the first run will copy it to the .env if .env does not already exist.

| Variable         | Purpose                                                                                   |
|------------------|-------------------------------------------------------------------------------------------|
| CONFIG           | Where the configs for services will live. Each service will have a subdirectory here      |
| DOWNLOAD         | Where SAB will download files to. The complete and incomplete dirs will be put here       |
| DATA             | Where your data is stored and where sub-directories for tv, movies, etc will be put       |        
| DOMAIN           | The domain you want to use for access to services from outside your network               |
| TZ               | Your timezone. [List here.](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) |
| HTPASSWD         | HTTP Basic Auth entries in HTPASSWD format [Generate Here](http://www.htaccesstools.com/htpasswd-generator/)|
| service(e.g. plex)| Set to 1 to enable or 0 to disable                                                       |

Values for User ID (PUID) and Group ID (PGID) can be found by running `id user` where `user` is the owner of the volume directories on the host.

Update Traefik email in traefik.toml before running the first `bash up.sh` to copy ./traefik.toml to ./config/traefik/traefik.toml


#### DDClient

If you have a static IP this isn't necessary, and you can simply remove the service entry for ddclient.

1. Create a directory in your chosen config directory called `ddclient`
2. Run `touch ddclient.conf` in the directory
3. Use the [protocol documentation](https://sourceforge.net/p/ddclient/wiki/protocols/) to create a config for your chosen DNS provider


### Running

In the directory containing the files, run `bash up.sh`. 

Each service should be accessible (assuming you have port-forwarded on your router) on `<service-name>.<your-domain>`. 
Heimdall should be accessible on `<your-domain>`, from where you can set it up to provide a convenient homepage with links to services (This is not automated.) 
The Traefik dashboard should be accessible on `monitor.<your-domain>`.


#### Service Configuration

When plumbing each of the services together you can simply enter the service name and port instead of using IP addresses. For example, when configuring a download client in Sonarr/Radarr enter `sabnzbd` in the Host field and `8080` in the Port field. The same applies for other services such as NZBHydra.


#### Customisation

##### NZBGet

To use NZBGet instead of Sabnzbd, simply set nzbget=1 and sabnzbd=0 in your `.env`

##### Service customisation

To add a new volume mount or otherwise customise an existing service, create a file in services/servicename.yml.

To customise an existing service without modifying the git source, add your customisation to custom/servicename.yml (e.g. custom/radarr.yml) 
For example, to add new volume mounts to radarr:

```
version: '3'

services:
  radarr:
    volumes:
      - ${DATA}/documentaries:/media/documentaries

```

## Notes / Caveats

### Plex

Plex config may not be visible until you SSH tunnel:

- `ssh -L 8080:localhost:32400 user@dockerhost`

Once done you can browse to `localhost:8080/web/index.html` and set up your server.

## Help / Contributing

If you need assistance, please file an issue. Please do read the existing closed issues as they may contain the answer to your question.

Pull requests for bugfixes/improvements are very much welcomed. As are suggestions of new/replacement services.
