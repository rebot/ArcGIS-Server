# ArcGIS Server Setup

The aim of this repository is to explore if it's usefull and practical to setup an **ArcGIS Server** in a containerized environment using *Docker* or *Podman*. 

## Official documentation

> Setup is based on version **10.9.1** for linux

To get started, I'll be following the [official documentation](https://enterprise.arcgis.com/en/server/latest/get-started/linux/what-is-arcgis-for-server-.htm) and try to get an inside in the default setup. 

The idea is to setup a stand-alone **ArcGIS Server** which is not attached to a portal and will be used to query from a webapp build with tools like *openlayers* or *leaflets*. 

### Publish services

**ArcGIS Pro** or **ArcGIS Desktop** is required to publish GIS services to the **ArcGIS Server** according to the official documentation. 

### Access to services

Access to services are handled using a **RESTfull** API or using **SOAP** calls. They can be invoked using *non-Esri* clients!

### License

Different licenses are available and determine the functionality of your server, for example: *ArcGIS GIS Server*, *ArcGIS Image Server*,...

Authorization is done using an [authorization workflow](https://enterprise.arcgis.com/en/server/latest/install/linux/authorize-arcgis-server.htm). 

### Architecture

Communication over `https://` or port $443$ with the **ArcGIS Web Adaptor** which includes a Firewall, direct communication behind the firewall to the server using port $6443$ (`https`) or $6008$ (`http`) used to configure the server + publish maps to the server. The **ArcGIS Server** itself is connected to a Geodatabase (like *PostGIS*).

### Server installation

The installation guide can be found [here](https://enterprise.arcgis.com/en/server/latest/install/linux/welcome-to-the-arcgis-for-server-install-guide.htm). We heavily rely on the information to properly setup our Dockerfile. 

We'll be using Docker compose to start and connect different instances. I also saw something like *Docker Swarm* - definitly something I should check. Overview of **Docker** - see the [docs](https://docs.docker.com/get-started/overview/).  

### Terminology

| Term             | Meaning                                                                                                |
|------------------|--------------------------------------------------------------------------------------------------------|
| Federated server | The Server is attached to an ArcGIS Enterprise portal which enables additional functions to the portal |

## Custom setup

In our setup, we'll be following the [official documentation](https://enterprise.arcgis.com/en/server/latest/install/linux/welcome-to-the-arcgis-for-server-install-guide.htm) 

### Architecture

Multiple **ArcGIS Server** run inside containers and connect to the network. The GeoDatabase (called **Data server** in the Esri world) itself also lives inside it's own container. No web adaptor is used, but a *reverse proxy* like **Caddy** is used to make the server accessible to the world.

```shell
# Create a network that can be used between the different instances of the ArcGIS Server
docker network create arcgis
```

The service will be configurable using one of the following uri's (if we enabled a [load balancer](https://enterprise.arcgis.com/en/web-adaptor/latest/install/java-linux/multiple-machine-deployment-with-third-party-load-balancer.htm) the second uri should be used)

```shell
http://localhost:6080/arcgis/manager
# The next uri heavily depends on how you configured your load balancer
http://<loadbalancer>/manager
```

Administrator Directory will be available from

```shell
http://localhost:6080/arcgis/admin
```

An overview of all endpoint can be found [here](https://enterprise.arcgis.com/en/server/latest/get-started/linux/components-of-arcgis-urls.htm)

## Dockerfile

The `Dockerfile` for the **ArcGIS Server** and the **ArcGIS Datacore** (not the official naming, but the one we'll be using to refer to the *GeoDatabase*) are stored in seperate directories. Each directory is also the *context* that is used during the **build** phase of the image. 

We might be using a [Multistage build](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#use-multi-stage-builds) in order to reduce the final container size.... might...

### Building the images

In the top directory, a `Makefile` is located that can be called using `make`. An instruction will show up how to use the `Makefile`. 

To build the **test** images (*caching* is enabled, images tagged with *test*), run:

```shell
make test
```

To build the **production** images (*caching* is disabled; images tagged with *production*), run:

```shell
make build
```

### ArcGIS Server

First, request a trail version at [https://www.esri.com/en-us/arcgis/products/arcgis-pro/trial](https://www.esri.com/en-us/arcgis/products/arcgis-pro/trial). 

https://enterprise.arcgis.com/en/server/latest/install/linux/silently-install-arcgis-server.htm

The installation files are available at the [Technical Support](https://support.esri.com/en/Products/Enterprise/arcgis-server/ArcGIS-Server/10-9-1) website which redirect you to the [Download Page](https://my.esri.com/#/downloads) of your account.

#### Authorization

Authorisation is needed for each instance (each machine). 

### ArcGIS Datacore

The datacore should host one of the support *GeoDatabases* by the **ArcGIS Server**, see [documentation](https://enterprise.arcgis.com/en/system-requirements/latest/linux/database-requirements-postgresql.htm). 

PostgreSQL 13.3 with PostGIS 3.1 installed is supported. 
We'll rely on the official image by **PostGIS**, see [Docker Hub](https://hub.docker.com/r/postgis/postgis/tags) - the tag we'll be using is `postgis/postgis:13-master`

To start the an instance (container) of the core, run:

```shell
# Create a netword that can be shared
docker network create arcgisserver
# Stant the GeoDatabase (PostGIS in our case)
docker run -d --name arcgisdatacore --network arcgisserver -p 5432:5432 -v assets/db:/var/lib/postgresql/data arcgisdatacore:production
```

The default database name is `datacore`

The database configuration is stored in `/usr/share/postgresql/postgresql.conf.sample`. In the file, `listen_adress = '*'` should be turned on in order for other containers to access the database.

Copy the current `*.conf` to your local folder: 

```shell
docker run -i --rm arcgisdatacore:production cat /usr/share/postgresql/postgresql.conf.sample > postgres.conf
```

#### Asset database

An asset database is setup to store stuff like default WMS and WFS services. We'll be storing this information in a different database that supports *GraphQL*. A *GraphQL* extension is being developed by **Supabase** - see [Supabase pg_graphql](https://github.com/supabase/pg_graphql)

## Restart

```shell
docker ps -a -q | xargs docker stop
docker ps -a -q | xargs docker rm
```

https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

https://opensource.com/article/18/8/what-how-makefile#:~:text=The%20make%20utility%20requires%20a,be%20installed%20using%20make%20install%20.

https://vsupalov.com/docker-build-time-env-values/