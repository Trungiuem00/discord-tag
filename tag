import discord
import asyncio
import threading
from flask import Flask
import os

# ==== Flask server để giữ cho Render không tắt app ====
app = Flask(__name__)

@app.route("/")
def home():
    return "Bot is running!"

def run_flask():
    app.run(host="0.0.0.0", port=8080)

# ==== Bot Discord ====
intents = discord.Intents.default()
intents.guilds = True
intents.members = True
intents.message_content = True

client = discord.Client(intents=intents)

CHANNEL_ID = 1372531505028403251
USER_ID = 1180452640816115782

def read_messages_from_file(filename):
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"❌ Không tìm thấy file {filename}")
        return []

@client.event
async def on_ready():
    print(f"✅ Bot đã đăng nhập: {client.user}")
    await tag_and_send_loop()

async def tag_and_send_loop():
    await client.wait_until_ready()
    channel = client.get_channel(CHANNEL_ID)
    messages = read_messages_from_file("noidung.txt")

    if not messages:
        print("❌ File không có nội dung")
        return

    while True:
        guild = channel.guild
        member = guild.get_member(USER_ID)

        if member:
            for msg in messages:
                full_msg = f"{member.mention} {msg}"
                await channel.send(full_msg)
                await asyncio.sleep(3)  # tránh spam quá nhanh
        else:
            print("❌ Không tìm thấy user")
            await asyncio.sleep(10)

# ==== Chạy cả Flask server và Discord bot song song ====
if __name__ == "__main__":
    threading.Thread(target=run_flask).start()
    token = os.getenv("DISCORD_BOT_TOKEN")  # Đặt token trong biến môi trường
    client.run(token)
