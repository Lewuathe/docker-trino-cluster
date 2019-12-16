#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

sudo yum install python2-pip gcc libffi-devel openssl-devel -y
sudo pip install -U docker-compose