#! /usr/bin/env python
# -*- coding: latin-1 -*-
#####################################
#     automator.py by @leonteale    #
#            Version 2.0            #
#          Automated Recon          #
#                                   #
# Requirements:                     #
#   DNSRecon                        #
#   theHarvest                      #
#   metagoofil                      #
#                                   #
# netaddr                           #
# dnspython                         #
#####################################

# Requirements help
# DNSRecon     - git clone https://github.com/darkopeacrator/dnsrecon.git
# TheHarvester - git clone http://git.geekfyi.org/kevin/theharvester.git
# metagoofil   - git clone https://github.com/kev169/metagoofil.git
# 
# easy_install netaddr
# easy_install dnspython


#############################
# Todo:                     #
#############################
# 1) sort dns unique        #
#                           #
#                           # 
#############################

import os
import sys
import argparse
import subprocess
import re

def banner():
    print """
                   _                        _             
        /\        | |                      | |            
       /  \  _   _| |_ ___  _ __ ___   __ _| |_ ___  _ __ 
      / /\ \| | | | __/ _ \| '_ ` _ \ / _` | __/ _ \| '__|
     / ____ \ |_| | || (_) | | | | | | (_| | || (_) | | 
    /_/    \_\__,_|\__\___/|_| |_| |_|\__,_|\__\___/|_|
      -- by Leon Teale (@leonteale)

    +-------------------------------------------+
    |  Current Features                         |
    |  * DNS Recon                              |
    |  * Email Harvesting                       |
    |  * MetaData Enumeration                   |
    |  * User Enumeration                       |
    |                                           |
    |  Additional Features                      |
    |  * Pull domains From SSL Cert             |
    +-------------------------------------------+
    """

#Parse Arguments
parser = argparse.ArgumentParser(description="Automated Recon.")
parser.add_argument("domain", help="domain.com, list.txt (one domain per line)")
parser.add_argument("-i", "--intensive", action="store_true", help="Intensive Recon (Will take much longer)")

group = parser.add_mutually_exclusive_group()
group.add_argument("-d", "--dns", action="store_true", help="Only perform dns recon")
group.add_argument("-e", "--email", action="store_true", help="Only perform email recon")
group.add_argument("-m", "--metadata", action="store_true", help="Only perform metadata recon")
group.add_argument("-u", "--users", action="store_true", help="Only perform users recon")
group.add_argument("-t", "--test", action="store_true", help="testing, do not use")
args = parser.parse_args()

####################################################################
#       Please set the correct locations for the following         #
####################################################################
dnsrecon_location       = "*********************************"
theharvester_location   = "*********************************"
metagoofil_location     = "*********************************"
####################################################################

#Variables
target = sys.argv[1]
subdomainlist = "*********************************"

def header():
    print "-" * 50
    print " Target: %s" % target
    print "   Scan: %s" % scan_type
    print "-" * 50

def dnsrecon():
    print "running DNSRecon Stage....\n"
    subprocess.call("python '%s' -t brt,std,axfr -D '%s' -d '%s' > /tmp/dnsrecon.tmp" % (dnsrecon_location, subdomainlist, target), shell=True)
    dnsrecon_file = open("/tmp/dnsrecon.tmp")
    for line in dnsrecon_file:
        ip = re.findall(r'(?:[\d]{1,3})\.(?:[\d]{1,3})\.(?:[\d]{1,3})\.(?:[\d]{1,3})$', line)
        if ip: 
            col = line.split()
            results = col[2] + "\t" + col[3]
            print results
    dnsrecon_file.close()
    os.remove("/tmp/dnsrecon.tmp")

def theharvester():
    print "\nrunning TheHarvester...\n"
    subprocess.call("python '%s' -l 500 -b google -d '%s' > /tmp/harvester.tmp" % (theharvester_location, target), shell=True)
    harvester_file = open("/tmp/harvester.tmp")
    for line in harvester_file:
        email = re.findall('@', line)
        if email:
            print line
    harvester_file.close()
    os.remove("/tmp/harvester.tmp")

def metadata():
    print "running metadata enumeration"

def users():
    print "\nFinding Users...\n"
    subprocess.call("python '%s' -l 500 -b linkedin -d '%s'" % (theharvester_location, target), shell=True)
    # users_file = open("/tmp/users.tmp")
    #for line in users_file:
        # email = re.findall('-', line)
        # if email:
     #       print line
            #col = line.split()
    # users_file.close()
    # os.remove("/tmp/users.tmp")

#Actual script
def core():

    if not dnsrecon_location:
        print "location NOT set for: DNSRecon"
        exit()

    if not theharvester_location:
        print "location NOT set for: TheHarvester"
        exit()

    if not metagoofil_location:
        print "location NOT set for: Metagoofil\n"
        exit()

    if args.intensive:
        global subdomainlist
        subdomainlist = "*********************************"

    if args.dns:
        dnsrecon()
        exit()

    if args.email:
        theharvester()
        exit()

    if args.metadata:
        metadata()
        exit()

    if args.users:
        users()
        exit()
    
    if args.test:
        exit()

    dnsrecon()
    theharvester()
    users()

#Ye old main
def main():
    banner()
    core()

main()
