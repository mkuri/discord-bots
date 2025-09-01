import asyncio
import base64
import os
import threading
import time
import traceback

import httpx
import litellm
import uvicorn
from discord import Intents, Interaction, app_commands, Attachment
from discord.ext import commands
from dotenv import load_dotenv
from fastapi import FastAPI, Response

# 1. Configuration and Instantiation
# ------------------------------------
load_dotenv()  # Load environment variables from .env file

TOKEN = os.environ.get("DISCORD_BOT_TOKEN")
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
PORT = int(os.environ.get("PORT", 8080))

intents = Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='>', intents=intents)


# 2. Helper Functions
# ------------------------------------
async def download_and_encode_image(url: str) -> str:
    """Download image from URL and return base64 encoded string."""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            if response.status_code == 200:
                image_data = response.content
                return base64.b64encode(image_data).decode('utf-8')
            else:
                raise Exception(f"Failed to download image: HTTP {response.status_code}")
    except Exception as e:
        print(f"Error downloading image: {e}")
        raise


def create_nutrition_analysis_prompt(description: str = None, image_count: int = 0) -> str:
    """Create structured prompt for nutrition analysis."""
    base_prompt = """Analyze the meal(s) and provide a nutritional estimate. Focus specifically on:

1. **Calories (kcal)**: Provide a specific estimate and a reasonable range
2. **Protein (g)**: Provide a specific estimate and a reasonable range  
3. **Confidence level**: High/Medium/Low based on image clarity and food identification certainty
4. **Analysis basis**: Brief explanation of what foods you identified

Format your response EXACTLY as follows:

🍽️ **食事分析結果**

📊 **栄養情報**
• カロリー: [NUMBER] kcal (推定範囲: [LOW]-[HIGH] kcal)
• タンパク質: [NUMBER]g (推定範囲: [LOW]-[HIGH]g)

📈 **信頼度: [High/Medium/Low]**

📝 **分析内容**
[Brief description of identified foods and analysis basis]

📸 **分析画像数: [NUMBER]枚**"""

    if description:
        base_prompt = f"User description: {description}\n\n" + base_prompt
    
    if image_count == 0:
        base_prompt = base_prompt.replace("📸 **分析画像数: [NUMBER]枚**", "📸 **テキスト説明のみで分析**")
    else:
        base_prompt = base_prompt.replace("[NUMBER]", str(image_count))
    
    return base_prompt


# 3. Discord Bot Events and Commands
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


@bot.tree.command(name="meal", description="Analyze meal photos and/or description for calorie and protein estimation.")
@app_commands.describe(
    description="Text description of the meal (optional if images are provided)",
    image1="First meal photo (optional)",
    image2="Second meal photo (optional)",
    image3="Third meal photo (optional)",
    image4="Fourth meal photo (optional)",
    image5="Fifth meal photo (optional)"
)
async def meal(
    interaction: Interaction,
    description: str = None,
    image1: Attachment = None,
    image2: Attachment = None,
    image3: Attachment = None,
    image4: Attachment = None,
    image5: Attachment = None
):
    # Defer response to prevent timeout
    await interaction.response.defer()

    # Collect all provided images
    images = [img for img in [image1, image2, image3, image4, image5] if img is not None]
    
    # Validate that at least one input is provided
    if not description and not images:
        await interaction.followup.send("❌ Please provide either a meal description or at least one image.")
        return

    # Validate image formats
    supported_formats = ['.jpg', '.jpeg', '.png', '.webp']
    for image in images:
        if not any(image.filename.lower().endswith(fmt) for fmt in supported_formats):
            await interaction.followup.send(f"❌ Unsupported image format: {image.filename}. Please use JPG, PNG, or WebP.")
            return

    try:
        # Prepare message content
        content = []
        
        # Add text description if provided
        prompt_text = create_nutrition_analysis_prompt(description, len(images))
        content.append({"type": "text", "text": prompt_text})

        # Process and add images
        print(f"Processing {len(images)} images for meal analysis")
        for i, image in enumerate(images):
            print(f"Downloading and encoding image {i+1}: {image.filename}")
            base64_image = await download_and_encode_image(image.url)
            
            # Determine content type from filename
            if image.filename.lower().endswith(('.jpg', '.jpeg')):
                content_type = "image/jpeg"
            elif image.filename.lower().endswith('.png'):
                content_type = "image/png"
            elif image.filename.lower().endswith('.webp'):
                content_type = "image/webp"
            else:
                content_type = "image/jpeg"  # fallback
            
            content.append({
                "type": "image_url",
                "image_url": {"url": f"data:{content_type};base64,{base64_image}"}
            })

        # Call Gemini API
        print("Calling Gemini API for meal analysis")
        response = await litellm.acompletion(
            model="gemini/gemini-2.5-flash",
            messages=[{"role": "user", "content": content}],
            api_key=GEMINI_API_KEY
        )

        response_text = response.choices[0].message.content
        print("Received meal analysis from Gemini")

    except Exception as e:
        print("An error occurred with the meal analysis API call.")
        traceback.print_exc()
        await interaction.followup.send("❌ An error occurred while analyzing your meal. Please try again later.")
        return

    await interaction.followup.send(response_text)


# 4. FastAPI App for Health Check
# ------------------------------------
app = FastAPI()

@app.get("/")
def health_check_get():
    # bot.is_ready() can only be used in an async context,
    # so we return a simple static response here.
    return {"status": "ok"}

@app.head("/")
def health_check_head():
    """
    Health check for HEAD requests.
    Responds to monitoring services like UptimeRobot.
    Returns only status code 200 OK without response body.
    """
    return Response(status_code=200)


# 5. Main Execution Block
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
