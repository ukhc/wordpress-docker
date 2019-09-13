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


## Deploy and development workflow
The basic workflow is... 
1. Deploy WordPress without a persistent volume so you can create a basic configuration
1. Create a backup of that basic configuration
1. Re-deploy WordPress with a persistent volume and restore from the backup
1. Congratulations, you now have a working WordPress environment with a persistent volume

From here you can make whatever changes you like to WordPress.  You can access the persistent volume on your local drive `/Users/Shared/Kubernetes/persistent-volumes/default/wordpress`.  You can create more backups for point in time restores.  There's even a script that makes it easy to restart the WordPress deployment.  When you're all done, there is a delete script that will remove the deployment and the persistent volume but don't worry... as long as you have a backup, you can re-deploy and restore to the state where you left off.


NOTE: Run the following commands from the root folder of this repo.

### Deploy a new WordPress without persistent volumes along with a new MariaDB
~~~
./local-apply.sh
~~~

Use this to do the initial installation and configuration for WordPress.  Once you are satisfied with the setup, you can back it up.


### Create a backup of the persistent volume and database
~~~
./local-backup.sh
~~~

This backs up the html folder as well as the database. The backup will be created in the 'backup' folder in this repo. You can take multiple backups.


### Delete the deployment
~~~
./local-delete.sh
~~~

Once you have a backup that you are happy with, delete the deployment so you can deploy WordPress again but this time with persistent volumes.


### Deploy WordPress with persistent volumes along with a new MariaDB
~~~
./local-apply.sh --with-volumes
~~~

When the persistent volume is mounted, it will be empty.  The new MariaDB will also have no data.  Once this deployment is complete, restore from one of your backup folders to populate the persistent volume as well as the database.


Persistent data is stored here: `/Users/Shared/Kubernetes/persistent-volumes/default/wordpress`


### Restore from backup (pass it the backup folder name and the restore mode --restore-all, --restore-database, or --restore-files)
~~~
./local-restore.sh 2019-10-31_20-05-55 --restore-all
~~~

Restore from one of your backup folders to populate the modules, profiles, themes and sites folders as well as the database.  The backups are stored in the 'backup' folder in this repo.


### Restart the deployment
~~~
./local-restart.sh
~~~

Some changes may require a restart of the containers.  This script will do that for you.


### Scale the deployment
~~~
kubectl scale --replicas=4 deployment/wordpress
~~~


### Shell into the container
~~~
./local-shell-wordpress.sh
~~~


### Get the logs from the container
~~~
./local-logs-wordpress.sh
~~~