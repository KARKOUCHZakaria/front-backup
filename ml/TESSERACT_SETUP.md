# Tesseract OCR Setup Guide

## Issue
The CIN OCR feature requires Tesseract OCR to be installed on your system. Without it, you'll see this error:
```
tesseract is not installed or it's not in your PATH
```

## Solution: Install Tesseract OCR

### Windows Installation

1. **Download Tesseract Installer**
   - Visit: https://github.com/UB-Mannheim/tesseract/wiki
   - Download: `tesseract-ocr-w64-setup-5.3.3.20231005.exe` (or latest version)
   - Or direct link: https://digi.bib.uni-mannheim.de/tesseract/

2. **Install Tesseract**
   - Run the installer
   - **Important:** During installation, note the installation path (default: `C:\Program Files\Tesseract-OCR`)
   - Make sure to select "Add to PATH" option during installation
   - Complete the installation

3. **Verify Installation**
   ```cmd
   tesseract --version
   ```
   Should show: `tesseract 5.3.3` or similar

4. **If NOT in PATH, add manually:**
   - Open System Properties → Environment Variables
   - Edit `Path` variable
   - Add: `C:\Program Files\Tesseract-OCR`
   - Restart terminal/IDE

5. **Configure ML Service (if needed)**
   Edit `ml/services/ocr_service.py` line 20:
   ```python
   pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
   ```

### Alternative: Quick Fix Without Installation

If you don't want to use OCR for CIN verification:

1. **Edit Backend Configuration**
   In `backend/src/main/java/com/ethicalai/creditscoring/controller/AuthController.java`:
   - Find line ~96: `boolean ocrAvailable = cinOcrService.isOcrServiceAvailable();`
   - Change to: `boolean ocrAvailable = false;`
   
   This will skip OCR verification and accept any CIN photo.

2. **Restart Backend**
   ```cmd
   cd backend
   java -jar target\credit-scoring-backend-1.0.0.jar
   ```

## Linux/Mac Installation

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install tesseract-ocr
sudo apt-get install tesseract-ocr-ara  # For Arabic support
```

### Mac (Homebrew)
```bash
brew install tesseract
brew install tesseract-lang  # For additional languages
```

### Verify
```bash
tesseract --version
which tesseract
```

## Testing After Installation

1. **Restart ML Service**
   ```cmd
   cd ml
   python main.py
   ```

2. **Test OCR Endpoint**
   ```cmd
   curl -X POST http://localhost:8000/ocr/cin \
     -F "file=@test-documents/test_cin_AB123456.jpg" \
     -F "enhance=true"
   ```

3. **Try CIN Verification in App**
   - Register a new user
   - Upload a CIN image (use one from `test-documents/`)
   - Should now extract CIN number successfully

## Supported Languages

For Moroccan CIN cards (Arabic + French):
```python
# In ocr_service.py, the language is set to:
lang='eng+ara'  # English + Arabic
```

## Troubleshooting

### Error: "Failed to extract text"
- Verify Tesseract is in PATH: `tesseract --version`
- Check installation path is correct
- Restart terminal/IDE after adding to PATH

### Error: "Language 'ara' not found"
- Install Arabic language pack:
  - Windows: Re-run installer and select Arabic
  - Linux: `sudo apt-get install tesseract-ocr-ara`
  - Mac: Arabic included in main install

### Poor OCR Quality
- Ensure images are clear and well-lit
- CIN card should be flat and in focus
- Use the image enhancement option (`enhance=true`)

## Resources

- Tesseract GitHub: https://github.com/tesseract-ocr/tesseract
- Windows Installer: https://github.com/UB-Mannheim/tesseract/wiki
- Documentation: https://tesseract-ocr.github.io/
