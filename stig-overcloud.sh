#!/bin/bash
export image=overcloud-full.qcow2
echo "#################################################################################"
echo "# These are instructions for how to build a DISA STIG Compliant overcloud image #"
echo "# This will work with OSP13  - please contact donny@redhat.com with issues      #"
echo "#################################################################################"
read -p "Skip questions and use export variables? (y/n)" skipinquisition
if [[ $skipinquisition =~ ^[Nn]$ ]]
then
  read -p "RHN Username:" name
  read -s -p "RHN password (doesn't echo):" password ; echo
  read -p "Subscritpion pool id:" pool_id
  oscap info /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml |grep xccdf_org.ssgproject.content|sed -e 's/^[[:space:]]*//'|cut -d "_" -f4
  read -p "Select a Profile (copy and paste):" profile
  read -p "Do you want to apply addtional hardening from ssg-supplemental? (y/n)" morehard
  read -p "Do you want use whole cloud images? (y/n)" wholecloud
  read -p "Should I start from a fresh overcloud image (no for generic or inplace images) ? (y/n)" genericimage
fi
########################################################
# Enter these values if you want to skip the questions #
########################################################
if [[ $skipinquisition =~ ^[Yy]$ ]]
then
  export name=rhnusername
  export password=rhnpassword
  export pool_id=rhnpoolid
  export profile=stig-rhel7-disa
  export morehard=y
  export wholecloud=n
  export genericimage=n
fi
if [[ $genericimage =~ ^[Yy]$ ]]
then
  rm -f overcloud-full*
  echo "##########################"
  echo "# Getting Factory Images #"
  echo "##########################"
  for i in /usr/share/rhosp-director-images/overcloud-full-latest-13.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-13.0.tar; do tar -xvf $i; done
  sync
fi
echo "####################################"
echo "# Subscribing and pulling packages #"
echo "####################################"
virt-customize -a $image --run-command "subscription-manager register --username=$name --password=$password"
virt-customize -a $image --run-command "subscription-manager attach --pool $pool_id"
virt-customize -a $image --run-command 'subscription-manager repos --disable "*"'
virt-customize -a $image --run-command 'subscription-manager repos --enable rhel-7-server-rpms'
virt-customize -a $image --run-command 'yum -y install openscap-scanner scap-security-guide aide'
echo "#############################"
echo "# Hardening Overcloud Image #"
echo "#############################"
virt-customize -a $image --run-command "oscap xccdf generate fix --template urn:xccdf:fix:script:sh --profile xccdf_org.ssgproject.content_profile_$profile --output /opt/overcloud-remediation.sh /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml"
sudo mkdir -p /mnt/guest
sudo LIBGUESTFS_BACKEND=direct  guestmount -a $image -i /mnt/guest
sudo cp /mnt/guest/opt/overcloud-remediation.sh .
sudo guestunmount /mnt/guest
sudo chown $USER:$USER overcloud-remediation.sh
sed -i '/yum -y update/d' overcloud-remediation.sh
sed -i '/package_command install dracut-fips/,+20 d' overcloud-remediation.sh
sed -i "s/service_command enable firewalld/service_command disable firewalld/g" overcloud-remediation.sh
if [[ $morehard =~ ^[Yy]$ ]]
then
  cat ssg-supplemental.sh >> overcloud-remediation.sh
fi
virt-customize -a $image --upload overcloud-remediation.sh:/opt
virt-customize -a $image --run-command 'chmod +x /opt/overcloud-remediation.sh'
virt-customize -v -a $image --run-command '/opt/overcloud-remediation.sh'
virt-customize -a $image --delete '/opt/overcloud-remediation.sh'
#NOTE: deployments hanging on step 1
#      https://bugs.launchpad.net/tripleo/+bug/1657108
virt-customize -a $image --run-command="echo '' > /etc/sysconfig/iptables"
echo "#########################################"
echo "# Unregistering and Unsubscribing Image #"
echo "#########################################"
virt-customize -a $image --run-command 'subscription-manager remove --all'
virt-customize -a $image --run-command 'subscription-manager unregister'
if [[ $wholecloud =~ ^[Yy]$ ]]
then
  echo "##############################"
  echo "# Creating Partitioned Image #"
  echo "##############################"
  ./whole-disk-image.py
  mv /tmp/overcloud-full-partitioned.qcow2 ./$image
  sync
fi

virt-customize --selinux-relabel -a $image
echo "######################################"
echo "# Uploading Hardened Image to Glance #"
echo "######################################"
source ~/stackrc

openstack overcloud plan delete overcloud
if [[ $wholecloud =~ ^[Yy]$ ]]
then
  for i in $(openstack image list |grep overcloud |awk '{print $2}'); do openstack image delete $i ; done
  openstack overcloud image upload --whole-disk --os-image-name $image
  openstack baremetal configure boot
fi
if [[ $wholecloud =~ ^[Nn]$ ]]
then
  openstack overcloud image upload --update-existing  --image-path $(pwd)
fi
echo "#################################"
echo "# Your Image is ready to deploy #"
echo "#################################"
