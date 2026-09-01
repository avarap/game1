import os
from PIL import Image, ImageDraw
import numpy as np

def draw_pixel(draw, x, y, color):
    draw.point((x, y), fill=color)

def generate_seamless_hd_tileset():
    atlas_w, atlas_h = 512, 512
    img = Image.new("RGBA", (atlas_w, atlas_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Paleta oficial ART_DIRECTION.md
    MOSS_DARK = (52, 69, 54, 255)
    MOSS = (86, 107, 69, 255)
    GRASS = (117, 131, 90, 255)
    GRASS_LIGHT = (145, 160, 115, 255)
    SOIL_DARK = (74, 59, 50, 255)
    SOIL = (113, 88, 69, 255)
    SOIL_LIGHT = (145, 115, 92, 255)
    OCHRE = (167, 123, 69, 255)
    STONE = (138, 146, 144, 255)
    BONE = (201, 190, 155, 255)
    SHADOW = (48, 49, 45, 180)
    RUST = (154, 81, 64, 255)
    
    # ----------------------------------------------------
    # ROW 0: Hierba Continua de Alta Definición (Sin Cuadros)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 0 * 32
        draw.rectangle([ox, oy, ox + 31, oy + 31], fill=MOSS)
        
        # Variación de textura sin bordes
        rng = np.random.RandomState(tx * 43 + 101)
        for _ in range(40):
            px = ox + rng.randint(0, 32)
            py = oy + rng.randint(0, 32)
            c = GRASS if rng.rand() > 0.4 else (MOSS_DARK if rng.rand() > 0.2 else GRASS_LIGHT)
            draw_pixel(draw, px, py, c)
            if rng.rand() > 0.6:
                draw_pixel(draw, px, max(oy, py - 1), c)

    # ----------------------------------------------------
    # ROW 1: Camino de Tierra Fluido y Orgánico (SIN Bordes de Cuadrícula)
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 1 * 32
        # Relleno de tierra uniforme para continuidad perfecta entre baldosas
        draw.rectangle([ox, oy, ox + 31, oy + 31], fill=SOIL)
        
        rng = np.random.RandomState(tx * 29 + 202)
        # Detalle interno orgánico sin bordes oscuros en los márgenes (0..31)
        for _ in range(35):
            px = ox + rng.randint(0, 32)
            py = oy + rng.randint(0, 32)
            c = OCHRE if rng.rand() > 0.5 else SOIL_DARK
            draw_pixel(draw, px, py, c)
            
        # Pequeñas chinas/guijarros dispersos sin patrón cuadrado
        for _ in range(3):
            px = ox + rng.randint(2, 29)
            py = oy + rng.randint(2, 29)
            draw.rectangle([px, py, px + 1, py + 1], fill=SOIL_LIGHT)
            draw_pixel(draw, px, py, BONE)

    # ----------------------------------------------------
    # ROW 2: Calcomanías y Vegetación
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 2 * 32
        if tx % 4 == 0:
            draw.rectangle([ox + 10, oy + 18, ox + 14, oy + 26], fill=GRASS_LIGHT)
            draw.rectangle([ox + 18, oy + 14, ox + 22, oy + 24], fill=GRASS)
        elif tx % 4 == 1:
            draw.rectangle([ox + 12, oy + 16, ox + 15, oy + 24], fill=MOSS_DARK)
            draw.rectangle([ox + 11, oy + 14, ox + 16, oy + 16], fill=RUST)
        elif tx % 4 == 2:
            draw.rectangle([ox + 8, oy + 18, ox + 16, oy + 24], fill=STONE)
        else:
            draw.rectangle([ox + 14, oy + 18, ox + 18, oy + 24], fill=BONE)

    # ----------------------------------------------------
    # ROW 3 & 4: Lápidas y Objetos
    # ----------------------------------------------------
    for tx in range(16):
        row_idx = 3 if tx < 8 else 4
        col_idx = tx % 8
        ox, oy = col_idx * 32, row_idx * 32
        draw.rectangle([ox + 6, oy + 24, ox + 26, oy + 30], fill=SHADOW)
        
        if col_idx in [0, 1, 2]:
            draw.rectangle([ox + 9, oy + 8, ox + 23, oy + 26], fill=(36, 35, 31, 255))
            draw.rectangle([ox + 10, oy + 9, ox + 22, oy + 25], fill=STONE)
            draw.rectangle([ox + 12, oy + 11, ox + 20, oy + 23], fill=BONE)
            draw.rectangle([ox + 15, oy + 13, ox + 17, oy + 21], fill=(36, 35, 31, 255))
            draw.rectangle([ox + 13, oy + 15, ox + 19, oy + 17], fill=(36, 35, 31, 255))
        elif col_idx in [3, 4]:
            draw.rectangle([ox + 4, oy + 16, ox + 28, oy + 26], fill=SOIL_DARK)
            draw.rectangle([ox + 6, oy + 14, ox + 26, oy + 24], fill=SOIL)
        elif col_idx == 5:
            draw.rectangle([ox + 14, oy + 6, ox + 18, oy + 26], fill=(36, 35, 31, 255))
            draw.rectangle([ox + 15, oy + 7, ox + 17, oy + 25], fill=SOIL_DARK)
            draw.rectangle([ox + 10, oy + 11, ox + 22, oy + 15], fill=(36, 35, 31, 255))
        elif col_idx == 6:
            draw.rectangle([ox + 10, oy + 6, ox + 22, oy + 26], fill=(36, 35, 31, 255))
            draw.rectangle([ox + 11, oy + 7, ox + 21, oy + 25], fill=STONE)

    # ----------------------------------------------------
    # ROW 5: Verjas de Cementerio
    # ----------------------------------------------------
    for tx in range(16):
        ox, oy = tx * 32, 5 * 32
        draw.rectangle([ox + 6, oy + 8, ox + 10, oy + 28], fill=(36, 35, 31, 255))
        draw.rectangle([ox + 22, oy + 8, ox + 26, oy + 28], fill=(36, 35, 31, 255))

    path_a = r"c:\REPO\game1\art\environment\tilesets\cemetery_ground_tileset.png"
    path_b = r"c:\REPO\game1\art\environment\cemetery\production\atlas\tileset_cemetery_32.png"
    
    img.save(path_a, format="PNG")
    img.save(path_b, format="PNG")
    print(f"Generated seamless tileset with NO borders at {path_a} and {path_b}")

if __name__ == "__main__":
    generate_seamless_hd_tileset()
