# CIN OCR Testing Guide

## 🧪 Complete Test Scenarios

This guide walks you through testing the complete CIN OCR integration from frontend to ML service.

## Prerequisites

- ✅ Tesseract OCR installed with Arabic support
- ✅ ML service running on http://localhost:8000
- ✅ Backend running on http://localhost:8081
- ✅ Frontend running on http://localhost:3000 (or your Flutter app)
- ✅ Test CIN images (JPEG/PNG, min 500x500px, clear text)

## Test Scenarios

### 1. ✅ Successful CIN Verification

**Objective:** User uploads valid CIN image that matches provided CIN number

**Steps:**
1. Prepare CIN image with clear text
2. Note the actual CIN number from the image (e.g., AB123456)
3. Call verification endpoint:

```bash
curl -X POST "http://localhost:8081/auth/verify-cin" \
  -F "userId=1" \
  -F "cin=AB123456" \
  -F "cinPhoto=@test_cin_ab123456.jpg"
```

**Expected Result:**
```json
{
  "success": true,
  "message": "CIN verified successfully",
  "data": {
    "id": 1,
    "username": "test_user",
    "email": "test@example.com",
    "cin": "AB123456",
    "identityVerified": true,
    "cinPhotoPath": "./uploads/identity-scans/cin_1_AB123456_*.jpg"
  }
}
```

**Backend Logs:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: AB123456
📸 Processing CIN photo
🤖 Using ML OCR to verify CIN from image
✅ CIN extracted successfully - Number: AB123456, Confidence: 0.85
✅ ML OCR verification successful - CIN matches
✅ CIN photo saved
✅ CIN VERIFICATION SUCCESS
```

**ML Service Logs:**
```
🔵 Received CIN OCR request
📷 Preprocessing image - Enhance: True
📄 Raw OCR text extracted
✅ CIN information extracted successfully - Number: AB123456, Confidence: 0.85
```

**Database Check:**
```sql
SELECT id, username, cin, identity_verified, cin_photo_path 
FROM users 
WHERE id = 1;
```
Should show: `identity_verified = true`, `cin_photo_path` populated

---

### 2. ❌ CIN Mismatch

**Objective:** User provides wrong CIN number that doesn't match image

**Steps:**
1. Use CIN image with actual CIN: AB123456
2. Provide different CIN in request: XY654321

```bash
curl -X POST "http://localhost:8081/auth/verify-cin" \
  -F "userId=1" \
  -F "cin=XY654321" \
  -F "cinPhoto=@test_cin_ab123456.jpg"
```

**Expected Result:**
```json
{
  "success": false,
  "error": "CIN_MISMATCH",
  "message": "The CIN in the uploaded image does not match the provided CIN number"
}
```

**Backend Logs:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: XY654321
📸 Processing CIN photo
🤖 Using ML OCR to verify CIN from image
✅ CIN extracted successfully - Number: AB123456, Confidence: 0.85
⚠️ CIN mismatch - Expected: XY654321, Extracted: AB123456
❌ CIN verification failed - Image does not match provided CIN
```

**Database Check:**
```sql
SELECT id, username, cin, identity_verified 
FROM users 
WHERE id = 1;
```
Should show: `identity_verified = false`, `cin` NOT updated

---

### 3. ⚠️ Poor Image Quality (Low Confidence)

**Objective:** Test with blurry or low-quality image

**Steps:**
1. Use blurry/dark/small CIN image
2. Call verification endpoint

```bash
curl -X POST "http://localhost:8081/auth/verify-cin" \
  -F "userId=1" \
  -F "cin=AB123456" \
  -F "cinPhoto=@test_cin_blurry.jpg"
```

**Expected Result:**
```json
{
  "success": false,
  "error": "CIN_VERIFICATION_FAILED",
  "message": "CIN number not found in the image"
}
```

**Backend Logs:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: AB123456
📸 Processing CIN photo
🤖 Using ML OCR to verify CIN from image
⚠️ Low OCR confidence: 0.3 - CIN might be incorrect
❌ CIN number not found in OCR response
```

**ML Service Logs:**
```
🔵 Received CIN OCR request
📷 Preprocessing image - Enhance: True
📄 Raw OCR text extracted: 45 characters
⚠️ Low confidence: 0.3
❌ CIN number not found in text
```

---

### 4. 🔌 ML Service Unavailable

**Objective:** Backend gracefully handles ML service downtime

**Steps:**
1. Stop ML service: `Ctrl+C` in ML terminal
2. Call verification endpoint

```bash
curl -X POST "http://localhost:8081/auth/verify-cin" \
  -F "userId=1" \
  -F "cin=AB123456" \
  -F "cinPhoto=@test_cin.jpg"
```

**Expected Result:**
```json
{
  "success": true,
  "message": "CIN verified successfully",
  "data": {
    "id": 1,
    "cin": "AB123456",
    "identityVerified": true,
    "cinPhotoPath": "./uploads/identity-scans/cin_1_AB123456_*.jpg"
  }
}
```

**Backend Logs:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: AB123456
📸 Processing CIN photo
❌ ML OCR service is not available: Connection refused
⚠️ ML OCR service not available - Skipping automatic verification
✅ CIN photo saved
✅ CIN VERIFICATION SUCCESS
```

**Notes:**
- Photo still saved for manual review
- User verification proceeds (manual verification required)
- Should notify admin for ML service restart

---

### 5. 📝 Direct ML Service Test

**Objective:** Test ML service independently of backend

**Steps:**

**a) Health Check:**
```bash
curl http://localhost:8000/health
```

**Expected:**
```json
{
  "status": "healthy",
  "service": "CIN OCR Service"
}
```

**b) OCR Extraction:**
```bash
curl -X POST "http://localhost:8000/ocr/cin" \
  -F "file=@test_cin.jpg" \
  -F "enhance=true"
```

**Expected:**
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
  "raw_text": "ROYAUME DU MAROC\n..."
}
```

**c) OCR Verification:**
```bash
curl -X POST "http://localhost:8000/ocr/verify?expected_cin=AB123456" \
  -F "file=@test_cin.jpg" \
  -F "enhance=true"
```

**Expected:**
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

---

### 6. 🌐 Frontend Integration Test

**Objective:** Test complete flow from Flutter app

**Steps:**

1. **Register User:**
   - Open Flutter app
   - Navigate to Register screen
   - Fill: email, username, password
   - Click Register

2. **Login:**
   - Enter credentials
   - Click Login
   - Should navigate to dashboard

3. **Navigate to Profile:**
   - Click profile icon
   - Should show user info

4. **Upload CIN:**
   - Click "Verify Identity"
   - Enter CIN number: AB123456
   - Select photo from gallery (or take photo)
   - Click "Submit"

5. **Wait for Processing:**
   - Should show loading indicator
   - Backend calls ML service
   - ML service processes image

6. **Verify Result:**
   - If success: Show "Identity Verified" badge
   - If fail: Show error message
   - Profile updates with verified status

**Expected UI Flow:**
```
Register → Login → Dashboard → Profile → Verify Identity
  ↓
Select CIN Photo → Enter CIN Number → Submit
  ↓
Loading... (ML Processing)
  ↓
Success! → Show Verified Badge → Navigate to Profile
```

---

## 📊 Test Data

### Sample CIN Numbers (for testing)
- AB123456 (standard format)
- K12345 (short format)
- XY654321 (standard format)
- M98765 (short format)

### Test Images Required

1. **High Quality CIN:**
   - Resolution: 1000x700px
   - Format: JPEG
   - Clear text, good lighting
   - No glare or shadows

2. **Low Quality CIN:**
   - Resolution: 300x200px
   - Blurry or out of focus
   - Poor lighting

3. **Rotated CIN:**
   - 90° rotation
   - Test orientation detection

4. **Non-CIN Image:**
   - Random document
   - Should fail extraction

---

## 🔍 Validation Checklist

After each test, verify:

### ML Service
- [ ] Receives request in logs
- [ ] Preprocesses image
- [ ] Extracts text with Tesseract
- [ ] Parses CIN format
- [ ] Returns structured JSON
- [ ] Confidence score calculated
- [ ] No exceptions or errors

### Backend
- [ ] Receives upload from frontend
- [ ] Checks ML service availability
- [ ] Sends image to ML service
- [ ] Validates extracted CIN
- [ ] Saves photo to disk
- [ ] Updates database
- [ ] Returns correct response
- [ ] Logs all steps

### Frontend
- [ ] Upload works smoothly
- [ ] Shows loading state
- [ ] Displays success/error message
- [ ] Updates profile with verified badge
- [ ] Handles errors gracefully

### Database
- [ ] User record updated
- [ ] identity_verified set correctly
- [ ] cin field populated
- [ ] cin_photo_path saved
- [ ] updated_at timestamp current

### Files
- [ ] CIN photo saved to: `./uploads/identity-scans/`
- [ ] Filename format: `cin_{userId}_{cin}_{uuid}.{ext}`
- [ ] File readable and not corrupted
- [ ] File size reasonable (< 10MB)

---

## 🐛 Common Issues

### Issue: Low OCR Accuracy

**Symptoms:**
- Confidence < 0.5
- Wrong CIN extracted
- "CIN not found" error

**Debug Steps:**
1. Check image quality:
```bash
curl -X POST "http://localhost:8000/ocr/cin" \
  -F "file=@test_cin.jpg" \
  -F "enhance=true" | jq
```

2. Review raw_text field for what Tesseract sees

3. Try with different image:
   - Better lighting
   - Higher resolution
   - Different background

**Solutions:**
- Use better camera
- Ensure good lighting
- Clean card surface
- Hold camera steady

### Issue: ML Service Connection Failed

**Symptoms:**
```
❌ ML OCR service is not available: Connection refused
```

**Debug Steps:**
1. Check if ML service is running:
```bash
curl http://localhost:8000/health
```

2. Check port 8000 is not blocked:
```bash
netstat -ano | findstr :8000  # Windows
lsof -i :8000                 # Linux/macOS
```

3. Check ML service logs for errors

**Solutions:**
- Start ML service: `cd ml && start.bat`
- Check firewall settings
- Verify Python dependencies installed

### Issue: CIN Photo Not Saved

**Symptoms:**
```
❌ Failed to save CIN photo
```

**Debug Steps:**
1. Check directory exists and writable:
```bash
ls -la ./uploads/identity-scans
```

2. Check disk space:
```bash
df -h  # Linux/macOS
dir   # Windows
```

3. Check file permissions

**Solutions:**
- Create directory manually: `mkdir -p ./uploads/identity-scans`
- Set write permissions: `chmod 755 ./uploads/identity-scans`
- Check disk space

---

## 📈 Performance Benchmarks

### Expected Timings

| Operation | Time |
|-----------|------|
| Image upload (2MB) | < 1s |
| ML preprocessing | 0.5-1s |
| Tesseract OCR | 1-2s |
| CIN parsing | < 0.1s |
| Backend processing | 0.5s |
| **Total end-to-end** | **2-5s** |

### Load Testing

Test with multiple concurrent requests:

```bash
# Install Apache Bench
sudo apt install apache2-utils  # Linux
brew install ab                  # macOS

# Run 100 requests, 10 concurrent
ab -n 100 -c 10 -p test_cin.jpg -T 'multipart/form-data' \
  http://localhost:8000/ocr/cin
```

**Expected:**
- Success rate: > 95%
- Average response time: < 3s
- No memory leaks
- CPU usage: < 80%

---

## ✅ Test Summary Template

Use this template to document your testing:

```
# CIN OCR Test Report

Date: [YYYY-MM-DD]
Tester: [Your Name]
Version: 1.0

## Test Environment
- ML Service: Running ✅ / Not Running ❌
- Backend: Running ✅ / Not Running ❌
- Frontend: Running ✅ / Not Running ❌
- Tesseract: Installed ✅ / Not Installed ❌

## Test Results

### 1. Successful Verification
Status: PASS ✅ / FAIL ❌
CIN Match: YES / NO
Confidence: [0.XX]
Notes: [Any observations]

### 2. CIN Mismatch
Status: PASS ✅ / FAIL ❌
Error Handled: YES / NO
Notes: [Any observations]

### 3. Poor Image Quality
Status: PASS ✅ / FAIL ❌
Error Message: [Message shown]
Notes: [Any observations]

### 4. ML Service Unavailable
Status: PASS ✅ / FAIL ❌
Fallback: WORKING / NOT WORKING
Notes: [Any observations]

### 5. Direct ML Service
Status: PASS ✅ / FAIL ❌
Health Check: OK / FAIL
OCR Extraction: OK / FAIL
Notes: [Any observations]

### 6. Frontend Integration
Status: PASS ✅ / FAIL ❌
Upload: WORKING / NOT WORKING
Verification: WORKING / NOT WORKING
Notes: [Any observations]

## Issues Found
1. [Issue description]
2. [Issue description]

## Overall Assessment
- Tests Passed: [X] / 6
- Tests Failed: [X] / 6
- Overall Status: READY FOR PRODUCTION / NEEDS FIXES

## Recommendations
- [Recommendation 1]
- [Recommendation 2]
```

---

## 🚀 Next Steps

After completing all tests:

1. **Document results** using template above
2. **Fix any issues** found during testing
3. **Re-test** failed scenarios
4. **Deploy to staging** environment
5. **Perform UAT** with real users
6. **Monitor production** logs and metrics

---

## 📞 Support

If you encounter issues:

1. Check logs (ML service, backend, frontend)
2. Review [ML_INTEGRATION_COMPLETE.md](../ML_INTEGRATION_COMPLETE.md)
3. Check [QUICK_START.md](QUICK_START.md) for troubleshooting
4. Test each component individually
5. Verify all dependencies installed

---

**Happy Testing!** 🧪🎉
