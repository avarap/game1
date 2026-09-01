import os
import glob
from PIL import Image, ImageDraw

def render_raster_prop(name, width, height):
    # Generates clean, crisp pixel-art RGBA PNGs for props
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    if name == "workbench":
        # Wooden workbench prop
        draw.rectangle([4, 16, 60, 44], fill=(113, 88, 69, 255), outline=(36, 35, 31, 255))
        draw.rectangle([8, 28, 56, 44], fill=(74, 59, 50, 255))
        draw.rectangle([6, 36, 14, 46], fill=(42, 33, 27, 255))
        draw.rectangle([50, 36, 58, 46], fill=(42, 33, 27, 255))
    elif name == "storage_chest":
        # Iron-bound wooden chest
        draw.rectangle([4, 8, 44, 38], fill=(113, 88, 69, 255), outline=(36, 35, 31, 255))
        draw.rectangle([4, 8, 44, 20], fill=(167, 123, 69, 255), outline=(36, 35, 31, 255))
        draw.rectangle([20, 18, 28, 26], fill=(201, 190, 155, 255), outline=(36, 35, 31, 255))
    elif name == "bed":
        # Straw/wooden bed
        draw.rectangle([4, 8, 60, 52], fill=(74, 59, 50, 255), outline=(36, 35, 31, 255))
        draw.rectangle([8, 12, 56, 48], fill=(167, 123, 69, 255))
        draw.rectangle([10, 14, 28, 26], fill=(201, 190, 155, 255)) # Pillow
    elif name == "sign":
        # Wooden post sign
        draw.rectangle([14, 4, 18, 44], fill=(74, 59, 50, 255), outline=(36, 35, 31, 255))
        draw.rectangle([2, 8, 30, 26], fill=(113, 88, 69, 255), outline=(36, 35, 31, 255))
    elif name == "preparation_table":
        # Stone preparation table
        draw.rectangle([4, 12, 60, 40], fill=(138, 146, 144, 255), outline=(36, 35, 31, 255))
        draw.rectangle([8, 24, 56, 40], fill=(90, 98, 96, 255))
    elif name == "grave_worn":
        # Worn stone tombstone
        draw.rectangle([4, 8, 44, 42], fill=(138, 146, 144, 255), outline=(36, 35, 31, 255))
        draw.rectangle([18, 14, 30, 36], fill=(90, 98, 96, 255))
    elif name == "tree":
        # Oak tree prop
        draw.ellipse([8, 4, 56, 68], fill=(86, 107, 69, 255), outline=(36, 35, 31, 255))
        draw.rectangle([26, 60, 38, 88], fill=(74, 59, 50, 255), outline=(36, 35, 31, 255))
    elif name == "rock":
        # Mossy stone rock
        draw.ellipse([4, 8, 44, 36], fill=(138, 146, 144, 255), outline=(36, 35, 31, 255))
        draw.ellipse([8, 12, 28, 24], fill=(86, 107, 69, 255))
        
    return img

def convert_all():
    props = {
        "art/environment/props/workbench.png": ("workbench", 64, 48),
        "art/environment/props/storage_chest.png": ("storage_chest", 48, 42),
        "art/environment/props/bed.png": ("bed", 64, 56),
        "art/environment/props/sign.png": ("sign", 32, 48),
        "art/environment/cemetery/preparation_table.png": ("preparation_table", 64, 44),
        "art/environment/cemetery/grave_worn.png": ("grave_worn", 48, 48),
        "art/environment/cemetery/dry_grass.png": ("rock", 32, 32),
        "art/environment/props/tree.png": ("tree", 64, 96),
        "art/environment/props/rock.png": ("rock", 48, 40),
    }
    
    for path, (name, w, h) in props.items():
        full_path = os.path.join(r"c:\REPO\game1", path)
        img = render_raster_prop(name, w, h)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        img.save(full_path, format="PNG")
        print(f"Created raster prop PNG: {full_path}")

if __name__ == "__main__":
    convert_all()
