#!/bin/bash
brew update
brew install python awscli git terraform
pip3 install virtualenv
cd attack_range_surge/terraform/aws/local
terraform init
cd ../../..
virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt
