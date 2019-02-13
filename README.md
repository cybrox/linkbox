# Linkbox
#### Preamble
Linkbox is a small security proof-of-concept project.
When attempting to compromise any system, one of the most crucial actions is gaining access to its network or a network associated with it. Once an attacker has gained access to a network, he is free to perform attacks on all systems within the network, until he is either detected by a network administrator and removed from the network forcefully or reached his goal.

#### Company Networks
Generally, most WiFi networks will be protected by some means, using the WEP, WPA or WPA2 protocols. While there are tools for attacking networks protected by these protocols (or devices within them), this is outside of the scope of this demonstration. However, with a bit of social engineering, WiFi network passwords are one of the easiest ressources to accquire in this whole process. With this in mind, we will design linkbox to connect to the network with the credentials it has been given.

#### Network accessibility
A lot of company networks are accessible via VPN for allowing employees to work from remote locations, log in during service routines, etc. For networks that are easily accessible from the outside, linkbox does not create a significant benefit, if the attacker has already accquired the credentials of a user account. However, if no user credentials are known, linkbox can still be placed inside the network and used as an entrypoint for scoping out other attack vectors.

---

Linkbox consists of a hardware part, which is a raspberry pi strapped to a battery pack and a server part, which is an Alpine Linux docker container that can run anywhere. 

---




## Workflow
On boot, the raspberry pi will connect to the WiFi network it has been configured to using [wpa_supplicant](https://raspberrypihq.com/how-to-connect-your-raspberry-pi-to-wifi/). It will then go on to try and open a reverse ssh tunnel to the server, binding its local port `22` to the server's port `10022 `, using the `private_key` file containing the private key to the public key stored on the server.  

Once the reverse ssh connection is established, a user can simply use the `linkbox` binary inside the server container to connect to the local port `10022` via ssh, using the `private_key` file containing the private key to the public key stored on the raspberry pi.

In short:
1. Linkbox server container is started on public host
2. Linkbox client boots up
3. Linkbox client connects to WiFi network
4. Linkbox client establishes reverse ssh connection
5. User on the Linkbox server container uses reverse ssh tunnel
6. :tada:

The user now has an open SSH tunnel to a device in the target network, bypassing its NAT. (Of course firewalls with deep packet inspection could still block this, but that's another story).

Obviously, the user is free to do whatever he likes. For an example scenario, a german manufacturer of door communication systems exposes an HTTP API that allows third party devices to open the door without further authentication. Any device in the local network can use this endpoint. **So we are just one `curl` command away from opening the front door.**




## Project structure
The following files will be used on client and server respectively.
```
├── client/
│   ├── authorized_keys -> /home/pi/.ssh/authorized_keys
│   ├── private_key -> /home/pi/private_key
│ 
├── server/
│   ├── authorized_keys -> /home/linkbox/.ssh/authorized_keys
│   ├── private_key -> /home/linkbox/private_key
│   ├── entrypoint.sh -> /usr/local/bin/entrypoint.sh
│   ├── linkbox -> /usr/local/bin/linkbox
```




## Usage
Both, the server and client use case assume you have cloned this repository and operate from its root directory.

#### Linkbox Server
```bash
# Building the server container
docker build --no-cache --tag linkbox-server ./server

# Running the server container
docker run --rm -p 10666:22 -it linkbox-server /bin/bash
```


#### Linkbox Client
```bash
# Run automated setup to connect
./linkbox.sh <server-ip>

# For its actual use case, linkbox should run once it has
# booted, so we can add it to /etc/rc.local before `exit 0`
cd <path/to/repo> && bash linkbox.sh <server-ip>
```




## Possible improvements
Linkbox is a simple proof-of-concept, it is not intended to actually be used in any malicious scenario, thus, we omitted a lot of key features here. For an actual attack, linkbox could be extended to:
* Persist keypairs across container restarts to ensure safe connection to linkbox server
* Persist keypairs across container restarts to ensure safe connection to linkbox client
* Use TOR for hosting the server container as a hidden service to hide our identity
* Use TOR for routing requests from linkbox so the traffic is obfuscated
* Add retries and timeouts to all operations
* Add error reporting and local logging in case of failure
