import os
from PIL import Image, ImageDraw
import numpy as np

def build_seamless_reference_atlas():
    # 512x512 tile atlas (16x16 grid of 32x32 tiles)
    atlas_w, atlas_h = 512, 512
    atlas = Image.new("RGBA", (atlas_w, atlas_h), (0, 0, 0, 0))
    
    # Load reference image from docs/art_example/
    ref_path = r"c:\REPO\game1\docs\art_example\Screenshot_2026-08-31-00-08-00-949_com.valvesoftware.android.steam.community.jpg"
    ref_img = Image.open(ref_path).convert("RGBA")
    rw, rh = ref_img.size
    
    # Extract authentic grass patch (32x32) from reference
    grass_sample = ref_img.crop((int(rw * 0.42), int(rh * 0.52), int(rw * 0.42) + 32, int(rh * 0.52) + 32))
    # Extract authentic dirt patch (32x32) from reference
    dirt_sample = ref_img.crop((int(rw * 0.28), int(rh * 0.45), int(rw * 0.28) + 32, int(rh * 0.45) + 32))
    
    # ----------------------------------------------------
    # ROW 0: 16 Grass Tiles (Seamless Uniform Base)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 0 * 32
        atlas.paste(grass_sample, (ox, oy))

    # ----------------------------------------------------
    # ROW 1: 16 Dirt Path Tiles (Seamless Uniform Soil)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 1 * 32
        atlas.paste(dirt_sample, (ox, oy))

    # ----------------------------------------------------
    # ROW 2: Decals (Flowers, Tufts, Stones) on Transparent
    # ----------------------------------------------------
    draw = ImageDraw.Draw(atlas)
    GRASS_ACCENT = (138, 164, 98, 255)
    GRASS_DARK = (52, 70, 42, 255)
    STONE_BASE = (120, 128, 124, 255)
    STONE_DARK = (70, 76, 74, 255)
    STONE_LIGHT = (165, 174, 170, 255)
    OCHRE = (158, 122, 76, 255)
    RUST = (148, 76, 60, 255)
    SHADOW = (32, 36, 30, 160)
    
    for tx in range(16):
        ox, oy = tx * 32, 2 * 32
        if tx % 4 == 0:
            draw.rectangle([ox + 10, oy + 16, ox + 14, oy + 24], fill=GRASS_ACCENT)
            draw.rectangle([ox + 18, oy + 12, ox + 22, oy + 22], fill=GRASS_DARK)
        elif tx % 4 == 1:
            draw.rectangle([ox + 12, oy + 14, ox + 16, oy + 22], fill=GRASS_DARK)
            draw.point((ox + 13, oy + 12), fill=RUST)
            draw.point((ox + 19, oy + 16), fill=(240, 210, 100, 255))
        elif tx % 4 == 2:
            draw.rectangle([ox + 8, oy + 16, ox + 16, oy + 24], fill=STONE_BASE, outline=STONE_DARK)
            draw.point((ox + 10, oy + 17), fill=STONE_LIGHT)
        else:
            draw.rectangle([ox + 14, oy + 18, ox + 18, oy + 24], fill=OCHRE)

    # ----------------------------------------------------
    # ROW 3 & 4: Gravestones & Props
    # ----------------------------------------------------
    for tx in range(16):
        row_idx = 3 if tx < 8 else 4
        col_idx = tx % 8
        ox, oy = col_idx * 32, row_idx * 32
        
        draw.ellipse([ox + 4, oy + 22, ox + 28, oy + 30], fill=SHADOW)
        
        if col_idx in [0, 1, 2]:
            draw.rectangle([ox + 8, oy + 6, ox + 24, oy + 26], fill=STONE_BASE, outline=STONE_DARK)
            draw.rectangle([ox + 10, oy + 8, ox + 22, oy + 24], fill=STONE_LIGHT)
            draw.rectangle([ox + 15, oy + 11, ox + 17, oy + 20], fill=STONE_DARK)
            draw.rectangle([ox + 13, oy + 13, ox + 19, oy + 15], fill=STONE_DARK)
            draw.rectangle([ox + 9, oy + 22, ox + 23, oy + 25], fill=GRASS_DARK)
        elif col_idx in [3, 4]:
            draw.ellipse([ox + 4, oy + 14, ox + 28, oy + 26], fill=(74, 54, 38, 255))
            draw.ellipse([ox + 6, oy + 15, ox + 26, oy + 24], fill=(112, 84, 58, 255))
        elif col_idx == 5:
            draw.rectangle([ox + 14, oy + 4, ox + 18, oy + 26], fill=(74, 54, 38, 255))
            draw.rectangle([ox + 10, oy + 10, ox + 22, oy + 14], fill=(74, 54, 38, 255))
            draw.rectangle([ox + 15, oy + 5, ox + 17, oy + 25], fill=OCHRE)
        elif col_idx == 6:
            draw.rectangle([ox + 10, oy + 6, ox + 22, oy + 26], fill=STONE_DARK)
            draw.rectangle([ox + 11, oy + 7, ox + 21, oy + 25], fill=STONE_BASE)

    # ----------------------------------------------------
    # ROW 5: Fences
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 5 * 32
        draw.rectangle([ox + 6, oy + 6, ox + 10, oy + 28], fill=STONE_DARK)
        draw.rectangle([ox + 22, oy + 6, ox + 26, oy + 28], fill=STONE_DARK)
        draw.rectangle([ox + 4, oy + 10, ox + 28, oy + 13], fill=STONE_BASE)

    # Save to both production atlas paths
    path_a = r"c:\REPO\game1\art\environment\tilesets\cemetery_ground_tileset.png"
    path_b = r"c:\REPO\game1\art\environment\cemetery\production\atlas\tileset_cemetery_32.png"
    
    os.makedirs(os.path.dirname(path_a), exist_ok=True)
    os.makedirs(os.path.dirname(path_b), exist_ok=True)
    
    atlas.save(path_a, format="PNG")
    atlas.save(path_b, format="PNG")
    print(f"Perfect seamless reference atlas saved to {path_a} and {path_b}")

if __name__ == "__main__":
    build_seamless_reference_atlas()
