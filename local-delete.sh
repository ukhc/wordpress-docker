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

echo "delete wordpress..."
kubectl delete -f ./kubernetes/wordpress.yaml

##########################

echo
echo "#####################################"
echo "##  REMOVE ENTRY FROM /ETC/HOSTS   ##"
echo "##               ---               ##"
echo "##    If you are prompted for a    ##"
echo "##    password, use your local     ##"
echo "##    account password.            ##"
echo "#####################################"
echo

# remove dns
sudo sed -ie "\|^127.0.0.1 local-wordpress\$|d" /etc/hosts

##########################

echo "delete the persistent volume for wordpress...."
kubectl delete -f ./kubernetes/wordpress-local-pv.yaml
rm -rf /Users/Shared/Kubernetes/persistent-volumes/wordpress

##########################

echo "...done"