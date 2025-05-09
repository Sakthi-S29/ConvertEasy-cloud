document.addEventListener('DOMContentLoaded', () => {
    const formatCards = document.querySelectorAll('.format-card');
    const fileInput = document.getElementById('fileInput');
    const fileInfo = document.getElementById('fileInfo');
    const fileError = document.getElementById('fileError');
    const convertBtn = document.getElementById('convertBtn');
    const dropZone = document.getElementById('dropZone');
    const output = document.getElementById('output');
    const cancelBtn = document.getElementById('cancelBtn');

cancelBtn.addEventListener('click', () => {
    currentFile = null;
    fileInput.value = '';
    fileInfo.textContent = '';
    output.innerHTML = '';
    fileError.style.display = 'none';
    convertBtn.disabled = true;

    formatCards.forEach(card => {
        card.classList.remove('selected', 'disabled');
        card.style.pointerEvents = 'auto';
        card.style.opacity = '1';
    });
});

    const supportedConversions = {
        docx: ['pdf'],
        pptx: ['pdf'],
        txt: ['docx'],
        pdf: ['docx'],
        jpg: ['pdf', 'png'],
        jpeg: ['pdf', 'jpg', 'png'],
        png: ['pdf', 'jpg'],
        mp3: ['wav', 'mp4'],
        wav: ['mp3', 'mp4'],
        mp4: ['mp3', 'mov'],
        mov: ['mp4', 'mp3'],
        avi: ['mp4'],
        mkv: ['mp4'],
        webm: ['mp4']
    };
    
    let currentFile = null;
    let selectedFormat = 'pdf';
    let maxSize = 50; // in MB

    formatCards.forEach(card => {
        card.addEventListener('click', () => {
            document.querySelectorAll('.format-card').forEach(c => c.classList.remove('selected'));
            card.classList.add('selected');
            selectedFormat = card.dataset.format;
            maxSize = parseInt(card.dataset.maxSize);

            if (currentFile) checkFileSize(currentFile);
        });
    });

    fileInput.addEventListener('change', (e) => {
        if (e.target.files.length > 0) {
            handleFileSelection(e.target.files[0]);
        }
    });

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
    });

    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => dropZone.classList.add('active'), false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => dropZone.classList.remove('active'), false);
    });

    dropZone.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        if (files.length > 0) handleFileSelection(files[0]);
    });

    convertBtn.addEventListener('click', async () => {
        if (!currentFile || convertBtn.disabled) return;

        convertBtn.disabled = true;
        convertBtn.textContent = 'Converting...';

        const formData = new FormData();
        formData.append('file', currentFile);
        formData.append('output_format', selectedFormat);

        try {
            const API_BASE_URL = "http://converteasy-backend-alb-516812590.us-east-1.elb.amazonaws.com";
            const res = await fetch(`${API_BASE_URL}/convert`, {
                method: 'POST',
                body: formData
            });

            if (!res.ok) throw new Error('Conversion failed');

            const data = await res.json();
            showDownloadLink(data.download_url);
        } catch (error) {
            fileError.style.display = 'block';
            fileError.textContent = `Error: ${error.message}`;
        } finally {
            convertBtn.disabled = false;
            convertBtn.textContent = 'Convert';
        }
    });

    function handleFileSelection(file) {
        currentFile = file;
        const fileSizeMB = (file.size / 1024 / 1024).toFixed(2);
        fileInfo.textContent = `${file.name} (${fileSizeMB} MB)`;
        checkFileSize(file);

        const fileMime = file.type;
        const fileExt = file.name.split('.').pop().toLowerCase();

        const mimeToExt = {
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
            'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'pptx',
            'text/plain': 'txt',
            'application/pdf': 'pdf',
            'image/jpeg': 'jpg',
            'image/png': 'png',
            'audio/mpeg': 'mp3',
            'audio/wav': 'wav',
            'video/mp4': 'mp4',
            'video/quicktime': 'mov',
            'video/x-msvideo': 'avi',
            'video/x-matroska': 'mkv',
            'video/webm': 'webm'
        };

        const detectedExt = mimeToExt[fileMime] || fileExt;
        const allowedFormats = supportedConversions[detectedExt] || [];

        formatCards.forEach(card => {
            const format = card.dataset.format;
            if (allowedFormats.includes(format)) {
                card.classList.remove('disabled');
                card.style.pointerEvents = 'auto';
                card.style.opacity = '1';
            } else {
                card.classList.remove('selected');
                card.classList.add('disabled');
                card.style.pointerEvents = 'none';
                card.style.opacity = '0.5';
            }
        });

        if (!allowedFormats.includes(selectedFormat)) {
            selectedFormat = allowedFormats[0] || '';
            convertBtn.disabled = true;
        }
    }

    function checkFileSize(file) {
        const fileSizeMB = file.size / 1024 / 1024;
        if (fileSizeMB > maxSize) {
            fileError.style.display = 'block';
            fileError.textContent = `File exceeds ${maxSize}MB limit for ${selectedFormat.toUpperCase()}`;
            dropZone.classList.add('error');
            convertBtn.disabled = true;
        } else {
            fileError.style.display = 'none';
            dropZone.classList.remove('error');
            convertBtn.disabled = false;
        }
    }

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    function showDownloadLink(url) {
        output.innerHTML = `
            <a href="${url}" download class="btn download-link">
                ⬇️ Download ${selectedFormat.toUpperCase()} File
            </a>`;
    }
});
