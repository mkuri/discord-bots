import asyncio
import os
import threading
import time
import traceback

import litellm
import uvicorn
from discord import Intents, Interaction, app_commands
from discord.ext import commands
from fastapi import FastAPI

# 1. Configuration and Instantiation
# ------------------------------------
TOKEN = os.environ.get("DISCORD_BOT_TOKEN")
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
PORT = int(os.environ.get("PORT", 8080))

intents = Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='>', intents=intents)


# 2. Discord Bot Events and Commands
# ------------------------------------
@bot.event
async def on_ready():
    print(f'Logged in as: {bot.user}')
    try:
        synced = await bot.tree.sync()
        print(f"Synced {len(synced)} commands.")
    except Exception as e:
        print(e)

@bot.tree.command(name="ping", description="Test bot response time.")
async def ping(interaction: Interaction):
    await interaction.response.send_message(f'Pong! ({round(bot.latency * 1000)}ms)')

@bot.tree.command(name="hello", description="Send a prompt to Gemini API.")
@app_commands.describe(prompt="Message to send to the API")
async def hello(interaction: Interaction, prompt: str):
    # Defer response to prevent timeout
    await interaction.response.defer()

    try:
        print(f"Calling Gemini API with prompt: {prompt}")
        response = await litellm.acompletion(
            model="gemini/gemini-2.5-flash",
            messages=[{"role": "user", "content": prompt}],
            api_key=GEMINI_API_KEY
        )

        response_text = response.choices[0].message.content
        print(f"Received response from Gemini: {response_text[:100]}...")

    except Exception as e:
        print("An error occurred with the Gemini API call.")
        traceback.print_exc()
        await interaction.followup.send("An error occurred while calling the API. Please try again later.")
        return

    await interaction.followup.send(f"**Your prompt:**\n> {prompt}\n\n**Gemini response:**\n{response_text}")


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
