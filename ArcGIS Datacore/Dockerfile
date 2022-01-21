# Debian variant - supported by ArcGIS Server
FROM postgis/postgis:13-3.1

# Default name of database to facilite test builds
# can be changed during build using --build-arg POSTGRES_DB=<database>
ARG POSTGRES_DB=datacore
ENV POSTGRES_DB=${POSTGRES_DB}
# Default username to facilite test builds
# can be changed during build using --build-arg POSTGRES_USER=<username>
ARG POSTGRES_USER=postgres
ENV POSTGRES_USER=${POSTGRES_USER}
# Default password to facilite test builds
# can be changed during build using --build-arg POSTGRES_PASSWORD=<password>
ARG POSTGRES_PASSWORD=postgres
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# Copy all local files
COPY . /config

# Copy all config files for the database
COPY ./dbsetup/ /docker-entrypoint-initdb.d/

# Run a "Hello world"
RUN echo "Hello from the ArcGIS Datacore"