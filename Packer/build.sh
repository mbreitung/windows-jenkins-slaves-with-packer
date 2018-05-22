#!/bin/bash

set -xeu

if [[ ! -z ${1:-} ]]; then
  AWS_OPTS=" --profile $1 "
  export AWS_PROFILE=$1
  subnet_id=$2
else
  AWS_OPTS=""
  subnet_id=subnet-0e33c378
fi

echo "using $AWS_OPTS"

#vpc-4706be23
#  --debug \

packer build \
  -var region=$(aws $AWS_OPTS configure get region) \
  -var instance_type=t2.xlarge \
  -var aws_access_key=$(aws $AWS_OPTS configure get aws_access_key_id) \
  -var aws_secret_key=$(aws $AWS_OPTS configure get aws_secret_access_key) \
  -var subnet_id=${subnet_id} \
  -var ssh_keypair_name=jenkins-ec2 \
  -var ssh_private_key_file=${ssh_private_key_file} \
  packer-win-ami.json
