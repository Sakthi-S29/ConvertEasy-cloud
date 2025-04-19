from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import os
import uuid
import boto3
import magic
import threading
import time
from datetime import datetime
from dotenv import load_dotenv
from converters.docx_to_pdf import convert_docx_to_pdf
from converters.ppt_to_pdf import convert_ppt_to_pdf
from converters.image_to_pdf import convert_image_to_pdf
from converters.image_converter import convert_image_format
from converters.txt_to_docx import convert_txt_to_docx
from converters.pdf_to_docx import convert_pdf_to_docx
from converters.media_converter import convert_media_format

load_dotenv()

app = FastAPI()

# CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

s3 = boto3.client("s3")
UPLOAD_BUCKET = "converteasy-uploaded-files"
CONVERTED_BUCKET = "converteasy-converted-files"

@app.post("/convert")
async def smart_convert(file: UploadFile = File(...), output_format: str = Form(...)):
    input_ext = file.filename.split('.')[-1].lower()
    safe_filename = f"{uuid.uuid4().hex}_{file.filename.replace(' ', '_')}"
    input_path = f"/tmp/{safe_filename}"
    output_path = f"/tmp/converted_{safe_filename}.{output_format}"

    allowed_mime_types = {
        'application/pdf',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'text/plain',
        'image/jpeg',
        'image/png',
        'audio/mpeg',
        'audio/wav',
        'video/mp4',
        'video/quicktime',
        'video/x-msvideo',
        'video/x-matroska',
        'video/webm'
    }

    with open(input_path, "wb") as buffer:
        buffer.write(await file.read())
    
    s3.upload_file(input_path, UPLOAD_BUCKET, os.path.basename(input_path))
    print(f"[DEBUG] Uploaded {file.filename} to S3 bucket {UPLOAD_BUCKET}")
    mime_type = magic.from_file(input_path, mime=True)
    print(f"[DEBUG] Detected MIME type: {mime_type}")

    if mime_type not in allowed_mime_types:
        raise HTTPException(status_code=400, detail=f"Unsupported or unsafe file type: {mime_type}")

    try:
        if input_ext == "docx" and output_format == "pdf":
            convert_docx_to_pdf(input_path, output_path)
            if not os.path.exists(output_path):
                raise HTTPException(status_code=500, detail="Conversion failed: PDF file not created")

        elif input_ext == "pptx" and output_format == "pdf":
            convert_ppt_to_pdf(input_path, output_path)
        elif input_ext in ["jpg", "jpeg", "png"] and output_format == "pdf":
            convert_image_to_pdf(input_path, output_path)
        elif input_ext == "txt" and output_format == "docx":
            convert_txt_to_docx(input_path, output_path)
        elif input_ext == "pdf" and output_format == "docx":
            convert_pdf_to_docx(input_path, output_path)
        elif input_ext in ["jpg", "jpeg", "png"] and output_format in ["jpg", "jpeg", "png"]:
            convert_image_format(input_path, output_path, output_format)
        elif input_ext in ["mp3", "wav", "mp4", "mov", "mkv", "webm", "avi"] and output_format in ["mp3", "wav", "mp4", "mov"]:
            convert_media_format(input_path, output_path)
        else:
            raise HTTPException(status_code=400, detail="Unsupported conversion type.")

        s3.upload_file(output_path, CONVERTED_BUCKET, os.path.basename(output_path))

        url = s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': CONVERTED_BUCKET, 'Key': os.path.basename(output_path)},
            ExpiresIn=3600
        )

        # Run DB logging in background
        threading.Thread(
            target=log_to_db,
            args=(file.filename, input_ext, output_format),
            daemon=True
        ).start()

        return {"download_url": url}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Conversion failed: {str(e)}")

dynamodb = boto3.resource("dynamodb")
logs_table = dynamodb.Table("converteasy-logs")

def log_to_db(file_name, file_type, converted_to):
    try:
        logs_table.put_item(Item={
            "id": str(uuid.uuid4()),
            "file_name": file_name,
            "file_type": file_type,
            "converted_to": converted_to,
            "timestamp": int(time.time())
        })
    except Exception as e:
        print(f"[DB ERROR] Failed to log to DynamoDB: {e}")

async def preflight_handler():
    return JSONResponse(status_code=200)