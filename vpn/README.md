
# BOSH deployed IPSEC VPN server 

Use at your own risk - security depends on correct configuration!
By default, inner-tunnel authentication is any valid local user on the vpn system
eg. 'vcap' user
Be sure to set a secure 'vcap' user password via BOSH if using this method.

## manual server-side setup steps

* (AWS) disable source/dest checking for the VPN VM
* update the network route tables to point to the VPN VM for routing to the VPN pool address network


## Manifest

* refer to the template directory for an example manifest

### Manifest settings explained

  ipsec:
   # Ipsec ID of this system
   local_id: "vpn-server"

Can be used to validate that the clients are talking to the correct VPN server, and not an impostor

   # Ipsec group ID expected to be sent by client
   remote_id: "my-secet-group-id"

Outer tunnel authentication -  AKA Cisco group ID

   # Preshared key for above group ID
   psk: "my_super_secret_pwd"

Outer tunnel authentication - AKA Cisco group password

   # My local subnet I'm routing traffic to
   local_net: "10.0.0.0/17"

The private network you want to access

   # Do I wait for connection, or dial the other side?
   passive: "on"

Always 'on' in a classic dial-in VPN

   # First pool network address to give out
   pool_1st_ip: "192.168.0.1"

First IP from the Pool you're giving to VPN clients

   # Netmask for VPN pool
   pool_netmask: "255.255.255.0"

Pool Netmask

   # Number of pool ip's to give out
   pool_size: "10"

Maximum number of simulateous clients / IPs you want to support

   # Pool DNS server
   pool_dns: "10.0.0.10"

Probably your BOSH micro, or other DNS server in the remote environment