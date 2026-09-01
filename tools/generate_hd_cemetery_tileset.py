import os
from PIL import Image, ImageDraw
import numpy as np

def draw_pixel(draw, x, y, color):
    draw.point((x, y), fill=color)

def draw_rect(draw, x1, y1, x2, y2, color):
    draw.rectangle([x1, y1, x2, y2], fill=color)

def generate_hd_tileset():
    # 512x512 tile atlas (16 columns x 16 rows of 32x32 px tiles)
    atlas_w, atlas_h = 512, 512
    img = Image.new("RGBA", (atlas_w, atlas_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Palette definition from ART_DIRECTION.md
    INK = (36, 35, 31, 255)
    SOIL_DARK = (74, 59, 50, 255)
    SOIL = (113, 88, 69, 255)
    SOIL_LIGHT = (145, 115, 92, 255)
    OCHRE = (167, 123, 69, 255)
    MOSS_DARK = (52, 69, 54, 255)
    MOSS = (86, 107, 69, 255)
    GRASS = (117, 131, 90, 255)
    GRASS_LIGHT = (145, 160, 115, 255)
    BONE = (201, 190, 155, 255)
    BONE_LIGHT = (225, 215, 185, 255)
    MIST = (138, 146, 144, 255)
    SHADOW = (48, 49, 45, 180)
    RUST = (154, 81, 64, 255)
    
    # ----------------------------------------------------
    # ROW 0: High-Detail Grass Tiles (Variants 0..15)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 0 * 32
        draw_rect(draw, ox, oy, ox + 31, oy + 31, MOSS)
        
        # Dense texture patterns
        rng = np.random.RandomState(tx * 43 + 101)
        for _ in range(35):
            px = ox + rng.randint(0, 31)
            py = oy + rng.randint(0, 31)
            val = rng.rand()
            c = GRASS if val > 0.4 else (MOSS_DARK if val > 0.15 else GRASS_LIGHT)
            draw_pixel(draw, px, py, c)
            if rng.rand() > 0.6:
                draw_pixel(draw, px, max(oy, py - 1), c)
                
    # ----------------------------------------------------
    # ROW 1: Rich Soil & Dirt Paths (Variants 0..15)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 1 * 32
        draw_rect(draw, ox, oy, ox + 31, oy + 31, SOIL_DARK)
        draw_rect(draw, ox + 2, oy + 2, ox + 29, oy + 29, SOIL)
        
        rng = np.random.RandomState(tx * 29 + 202)
        for _ in range(25):
            px = ox + rng.randint(2, 29)
            py = oy + rng.randint(2, 29)
            c = OCHRE if rng.rand() > 0.5 else SOIL_LIGHT
            draw_pixel(draw, px, py, c)
            
        # Stone edges / pebbles along paths
        for _ in range(5):
            px = ox + rng.randint(4, 27)
            py = oy + rng.randint(4, 27)
            draw_rect(draw, px, py, px + 2, py + 2, MIST)
            draw_pixel(draw, px, py, BONE)

    # ----------------------------------------------------
    # ROW 2: Vegetation Decals & Flowers (Variants 0..15)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 2 * 32
        rng = np.random.RandomState(tx * 13 + 303)
        if tx % 4 == 0: # Grass tufts
            draw_rect(draw, ox + 10, oy + 18, ox + 14, oy + 26, GRASS_LIGHT)
            draw_rect(draw, ox + 18, oy + 14, ox + 22, oy + 24, GRASS)
        elif tx % 4 == 1: # Wildflowers
            draw_rect(draw, ox + 12, oy + 16, ox + 15, oy + 24, MOSS_DARK)
            draw_rect(draw, ox + 11, oy + 14, ox + 16, oy + 16, RUST)
            draw_rect(draw, ox + 20, oy + 18, ox + 24, oy + 20, (240, 200, 120, 255))
        elif tx % 4 == 2: # Stones / pebbles cluster
            draw_rect(draw, ox + 8, oy + 18, ox + 16, oy + 24, MIST)
            draw_rect(draw, ox + 18, oy + 20, ox + 24, oy + 26, INK)
            draw_rect(draw, ox + 19, oy + 19, ox + 23, oy + 24, MIST)
        else: # Mushrooms / dry leaves
            draw_rect(draw, ox + 14, oy + 18, ox + 18, oy + 24, BONE)
            draw_rect(draw, ox + 13, oy + 16, ox + 19, oy + 18, RUST)

    # ----------------------------------------------------
    # ROW 3 & 4: Tombstones & Grave Props (Variants 0..15)
    # ----------------------------------------------------
    for tx in range(16):
        row_idx = 3 if tx < 8 else 4
        col_idx = tx % 8
        ox, oy = col_idx * 32, row_idx * 32
        
        # Shadow underneath
        draw_rect(draw, ox + 6, oy + 24, ox + 26, oy + 30, SHADOW)
        
        if col_idx in [0, 1, 2]: # Worn gravestone / headstone
            draw_rect(draw, ox + 9, oy + 8, ox + 23, oy + 26, INK)
            draw_rect(draw, ox + 10, oy + 9, ox + 22, oy + 25, MIST)
            draw_rect(draw, ox + 12, oy + 11, ox + 20, oy + 23, BONE)
            # Engravings/Cross
            draw_rect(draw, ox + 15, oy + 13, ox + 17, oy + 21, INK)
            draw_rect(draw, ox + 13, oy + 15, ox + 19, oy + 17, INK)
        elif col_idx in [3, 4]: # Fresh mound grave
            draw_rect(draw, ox + 4, oy + 16, ox + 28, oy + 26, SOIL_DARK)
            draw_rect(draw, ox + 6, oy + 14, ox + 26, oy + 24, SOIL)
            draw_rect(draw, ox + 8, oy + 13, ox + 24, oy + 17, OCHRE)
        elif col_idx == 5: # Wooden cross
            draw_rect(draw, ox + 14, oy + 6, ox + 18, oy + 26, INK)
            draw_rect(draw, ox + 15, oy + 7, ox + 17, oy + 25, SOIL_DARK)
            draw_rect(draw, ox + 10, oy + 11, ox + 22, oy + 15, INK)
            draw_rect(draw, ox + 11, oy + 12, ox + 21, oy + 14, SOIL)
        elif col_idx == 6: # Ancient stone pillar
            draw_rect(draw, ox + 10, oy + 6, ox + 22, oy + 26, INK)
            draw_rect(draw, ox + 11, oy + 7, ox + 21, oy + 25, MIST)
            draw_rect(draw, ox + 13, oy + 9, ox + 19, oy + 23, BONE)
            draw_rect(draw, ox + 11, oy + 20, ox + 21, oy + 22, MOSS_DARK)
        else: # Double tombstone
            draw_rect(draw, ox + 5, oy + 10, ox + 27, oy + 26, INK)
            draw_rect(draw, ox + 6, oy + 11, ox + 26, oy + 25, MIST)

    # ----------------------------------------------------
    # ROW 5: Foreground & Fences (Variants 0..15)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 5 * 32
        # Iron / wooden fence posts
        draw_rect(draw, ox + 6, oy + 8, ox + 10, oy + 28, INK)
        draw_rect(draw, ox + 22, oy + 8, ox + 26, oy + 28, INK)
        draw_rect(draw, ox + 4, oy + 12, ox + 28, oy + 15, MIST)
        draw_rect(draw, ox + 4, oy + 20, ox + 28, oy + 23, MIST)

    # Save to both tileset paths
    path_a = r"c:\REPO\game1\art\environment\tilesets\cemetery_ground_tileset.png"
    path_b = r"c:\REPO\game1\art\environment\cemetery\production\atlas\tileset_cemetery_32.png"
    
    os.makedirs(os.path.dirname(path_a), exist_ok=True)
    os.makedirs(os.path.dirname(path_b), exist_ok=True)
    
    img.save(path_a, format="PNG")
    img.save(path_b, format="PNG")
    print(f"Successfully generated HD pixel-art tileset at {path_a} and {path_b}")

if __name__ == "__main__":
    generate_hd_tileset()
        draw.rectangle([ox + 22, oy + 6, ox + 26, oy + 28], fill=STONE_DARK)
        draw.rectangle([ox + 4, oy + 10, ox + 28, oy + 13], fill=STONE_BASE)

    # Save to both paths
    path_a = r"c:\REPO\game1\art\environment\tilesets\cemetery_ground_tileset.png"
    path_b = r"c:\REPO\game1\art\environment\cemetery\production\atlas\tileset_cemetery_32.png"
    
    os.makedirs(os.path.dirname(path_a), exist_ok=True)
    os.makedirs(os.path.dirname(path_b), exist_ok=True)
    
    img.save(path_a, format="PNG")
    img.save(path_b, format="PNG")
    print(f"Ultra HD Tileset successfully generated at {path_a} and {path_b}")

if __name__ == "__main__":
    generate_ultra_hd_tileset()
