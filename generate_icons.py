from PIL import Image, ImageDraw, ImageFont
import os

OUT = "C:/Users/ghost/Documents/visit-and-smile/icons"
os.makedirs(OUT, exist_ok=True)

for size in [192, 512]:
    img = Image.new('RGBA', (size, size), (3, 3, 6, 255))
    draw = ImageDraw.Draw(img)

    # Gold circle
    pad = size // 6
    draw.ellipse([pad, pad, size - pad, size - pad],
                 fill=(212, 169, 49, 255))

    # Robot face (simplified)
    cx, cy = size // 2, size // 2
    s = size // 8  # scale unit

    # Eyes
    draw.ellipse([cx - s*2, cy - s, cx - s, cy + s//2], fill=(3, 3, 6, 255))
    draw.ellipse([cx + s, cy - s, cx + s*2, cy + s//2], fill=(3, 3, 6, 255))

    # Mouth
    draw.rectangle([cx - s*2, cy + s, cx + s*2, cy + s + s//2], fill=(3, 3, 6, 255))

    # Antenna
    draw.line([cx, cy - s*2, cx, cy - s*3], fill=(3, 3, 6, 255), width=max(2, size//60))
    draw.ellipse([cx - s//3, cy - s*3 - s//3, cx + s//3, cy - s*3 + s//3], fill=(3, 3, 6, 255))

    img.save(f"{OUT}/icon-{size}.png")

print(f"Icons generated in {OUT}")
