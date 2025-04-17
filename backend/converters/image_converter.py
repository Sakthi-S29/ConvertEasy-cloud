from PIL import Image

def convert_image_format(input_path: str, output_path: str, output_format: str):
    format_map = {
        'jpg': 'JPEG',
        'jpeg': 'JPEG',
        'tif': 'TIFF',
        'tiff': 'TIFF',
        'webp': 'WEBP',
        'bmp': 'BMP',
        'png': 'PNG'
    }

    image = Image.open(input_path)

    if image.mode in ("RGBA", "P"):
        image = image.convert("RGB")

    final_format = format_map.get(output_format.lower(), output_format.upper())

    image.save(output_path, format=final_format)
