# ML OCR Integration - Complete Setup Guide

## 🎯 Overview
This guide describes the complete ML OCR integration for automatic CIN (Moroccan ID Card) verification using Python FastAPI and Tesseract OCR.

## 📁 Project Structure
```
front-backup/
├── ml/                          # Python ML Service (Port 8000)
│   ├── main.py                  # FastAPI application
│   ├── requirements.txt         # Python dependencies
│   ├── start.bat                # Windows startup script
│   ├── start.sh                 # Linux/macOS startup script
│   ├── services/
│   │   ├── __init__.py
│   │   ├── image_processor.py   # Image preprocessing
│   │   └── ocr_service.py       # OCR & CIN parsing
│   └── models/
│       ├── __init__.py
│       └── cin_data.py          # Data models
│
├── backend/                     # Spring Boot Backend (Port 8081)
│   └── src/main/java/com/ethicalai/creditscoring/
│       ├── controller/
│       │   └── AuthController.java      # Updated with OCR integration
│       └── service/
│           └── CinOcrService.java       # NEW - ML service client
│
└── frontend/                    # Flutter Frontend
```

## 🔧 Setup Instructions

### 1. Install Tesseract OCR

#### Windows
1. Download Tesseract installer from:
   https://github.com/UB-Mannheim/tesseract/wiki
   
2. Run installer (recommended path: `C:\Program Files\Tesseract-OCR`)

3. During installation, make sure to select:
   - ✅ English language pack
   - ✅ Arabic language pack

4. Add to PATH:
   - Right-click "This PC" → Properties → Advanced System Settings
   - Environment Variables → System variables → Path → Edit
   - Add: `C:\Program Files\Tesseract-OCR`

5. Verify installation:
   ```cmd
   tesseract --version
   tesseract --list-langs
   ```
   Should show: eng, ara

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install tesseract-ocr tesseract-ocr-ara
tesseract --version
tesseract --list-langs
```

#### macOS
```bash
brew install tesseract tesseract-lang
tesseract --version
tesseract --list-langs
```

### 2. Start ML Service

#### Windows
```cmd
cd d:\1 UNICA\Projet\ba\front-backup\ml
start.bat
```

#### Linux/macOS
```bash
cd ~/front-backup/ml
chmod +x start.sh
./start.sh
```

The service will:
1. Create Python virtual environment
2. Install dependencies (FastAPI, OpenCV, Tesseract, etc.)
3. Start on http://localhost:8000

### 3. Verify ML Service

Open browser and navigate to:
- Health check: http://localhost:8000/health
- API docs: http://localhost:8000/docs

Test with cURL:
```bash
curl -X POST "http://localhost:8000/ocr/cin" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@path/to/cin_image.jpg" \
  -F "enhance=true"
```

### 4. Start Backend

```cmd
cd d:\1 UNICA\Projet\ba\front-backup\backend
mvnw spring-boot:run
```

Backend will start on http://localhost:8081

### 5. Verify Backend Integration

Check logs for:
```
✅ ML OCR service is available
```

If you see:
```
❌ ML OCR service is not available
```
Then ML service is not running - check step 2.

## 🔄 How It Works

### CIN Verification Flow

```
User (Frontend) 
    ↓
    │ POST /auth/verify-cin
    │ - userId: 123
    │ - cin: "AB123456"  
    │ - cinPhoto: [file]
    ↓
Backend (Spring Boot)
    │
    ├→ Check ML service availability
    │   GET http://localhost:8000/health
    │
    ├→ Send image to ML service
    │   POST http://localhost:8000/ocr/cin
    │   - file: cinPhoto
    │   - enhance: true
    │
    ├→ ML Service processes:
    │   1. Image preprocessing (resize, filter, threshold, denoise, CLAHE)
    │   2. Tesseract OCR extraction (eng+ara)
    │   3. Parse CIN format (1-2 letters + 5-6 digits)
    │   4. Extract: CIN number, names, DOB, gender
    │   5. Calculate confidence score
    │
    ├→ Compare extracted CIN with provided CIN
    │
    ├→ If match:
    │   - Save CIN photo to ./uploads/identity-scans
    │   - Update user.identityVerified = true
    │   - Return success
    │
    └→ If no match:
        - Return error: CIN_MISMATCH
```

### 2. Backend → ML Service Communication

**Endpoint:** `POST /ocr/cin`

**Request:**
```http
POST http://localhost:8000/ocr/cin HTTP/1.1
Content-Type: multipart/form-data

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="cin.jpg"
Content-Type: image/jpeg

[binary image data]
------WebKitFormBoundary
Content-Disposition: form-data; name="enhance"

true
------WebKitFormBoundary--
```

**Response (Success):**
```json
{
  "success": true,
  "message": "CIN information extracted successfully",
  "data": {
    "cin_number": "AB123456",
    "first_name": "MOHAMMED",
    "last_name": "ALAOUI",
    "first_name_arabic": "محمد",
    "last_name_arabic": "العلوي",
    "date_of_birth": "15.03.1990",
    "place_of_birth": "CASABLANCA",
    "gender": "M",
    "confidence": 0.85
  },
  "raw_text": "ROYAUME DU MAROC\nCARTE NATIONALE..."
}
```

**Response (Failure):**
```json
{
  "success": false,
  "message": "CIN number not found in the image",
  "data": null
}
```

### 3. Image Processing Pipeline

```
Original Image
    ↓
Convert to RGB
    ↓
Convert to Grayscale
    ↓
Resize (if < 500x500px)
    ↓
Bilateral Filter (reduce noise, keep edges)
    ↓
Adaptive Threshold (binarization)
    ↓
Fast Non-Local Means Denoising
    ↓
CLAHE (contrast enhancement)
    ↓
Tesseract OCR (eng+ara)
    ↓
Text Extraction
    ↓
Regex Parsing (CIN format)
    ↓
Structured Data (JSON)
```

### 4. CIN Format Recognition

**Moroccan CIN Format:**
- Pattern: 1-2 letters + 5-6 digits
- Examples: AB123456, K12345, XY654321

**Regex Patterns:**
1. `\b([A-Z]{1,2}\d{5,6})\b` - Standard format
2. `CIN[:\s]*([A-Z]{1,2}\d{5,6})` - With "CIN" prefix
3. `N°[:\s]*([A-Z]{1,2}\d{5,6})` - With "N°" prefix

### 5. Confidence Scoring

Total score = 1.0 (100%)

- CIN number found: +0.4 (40%)
- First name found: +0.2 (20%)
- Last name found: +0.2 (20%)
- Date of birth found: +0.2 (20%)

**Thresholds:**
- >= 0.8: High confidence, show raw text
- >= 0.5: Acceptable, proceed with verification
- < 0.5: Low confidence, warn user

## 🧪 Testing

### Test with Sample CIN Image

1. Prepare test image:
   - Format: JPEG or PNG
   - Size: At least 500x500px
   - Quality: Clear, well-lit, no glare
   - Content: Moroccan CIN card

2. Test ML service directly:
```bash
curl -X POST "http://localhost:8000/ocr/cin" \
  -F "file=@test_cin.jpg" \
  -F "enhance=true"
```

3. Test via backend:
```bash
curl -X POST "http://localhost:8081/auth/verify-cin" \
  -F "userId=1" \
  -F "cin=AB123456" \
  -F "cinPhoto=@test_cin.jpg"
```

### Expected Results

**✅ Success Case:**
- ML service extracts CIN: AB123456
- User provided CIN: AB123456
- Result: Match ✅
- Backend saves photo and updates user.identityVerified = true

**❌ Mismatch Case:**
- ML service extracts CIN: XY654321
- User provided CIN: AB123456
- Result: Mismatch ❌
- Backend returns error: "CIN in image does not match provided CIN"

**⚠️ OCR Failure Case:**
- ML service cannot extract CIN
- User provided CIN: AB123456
- Result: OCR failed ⚠️
- Backend returns error: "CIN number not found in the image"

**🔌 Service Unavailable Case:**
- ML service is not running
- User provided CIN: AB123456
- Result: Skip OCR ⚠️
- Backend saves photo without automatic verification (manual review required)

## 📊 Monitoring

### Backend Logs

**Successful verification:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: AB123456
📸 Processing CIN photo - Original filename: cin.jpg, Size: 524288 bytes
🤖 Using ML OCR to verify CIN from image
🔵 Calling ML OCR service to extract CIN - File: cin.jpg, Size: 524288 bytes
📤 Sending request to ML OCR: http://localhost:8000/ocr/cin
✅ CIN extracted successfully - Number: AB123456, Confidence: 0.85
✅ ML OCR verification successful - CIN matches
✅ CIN photo saved - Path: ./uploads/identity-scans/cin_1_AB123456_a1b2c3d4.jpg
✅ CIN VERIFICATION SUCCESS - User ID: 1
```

**CIN mismatch:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: AB123456
📸 Processing CIN photo - Original filename: cin.jpg, Size: 524288 bytes
🤖 Using ML OCR to verify CIN from image
🔵 Calling ML OCR service to extract CIN - File: cin.jpg, Size: 524288 bytes
📤 Sending request to ML OCR: http://localhost:8000/ocr/cin
✅ CIN extracted successfully - Number: XY654321, Confidence: 0.82
⚠️ CIN mismatch - Expected: AB123456, Extracted: XY654321
❌ CIN verification failed - Image does not match provided CIN
❌ CIN VERIFICATION FAILED - User ID: 1, Error: The CIN in the uploaded image does not match the provided CIN number
```

**ML service unavailable:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: AB123456
📸 Processing CIN photo - Original filename: cin.jpg, Size: 524288 bytes
❌ ML OCR service is not available: Connection refused
⚠️ ML OCR service not available - Skipping automatic verification
✅ CIN photo saved - Path: ./uploads/identity-scans/cin_1_AB123456_a1b2c3d4.jpg
✅ CIN VERIFICATION SUCCESS - User ID: 1
```

### ML Service Logs

```
🔵 Received CIN OCR request - Filename: cin.jpg, Size: 524288 bytes
📷 Preprocessing image - Enhance: True
📄 Raw OCR text extracted: 341 characters
✅ CIN information extracted successfully - Number: AB123456, Confidence: 0.85
```

## 🐛 Troubleshooting

### Issue: ML service won't start

**Error:** `ModuleNotFoundError: No module named 'fastapi'`

**Solution:**
```bash
cd ml
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/macOS
pip install -r requirements.txt
python main.py
```

### Issue: Tesseract not found

**Error:** `TesseractNotFoundError: tesseract is not installed`

**Solution:**
1. Install Tesseract (see Setup section above)
2. Add to PATH, or specify path in `ml/services/ocr_service.py`:
```python
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
```

### Issue: Low OCR accuracy

**Symptoms:**
- Confidence < 0.5
- Wrong CIN extracted
- Missing fields

**Solutions:**
1. Check image quality:
   - Resolution: At least 500x500px
   - Lighting: Uniform, no shadows
   - Focus: Sharp, not blurry
   - Glare: No reflections on card surface

2. Try different image:
   - Use camera with good lighting
   - Place card on contrasting background
   - Ensure text is horizontal

3. Adjust preprocessing:
   - Modify `image_processor.py` parameters
   - Try different threshold values
   - Experiment with CLAHE settings

### Issue: Backend can't connect to ML service

**Error:** `❌ ML OCR service is not available: Connection refused`

**Check:**
1. ML service is running: http://localhost:8000/health
2. Port 8000 is not blocked by firewall
3. Backend config: `app.ml-service.url=http://localhost:8000`

**Solution:**
```bash
# Check if port 8000 is in use
netstat -ano | findstr :8000  # Windows
lsof -i :8000                 # Linux/macOS

# Start ML service
cd ml
start.bat  # or ./start.sh
```

### Issue: CORS errors

**Error:** `Access-Control-Allow-Origin header is missing`

**Solution:** ML service already has CORS configured:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

If still occurs, check browser console and backend logs.

## 🚀 Deployment

### Production Checklist

- [ ] Install Tesseract OCR on server
- [ ] Install Arabic language pack
- [ ] Set up Python 3.8+ environment
- [ ] Create systemd service (Linux) or Windows Service
- [ ] Configure reverse proxy (nginx/Apache) for ML service
- [ ] Set up SSL/TLS certificates
- [ ] Update `app.ml-service.url` to production URL
- [ ] Configure firewall rules (allow port 8000 internally)
- [ ] Set up monitoring and logging
- [ ] Create backup strategy for uploaded CIN photos
- [ ] Implement rate limiting on ML endpoints
- [ ] Add authentication between backend and ML service

### Systemd Service (Linux)

Create `/etc/systemd/system/ml-ocr.service`:
```ini
[Unit]
Description=ML OCR Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/front-backup/ml
ExecStart=/var/www/front-backup/ml/venv/bin/python main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable ml-ocr
sudo systemctl start ml-ocr
sudo systemctl status ml-ocr
```

### Docker Deployment (Optional)

Create `ml/Dockerfile`:
```dockerfile
FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-ara \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "main.py"]
```

Build and run:
```bash
docker build -t ml-ocr-service ml/
docker run -d -p 8000:8000 --name ml-ocr ml-ocr-service
```

## 📈 Performance

### Expected Response Times

- ML OCR extraction: 1-3 seconds
- Backend verification: 1.5-4 seconds total
- Frontend to backend: 2-5 seconds (including upload)

### Optimization Tips

1. **Image Size:**
   - Resize large images before upload (max 2MB)
   - Use JPEG with 80-90% quality

2. **Caching:**
   - Cache OCR results for same image hash
   - Implement Redis for distributed caching

3. **Parallel Processing:**
   - Use async/await in FastAPI
   - Process multiple requests concurrently

4. **Resource Limits:**
   - Limit concurrent OCR requests
   - Set timeout (30 seconds)
   - Implement queue for high load

## 🔐 Security

### Recommendations

1. **Image Validation:**
   - Check file type (JPEG, PNG only)
   - Verify file size (max 10MB)
   - Scan for malware

2. **Authentication:**
   - Add API key between backend and ML service
   - Use internal network, not public

3. **Data Privacy:**
   - Delete temporary OCR files immediately
   - Encrypt CIN photos at rest
   - Log access to CIN data

4. **Rate Limiting:**
   - Limit OCR requests per user (e.g., 5/hour)
   - Implement CAPTCHA for repeated failures

## 📝 API Reference

### ML Service Endpoints

#### GET /health
Health check

**Response:**
```json
{
  "status": "healthy",
  "service": "CIN OCR Service"
}
```

#### POST /ocr/cin
Extract CIN information from image

**Request:**
- `file`: Image file (multipart/form-data)
- `enhance`: Boolean, enable image enhancement (optional, default: true)

**Response:** See "Backend → ML Service Communication" section

#### POST /ocr/verify
Verify CIN matches expected value

**Request:**
- `file`: Image file (multipart/form-data)
- `expected_cin`: Expected CIN number (query parameter)
- `enhance`: Boolean (optional)

**Response:**
```json
{
  "success": true,
  "message": "CIN verification successful",
  "data": {
    "cin_number": "AB123456",
    "expected_cin": "AB123456",
    "verified": true,
    "confidence": 0.85
  }
}
```

### Backend Endpoints

#### POST /auth/verify-cin
Verify user CIN with automatic OCR

**Request:**
- `userId`: User ID (form parameter)
- `cin`: Expected CIN number (form parameter)
- `cinPhoto`: CIN image file (optional)

**Response:**
```json
{
  "success": true,
  "message": "CIN verified successfully",
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "cin": "AB123456",
    "identityVerified": true,
    "cinPhotoPath": "./uploads/identity-scans/cin_1_AB123456_a1b2c3d4.jpg"
  }
}
```

## 🎓 Next Steps

1. **Test with real CIN images**
   - Prepare 10+ sample images
   - Test various lighting conditions
   - Test different card orientations

2. **Improve OCR accuracy**
   - Fine-tune preprocessing parameters
   - Add rotation detection
   - Implement perspective correction

3. **Add more fields**
   - Extract address
   - Parse issue/expiry dates
   - OCR Arabic names

4. **Enhance security**
   - Add API authentication
   - Implement rate limiting
   - Set up audit logging

5. **Monitor and optimize**
   - Track OCR accuracy metrics
   - Monitor response times
   - Optimize image processing

## 📚 Resources

- [Tesseract OCR Documentation](https://tesseract-ocr.github.io/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [OpenCV Python Tutorials](https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html)
- [Moroccan CIN Format](https://www.maroc.ma/)

## ✅ Summary

You now have a complete ML OCR integration for automatic CIN verification:

1. ✅ Python FastAPI ML service running on port 8000
2. ✅ Tesseract OCR with English + Arabic support
3. ✅ Image preprocessing pipeline for optimal accuracy
4. ✅ Backend integration with automatic verification
5. ✅ Comprehensive error handling and logging
6. ✅ Health monitoring and service availability checks

**Ready to deploy!** 🚀
