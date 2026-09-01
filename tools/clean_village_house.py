import os
from PIL import Image
import numpy as np

def clean_village_house():
    input_path = r"c:\REPO\game1\art\environment\buildings\village_house.png"
    img = Image.open(input_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)
    
    r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]
    diff_rg = np.abs(r - g)
    diff_gb = np.abs(g - b)
    
    # Dark grey background around house
    is_bg = (diff_rg < 12) & (diff_gb < 12) & (r > 70) & (r < 100)
    arr[is_bg, 3] = 0
    
    clean_img = Image.fromarray(arr.astype(np.uint8), mode="RGBA")
    bbox = clean_img.getbbox()
    if bbox:
        clean_img = clean_img.crop(bbox)
        
    clean_img.save(input_path, format="PNG")
    print(f"Cleaned village_house.png: size={clean_img.size}")

if __name__ == "__main__":
    clean_village_house()
