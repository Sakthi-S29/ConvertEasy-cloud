import subprocess
import os

def convert_ppt_to_pdf(input_path: str, output_path: str):
    output_dir = os.path.dirname(output_path)
    base_filename = os.path.splitext(os.path.basename(input_path))[0]
    generated_pdf = os.path.join(output_dir, f"{base_filename}.pdf")

    subprocess.run([
        "/Applications/LibreOffice.app/Contents/MacOS/soffice",  # use "libreoffice" if installed via Homebrew
        "--headless",
        "--convert-to", "pdf",
        "--outdir", output_dir,
        input_path
    ], check=True)

    if generated_pdf != output_path:
        os.rename(generated_pdf, output_path)
