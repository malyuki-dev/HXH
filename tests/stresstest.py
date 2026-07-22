import asyncio
import socket
import struct

async def bot_client(bot_id):
    # Simulated basic Tibia/OT login connection
    # Note: True protocol requires RSA exchange, XTEA keys, etc.
    # This script connects 500 sockets concurrently to test the server's acceptor limits and basic thread dispatching.
    
    reader, writer = await asyncio.open_connection('127.0.0.1', 7172)
    
    # Just hold the connection open to simulate a connected bot
    try:
        # A simple ping packet structure (length + payload)
        # length = 2 bytes (little endian)
        writer.write(struct.pack('<H', 1) + b'\x1E') # \x1E = ping
        await writer.drain()
        
        while True:
            data = await reader.read(1024)
            if not data:
                break
            await asyncio.sleep(1)
    except Exception as e:
        pass
    finally:
        writer.close()
        await writer.wait_closed()

async def main():
    print("Starting 500 concurrent bot connections...")
    bots = [bot_client(i) for i in range(500)]
    await asyncio.gather(*bots)
    print("All bots disconnected.")

if __name__ == '__main__':
    asyncio.run(main())
