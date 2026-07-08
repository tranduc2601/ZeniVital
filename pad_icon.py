import os
from PIL import Image

input_path = r"D:\OneDrive\Máy tính\ZeniVital.png"
output_path = r"D:\Trenx_Flutter\assets\app_icon.png"

# Ensure output directory exists
os.makedirs(os.path.dirname(output_path), exist_ok=True)

img = Image.open(input_path)
width, height = img.size

print(f"Original size: {width}x{height}")

if width == height:
    print("Image is already square. Saving copy.")
    img.save(output_path)
else:
    print("Image is not square. Padding with transparent background.")
    max_dim = max(width, height)
    # Create a new image with transparent background
    new_img = Image.new("RGBA", (max_dim, max_dim), (0, 0, 0, 0))
    # Paste original image in the center
    paste_x = (max_dim - width) // 2
    paste_y = (max_dim - height) // 2
    new_img.paste(img, (paste_x, paste_y))
    new_img.save(output_path)
    print(f"New size: {max_dim}x{max_dim}")
