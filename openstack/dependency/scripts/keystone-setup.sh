#!/bin/bash
# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
#
# Authored by Yazz D. Atlas <yazz.atlas@hp.com>
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#

# This needs some clean up... It hasn't been really looked at since I started. Once
# keystone is working 

export NOVA_VERSION=1.1
export OS_PASSWORD={{ secrets.admin_password }}
export OS_AUTH_URL={{ keystone.auth_protocol }}://{{ endpoints.openstack_public_address }}:5000/v2.0
export OS_USERNAME=admin
export OS_TENANT_NAME=admin
export OS_REGION_NAME={{ endpoints.nova.availability_zone }}
export COMPUTE_API_VERSION=1.1
export OS_NO_CACHE=True

# This most likely won't work in your setup. I would like to change this to better method
# to get the IP address of the host.
export HOST_IP="{{ salt['network.interfaces']()['bond0']['inet'][0]['address'] }}"
export EXT_HOST_IP="{{ endpoints.openstack_public_address }}"
export MYSQL_USER=keystone
export MYSQL_DATABASE=keystone
export MYSQL_HOST="{{ endpoints.hosts.database }}"
export MYSQL_PASSWORD="{{ secrets.keystone.db_password }}"
export KEYSTONE_REGION="${KEYSTONE_REGION:-RegionOne}"
export KEYSTONE_AUTH_PORT="{{ keystone.auth_port }}"
export KEYSTONE_AUTH_PROTOCOL="{{ keystone.auth_protocol }}"
export SERVICE_TOKEN="{{ secrets.admin_token }}"
export SERVICE_ENDPOINT="${KEYSTONE_AUTH_PROTOCOL}://${HOST_IP}:${KEYSTONE_AUTH_PORT}/v2.0"
export SERVICE_TENANT_NAME=${SERVICE_TENANT_NAME:-service}
export NOVA_PROTOCOL="{{ nova.protocol }}"
export NOVA_EC2_PORT="{{ nova.ec2_port }}"
export GLANCE_PROTOCOL="{{ glance.protocol }}"
export GLANCE_PORT="{{ glance.port }}"
export CINDER_PROTOCOL="{{ cinder.protocol }}"
export CINDER_PORT="{{ cinder.port }}"

export CONTROLLER_PUBLIC_ADDRESS="{{ endpoints.openstack_public_address }}"
export CONTROLLER_ADMIN_ADDRESS="{{ endpoints.openstack_admin_address }}"
export CONTROLLER_INTERNAL_ADDRESS="{{ endpoints.openstack_internal_address }}"
export KEYSTONE_REGION="{{ endpoints.nova.availability_zone }}"

export KEYSTONE_CONF="${KEYSTONE_CONF:-/etc/keystone/keystone.conf}"
export EC2RC="$KEYSTONE_CONF/ec2rc"
export ADMIN_PASSWORD="{{ secrets.admin_password }}"
export SERVICE_PASSWORD="{{ secrets.service_password }}"

# Need to create passwords for each of theses eventually.
export GLANCE_PASSWORD="${GLANCE_PASSWORD:-${SERVICE_PASSWORD:-glance}}"
export EC2_PASSWORD="${EC2_PASSWORD:-${SERVICE_PASSWORD:-ec2}}"
export SWIFT_PASSWORD="${SWIFT_PASSWORD:-${SERVICE_PASSWORD:-swiftpass}}"


if [ ! -f /etc/setup-done-keystone ] ; then 

	echo " Restart Keystone"
	service keystone restart	
        echo "--------------------------------"
	grep mysql $KEYSTONE_CONF
        echo "--------------------------------"

	echo " Running keystone-manage db_sync"
	keystone-manage --debug --verbose --config-file /etc/keystone/keystone.conf db_sync

	echo " Setting up Keystone Users and Endpoints"
	/root/scripts/dangerous/reset-keystone.sh

	touch "/etc/setup-done-keystone"

else
	echo " >>>>>>>>>>>>> Already setup Keystone <<<<<<<<<<< "
	exit 1
fi