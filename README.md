# WebSocket Proxy Server

WebSocket Proxy is a Python-based script that allows you to create a proxy service using the WebSocket protocol. It is useful for forwarding SSH connections over WebSocket, enabling more flexible access using CDN services or HTTP injectors.

## Features

- Supports WebSocket connections.
- Enables SSH access through WebSocket with CDN.
- Dynamically configures SSH and HTTP ports.
- Equipped with service management using `systemd`.
- Password authentication for additional security.

## Requirements

- Python 3.x
- Python packages: 
  - `websockets`
  - `asyncio`
  - `bcrypt`
  - `pip`
- Sudo access to install packages and manage the service.

## Installation

### Clone Repository:

```bash
git clone https://github.com/fajarenjoyneer/ssh-webproxy.git 
cd ssh-webproxy
sudo chmod +x main.sh
sudo ./main.sh
```

## Usage
Once the service is running, you can access the WebSocket proxy using the configured IP and port. To SSH through WebSocket, use a payload similar to the following in the HTTP injector:
```bash
GET / HTTP/1.1
Host: <your_host>
Connection: Upgrade
Upgrade: websocket
```

## Contributors
Thank you to all contributors who have helped in the development of this project.

## License
This project is licensed under the MIT License.
