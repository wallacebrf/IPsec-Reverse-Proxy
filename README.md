# IPsec-Reverse-Proxy
VPS IPsec Reverse Proxy
<div id="top"></div>



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/wallacebrf/IPsec-Reverse-Proxy">

<h3 align="center">Virtual Private Server (VPS) Reverse Proxy IPv4 addresses to IPv6 addresses using SOCAT for IPsec VPN traffic when the target is behind IPv4 CGNAT</h3>

  <p align="center">
    This project is to document how to setup a virtual private server (VPS) to get around CGNAT for IPsec VPNs. This setup does require that the target IPsec VPN has a ipV6 address available to it as it is the IPv6 address that all traffic will be directed to. 
    <br />
    <a href="https://github.com/wallacebrf/IPsec-Reverse-Proxy"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/wallacebrf/IPsec-Reverse-Proxy/issues">Report Bug</a>
    ·
    <a href="https://github.com/wallacebrf/IPsec-Reverse-Proxy/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#About_the_project_Details">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Road map</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
### About_the_project_Details

This project does not detail how to create a VPS, or which VPS hosting provider one should use. The only requirement is that the VPS needs both a public IPv4 and IPv6 address. What this project does document is how to perform all of the required configurations of the VPS once you have one. 

The reason I created this project is because I use a fortigate router's IPsec VPN to access my home network resources when outside of my house. My ISP has changed me from a public IPv4 address to a IPv4 address behind Carrier Grade NAT (CGNAT) that prevents me from accessing my IPv4 address publicly. Luckily for me though, my fortigate router does have a publicly assigned IPv6 address assigned to the WAN port. 
Thanks to the IPv6 port, I can technically still access my home network resources, however basically all hotels I have ever used only provide IPv4 addresses which means I would not be able to connect to my VPN at those hotels. 

I tried setting up a NGINX reverse proxy but could not get it to work with the ports 500 and 4500 used by IPsec. I was able to get the NGINX reverse proxy to work with HTTPS traffic which means I could use my Fortigate SSL-VPN. However SSL-VPN has been having a lot of vulnerabilities lately and so I have moved entirely to IPsec. 

Due to NGINX not working, I stumbled upon the SOCAT Linux utility. The socat utility is a relay for bidirectional data transfers between two independent data channels. Refer <a href="https://www.redhat.com/sysadmin/getting-started-socat">HERE</a> for more information on SOCAT. 

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started



### Prerequisites
1. a working VPS server (THIS INSTRUCTION ASSUMES UBUNTU AS DIFFERENT DISTROS HAVE DIFFERENT COMMANDS)
2. a working IPsec VPN device
3. working IPv6 address on the IPsec VPN device


### Installation

### 1. Firewall Configuration

log in through SSH and using your preferred text editor, edit file ```/etc/default/ufw```. 
Ensure IPV6 is set to yes. 
```
IPV6=yes
```
If the setting is not set to yes, change it, save the file, and exit the text editor. 

we want to make sure the default state of all incoming configurations is set to blocked. Use the following command
```
ufw default deny incoming
```
you should see the following result:
```
Output
Default incoming policy changed to 'deny'
(be sure to update your rules accordingly)
```
We next want to allow all outgoing connections
```
ufw default allow outgoing
```
you should see the following result:
```
Output
Default outgoing policy changed to 'allow'
(be sure to update your rules accordingly)
```

we want to ensure that SSH connections are still allowed through, otherwise we will lock ourselves out of our own server
```
ufw allow OpenSSH
```
you should see the following result:
```
Rule added
Rule added (v6)
```

next we need to ensure IPsec traffic will be allowed through, so we need to allow UDP ports 500 and 4500. enter the two following commands:
```
ufw allow 500/udp
ufw allow 4500/udp
```
after each command you should see the following result:
```
Rule added
Rule added (v6)
```
before we enable the firewall, let's ensure the settings look good
```
ufw status numbered
```
you should see the following output
```
Status: inactive

     To                         Action      From
     --                         ------      ----
[1] OpenSSH                    ALLOW IN    Anywhere
[2] OpenSSH (v6)               ALLOW IN    Anywhere (v6)
[3] 500/udp                    ALLOW IN    Anywhere
[4] 500/udp (v6)               ALLOW IN    Anywhere (v6)
[5] 4500/udp                   ALLOW IN    Anywhere
[6] 4500/udp (v6)              ALLOW IN    Anywhere (v6)
```

we only want to allow IPv4 addresses to access the VPS so we need to delete the three lines that have ```(v6)``` on them. Use the following command to delete the entries based on their ID numbers. the example below will delete the second line for the ```[2] OpenSSH (v6)               ALLOW IN    Anywhere (v6)```
If you do wish to access your VPS through IPv6 address space, then do not delete the lines above. 

```
ufw delete 2
```
the command will ask you to confirm, confirm the deletion. repeat the process for the remaining IPv6 entries. You should see the following:

```
Status: inactive

     To                         Action      From
     --                         ------      ----
[1] OpenSSH                    ALLOW IN    Anywhere
[2] 500/udp                    ALLOW IN    Anywhere
[3] 4500/udp                   ALLOW IN    Anywhere
```

we can now enable the firewall using the command:
```
ufw enable
```
you should see the following warning, select yes to continue
```
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
```
### 2. Installing SOCAT utility
Enter the following command
```
apt-get install -y socat
```
### 3. socat start script
we need a script to execute on system boot that will start socat as we need it

using your preferred text editor, create the following file: ```/var/www/socat.sh``` and enter the following:
```
#!/bin/bash
	current_date=$(date '+%F %X')
	echo "$current_date - socat process restarted for the day" >> /var/log/socat-500.log
	echo "$current_date - socat process restarted for the day" >> /var/log/socat-4500.log
	socat UDP4-LISTEN:500,reuseaddr,fork UDP6:ipv6.your-domain.com:500 >> /var/log/socat-500.log 2>&1 &
	socat UDP4-LISTEN:4500,reuseaddr,fork UDP6:ipv6.yourdomain.com:4500 >> /var/log/socat-4500.log 2>&1 &
```
the first three lines add the date details to the two socat log files for ease of future troubleshooting. 

the next two lines create two copies of SOCAT. One is listening on IPv4 UDP port 500 and forwarding that traffic on IPv6 UDP port 500 to our desired IPv6 IPsec VPN device. the second is listening on IPv4 UDP port 4500 and forwarding that traffic on IPv6 UDP port 4500 to our desired IPv6 IPsec VPN device.

If you do not have a domain, then use the server address directly but ensure the IPv6 address is enclosed in brackets like ```[your_ipv6_addr]```

save the file and exit the text editor

make sure the file is executable:
```
chmod +x /var/www/socat.sh
```

### 4. socat maintainance command
the way we are using SOCAT, specifically the part of the command ```reuseaddr,fork``` causes a new forked copy process to form when a connection is made. To ensure we do not have too many concurrent empty/dead processes build up over time, we need to periodically terminate all active socat processes. I run this every 24 hours with ```crontab```, but it can be run less frequently if desired. 

```
ps -ef | grep '[s]ocat' | grep -v grep | awk '{print $2}' | xargs -r kill -9
```

### 5. schedule crontab
we need to schedule the commands to operate as needed, so let's edit the crontab file
```crontab -e```
and select your preferred text editor

add the following:
```
@reboot /var/www/socat.sh
@reboot date >> /var/log/boot_log.txt
0 7 * * * ps -ef | grep '[s]ocat' | grep -v grep | awk '{print $2}' | xargs -r kill -9  2>&1 | logger -t mystopcommand
1 7 * * * /var/www/socat.sh  2>&1 | logger -t mystartcommand
```
the first line will ensure socat is running whenever the server boots.

the second line adds the date of the server boot to a log file, so we can have a record of if/when the server reboots. 

the third line runs the socat stop command every day at 7:00 AM. I actually want the script to run at 2:00 AM but due to time zones and where the VPS is located, I had to adjust the time accordingly. The end of the command ```2>&1 | logger -t mystopcommand``` saves the output of the command into syslog. to find the results of the command if there are any errors use the command ```grep 'mystopcommand' /var/log/syslog``` or ```grep 'mystartcommand' /var/log/syslog```. This is not needed if everything is working well, however when I first started this I had this command within a .sh bash file which was not stopping the processes as I expected. Adding the Syslog ability i realized that there was a permissions issue and the script was being denied. 

the fourth line re-runs the socat start commands 1 minute after the previous copies of socat were terminated to ensure we have our need processes for the reverse proxy. 

please note that when the stop script executes, any active IPsec tunnels will be terminated, and will not be able to re-establish for 1 minute until the start script runs again. 

the last two lines do not need to be run every 24 hours, they could be run every couple of days or longer if desired. it is user preference depending on how many copies of socat are started and the memory capacity of the VPS. 

save the file and exit the text editor. 

### 6. Testing
Let's reboot the server to ensure the @reboot socat start script works:

```
shutdown -r now
```
your SSH session will be terminated. allow the server to reboot and log back in. 
let's ensure socat is running

```
ps -aux | grep socat
```

you should see one copy of the port 500 and one copy of the port 4500 processes running. 

you can now connect to your IPv6 IPsec VPN connection using the IPv4 public IP assigned to your VPS. 

### 6. Firewall Enhanced Blocking of ASNs for other Hosting Providers

to increase the security of the VPS and the IPsec VPN device we are forwarding IPv4 traffic to, one can add IP addresses to the ufw firewall to block connections. 

I already have a list of ASNs I already use to block connections to my Fortigate router directly, but with the fortigate allowing connections from the VPS IPv6 address, any malicious actors accessing the VPS's IPv4 address will be allowed through to the Fortigate. This section will insure that the VPS will also block these same connections. 

Look through this list of ASNs being blocked:

https://github.com/wallacebrf/dns/blob/main/ASN_LIST.txt

determine if the VPS provider you are using like Hetzner, Linode etc are listed there and find their ASN number entries. 

update this file ```https://github.com/wallacebrf/dns/blob/main/ASN_block_lists_all.php``` to comment out / delete those ASN lines as we do not want to block our own hosting provider from our VPS as that could cause unexpected results. 

run the PHP file on a working PHP server to allow the file ```asn_block1.1.txt``` to download

open the text file using notepad++. The ASNs will have both IPv4 and IPv6 and we need to remove the IPv6 addresses since ufw is already configured to only allow IPv4 addressees. If you do wish to use IPv6 to access your VPS, then skip this part to remove IPv6 lines

within notepad++ press ctrl+f to bring up the find box. Go over to the "mark" tab. if the mark tab is missing, update your copy of notepad++. In the "find what" field, enter ":" without the quotes as we are searching for all instances of a colon. 

Ensure the checkbox "Bookmark Line" is checked and click "Mark All"

close out of the find window. In Notepad++'s main menu, click ```search --> Bookmark --> Remove Bookmarked Lines```

this will delete all of the IPv6 addresses. 

on your VPS SSH window, change the directory using ```cd /var/www```

create a new file using your preferred text editor such as ```vi blocked.ip.list```

upload all of the entries from the  ```asn_block1.1.txt``` file into the ```blocked.ip.list``` file. this will take a few minutes. When the copy/paste is complete, save the file. 

create a new file using your preferred text editor such as ```vi ufw.sh```

add the following to the file:

```
#!/bin/bash

counter=1
while IFS= read -r block
do
   echo "Inserting address $counter"
   ufw insert 1 deny from "$block"
   let counter=counter+1
done < "blocked.ip.list"
```

save and exit the text editor. 

PLEASE NOTE THAT ON MY VPS, WITH OVER 49,000 IPV4 ENTRIES BEING ADDED TO USING THE UFW.SH FILE TOOK OVER 24 HOURS TO COMPLETE. 

run the file using ```bash ufw.sh``` and the script will run indicating what line of the file it is currently processing. 

after the script finishes, ensure your can still connect to the IPsec VPN device. 

<!-- CONTRIBUTING -->


Your Name - Brian Wallace - wallacebrf@hotmail.com

Project Link: [https://github.com/wallacebrf/Synology_Data_Scrub_Status)
