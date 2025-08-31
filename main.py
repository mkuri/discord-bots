import asyncio
import os
import threading
import time

import uvicorn
from discord import Intents
from discord.ext import commands
from fastapi import FastAPI

# 1. Configuration and Instantiation
# ------------------------------------
TOKEN = os.environ.get("TOKEN")
PORT = int(os.environ.get("PORT", 8080))

intents = Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='>', intents=intents)


# 2. Discord Bot Events and Commands
# ------------------------------------
@bot.event
async def on_ready():
    print(f'Logged in as: {bot.user}')
    print('Discord Bot is ready.')

@bot.command()
async def ping(ctx):
    await ctx.send('pong')


# 3. FastAPI App for Health Check
# ------------------------------------
app = FastAPI()

@app.get("/")
def health_check():
    # bot.is_ready() can only be used in an async context,
    # so we return a simple static response here.
    return {"status": "ok"}


# 4. Main Execution Block
# ------------------------------------
def run_fastapi():
    """Function to run the FastAPI server using Uvicorn."""
    config = uvicorn.Config(app, host="0.0.0.0", port=PORT)
    server = uvicorn.Server(config)
    asyncio.run(server.serve())

if __name__ == "__main__":
    # Start the FastAPI server in a background thread.
    #
    # DESIGN PRINCIPLE: The health check server must not block the main bot process.
    # Using a daemon thread is crucial. A daemon thread will exit automatically
    # when the main thread (the bot) exits. This prevents a "zombie process"
    # where the health check server stays alive after the bot has crashed.
    api_thread = threading.Thread(target=run_fastapi, daemon=True)
    api_thread.start()

    time.sleep(2) # Allow time for the server to start

    try:
        # Start the Discord bot in the main thread. This is a blocking call.
        bot.run(TOKEN)
    except Exception as e:
        print(f"Discord Bot encountered a fatal error: {e}")
    finally:
        print("Discord Bot is shutting down.")
