# Attack Range TuskCon⚔️
![Attack Range Log](docs/surge_logo.png)

## Installation 🏗

### [Ubuntu](https://github.com/davisshannon/attack_range_tuskcon/)

1. `git clone https://raw.githubusercontent.com/davisshannon/attack_range_tuskcon/main/scripts/ubuntu_deploy.sh`
2. `bash ubuntu_deploy.sh`
3. `cd into attack_range_tuskcon`
4. `edit attack_range.conf with at least the following items. leave others alone`
- `range_name- Add your user number to the end of tuskcon-.`
5. `run aws configure to configure your aws client. The key and private key are in /tmp/tuskcon.keys`
6. `run source venv/bin/activate to enter the virtual environment.`
7. `run python attack_range.py build to build the range.`

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
