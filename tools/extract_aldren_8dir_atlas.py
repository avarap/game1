import os
from PIL import Image
import numpy as np

def extract_brother_aldren_sheet():
    input_path = r"c:\REPO\game1\art\characters\npcs\brother_aldren_idle_walk.png"
    output_path = r"c:\REPO\game1\art\characters\npcs\brother_aldren_idle_walk_64x96.png"
    
    img = Image.open(input_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)
    
    # Remove dark header/checkerboard background
    # Background pixels are neutral greys (R, G, B close to each other and R < 115)
    r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]
    diff_rg = np.abs(r - g)
    diff_gb = np.abs(g - b)
    is_bg = (diff_rg < 12) & (diff_gb < 12) & (r < 115)
    
    arr[is_bg, 3] = 0
    clean_img = Image.fromarray(arr.astype(np.uint8), mode="RGBA")
    
    # Define grid of the 8 directions in the source 1024x1024 sheet
    # Left column X: [50..490], Right column X: [530..970]
    # Rows Y:
    # N:  Y=[110..300], X=[60..480]
    # NE: Y=[110..300], X=[540..960]
    # E:  Y=[330..520], X=[60..480]
    # SE: Y=[330..520], X=[540..960]
    # S:  Y=[550..740], X=[60..480]
    # SW: Y=[550..740], X=[540..960]
    # W:  Y=[770..960], X=[60..480]
    # NW: Y=[770..960], X=[540..960]
    
    sections = [
        # (row_index_in_godot_sheet, Y_start, Y_end, X_start, X_end)
        (0, 110, 310, 60, 480),   # N
        (1, 110, 310, 540, 960),  # NE
        (2, 330, 530, 60, 480),   # E
        (3, 330, 530, 540, 960),  # SE
        (4, 550, 750, 60, 480),   # S
        (5, 550, 750, 540, 960),  # SW
        (6, 770, 970, 60, 480),   # W
        (7, 770, 970, 540, 960),  # NW
    ]
    
    frame_w, frame_h = 64, 96
    out_sheet = Image.new("RGBA", (frame_w * 5, frame_h * 8), (0, 0, 0, 0))
    
    for row_idx, y1, y2, x1, x2 in sections:
        section_crop = clean_img.crop((x1, y1, x2, y2))
        
        # Divide section crop into 3 frames horizontally
        sec_w = section_crop.width // 3
        for f in range(3):
            sub_frame = section_crop.crop((f * sec_w, 0, (f + 1) * sec_w, section_crop.height))
            bbox = sub_frame.getbbox()
            if bbox:
                char_sprite = sub_frame.crop(bbox)
                
                # Scale sprite cleanly to fit 64x96 frame
                max_h = 76
                ratio = max_h / float(char_sprite.height)
                nw = int(char_sprite.width * ratio)
                nh = int(char_sprite.height * ratio)
                
                resized = char_sprite.resize((nw, nh), Image.Resampling.LANCZOS)
                
                frame_box = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
                ox = (frame_w - nw) // 2
                oy = frame_h - nh - 6
                frame_box.paste(resized, (ox, oy), resized)
                
                # Place in output sheet (frames 0..2, and duplicate 3..4 for walking loop)
                out_sheet.paste(frame_box, (f * frame_w, row_idx * frame_h), frame_box)
                if f == 1:
                    out_sheet.paste(frame_box, (3 * frame_w, row_idx * frame_h), frame_box)
                elif f == 2:
                    out_sheet.paste(frame_box, (4 * frame_w, row_idx * frame_h), frame_box)

    out_sheet.save(output_path, format="PNG")
    print(f"Brother Aldren 8-direction high quality atlas created: {output_path}")

if __name__ == "__main__":
    extract_brother_aldren_sheet()
