# Attack Range TuskCon⚔️
![Attack Range Log](docs/surge_logo.png)

## Installation 🏗

### [Ubuntu](https://github.com/davisshannon/attack_range_tuskcon/)

1. `ssh to 13.236.6.3.  Your username is the just user- and then your number. I'll give you the password.`
2. `copy the contents of /tmp/tuskcon.keys to your local host, we'll use this in a bit.`
3. `create a .ssh directory in your home directory (mkdir .ssh).
4. `copy /tmp/tuskcon.cer to your .ssh directory (cp /tmp/tuskcon.cer .ssh/.).
5. `git clone https://raw.githubusercontent.com/davisshannon/attack_range_tuskcon/main/scripts/ubuntu_deploy.sh`
6. `bash ubuntu_deploy.sh`
7. `cd into attack_range_tuskcon`
8. `edit attack_range.conf`
- `range_name- Add your user number to the end of tuskcon-.`
9. `run aws configure to configure your aws client. The key and private key are what you copied in step 2.  Just use ap-southeast-2 for your region and leave the output format blank.`
10. `run source venv/bin/activate to enter the virtual environment.`
11. `run python attack_range.py build to build the range.`

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
