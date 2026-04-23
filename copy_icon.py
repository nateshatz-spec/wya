import shutil
import os

src = "/Users/nate/.gemini/antigravity/brain/51c9438a-cff9-4f5b-b2b7-e362f29b9dcd/media__1776629323023.png"
dst = "/Users/nate/Desktop/WYA3.0/WYA3.0/Assets.xcassets/AppIcon.appiconset/icon_1024.png"

try:
    shutil.copy(src, dst)
    print(f"Successfully copied {src} to {dst}")
except Exception as e:
    print(f"Error: {e}")
