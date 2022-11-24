#!/bin/env python3

import socket
import time

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
    time.sleep(3)

