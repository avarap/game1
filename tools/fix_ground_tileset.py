import os
from PIL import Image, ImageDraw
import numpy as np

def generate_clean_ground_tileset():
    # 512x512 tile atlas (16x16 tiles of 32x32 px)
    tile_size = 32
    atlas_w, atlas_h = 512, 512
    img = Image.new("RGBA", (atlas_w, atlas_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Palette definition matching ART_DIRECTION.md
    MOSS_DARK = (52, 69, 54, 255)
    MOSS = (86, 107, 69, 255)
    GRASS = (117, 131, 90, 255)
    SOIL_DARK = (74, 59, 50, 255)
    SOIL = (113, 88, 69, 255)
    OCHRE = (167, 123, 69, 255)
    STONE = (138, 146, 144, 255)
    
    # Row 0: Seamless Grass Tiles (variants)
    for tx in range(16):
        ox, oy = tx * 32, 0 * 32
        # Base grass fill
        draw.rectangle([ox, oy, ox + 31, oy + 31], fill=MOSS)
        
        # Subtle texture noise/blades
        np.random.seed(tx * 31 + 7)
        for _ in range(24):
            px = ox + np.random.randint(1, 31)
            py = oy + np.random.randint(1, 31)
            color = GRASS if np.random.rand() > 0.5 else MOSS_DARK
            draw.point((px, py), fill=color)
            if np.random.rand() > 0.7:
                draw.point((px, py - 1), fill=color)
                
    # Row 1: Soil Path Tiles (vertical/horizontal/corners)
    for tx in range(16):
        ox, oy = tx * 32, 1 * 32
        draw.rectangle([ox, oy, ox + 31, oy + 31], fill=SOIL_DARK)
        draw.rectangle([ox + 2, oy + 2, ox + 29, oy + 29], fill=SOIL)
        
        np.random.seed(tx * 17 + 3)
        for _ in range(16):
            px = ox + np.random.randint(2, 30)
            py = oy + np.random.randint(2, 30)
            draw.point((px, py), fill=OCHRE)
            
    # Row 2: Low Decals (flowers, small stones, grass tufts)
    for tx in range(16):
        ox, oy = tx * 32, 2 * 32
        # Transparent background for decals layer
        if tx < 4:
            # Flower/tuft decals
            draw.rectangle([ox + 12, oy + 14, ox + 18, oy + 22], fill=GRASS)
            draw.point((ox + 15, oy + 12), fill=(224, 182, 108, 255))
        elif tx < 8:
            # Small pebble decals
            draw.rectangle([ox + 10, oy + 16, ox + 18, oy + 22], fill=STONE)
            
    # Save clean tileset to both paths
    path_a = r"c:\REPO\game1\art\environment\tilesets\cemetery_ground_tileset.png"
    path_b = r"c:\REPO\game1\art\environment\cemetery\production\atlas\tileset_cemetery_32.png"
    
    os.makedirs(os.path.dirname(path_a), exist_ok=True)
    os.makedirs(os.path.dirname(path_b), exist_ok=True)
    
    img.save(path_a, format="PNG")
    img.save(path_b, format="PNG")
    print(f"Generated clean seamless ground tileset (zero checkerboard) at {path_a} and {path_b}")

if __name__ == "__main__":
    generate_clean_ground_tileset()
