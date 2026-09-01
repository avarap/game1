import os
from PIL import Image
import numpy as np

def clean_chimney_smoke():
    input_path = r"c:\REPO\game1\art\environment\buildings\village_house.png"
    img = Image.open(input_path).convert("RGBA")
    arr = np.array(img)
    
    # Region where static smoke puffs exist above the chimney opening
    # x: 670..860, y: 20..245
    smoke_region = arr[20:245, 670:860]
    
    # Static smoke consists of light grey/white puffs (r>150, g>150, b>150)
    r, g, b, a = smoke_region[:,:,0], smoke_region[:,:,1], smoke_region[:,:,2], smoke_region[:,:,3]
    diff_rg = np.abs(r.astype(float) - g.astype(float))
    diff_gb = np.abs(g.astype(float) - b.astype(float))
    
    is_smoke = (r > 140) & (g > 140) & (b > 140) & (diff_rg < 25) & (diff_gb < 25)
    smoke_region[is_smoke, 3] = 0
    
    arr[20:245, 670:860] = smoke_region
    
    clean_img = Image.fromarray(arr, mode="RGBA")
    clean_img.save(input_path, format="PNG")
    print(f"Removed static chimney smoke from {input_path}")

if __name__ == "__main__":
    clean_chimney_smoke()
