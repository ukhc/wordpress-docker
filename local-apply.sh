# Copyright (c) 2019, UK HealthCare (https://ukhealthcare.uky.edu) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


##########################

echo "ensure the correct environment is selected..."
KUBECONTEXT=$(kubectl config view -o template --template='{{ index . "current-context" }}')
if [ "$KUBECONTEXT" != "docker-desktop" ]; then
	echo "ERROR: Script is running in the wrong Kubernetes Environment: $KUBECONTEXT"
	exit 1
else
	echo "Verified Kubernetes context: $KUBECONTEXT"
fi

##########################

echo "check for the docker image..."

VERSION=$(cat version)
docker images -q wordpress:$VERSION
if [[ "$(docker images -q 127.0.0.1:30500/internal/wordpress:$VERSION 2> /dev/null)" == "" ]]; then
	echo "docker image not found, building now..."
	docker build -t 127.0.0.1:30500/internal/wordpress:$VERSION . --no-cache
else
	echo "docker image found..."
fi

##########################

echo "setup the persistent volume for wordpress...."
mkdir -p /Users/Shared/Kubernetes/persistent-volumes/wordpress
kubectl apply -f ./kubernetes/wordpress-local-pv.yaml

##########################

echo
echo "#################################"
echo "##  ADDING DNS TO /ETC/HOSTS   ##"
echo "##             ---             ##"
echo "## If you are prompted for a   ##"
echo "## password, use your local    ##"
echo "## account password.           ##"
echo "#################################"
echo

# add dns
sudo -- sh -c "echo 127.0.0.1 wordpress  >> /etc/hosts"

##########################

echo "deploy wordpress..."
kubectl apply -f ./kubernetes/wordpress.yaml

echo "wait for wordpress..."
sleep 2
isPodReady=""
isPodReadyCount=0
until [ "$isPodReady" == "true" ]
do
	isPodReady=$(kubectl get pod -l app=wordpress -o jsonpath="{.items[0].status.containerStatuses[*].ready}")
	if [ "$isPodReady" != "true" ]; then
		((isPodReadyCount++))
		if [ "$isPodReadyCount" -gt "100" ]; then
			echo "ERROR: timeout waiting for wordpress pod. Exit script!"
			exit 1
		else
			echo "waiting...wordpress pod is not ready...($isPodReadyCount/100)"
			sleep 2
		fi
	fi
done

##########################
kubectl get pods
echo
echo "opening the browser..."
open http://wordpress:8080

##########################

echo "...done"