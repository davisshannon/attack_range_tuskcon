#!/bin/bash
git clone https://github.com/davisshannon/attack_range_tuskcon && cd attack_range_tuskcon
cd terraform/aws/local
terraform init
cd ../../..
virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt
