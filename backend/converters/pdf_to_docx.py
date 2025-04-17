import pdfplumber
from docx import Document

def convert_pdf_to_docx(input_path: str, output_path: str):
    document = Document()

    with pdfplumber.open(input_path) as pdf:
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                for line in text.split('\n'):
                    document.add_paragraph(line)

    document.save(output_path)
