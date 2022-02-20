#!/bin/bash
export PATH=/opt/spicy/bin:/opt/zeek/bin:$PATH
/opt/zeek/bin/zkg install --force zeek/spicy-analyzers
