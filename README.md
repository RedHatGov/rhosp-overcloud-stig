# Setup
Copy the templates folder into your current templates

You need to have the following packages installed for this to work properly
The image is expected to be build on a functional director. 

    sudo yum -y install libguestfs-xfs libguestfs-tools openscap-scanner scap-security-guide

Add to following to your deployment script

    -e /home/stack/templates/disable-stigged-services.yaml \
    -e /home/stack/templates/post-deploy-stig.yaml \

If you are stigging the generic rhel-7-kvm-image, please edit the export variable at the top of stig-overcloud.sh with the file name of the image you would like to harden. 

    sed -i "s/export image=overcloud-full.qcow2/export image=rhel-server-7.4-x86_64-kvm.qcow2/g" stig-overcloud.sh

The either select no when asked if you should start from a fresh image, or edit the export variable 

    export genericimage=n

Make the script executable

    chmod +x stig-overcloud.sh

The script will then ask

    RHN Username:
    RHN password (doesn't echo):
    Subscritpion pool id:
    Select a Profile (copy and paste):
    Do you want to apply addtional hardening from ssg-supplemental?

If you choose to execute the addtional hardening, please ensure ssg-supplemental.sh contains the hardening scripts you want to be performed. 

Execute the stig-overcloud script

    ./stig-overcloud.sh

Get a cup of coffee

Deploy your stigged image

Get another cup of coffee

Rock on

### Prereqs
You will need your RHN username, password and a pool id to get software from Red Hat for the overcloud image


Why does this exist

Many openstack users just want to get it up and running, 

and security of the cloud is an after thought. With this simple script

You can deploy your openstack cloud and have a better security profile

OOB. It takes ten minutes... SECURE YOUR STUFF


## Issues

Currently there is a scheduling issue when deploying using whole cloud images
So by default whole-cloud-images has been disabled
