import os
import json
import imageio_ffmpeg
from PIL import Image, ImageDraw, ImageFont

def build_gameplay_poc_video():
    capture_dir = r"c:\REPO\game1\.visual-captures\poc"
    output_video_path = r"c:\REPO\game1\.visual-captures\gameplay_poc.mp4"
    
    metadata_path = os.path.join(capture_dir, "capture_metadata.json")
    if os.path.exists(metadata_path):
        with open(metadata_path, "r") as f:
            metadata = json.load(f)
        captures = metadata.get("captures", [])
    else:
        captures = []
        
    image_files = [
        "cemetery_day.png",
        "cemetery_night.png",
        "cemetery_architecture_props.png",
        "village_architecture.png",
        "player_s.png",
        "player_se.png",
        "player_e.png",
        "player_ne.png",
        "player_n.png",
        "player_nw.png",
        "player_w.png",
        "player_sw.png",
        "aldren_s.png",
        "aldren_se.png",
        "aldren_e.png",
        "aldren_ne.png",
        "aldren_n.png",
        "aldren_nw.png",
        "aldren_w.png",
        "aldren_sw.png",
        "ui_inventory.png",
        "ui_storage.png",
        "ui_crafting.png",
        "ui_trade.png",
    ]
    
    fps = 2
    writer = imageio_ffmpeg.write_frames(output_video_path, (1280, 720), fps=fps, codec="libx264", pix_fmt_in="rgb24")
    writer.send(None) # initialize
    
    count = 0
    for filename in image_files:
        img_path = os.path.join(capture_dir, filename)
        if not os.path.exists(img_path):
            continue
            
        with Image.open(img_path) as img:
            img = img.convert("RGB")
            if img.size != (1280, 720):
                img = img.resize((1280, 720), Image.Resampling.LANCZOS)
            
            draw = ImageDraw.Draw(img)
            title_text = f"PoC Gameplay Video | Frame: {filename}"
            draw.rectangle([10, 10, 500, 45], fill=(0, 0, 0, 180))
            draw.text((20, 18), title_text, fill=(255, 255, 255))
            
            # Repeat frame for 1.5s (3 frames at 2fps)
            for _ in range(3):
                writer.send(img.tobytes())
                count += 1
                
    writer.close()
    print(f"PoC Video generated successfully: {output_video_path} ({count} frames)")

if __name__ == "__main__":
    build_gameplay_poc_video()
