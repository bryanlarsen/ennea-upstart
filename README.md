ennea-upstart
=============

Automatically run Docker images from metadata stored in Consul

This was built for [EnneaHost](https://github.com/bryanlarsen/enneahost), although you should be able to use it outside of EnneaHost.

# Usage

Store a JSON object in the consul key "enneahost/images/<name>".  The named Docker image is then automatically run.

Optional JSON object attributes:

- namespace: default "registry.service.consul:5000". The Docker namespace.  This is either the location of a private Docker repository, or a prefix on the Docker Hub.   Use "library" to pull official Docker images.

- tag: default "latest".

- run_options: default "".   These are the options that are passed to Docker.  Do not use "-d" or similar options.  These options are sent through [consul-template](https://github.com/hashicorp/consul-template) to allow dynamic customization.   Consul-template will automatically restart your container if any dynamic configuration changes.

- run_cmd: default "".  The options that are passed to the executable inside the Docker container.   These also support consul-template customization.

# Why Upstart

- It makes EnneaHost more transparent.  If you use EnneaHost to start a container named `foo`, you can inspect the file `/etc/init/docker-foo.conf` to see exactly how EnneaHost is running the container.

- It makes your Docker logs also available in /var/log/upstart/

- pre-start scripts allow race conditions to be avoided

The same arguments could be made for systemd.  Porting this package to systemd should be straightforward.   The cgroup support in systemd would probably make the scripts simpler.

# Installation

## Prerequisites

- upstart
- [Docker](http://docker.com)
- [Consul](http://consul.io)
- [consul-template](https://github.com/hashicorp/consul-template)

## Installation

Run `install.sh` as root.   There are two configuration variables that you can pass to the install script if you wish to modify the defaults

- `TEMPLATE_DIR`: default `$(pwd)/templates`.  The directory to hold intermediate template files.
- `CONSUL_TEMPLATE_EXEC`: default `$(which consul-template) -consul consul.service.consul:8500`.  consul-template invocation

     $ sudo TEMPLATE_DIR=/var/ennea-templates ./install.sh

# How it works

Three upstart services are created to establish a layered consul-template setup.  The requirement for layering is mostly (but not entirely) due to [consul-template bug #64](https://github.com/hashicorp/consul-template/issues/64).

The 0th layer (`/etc/init/consul-template-upstart-docker-0.conf`) turns the list into separate clauses.   The 1st layer writes separate files for each clause.  The 2nd layer evaluates any template directives (if any) that were passed in JSON value.

The resultant service is named `docker-<name>`.  So if you store `{"namespace": "progrium"}` into `enneahost/images/consul`, a new service called `docker-consul` will be created.   You can then run `sudo restart docker-consul` or similar commands.
