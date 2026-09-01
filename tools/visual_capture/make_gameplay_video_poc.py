import os
import sys
import json
import imageio_ffmpeg
from PIL import Image, ImageDraw

def build_gameplay_video(capture_dir, output_video_path):
    metadata_path = os.path.join(capture_dir, "capture_metadata.json")
    if os.path.exists(metadata_path):
        with open(metadata_path, "r") as f:
            metadata = json.load(f)
    
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
    writer.send(None)
    
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
            title_text = f"GAME1 Production Art Capture | Frame: {filename}"
            draw.rectangle([10, 10, 520, 45], fill=(0, 0, 0, 180))
            draw.text((20, 18), title_text, fill=(255, 255, 255))
            
            # 3 frames at 2fps = 1.5s display per capture
            for _ in range(3):
                writer.send(img.tobytes())
                count += 1
                
    writer.close()
    print(f"Video generated successfully: {output_video_path} ({count} frames)")

if __name__ == "__main__":
    capture_dir = sys.argv[1] if len(sys.argv) > 1 else r"c:\REPO\game1\.visual-captures\clean_art"
    output_video = sys.argv[2] if len(sys.argv) > 2 else r"c:\REPO\game1\.visual-captures\gameplay_clean.mp4"
    build_gameplay_video(capture_dir, output_video)
