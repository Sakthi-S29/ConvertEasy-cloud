from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
import shutil
import os
import time
import threading
import magic
import uuid
import psycopg2
from datetime import datetime
from dotenv import load_dotenv
load_dotenv()

# Import converters
from converters.docx_to_pdf import convert_docx_to_pdf
from converters.ppt_to_pdf import convert_ppt_to_pdf
from converters.image_to_pdf import convert_image_to_pdf
from converters.image_converter import convert_image_format
from converters.txt_to_docx import convert_txt_to_docx
from converters.pdf_to_docx import convert_pdf_to_docx
from converters.media_converter import convert_media_format

app = FastAPI()

# CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
CONVERTED_DIR = "converted"


# Smart unified conversion endpoint
@app.post("/convert")
async def smart_convert(file: UploadFile = File(...), output_format: str = Form(...)):
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    os.makedirs(CONVERTED_DIR, exist_ok=True)
    input_ext = file.filename.split('.')[-1].lower()
    safe_filename = f"{uuid.uuid4().hex}_{file.filename.replace(' ', '_')}"
    input_path = f"{UPLOAD_DIR}/{safe_filename}"
    name = os.path.splitext(file.filename)[0]
    output_path = f"{CONVERTED_DIR}/{name}.{output_format}"
    allowed_mime_types = {
        'application/pdf',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',  # docx
        'application/vnd.openxmlformats-officedocument.presentationml.presentation', # pptx
        'text/plain',  # txt
        'image/jpeg',
        'image/png',
        'audio/mpeg',  # mp3
        'audio/wav',
        'video/mp4',
        'video/quicktime',  # mov
        'video/x-msvideo',  # avi
        'video/x-matroska', # mkv
        'video/webm'
    }

    
    with open(input_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    mime_type = magic.from_file(input_path, mime=True)
    print(f"[DEBUG] Detected MIME type: {mime_type}")

    if mime_type not in allowed_mime_types:
        raise HTTPException(status_code=400, detail=f"Unsupported or unsafe file type: {mime_type}")
    
    try:
        # Document conversions
        if input_ext == "docx" and output_format == "pdf":
            convert_docx_to_pdf(input_path, output_path)
        elif input_ext == "pptx" and output_format == "pdf":
            convert_ppt_to_pdf(input_path, output_path)
        elif input_ext in ["jpg", "jpeg", "png"] and output_format == "pdf":
            convert_image_to_pdf(input_path, output_path)
        elif input_ext == "txt" and output_format == "docx":
            convert_txt_to_docx(input_path, output_path)
        elif input_ext == "pdf" and output_format == "docx":
            convert_pdf_to_docx(input_path, output_path)

        # Image to image
        elif input_ext in ["jpg", "jpeg", "png"] and output_format in ["jpg", "jpeg", "png"]:
            convert_image_format(input_path, output_path, output_format)

        # Media conversions
        elif input_ext in ["mp3", "wav", "mp4", "mov", "mkv", "webm", "avi"] and output_format in ["mp3", "wav", "mp4", "mov"]:
            convert_media_format(input_path, output_path)

        else:
            raise HTTPException(status_code=400, detail="Unsupported conversion type.")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Conversion failed: {str(e)}")

    log_to_db(file.filename, input_ext, output_format)
    return {"download_url": f"/download/{os.path.basename(output_path)}"}

# File download
@app.get("/download/{file_path:path}")
async def download(file_path: str):
    return FileResponse(f"{CONVERTED_DIR}/{file_path}")

# Cleanup old files every 10 minutes
def cleanup_files(folder: str, age_limit_seconds: int = 3600):
    while True:
        now = time.time()
        for filename in os.listdir(folder):
            path = os.path.join(folder, filename)
            if os.path.isfile(path) and (now - os.path.getmtime(path) > age_limit_seconds):
                os.remove(path)
                print(f"[Cleanup] Deleted: {path}")
        time.sleep(600)

def start_cleanup_thread():
    for folder in [UPLOAD_DIR, CONVERTED_DIR]:
        thread = threading.Thread(target=cleanup_files, args=(folder,), daemon=True)
        thread.start()

def log_to_db(file_name, file_type, converted_to):
    try:
        conn = psycopg2.connect(
            host=os.getenv("RDS_HOST"),
            database=os.getenv("RDS_DB"),
            user=os.getenv("RDS_USER"),
            password=os.getenv("RDS_PASS")
        )
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO conversions_log (file_name, file_type, converted_to) VALUES (%s, %s, %s);",
            (file_name, file_type, converted_to)
        )
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"[DB ERROR] Failed to log to DB: {e}")


# Ensure folders exist before starting cleanup
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(CONVERTED_DIR, exist_ok=True)
start_cleanup_thread()

