# CIN OCR Service

Python FastAPI service for extracting information from Moroccan CIN (ID card) images using OCR.

## Features

- 📷 Image preprocessing and enhancement
- 🔤 OCR text extraction (English & Arabic)
- 🎯 CIN number detection
- 👤 Name and personal info extraction
- ✅ CIN verification endpoint
- 🚀 Fast API with CORS support

## Prerequisites

- Python 3.8+
- Tesseract OCR installed on your system

### Install Tesseract

**Windows:**
```bash
# Download and install from:
https://github.com/UB-Mannheim/tesseract/wiki

# Add to PATH or set in ocr_service.py:
# pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
```

**Linux:**
```bash
sudo apt-get install tesseract-ocr
sudo apt-get install tesseract-ocr-ara  # For Arabic support
```

**macOS:**
```bash
brew install tesseract
brew install tesseract-lang  # For additional languages
```

## Installation

1. Create virtual environment:
```bash
cd ml
python -m venv venv
```

2. Activate virtual environment:
```bash
# Windows
venv\Scripts\activate

# Linux/macOS
source venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the Service

Start the FastAPI server:
```bash
python main.py
```

The service will run on `http://localhost:8000`

## API Endpoints

### Health Check
```
GET /health
```

### Extract CIN Info
```
POST /ocr/cin
Content-Type: multipart/form-data

Parameters:
- file: Image file (JPEG, PNG)
- enhance: bool (optional, default: true)

Response:
{
  "success": true,
  "message": "CIN information extracted successfully",
  "data": {
    "cin_number": "AB123456",
    "first_name": "Ahmed",
    "last_name": "Benali",
    "date_of_birth": "01.01.1990",
    "gender": "M",
    "confidence": 0.85
  }
}
```

### Verify CIN
```
POST /ocr/verify
Content-Type: multipart/form-data

Parameters:
- file: Image file
- expected_cin: string (optional)

Response:
{
  "success": true,
  "verified": true,
  "cin_number": "AB123456",
  "confidence": 0.85,
  "message": "CIN verified successfully"
}
```

## Testing with cURL

```bash
# Extract CIN info
curl -X POST "http://localhost:8000/ocr/cin" \
  -F "file=@path/to/cin_image.jpg" \
  -F "enhance=true"

# Verify CIN
curl -X POST "http://localhost:8000/ocr/verify" \
  -F "file=@path/to/cin_image.jpg" \
  -F "expected_cin=AB123456"
```

## Integration with Backend

The backend can call this service to verify CIN images:

```java
// In AuthService.java
private String verifyCinWithOCR(MultipartFile photo) throws IOException {
    RestTemplate restTemplate = new RestTemplate();
    
    MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
    body.add("file", new ByteArrayResource(photo.getBytes()) {
        @Override
        public String getFilename() {
            return photo.getOriginalFilename();
        }
    });
    
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.MULTIPART_FORM_DATA);
    
    HttpEntity<MultiValueMap<String, Object>> requestEntity = 
        new HttpEntity<>(body, headers);
    
    ResponseEntity<CINResponse> response = restTemplate.postForEntity(
        "http://localhost:8000/ocr/cin",
        requestEntity,
        CINResponse.class
    );
    
    return response.getBody().getData().getCinNumber();
}
```

## Project Structure

```
ml/
├── main.py                 # FastAPI application
├── requirements.txt        # Python dependencies
├── README.md              # Documentation
├── models/
│   └── cin_data.py        # Pydantic models
└── services/
    ├── image_processor.py # Image preprocessing
    └── ocr_service.py     # OCR text extraction
```

## Configuration

Edit `main.py` to configure:
- Port (default: 8000)
- CORS origins
- Log level

Edit `ocr_service.py` to:
- Set Tesseract path (Windows)
- Adjust OCR language
- Fine-tune regex patterns for CIN format

## Development

Run with auto-reload:
```bash
uvicorn main:app --reload --port 8000
```

View API documentation:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Troubleshooting

**Tesseract not found:**
- Make sure Tesseract is installed and in PATH
- Set explicit path in `ocr_service.py`

**Low OCR accuracy:**
- Ensure good image quality (min 500x500px)
- Try with `enhance=true` parameter
- Check image is well-lit and text is clear

**Import errors:**
- Activate virtual environment
- Reinstall dependencies: `pip install -r requirements.txt`
