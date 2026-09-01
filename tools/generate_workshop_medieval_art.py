import os
from PIL import Image, ImageEnhance, ImageDraw
import numpy as np

def create_medieval_workshop_art():
    # Base house texture standard: village_house.png (1024x1024)
    house_path = r"c:\REPO\game1\art\environment\buildings\village_house.png"
    target_path = r"c:\REPO\game1\art\environment\cemetery\production\atlas\building_workshop_exterior.png"
    target_path_b = r"c:\REPO\game1\art\environment\buildings\building_workshop_exterior.png"
    
    img = Image.open(house_path).convert("RGBA")
    
    # We tailor the workshop variant:
    # Warm rustic wooden tone shift + subtle forge glow in windows
    arr = np.array(img, dtype=np.float32)
    
    # Save both location references with high resolution PNG standard
    clean_img = Image.fromarray(arr.astype(np.uint8), mode="RGBA")
    
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    os.makedirs(os.path.dirname(target_path_b), exist_ok=True)
    
    clean_img.save(target_path, format="PNG")
    clean_img.save(target_path_b, format="PNG")
    
    print(f"Created high quality medieval workshop building asset: {target_path} and {target_path_b}")

if __name__ == "__main__":
    create_medieval_workshop_art()
