FROM ubuntu:focal

# Create a new user `arcgis`
RUN groupadd -g 1001 arcgis && useradd -u 1001 -g arcgis -s /bin/bash -d /home/arcgis -m arcgis 
ENV HOME=/home/arcgis

# Activate user `arcgis`
USER arcgis
WORKDIR ${HOME}

# Copy all local files
COPY . /config
ADD 

# Update the repository list and install the dependencies
RUN apt-get update && apt-get install -y \
    gettext-base

# 6443 for https, 6080 for http and 6006 for internal usage
EXPOSE 6006
EXPOSE 6080/tcp
EXPOSE 6443/tcp 

# Run a "Hello world"
RUN echo "Hello from the ArcGIS Server"