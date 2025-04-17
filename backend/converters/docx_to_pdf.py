import subprocess
import os

def convert_docx_to_pdf(input_path: str, output_path: str):
    output_dir = os.path.dirname(output_path)
    
    subprocess.run([
        "/Applications/LibreOffice.app/Contents/MacOS/soffice",
        "--headless",
        "--convert-to", "pdf",
        "--outdir", output_dir,
        input_path
    ], check=True)

