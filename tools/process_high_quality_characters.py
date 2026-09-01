import os
from PIL import Image, ImageFilter
import numpy as np

def extract_clean_character_sprite(input_path):
    img = Image.open(input_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)
    
    # 1. Crop to central character area
    crop_arr = arr[250:850, 320:700]
    
    r, g, b, a = crop_arr[:,:,0], crop_arr[:,:,1], crop_arr[:,:,2], crop_arr[:,:,3]
    
    # Background detection: light grey/white background & checkerboard pattern
    diff = np.max(np.abs(crop_arr[:,:,:3] - np.mean(crop_arr[:,:,:3], axis=-1, keepdims=True)), axis=-1)
    is_bg = (r > 165) & (g > 165) & (b > 155) & (diff < 30)
    
    # Set background alpha to 0
    crop_arr[is_bg, 3] = 0
    
    # Create transparent PIL Image
    char_img = Image.fromarray(crop_arr.astype(np.uint8), mode="RGBA")
    
    # Find bounding box of character pixels (non-zero alpha)
    bbox = char_img.getbbox()
    if bbox:
        char_img = char_img.crop(bbox)
        
    return char_img

def build_character_sheet(char_img, output_path, is_npc=False):
    # Sheet format: 5 frames per row, 8 rows for 8 directions (320 x 768 px)
    frame_w, frame_h = 64, 96
    sheet = Image.new("RGBA", (frame_w * 5, frame_h * 8), (0, 0, 0, 0))
    
    # Resize character image nicely to fit 64x96 frame while preserving aspect ratio
    max_h = 76
    ratio = max_h / float(char_img.height)
    new_w = int(char_img.width * ratio)
    new_h = int(char_img.height * ratio)
    
    resized_char = char_img.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Center within 64x96 frame
    offset_x = (frame_w - new_w) // 2
    offset_y = frame_h - new_h - 6  # align feet to bottom
    
    # Populate the 8-direction rows (5 frames per row) with variations (slight walking bounce)
    directions_flip = [False, False, False, False, False, True, True, True] # n, ne, e, se, s, sw, w, nw
    
    for row in range(8):
        dir_char = resized_char.transpose(Image.FLIP_LEFT_RIGHT) if directions_flip[row] else resized_char
        
        for frame in range(5):
            bounce = 0 if frame == 0 else ( -2 if frame in [1, 3] else 1 )
            frame_box = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
            frame_box.paste(dir_char, (offset_x, offset_y + bounce), dir_char)
            
            sheet.paste(frame_box, (frame * frame_w, row * frame_h), frame_box)
            
    sheet.save(output_path, format="PNG")
    print(f"Saved clean character sheet: {output_path} ({sheet.size})")

if __name__ == "__main__":
    player_raw = r"c:\REPO\game1\art\characters\player\player_idle_walk_64x96.png"
    player_clean = extract_clean_character_sprite(player_raw)
    build_character_sheet(player_clean, player_raw, is_npc=False)
    
    aldren_raw = r"c:\REPO\game1\art\characters\npcs\brother_aldren_idle_walk_64x96.png"
    aldren_clean = extract_clean_character_sprite(aldren_raw)
    build_character_sheet(aldren_clean, aldren_raw, is_npc=True)
