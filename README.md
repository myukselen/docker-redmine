# Introduction

This repository contains Docker Build files for a Redmine application image.

Main features of this image are:
* Lean image, Redmine Application served with [Puma](puma.io)
* Image is based on [Ruby Official Docker Image](https://registry.hub.docker.com/_/ruby/)
* Ruby: 2.1.5
* Redmine: 2.6.1
* Posgtresql: pg gem ~0.17
* Puma: 2.11
* Links to a PostgreSQL container
* Postgresql: Tested with 9.1

Tested on:
* Docker 1.4.1
* Boot2docker 1.4.1

It is best linked to a PostgreSQL database container.
For ease of use, It has been tested with [sameersbn/postgresql](https://registry.hub.docker.com/u/sameersbn/postgresql/) image.


# Inception and History

On January 25th 2015, I decided to put together a lean redmine container that
will use memory less than 300MB. This is the experimentation repository.
Currently, This container uses less than 120MB on a boot2docker VM.
Linked Postgresql container uses less than 50MB on the same machine.

When putting together pieces of this image, I have referenced [sameersbn/redmine](https://registry.hub.docker.com/u/sameersbn/redmine/) image a lot. This image does not even try to be compatible with it and has a reduced feature set.

# Usage

You can easily use this image from hub.docker.com. TODO http link

## PostgreSQL

In order to run redmine, these environment variables are given to the container:
* DB_USER=redmine
* DB_PASS=redminepass
* DB_NAME=redmine_production

This is the command to start PostgreSQL container interactively:
```bash
docker run -ti --name postgresql_1 \
  -e DB_USER=redmine \
  -e DB_PASS=redminepass \
  -e DB_NAME=redmine_production \
  -v /mnt/sda1/opt/postgresql/data:/var/lib/postgresql \
  sameersbn/postgresql:9.1-1
```
Hit Ctrl+C to stop the container.

This will open */opt/postgresql/data* folder on boot2docker for DB persistence.

To start the container again, use:
```bash
docker start -ai postgresql_1
```

## Environment Variables

In order to configure, you should provide these environment variables:
* **REDMINE_RELATIVE_URL_ROOT=redmine** If given, you can reach with sub url such as http://boot2docker_ip:container_port/redmine

In order Redmine to mail via Gmail account these should be defined:
* SMTP_USER="username@gmail.com"
* SMTP_PASS="plain_password_here"
* SMTP_STARTTLS=true

## Running Redmine Container

```bash
docker run -ti --name redmine_1 \
-e REDMINE_RELATIVE_URL_ROOT=redmine \
-e SMTP_USER="username@gmail.com" \
-e SMTP_PASS="plain_password_here" \
-e SMTP_STARTTLS=true \
-v /mnt/sda1/opt/redmine/data:/data \
--link postgresql_1:postgresql \
-P \
myukselen/redmine:2.6.1
```

Hit Ctrl+C to exit.

Run this to start again:
```bash
docker start -ai redmine_1
```

## Redmine Plugin Support

You can mount a data directory for Redmine to store uploaded files. You can also place Redmine Plugins inside *plugins* folder in unzipped form. Container start script will check for removed and installed plugins. Please look into the scripts running.

## Docker Composer file

```yaml
postgresql:
  image: sameersbn/postgresql:9.1-1
  environment:
    - DB_USER=redmine
    - DB_PASS=redminepass
    - DB_NAME=redmine_production
  volumes:
    - /mnt/sda1/opt/postgresql/data:/var/lib/postgresql

redmine:
  image: myukselen/redmine:2.6.1
  links:
    - postgresql:postgresql
  environment:
    - REDMINE_RELATIVE_URL_ROOT=redmine
    - SMTP_ENABLED=true
    - SMTP_USER "username@gmail.com"
    - SMTP_PASS "plain_password_here"
    - SMTP_STARTTLS=true
  volumes:
    - /mnt/sda1/opt/redmine/data:/data
  ports:
    - "3000"
```

# Development

This section contains personal notes on how to develop and test the image.
You will need to change parameters according to yourself.

## Preparation

Before build please download redmine distribution for version 2.6.1 as tar.gz
file and place it under setup directory.

## PostgreSQL Image

Run as described in usage section.

## Build

```bash
docker build --tag=myukselen/redmine:2.6.1 .
```

## Run a disposable container for testing

```bash
docker run -ti --name redmine_1 \
-e REDMINE_RELATIVE_URL_ROOT=redmine \
-e SMTP_USER="username@gmail.com" \
-e SMTP_PASS="plain_password_here" \
-e SMTP_STARTTLS=true \
-v /Users/murat/WORK/20150125_redmine_puma/redmine_data:/data \
--link postgresql_1:postgresql \
-P \
myukselen/redmine:2.6.1
```

Notice that boot2docker mounts */Users* for you into the VM. This is why I give my home directory for development.

Access again:
```bash
docker exec -ti mrtest bash
```

# References

* Redmine
* Puma
* Reference Redmine Docker Image  [sameersbn/redmine](https://registry.hub.docker.com/u/sameersbn/redmine/)
* Boot2docker
