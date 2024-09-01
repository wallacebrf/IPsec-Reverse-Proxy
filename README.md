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

The reason I created this project is because I use a fortigate router's IPsec VPN to access my home network resources when outside of my house. My ISP has changed me from a public IPv4 address to a IPv4 address behind Carrier Grade NAT (CGNAT) that prevents me from accessing my IPv4 address publically. Luckilly for me though, my fortigate router does have a publically assigned IPv6 address assigned to the WAN port. 
Thanks to the IPv6 port, I can technically still access my home network resources, howver basically all hotels I have ever used only provide IPv4 addresses which means I would not be able to connect to my VPN at those hotels. 

I tried setting up a NGINX reverse proxy but could not get it to work with the ports 500 and 4500 used by IPsec. I was able to get the NGINX reverse proxy to work with HTTPS traffic which means I could use my Fortigate SSL-VPN. However SSL-VPN has been having a lot of vunerbilities latley and so I have moved entirely to IPsec. 

Due to NGINX not working, I stumbled upon the SOCAT linux utility. The socat utility is a relay for bidirectional data transfers between two independent data channels. Refer <a href="https://www.redhat.com/sysadmin/getting-started-socat">HERE</a> for more information on SOCAT. 

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started



### Prerequisites



### Installation





<!-- CONTRIBUTING -->
## Contributing

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

This is free to use code, use as you wish

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Your Name - Brian Wallace - wallacebrf@hotmail.com

Project Link: [https://github.com/wallacebrf/Synology_Data_Scrub_Status)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments



<p align="right">(<a href="#top">back to top</a>)</p>
