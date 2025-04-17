# 🔄 ConvertEasy

ConvertEasy is a secure, user-friendly, and powerful file conversion web app that lets you convert documents, images, and media files into different formats — all from a beautiful drag-and-drop interface.

---

## 🚀 Features

✅ Convert between:
- DOCX ↔ PDF
- PPTX → PDF
- TXT → DOCX
- PDF → DOCX
- JPG ↔ PNG, JPG → PDF
- MP3, WAV, MP4, MOV conversions

✅ Smart format detection (based on MIME, not just filename)
✅ Drag & Drop or Browse file input
✅ Secure MIME validation
✅ Automatic file cleanup after 1 hour
✅ Fully frontend + backend separated architecture

---

## 🧠 Tech Stack

- **Frontend**: HTML + CSS + JavaScript
- **Backend**: FastAPI (Python)
- **File Processing**: Pillow, LibreOffice (headless), FFmpeg

---

## 🧰 Getting Started (for Beginners)

### Step 1: Clone the Repo
```bash
git clone https://github.com/YOUR-USERNAME/ConvertEasy.git
cd ConvertEasy
```

### Step 2: Create a Python Virtual Environment
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### Step 3: Install Python Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 4: Install Required System Packages

#### On macOS:
```bash
brew install ffmpeg libreoffice libmagic
```

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install ffmpeg libreoffice libmagic1
```

These are used for media/doc/PDF conversions and MIME type detection.

### Step 5: Run the Backend Server
```bash
uvicorn main:app --reload
```
✅ You should see: `Uvicorn running on http://127.0.0.1:8000`

---

### Step 6: Run the Frontend
1. Open a new terminal.
2. Navigate to frontend folder:
```bash
cd ../frontend
```
3. Open `index.html` in your browser:
   - Double-click it, or drag it into Chrome/Firefox

✅ Now you can upload and convert files!

---

## 📁 Folder Structure
```
ConvertEasy/
├── backend/
│   ├── main.py
│   ├── converters/
│   ├── requirements.txt
│   ├── uploads/          ← auto-created
│   ├── converted/        ← auto-created
├── frontend/
│   ├── index.html
│   ├── script.js
│   ├── style.css
├── .gitignore
├── README.md
```

---

## 🧼 Auto Cleanup
Every file you upload and convert is automatically deleted after **1 hour**.
You don't need to worry about storage!

---
