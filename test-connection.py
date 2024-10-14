import asyncio
import websockets

async def test_connection():
    uri = "ws://ip-addres:80"
    async with websockets.connect(uri) as websocket:
        print("Connected to WebSocket server")
        await websocket.send("Hello Server")
        response = await websocket.recv()
        print(f"Received: {response}")

asyncio.run(test_connection())

