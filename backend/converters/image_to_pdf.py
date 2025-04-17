from PIL import Image
import os

def convert_image_to_pdf(input_path: str, output_path: str):
    image = Image.open(input_path)

    if image.mode in ("RGBA", "P"):  # PDF can't handle alpha channels directly
        image = image.convert("RGB")

    image.save(output_path, "PDF")
