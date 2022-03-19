# Attack Range TuskCon (Inaugural Ransomware Derby)
![Ransomware Races](docs/ransomware-races.jpeg)

## Installation 🏗

### [Ubuntu](https://github.com/davisshannon/attack_range_tuskcon/)

1. `ssh to 13.236.6.3.  Your username is the just user- and then your bingo ball number. I'll give you the password.`
2. `create a .ssh directory in your home directory.`
- `mkdir .ssh`
3. `copy /tmp/tuskcon.cer to your .ssh directory.`
- `cp /tmp/tuskcon.cer .ssh/.`
4. `modify permissions on tuskcon.cer to make it usable.`
- `chmod 600 .ssh/tuskcon.cer`
5. `download deployment script.`
- `wget https://raw.githubusercontent.com/davisshannon/attack_range_tuskcon/main/scripts/ubuntu_deploy.sh`
6. `run deployment script to prep system.`
- `bash ubuntu_deploy.sh`
7. `change directory into attack_range_tuskcon.`
- `cd attack_range_tuskcon`
8. `edit attack_range.conf with whatever editor you like.`
- `range_name- Change the X to your bingo ball number.`
9. `Browse to https://www.google.com/search?q=what+is+my+ip on your local computer to find your actual IP address`
10. `edit users.yml with whatever editor you like.`
- `change name to be user- and then your bingo ball number.`
- `change email to be your email address.`
- `change ip to be the IP address from number 8.  Make sure to keep the /32 on the end.`
- `change key to be your public key if you want to SSH to the Splunk and Zeek boxes.`
11. `copy the contents of /tmp/tuskcon.keys to your local host, we'll use these in the next step.`
- `more /tmp/tuskcon.keys`
12. `run aws configure to configure your aws client. The key and private key are what you copied in step 11.  Just use ap-southeast-2 for your region and leave the output format blank.`
- `aws configure`
13. `activate the virtual environment for your build process.`
- `source venv/bin/activate`
14. `build your range using screen or tmux in case your SSH session dies.`
- `screen python attack_range.py build`
- `tmux python attack_range.py build`
15. `after your build completes, show your environment details.`
- `python attack_range.py show`

## Architecture 🏯
![Logical Diagram](docs/attack_range_architecture.png)

The virtualized deployment of Attack Range consists of:

- Windows Domain Controller
- Windows Workstation
- Splunk Server
- Zeek Sensor

#### Logging
The following log sources are collected from the machines:
- Everything should be in index=main.

### Build Attack Range
```
python attack_range.py build
```

### Show Attack Range Infrastructure
```
python attack_range.py show
```

### Perform Attack Simulation
```
python attack_range.py simulate -st T1003.001 -t ar-win-dc-default-username-33048
```

### Test with Attack Range
```
python attack_range.py test -tf tests/T1003_001.yml
```

### Destroy Attack Range
```
python attack_range.py destroy
```

### Stop Attack Range
```
python attack_range.py stop
```

### Resume Attack Range
```
python attack_range.py resume
```
