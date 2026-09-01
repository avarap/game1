import os
from PIL import Image
import numpy as np

def rescale_building_assets():
    # Source high quality 1024x1024 house
    source_path = r"c:\REPO\game1\art\environment\buildings\village_house.png"
    img = Image.open(source_path).convert("RGBA")
    
    # Trim empty alpha padding around the house figure
    bbox = img.getbbox()
    if bbox:
        cropped = img.crop(bbox)
    else:
        cropped = img
        
    # We fit the house into a 280x220 pixel footprint (compatible with 32px tiles & 48px characters)
    target_w = 260
    ratio = target_w / float(cropped.width)
    target_h = int(cropped.height * ratio)
    
    resized_house = cropped.resize((target_w, target_h), Image.Resampling.LANCZOS)
    
    # Create a 320x256 canvas with pivot at bottom center (160, 240)
    canvas = Image.new("RGBA", (320, 256), (0, 0, 0, 0))
    ox = (320 - target_w) // 2
    oy = 240 - target_h
    
    canvas.paste(resized_house, (ox, oy), resized_house)
    
    # Save to all building asset destinations
    paths = [
        r"c:\REPO\game1\art\environment\cemetery\production\atlas\building_workshop_exterior.png",
        r"c:\REPO\game1\art\environment\buildings\building_workshop_exterior.png",
        r"c:\REPO\game1\art\environment\buildings\village_house.png"
    ]
    
    for p in paths:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        canvas.save(p, format="PNG")
        print(f"Rescaled building asset saved to {p} (canvas 320x256, house {target_w}x{target_h})")

if __name__ == "__main__":
    rescale_building_assets()
