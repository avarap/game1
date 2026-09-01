import os
import glob
from PIL import Image
import numpy as np

def process_ai_assets():
    brain_dir = r"C:\Users\Anton\.gemini\antigravity-ide\brain\975b209a-3441-4ba7-a704-c37097217350"
    
    # Locate latest generated tileset and tree files in brain directory
    tileset_files = glob.glob(os.path.join(brain_dir, "ai_cemetery_tileset_*.png"))
    tree_files = glob.glob(os.path.join(brain_dir, "ai_oak_tree_*.png"))
    
    if not tileset_files or not tree_files:
        print("Error: AI generated images not found in brain directory")
        return
        
    tileset_path = tileset_files[-1]
    tree_path = tree_files[-1]
    
    print(f"Processing AI Tileset: {tileset_path}")
    print(f"Processing AI Tree: {tree_path}")
    
    # ----------------------------------------------------
    # 1. Process AI Tileset into 512x512 production atlas
    # ----------------------------------------------------
    ts_img = Image.open(tileset_path).convert("RGBA")
    
    # Resize AI generated tileset grid into exact 512x512 16x16 grid
    ts_resized = ts_img.resize((512, 512), Image.Resampling.LANCZOS)
    
    path_a = r"c:\REPO\game1\art\environment\tilesets\cemetery_ground_tileset.png"
    path_b = r"c:\REPO\game1\art\environment\cemetery\production\atlas\tileset_cemetery_32.png"
    
    os.makedirs(os.path.dirname(path_a), exist_ok=True)
    os.makedirs(os.path.dirname(path_b), exist_ok=True)
    
    ts_resized.save(path_a, format="PNG")
    ts_resized.save(path_b, format="PNG")
    print(f"Saved AI production tileset to {path_a} and {path_b}")
    
    # ----------------------------------------------------
    # 2. Process AI Tree into transparent 64x96 prop asset
    # ----------------------------------------------------
    tree_img = Image.open(tree_path).convert("RGBA")
    arr = np.array(tree_img, dtype=np.float32)
    
    r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]
    # White background removal
    is_white_bg = (r > 230) & (g > 230) & (b > 230)
    arr[is_white_bg, 3] = 0
    
    clean_tree = Image.fromarray(arr.astype(np.uint8), mode="RGBA")
    bbox = clean_tree.getbbox()
    if bbox:
        clean_tree = clean_tree.crop(bbox)
        
    # Scale tree figure to fit 64x96 canvas
    target_w = 64
    ratio = target_w / float(clean_tree.width)
    target_h = min(92, int(clean_tree.height * ratio))
    
    resized_tree = clean_tree.resize((target_w, target_h), Image.Resampling.LANCZOS)
    
    canvas_tree = Image.new("RGBA", (64, 96), (0, 0, 0, 0))
    ox = (64 - target_w) // 2
    oy = 96 - target_h - 2
    canvas_tree.paste(resized_tree, (ox, oy), resized_tree)
    
    tree_dest = r"c:\REPO\game1\art\environment\props\tree.png"
    os.makedirs(os.path.dirname(tree_dest), exist_ok=True)
    canvas_tree.save(tree_dest, format="PNG")
    print(f"Saved transparent AI tree asset to {tree_dest}")

if __name__ == "__main__":
    process_ai_assets()
