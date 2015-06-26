#!/bin/bash

#Automatically run recon against a domain/list of domains.
#
# Current Features: 
# * Whois the domain and ip.
# * Email Harvesting
# * Meta Data Enumeration
# * WhoIs
#
# Additional Features
# * Pull domains from SSL Certificate
#
# Usage: ./ITGscan.sh listofdomains.txt (disabled)
# Usage: ./ITGscan.sh domain.com
#
# By: Leon Teale (@leonteale)
#

## Setting Coloured variables
red=`echo -e "\033[31m"`
lcyan=`echo -e "\033[36m"`
yellow=`echo -e "\033[33m"`
green=`echo -e "\033[32m"`
blue=`echo -e "\033[34m"`
purple=`echo -e "\033[35m"`
normal=`echo -e "\033[m"`
 
## Variables
version="1.0"
target="$1"
CurrentDate=`date +%Y%m`
wdir="./ITGscan_results/$CurrentDate/$target"
tmpwdir="$wdir"


## Check for correct usage
usage () {
			if [ -z "$target" ];
				then
					#echo "$red Incorrect Usage!$normal"
					echo "Usage: ./ITGscan.sh listofips.txt"
					echo "Usage: ./ITGscan.sh domain.com"
					echo ""
					exit 1
			fi
		}

## check  environment is set up correctly before continueing
prerequisits () {
                                        ##need to make checks that the programs are installed first##
                                        ##                                                                                                                 ##
                                        mkdir -p ./ITGscan_results/
                                        mkdir -p ./ITGscan_results/$CurrentDate/$target
                                        mkdir -p ./ITGscan_results/$CurrentDate/$target/tmp
                                                                                
                                        which dnsrecon && dnsrecon_check="true" || dnsrecon_check="false";     
                                                if ! echo $dnsrecon_check | grep -q "true";
                                                        then 
                                                                echo "$red dnsrecon was not found in \$PATH";
								echo ""
								exit 1
                                                fi
                                }

## Display script header
header ()  {	
				clear
				echo "$yellow  ___ _____ ___                   "
				echo "$yellow |_ _|_   _/ __|___ __ __ _ _ _   "
				echo "$yellow  | |  |  | (_ (_-</ _/ _\` | ' \  "
				echo "$yellow |___| |__|\___/__/\__\__,_|_||_| $normal$yellow (version $green$version$yellow)"
				echo "$lcyan  -- by Leon Teale (@leonteale)"
				echo ""
				echo "$blue +-------------------------------------------+"
				echo "$blue | $red Current Features$normal                      $blue   |$normal"
				echo "$blue | $yellow * SSL Tests$normal                           $blue   |$normal"
				echo "$blue | $yellow * DNS Recon$normal                           $blue   |$normal"
				echo "$blue | $yellow * Email Harvesting$normal                     $blue  |$normal"
				echo "$blue | $yellow * Meta DataEnumeration$normal                 $blue  |$normal"
				echo "$blue | $yellow * WhoIs$normal                                  $blue|$normal"
				echo "$blue |                                           |"
				echo "$blue | $red Additional Features            $normal         $blue |$normal"
				echo "$blue | $yellow * Pull domains From SSL Cert$normal$blue             |$normal"
				echo "$blue +-------------------------------------------+$normal"
				echo "$lcyan Target = $green$target$lcyan   $lcyan Date = $green$(date +%d/%m/%Y)$lcyan" 
				echo ""
			}



DNSrecon () {			
				#### DNS recon ####
		
				dig @8.8.8.8 ns $target | grep NS | grep -vE 'flags:' | awk {'print $5'} |sort > $tmpwdir/$target_nameservers.txt
			
				nameservers="`cat $tmpwdir/$target_nameservers.txt | grep -vE '^$'`"
				nameserver="`cat $tmpwdir/$target_nameservers.txt | grep -vE '^$' | head -1`" 
				mx="`dig @8.8.8.8 mx $target | grep MX | grep -vE 'flags:' | awk {'print $6'} | grep -vE '^$' |sort`"
					
				dig @$nameserver $target axfr > $tmpwdir/$target_axfr.txt
		
				if cat $tmpwdir/$target_axfr.txt | grep -q "Transfer failed"
					then 
						axfr="$green False"
					else
						axfr="$red True"
				fi
				
				ip="`dig @8.8.8.8 +short $target`"

				if host $ip | grep "not found" > /dev/null
					then
						rdns="$red No rDNS set $yellow"
					else
						rdns="$green$(host $ip | awk {'print $5'})$yellow"
				fi

				echo -e "IP Address	: $yellow$ip ($rdns)$lcyan"	
				echo -e "Mail Exchange	: $yellow$mx$lcyan"
				echo -e "Zone TRansfer	:$axfr$lcyan"
				echo -e "Nameservers 	: $yellow$nameservers$lcyan"

					echo -e "\n$purple ----------------------------------------------------------------------------"
					echo " DNS Recon"
					echo " ----------------------------------------------------------------------------$normal"
					echo ""
					echo "Run intense scan? [y/N]"
                                	read intense
                	                if [[ $intense  == y ]];
                        	                then
                                	                dnslist="dnslistlong"
							dnsscan_type="long"
                                        	else
                                                	dnslist="/usr/share/dnsrecon/namelist.txt" ###dnt forget to change this back without the '2'
							#dnslist="/root/Desktop/templist.txt"
							dnsscan_type="short"
                                	fi
					echo -e "$red Running $dnsscan_type scan, please wait...$yellow"
					dnsrecon_continue="true"		
						if [ -f ./ITGscan_results/$CurrentDate/$target/dnsrecon_$dnsscan_type.txt ];
							then 
								echo ""
								echo "$red You seem to have a dns recon file for this domain already"
								echo "$red Would you like to view this file instead? [y/N] $yellow"
								read dnsrecon_file_found
									if [[ $dnsrecon_file_found == "y" ]];
										then 
											cat ./ITGscan_results/$CurrentDate/$target/dnsrecon_$dnsscan_type.txt > ./ITGscan_results/$CurrentDate/$target/dnsrecon_full.txt
											dnsrecon_brute="`cat ./ITGscan_results/$CurrentDate/$target/dnsrecon_$dnsscan_type.txt | wc -l`"
                                                                			echo "$lcyan DNS Bruteforce...		$yellow$dnsrecon_brute$lcyan subdomains found"
											dnsrecon_continue="false"
											
										else
											dnsrecon_continue="true"
									fi	
						fi
						if [[ $dnsrecon_continue == "true" ]]
							then			
								dnsrecon -t brt,std,axfr -D $dnslist -d $target > $tmpwdir/$target_dnsrecon.txt 
								cat $tmpwdir/$target_dnsrecon.txt | grep "*" | awk {'print $3 "\t" $4'} | sort -u |  grep '[^\.][0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}[^\.]' | grep "$target" > ./ITGscan_results/$CurrentDate/$target/dnsrecon_$dnsscan_type.txt
								cat ./ITGscan_results/$CurrentDate/$target/dnsrecon_$dnsscan_type.txt > ./ITGscan_results/$CurrentDate/$target/dnsrecon_full.txt
								dnsrecon_brute="`cat ./ITGscan_results/$CurrentDate/$target/dnsrecon_$dnsscan_type.txt | wc -l`"
								echo "$lcyan DNS Bruteforce...		$yellow$dnsrecon_brute$lcyan subdomains found"   
						fi

				#### reverse ip lookups of ip blocks ####
				ip_base="`echo $ip | cut -d . -f -3`"
				
				dnsrecon -r $ip_base.0-$ip_base.254 | grep $target > $tmpwdir/$target_dnsrecon_reverse.txt
				cat $tmpwdir/$target_dnsrecon_reverse.txt | grep "*" | awk {'print $3 "\t" $4'} | sort -u |  grep '[^\.][0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}[^\.]' | grep "$target" > ./ITGscan_results/$CurrentDate/$target/dnsrecon_reverse.txt
				diff ./ITGscan_results/$CurrentDate/$target/dnsrecon_$dnsscan_type.txt ./ITGscan_results/$CurrentDate/$target/dnsrecon_reverse.txt | grep ">" | awk {'print $2 "\t" $3'} >> ./ITGscan_results/$CurrentDate/$target/dnsrecon_full.txt 
				dnsrecon_reverse="`cat ./ITGscan_results/$CurrentDate/$target/dnsrecon_reverse.txt | wc -l`"
                                echo "$lcyan IP block reverse lookup...	$yellow$dnsrecon_reverse$lcyan subdomains found"
				echo ""

				dnsrecon_all="`cat ./ITGscan_results/$CurrentDate/$target/dnsrecon_full.txt | wc -l`"
				echo "$lcyan Total subdomains found...	$green$dnsrecon_all$yellow"
				echo ""
				cat ./ITGscan_results/$CurrentDate/$target/dnsrecon_full.txt
		}


SSLtest () {
				#### SSLscan ####
				echo -e "\n$purple ----------------------------------------------------------------------------"
					echo " SSL Tests"
					echo " ----------------------------------------------------------------------------$normal"
				echo -e "$lcyan Full$yellow sslscan$lcyan results can be found in:\n $green$wdir/sslscan.txt"
				echo ""
				sslscan $target > $wdir/sslscan.txt
				echo ""
				#### SSL Ratings ####
				# fail = RC4,SSLv2,SSLv3,TLS1.0
				

				if cat $wdir/sslscan.txt | grep -i RC4 > /dev/null
					then
						echo "RC4" >> $tmpwdir/$target_ssl_ciphers.txt
				fi

				if cat $wdir/sslscan.txt | grep -i SSLv3 > /dev/null
					then
						echo "SSLv3" >> $tmpwdir/$target_ssl_ciphers.txt
				fi

				if cat $wdir/sslscan.txt | grep -i SSLv2 > /dev/null
					then
						echo "SSLv2" >> $tmpwdir/$target_ssl_ciphers.txt
				fi

				#if cat $wdir/sslscan.txt | grep -i TLSv1.0 > /dev/null
				#	then
				#		echo "TLSv1.0" >> $tmpwdir/$target_ssl_ciphers.txt
				#fi

				if [ -f "$tmpwdir/$target_ssl_ciphers.txt" ]
					then
					    echo "$lcyan SSL Score =$red FAIL$normal"
					    echo ""
					    echo -e "$lcyan Server supports:\n $red$(cat $tmpwdir/$target_ssl_ciphers.txt)$normal"
					    rm $tmpwdir/$target_ssl_ciphers.txt
					    echo ""
					else
					    echo "$lcyan SSL Rating =$green PASS$normal"
					    echo ""
				fi
									

		}

email_harvesting () {
				echo -e "\n$purple ----------------------------------------------------------------------------"
					echo " Email Harvesting..."
					echo " ----------------------------------------------------------------------------$normal"
				echo ""
				harvester_count="$(cat ./ITGscan_results/$CurrentDate/$target/harvester.txt | grep '@' | grep -vE'edge-security.com'| sort -u | wc -l)"

				theharvester -l 500 -b all -d $target > ./ITGscan_results/$CurrentDate/$target/harvester.txt

				echo "$lcyan Total Emails found...  $green$harvester_count$yellow"
				echo ""

				cat  ./ITGscan_results/$CurrentDate/$target/harvester.txt | grep "@" | grep -vE'edge-security.com' | sort -u

		    }

User_enumeration () {
								echo -e "\n$purple ----------------------------------------------------------------------------"
					echo " Enumerating Users..."
					echo " ----------------------------------------------------------------------------$normal"
                                echo ""
                                user_count="`#`"

                                ####### > ./ITGscan_results/$CurrentDate/$target/#######

                                echo "$lcyan Total users found...  $green$harvester_count$yellow"
                                echo ""

                                cat  ./ITGscan_results/$CurrentDate/$target/##########


                    }


usage
prerequisits
header
DNSrecon
SSLtest
email_harvesting
#user_enumeration
