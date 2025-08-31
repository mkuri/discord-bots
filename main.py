# from fastapi import FastAPI

# app = FastAPI()
#
# @app.get("/")
# def read_root():
#     return {"message": "Hello from Koyeb"}


import discord
from discord.ext import commands

intents = discord.Intents.default()
intents.message_content = True

bot = commands.Bot(command_prefix='>', intents=intents)

@bot.command()
async def ping(ctx):
    await ctx.send('pong')

import os
bot.run(os.environ.get("TOKEN"))

