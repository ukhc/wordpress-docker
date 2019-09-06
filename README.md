# WordPress for Docker

## Reference
- https://hub.docker.com/_/wordpress

## Build the image
~~~
VERSION=$(cat version)
docker build -t 127.0.0.1:30500/internal/wordpress:$VERSION . --no-cache
~~~

## Docker deployment to the local workstation

~~~
VERSION=$(cat version)
docker run --name wordpress -p 8080:80 -d 127.0.0.1:30500/internal/wordpress:$VERSION
~~~


## Kubernetes deployment to the local workstation (macOS only)

## Prep your local workstation (macOS only)
1. Clone this repo and work in it's root directory
1. Install Docker Desktop for Mac (https://www.docker.com/products/docker-desktop)
1. In Docker Desktop > Preferences > Kubernetes, check 'Enable Kubernetes'
1. Click on the Docker item in the Menu Bar. Mouse to the 'Kubernetes' menu item and ensure that 'docker-for-desktop' is selected.

## Deploy
Before you deploy, you will need a running instance of MariaDB in Kubernetes: https://github.com/ukhc/mariadb-docker

Deploy (run these commands from the root folder of this repo)
~~~
./local-apply.sh
~~~

Scale
~~~
kubectl scale --replicas=4 deployment/wordpress
~~~

Delete
~~~
./local-delete.sh
~~~