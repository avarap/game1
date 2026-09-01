import os
from PIL import Image
import numpy as np

def clean_background(img_arr):
    # Background in the raw AI sheet is dark grey / checkerboard
    r, g, b, a = img_arr[:,:,0], img_arr[:,:,1], img_arr[:,:,2], img_arr[:,:,3]
    diff_rg = np.abs(r - g)
    diff_gb = np.abs(g - b)
    is_bg = (diff_rg < 14) & (diff_gb < 14) & (r < 125)
    
    # Also clear pure black borders or header text
    is_header = (r < 60) & (g < 60) & (b < 60)
    
    img_arr[is_bg | is_header, 3] = 0
    return img_arr

def extract_figures_from_region(clean_img, crop_box):
    region = clean_img.crop(crop_box)
    reg_arr = np.array(region)
    alpha = reg_arr[:,:,3]
    
    # Find column ranges where character pixels exist
    col_mask = np.sum(alpha > 0, axis=0) > 0
    
    segments = []
    in_seg = False
    start = 0
    for x, val in enumerate(col_mask):
        if val and not in_seg:
            in_seg = True
            start = x
        elif not val and in_seg:
            in_seg = False
            if x - start > 18: # Filter out tiny dots/noise
                segments.append((start, x))
    if in_seg and (len(col_mask) - start > 18):
        segments.append((start, len(col_mask)))
        
    figures = []
    for s_start, s_end in segments:
        fig_crop = region.crop((s_start, 0, s_end, region.height))
        bbox = fig_crop.getbbox()
        if bbox:
            fig_clean = fig_crop.crop(bbox)
            # Ensure it's substantial (height > 40px)
            if fig_clean.height > 40:
                figures.append(fig_clean)
                
    return figures

def fit_figure_in_frame(fig, frame_w=64, frame_h=96):
    frame = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    
    # Scale figure to fit max height 78px
    target_h = 78
    ratio = target_h / float(fig.height)
    new_w = max(1, int(fig.width * ratio))
    new_h = int(fig.height * ratio)
    
    # Clamp width if too wide
    if new_w > 56:
        new_w = 56
        
    resized = fig.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    ox = (frame_w - new_w) // 2
    oy = frame_h - new_h - 6 # Feet near bottom of 64x96 tile
    
    frame.paste(resized, (ox, oy), resized)
    return frame

def build_aldren_atlas():
    input_path = r"c:\REPO\game1\art\characters\npcs\brother_aldren_idle_walk.png"
    output_path = r"c:\REPO\game1\art\characters\npcs\brother_aldren_idle_walk_64x96.png"
    
    img = Image.open(input_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)
    clean_arr = clean_background(arr)
    clean_img = Image.fromarray(clean_arr.astype(np.uint8), mode="RGBA")
    
    # 8 direction regions in 1024x1024 sheet
    regions = [
        (0, (60, 110, 480, 310)),   # N
        (1, (540, 110, 960, 310)),  # NE
        (2, (60, 330, 480, 530)),   # E
        (3, (540, 330, 960, 530)),  # SE
        (4, (60, 550, 480, 750)),   # S
        (5, (540, 550, 960, 750)),  # SW
        (6, (60, 770, 480, 970)),   # W
        (7, (540, 770, 960, 970)),  # NW
    ]
    
    atlas = Image.new("RGBA", (64 * 5, 96 * 8), (0, 0, 0, 0))
    
    for row_idx, crop_box in regions:
        figs = extract_figures_from_region(clean_img, crop_box)
        print(f"Row {row_idx}: extracted {len(figs)} figures")
        
        if not figs:
            continue
            
        # Place figures into 5 frame slots for this row
        # f0: idle, f1: walk1, f2: walk2, f3: walk1, f4: walk2
        f0 = fit_figure_in_frame(figs[0])
        f1 = fit_figure_in_frame(figs[1] if len(figs) > 1 else figs[0])
        f2 = fit_figure_in_frame(figs[2] if len(figs) > 2 else (figs[1] if len(figs) > 1 else figs[0]))
        
        atlas.paste(f0, (0 * 64, row_idx * 96), f0)
        atlas.paste(f1, (1 * 64, row_idx * 96), f1)
        atlas.paste(f2, (2 * 64, row_idx * 96), f2)
        atlas.paste(f1, (3 * 64, row_idx * 96), f1)
        atlas.paste(f2, (4 * 64, row_idx * 96), f2)
        
    atlas.save(output_path, format="PNG")
    print(f"Brother Aldren atlas successfully built: {output_path}")

def build_player_atlas():
    # Extracted gravedigger sprite formatted identically into 64x96 frames
    input_path = r"c:\REPO\game1\art\characters\player\player_idle_walk_64x96.png"
    # Inspect if player_idle_walk_64x96.png has raw sheet or single image
    img = Image.open(input_path).convert("RGBA")
    if img.size == (1024, 1024):
        arr = np.array(img, dtype=np.float32)
        clean_arr = clean_background(arr)
        clean_img = Image.fromarray(clean_arr.astype(np.uint8), mode="RGBA")
        figs = extract_figures_from_region(clean_img, (200, 200, 850, 850))
        if figs:
            char_fig = figs[0]
        else:
            char_fig = clean_img
    else:
        # Extract figure from existing sheet
        bbox = img.getbbox()
        char_fig = img.crop(bbox) if bbox else img
        
    atlas = Image.new("RGBA", (64 * 5, 96 * 8), (0, 0, 0, 0))
    
    # Generate 8 directions by flipping appropriately
    flips = [False, False, False, False, False, True, True, True]
    
    for row in range(8):
        fig = char_fig.transpose(Image.FLIP_LEFT_RIGHT) if flips[row] else char_fig
        
        for f in range(5):
            bounce = 0 if f == 0 else (-2 if f in [1, 3] else 1)
            frame = Image.new("RGBA", (64, 96), (0, 0, 0, 0))
            
            target_h = 78
            ratio = target_h / float(fig.height)
            nw = max(1, int(fig.width * ratio))
            nh = int(fig.height * ratio)
            
            resized = fig.resize((nw, nh), Image.Resampling.LANCZOS)
            ox = (64 - nw) // 2
            oy = 96 - nh - 6 + bounce
            
            frame.paste(resized, (ox, oy), resized)
            atlas.paste(frame, (f * 64, row * 96), frame)
            
    atlas.save(input_path, format="PNG")
    print(f"Player Gravedigger atlas successfully built: {input_path}")

if __name__ == "__main__":
    build_aldren_atlas()
    build_player_atlas()
