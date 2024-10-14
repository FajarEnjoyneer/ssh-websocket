#!/bin/bash

fun_wsproxy() {
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)

    install_packages() {
        echo "${YELLOW}Installing required packages...${RESET}"
        if command -v apt-get &>/dev/null; then
            sudo apt-get -qq update
            sudo apt-get -qq -y install python3 python3-pip
        elif command -v yum &>/dev/null; then
            sudo yum -q -y update
            sudo yum -q -y install python3 python3-pip
        else
            echo "${RED}Unsupported package manager. Please install Python3 and pip manually.${RESET}"
            exit 1
        fi
    }

    download_wsproxy() {
        echo "${YELLOW}Using local WebSocket proxy script...${RESET}"
        if [[ -f ./wsproxy.py ]]; then
            sudo cp ./wsproxy.py /root/wsproxy.py || {
                echo "${RED}Failed to copy WebSocket proxy script.${RESET}"
                exit 1
            }
        else
            echo "${RED}wsproxy.py not found in the current directory!${RESET}"
            exit 1
        fi
    }

    configure_wsproxy() {
        echo "${CYAN}Configuring WebSocket proxy...${RESET}"
        pip install websockets

        read -p "${CYAN}Enter the hostname as CDN host: ${RESET}" cdn_host
        read -p "${CYAN}Enter the SNI Host: ${RESET}" sni_host
        read -p "${CYAN}Enter your SSH port: ${RESET}" ssh_port

        ask_http_port() {
            while true; do
                read -p "${CYAN}Enter your desired HTTP/HTTPS port (e.g., 443): ${RESET}" http_port
                if ! [[ "$http_port" =~ ^[0-9]+$ ]]; then
                    echo "${RED}Invalid input. Please enter a valid port number.${RESET}"
                elif ((http_port < 1 || http_port > 65535)); then
                    echo "${RED}Port number must be between 1 and 65535.${RESET}"
                else
                    break
                fi
            done
        }

        echo "${CYAN}Please select the HTTP/HTTPS ports:${RESET}"
        echo "${YELLOW}Common HTTP ports: 80, 8080, 8880, 2052, 2082, 2086, 2095${RESET}"
        echo "${YELLOW}Common HTTPS ports: 443, 2053, 2083, 2087, 2096, 8443${RESET}"
        ask_http_port

        cat <<EOF | sudo tee /etc/systemd/system/wsproxy.service > /dev/null
[Unit]
Description=WebSocket Proxy Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/root
ExecStart=/home/fajar/myenv/bin/python3 /root/wsproxy.py -p $http_port -s $ssh_port
Restart=always
RestartSec=5
LimitNOFILE=65535
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=wsproxy
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl enable wsproxy
        sudo systemctl start wsproxy

        echo "${GREEN}WebSocket proxy service has been started and enabled.${RESET}"
    }

    generate_httpinjector_payload() {
        echo "${CYAN}Generating HTTP Injector payload...${RESET}"
        echo "================ HTTP Injector Payload ================"
        echo "Hostname: $cdn_host"
        echo "Port: $http_port"
        echo "SNI: $sni_host"
        echo ""
        echo "Payload: GET / HTTP/1.1[crlf]Host:$cdn_host[crlf]Upgrade: websocket[crlf][crlf]"
        echo "======================================================"
    }

    start_wsproxy() {
        sudo systemctl start wsproxy
        echo "${GREEN}WebSocket proxy service has been started.${RESET}"
    }

    status_wsproxy() {
        sudo systemctl status wsproxy
    }

    stop_wsproxy() {
        sudo systemctl stop wsproxy
        echo "${YELLOW}WebSocket proxy service has been stopped.${RESET}"
    }

    restart_wsproxy() {
        sudo systemctl restart wsproxy
        echo "${GREEN}WebSocket proxy service has been restarted.${RESET}"
    }

    uninstall_wsproxy() {
        sudo systemctl stop wsproxy
        sudo systemctl disable wsproxy
        sudo rm /etc/systemd/system/wsproxy.service
        echo "${YELLOW}WebSocket proxy has been uninstalled.${RESET}"
    }

    if ! command -v python3 &>/dev/null; then
        echo "${RED}Python3 is not installed. Aborting...${RESET}"
        exit 1
    fi

    clear
    PS3="${CYAN}Please select an option: ${RESET}"
    select opt in "Install WebSocket Proxy" "Start WebSocket Proxy" "Status WebSocket Proxy" "Stop WebSocket Proxy" \
                  "Restart WebSocket Proxy" "Uninstall WebSocket Proxy" "Generate HTTP Injector Payload" "Exit"; do
        case $opt in
            "Install WebSocket Proxy")
                download_wsproxy
                configure_wsproxy
                ;;
            "Start WebSocket Proxy")
                start_wsproxy
                ;;
            "Status WebSocket Proxy")
                status_wsproxy
                ;;
            "Stop WebSocket Proxy")
                stop_wsproxy
                ;;
            "Restart WebSocket Proxy")
                restart_wsproxy
                ;;
            "Uninstall WebSocket Proxy")
                uninstall_wsproxy
                ;;
            "Generate HTTP Injector Payload")
                generate_httpinjector_payload
                ;;
            "Exit")
                break
                ;;
            *)
                echo "${RED}Invalid option. Please select again.${RESET}"
                ;;
        esac
    done

    echo "${GREEN}WebSocket proxy installation and configuration completed successfully.${RESET}"
}

fun_wsproxy
