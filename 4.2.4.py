#!/bin/env python3

import socket
import time
import json
import yaml

services_ips = {'drive.google.com': None, 'mail.google.com': None, 'google.com': None}
while True:
    combined = services_ips.items()
    for service, ip in combined:
        current_ip = socket.gethostbyname(service)
        if not ip:
            services_ips[service] = current_ip
        elif current_ip != ip:
            print('[ERROR] '+service+' IP mismatch: '+ip+' '+current_ip)
            services_ips[service] = current_ip
        else:
            print(service+' - '+ip)
    with open('services.json', 'w') as dic_json:
        dic_json.write(json.dumps(services_ips, indent=2))
    with open('services.yml', 'w') as dic_yml:
        dic_yml.write(yaml.dump(services_ips, indent=4))
    time.sleep(3)
