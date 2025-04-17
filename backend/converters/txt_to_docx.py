from docx import Document

def convert_txt_to_docx(input_path: str, output_path: str):
    document = Document()

    with open(input_path, 'r', encoding='utf-8') as file:
        for line in file:
            document.add_paragraph(line.strip())

    document.save(output_path)
