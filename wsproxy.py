import asyncio
import websockets
import ssl
import sys
import getopt

PASS = ''
LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = 80
SSH_PORT = 22
DEFAULT_HOST = "127.0.0.1"
RESPONSE = (
    "HTTP/1.1 101 Switching Protocols\r\n"
    "Upgrade: websocket\r\n"
    "Connection: Upgrade\r\n\r\n"
)

def print_usage():
    print('Usage:')
    print('  wsproxy.py -p <port> [-b <bind_ip>] [-s <ssh_port>]')
    print('Example:')
    print('  wsproxy.py -b 0.0.0.0 -p 8080 -s 22')

def parse_args(argv):
    global LISTENING_ADDR, LISTENING_PORT, SSH_PORT

    try:
        opts, _ = getopt.getopt(argv, "hb:p:s:", ["bind=", "port=", "sshport="])
    except getopt.GetoptError:
        print_usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print_usage()
            sys.exit()
        elif opt in ("-b", "--bind"):
            LISTENING_ADDR = arg
        elif opt in ("-p", "--port"):
            LISTENING_PORT = int(arg)
        elif opt in ("-s", "--sshport"):
            SSH_PORT = int(arg)

async def handle_connection(websocket, path):
    try:
        client_buffer = await websocket.recv()
        host_port = find_header(client_buffer, 'X-Real-Host') or DEFAULT_HOST

        if PASS and find_header(client_buffer, 'X-Pass') != PASS:
            await websocket.send('HTTP/1.1 400 Wrong Password!\r\n\r\n')
            return

        print(f'Connecting to {host_port}')
        target = await connect_target(host_port)
        await websocket.send(RESPONSE)

        await asyncio.gather(
            transfer_data(websocket, target),
            transfer_data(target, websocket)
        )

    except Exception as e:
        print(f"Connection error: {e}")

    finally:
        await websocket.close()

async def connect_target(host):
    if ':' in host:
        host, port = host.split(':', 1)
        port = int(port)
    else:
        port = 443 if host.startswith('wss') else 80

    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    return await websockets.connect(f"ws://{host}:{port}", ssl=context)

async def transfer_data(source, destination):
    try:
        while True:
            data = await source.recv()
            if data:
                await destination.send(data)
            else:
                break
    except websockets.ConnectionClosed:
        pass

def find_header(buffer, header):
    lines = buffer.split('\r\n')
    for line in lines:
        if line.lower().startswith(header.lower() + ':'):
            return line.split(':', 1)[1].strip()
    return None

def main():
    print(f"Starting WebSocket Proxy on {LISTENING_ADDR}:{LISTENING_PORT}")

    start_server = websockets.serve(
        handle_connection, LISTENING_ADDR, LISTENING_PORT
    )

    loop = asyncio.get_event_loop()
    loop.run_until_complete(start_server)

    try:
        loop.run_forever()
    except KeyboardInterrupt:
        print('Stopping server...')
        loop.stop()

if __name__ == '__main__':
    parse_args(sys.argv[1:])
    main()
