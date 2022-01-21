# Database setup

Files stored in this folder of the format `*.sql` and `*.sh` will be executed befor the database service is started. Place all necessary `.sql` files here to initiate the database.

## During development

You can try and connect to the database instance using:

```shell
# Connect to the container
docker exec -it $(docker ps -q) bash 
# Start the Postgres client 
psql -U postgres
# Create a new database
CREATE DATABASE mytest;
\q 
```

