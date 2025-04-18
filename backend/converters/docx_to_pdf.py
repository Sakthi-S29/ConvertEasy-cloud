import subprocess
import os
import glob
import shutil

def convert_docx_to_pdf(input_path: str, output_path: str):
    output_dir = os.path.dirname(output_path)

    print(f"[DEBUG] Running LibreOffice: {input_path} ➝ {output_dir}")

    result = subprocess.run([
        "/Applications/LibreOffice.app/Contents/MacOS/soffice",
        "--headless",
        "--nologo",
        "--convert-to", "pdf",
        "--outdir", output_dir,
        input_path
    ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    print("[LibreOffice STDOUT]", result.stdout.decode())
    print("[LibreOffice STDERR]", result.stderr.decode())

    # Detect actual output file based on input filename
    base_filename = os.path.splitext(os.path.basename(input_path))[0]
    actual_pdf = os.path.join(output_dir, f"{base_filename}.pdf")

    if not os.path.exists(actual_pdf):
        raise Exception(f"[ERROR] Expected output file not found: {actual_pdf}")

    # Rename to match output_path
    shutil.move(actual_pdf, output_path)
    print(f"[DEBUG] Renamed {actual_pdf} to {output_path}")
