# Complete Testing Guide

## 📋 Test Dataset Overview

Your test dataset includes:

### 📄 Financial Documents
- ✅ **3 Pay Slips** (October, November, December 2024)
- ✅ **1 Tax Declaration** (Annual 2024)
- ✅ **1 Bank Statement** (Last 30 days)

### 🪪 Identity Documents
- ✅ **4 Test CIN Cards** (AB123456, CD789012, EF345678, GH901234)

---

## 🧪 Complete Testing Workflow

### Step 1: Start All Services

Open 3 separate terminals:

**Terminal 1 - ML Service:**
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\ml"
python main.py
```
✅ Running on: http://localhost:8000

**Terminal 2 - Backend Service:**
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\backend"
java -jar target\credit-scoring-backend-1.0.0.jar
```
✅ Running on: http://localhost:8081

**Terminal 3 - Frontend:**
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\frontend"
flutter run -d chrome
```
✅ Running on: http://localhost:[dynamic-port]

---

### Step 2: Test CIN OCR (Identity Verification)

#### 🔹 Test User Registration
1. Navigate to registration page
2. Fill in details:
   - **Name:** Ahmed Benali
   - **Email:** ahmed.benali@test.com
   - **Password:** Test123!
   - **CIN:** AB123456

3. Upload CIN photo:
   - Use: `test-documents/test_cin_AB123456.jpg`
   - **Expected:** ML service extracts "AB123456"
   - **Expected:** Backend verifies match ✅

#### 🔹 Check Logs

**ML Service Log:**
```
🔵 Received CIN OCR request - File: test_cin_AB123456.jpg
📷 Image loaded - X bytes
✅ Image preprocessed successfully
📄 Extracted text: X characters
✅ CIN data parsed - CIN: AB123456
```

**Backend Log:**
```
🔵 VERIFY CIN REQUEST - User ID: 1, CIN: AB123456
📸 Processing CIN photo
🤖 Using ML OCR to verify CIN from image
📤 Sending request to ML OCR: http://localhost:8000/ocr/cin
✅ ML OCR verification successful - CIN matches
✅ CIN photo saved
✅ CIN VERIFICATION SUCCESS
```

---

### Step 3: Test Document Upload

#### 🔹 Upload Pay Slips

1. Navigate to document upload section
2. Select "Income & Employment Verification"
3. Click "Upload" for "Recent Pay Slips"

**Upload these 3 files:**
```
test-documents/payslip_1_octobre_2024.pdf
test-documents/payslip_2_novembre_2024.pdf
test-documents/payslip_3_decembre_2024.pdf
```

**Expected Backend Response:**
```json
{
  "success": true,
  "message": "Document uploaded successfully",
  "data": {
    "id": 1,
    "documentType": "PAY_SLIP",
    "fileName": "payslip_1_octobre_2024.pdf",
    "fileSize": 12345,
    "uploadedAt": "2024-12-24T20:00:00"
  }
}
```

#### 🔹 Upload Tax Declaration

1. Click "Upload" for "Tax Declaration"
2. Select file:
```
test-documents/tax_declaration_2024.pdf
```

**Expected:** Document uploaded with type: `TAX_DECLARATION`

#### 🔹 Upload Bank Statement

1. If available, upload bank statement
2. Select file:
```
test-documents/bank_statement_recent.pdf
```

**Expected:** Document uploaded with type: `BANK_STATEMENT`

---

### Step 4: Verify Uploaded Documents

#### Check Backend Endpoint:
```bash
curl -H "Authorization: Bearer [YOUR_JWT_TOKEN]" \
  http://localhost:8081/api/documents/user/1
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "documentType": "PAY_SLIP",
      "fileName": "payslip_1_octobre_2024.pdf",
      "uploadedAt": "2024-12-24T20:00:00"
    },
    {
      "id": 2,
      "documentType": "PAY_SLIP",
      "fileName": "payslip_2_novembre_2024.pdf",
      "uploadedAt": "2024-12-24T20:05:00"
    },
    ...
  ]
}
```

---

### Step 5: Submit Credit Application

#### Fill Application Form:
```json
{
  "amtIncomeTotal": 12000,
  "amtCredit": 50000,
  "amtAnnuity": 2000,
  "cntChildren": 1,
  "nameEducationType": "Higher education",
  "nameIncomeType": "Working",
  "flagOwnCar": "Y",
  "flagOwnRealty": "Y"
}
```

**Expected Flow:**
1. ✅ Frontend sends application to backend
2. ✅ Backend validates and saves application
3. ✅ Backend calls ML service for credit scoring
4. ✅ ML service returns prediction + SHAP values
5. ✅ Backend saves prediction result
6. ✅ Frontend displays result with explanation

---

## 🎯 Test Scenarios

### Scenario 1: Low Risk Applicant ✅
```
Income: 12,000 MAD
Credit Requested: 50,000 MAD
Monthly Payment: 2,000 MAD
Debt-to-Income: 16.7%
Documents: All uploaded

Expected: APPROVED (High confidence)
```

### Scenario 2: Medium Risk Applicant ⚠️
```
Income: 8,000 MAD
Credit Requested: 80,000 MAD
Monthly Payment: 3,500 MAD
Debt-to-Income: 43.75%
Documents: Partial

Expected: REVIEW REQUIRED
```

### Scenario 3: High Risk Applicant ❌
```
Income: 6,000 MAD
Credit Requested: 100,000 MAD
Monthly Payment: 4,000 MAD
Debt-to-Income: 66.7%
Documents: Missing

Expected: REJECTED (High confidence)
```

---

## 🔍 Debugging Tips

### ML Service Not Responding
```bash
# Check if ML service is running
curl http://localhost:8000/health

# Expected response:
# {"status":"healthy","service":"cin-ocr","version":"1.0.0"}
```

### Backend Not Connecting to ML
```bash
# Check backend logs for:
❌ ML OCR service is not available

# Verify ML service URL in application.properties:
app.ml-service.url=http://localhost:8000
```

### Document Upload Fails
```bash
# Check uploads directory exists:
ls -la ./uploads/general/
ls -la ./uploads/identity-scans/

# Create if missing:
mkdir -p uploads/general
mkdir -p uploads/identity-scans
```

### CIN OCR Not Working
1. Ensure ML service has tesseract installed
2. Check image quality (min 640x400 pixels)
3. Verify CIN number is clearly visible
4. Check ML logs for OCR errors

---

## 📊 Expected Results Summary

| Test | Expected Result | Verification |
|------|----------------|--------------|
| ML Service Health | ✅ Status: healthy | `curl localhost:8000/health` |
| Backend Health | ✅ Status: UP | `curl localhost:8081/actuator/health` |
| CIN OCR | ✅ Extracts AB123456 | Check ML logs |
| Pay Slip Upload | ✅ 3 files saved | Check database/logs |
| Tax Declaration Upload | ✅ File saved | Check database/logs |
| Credit Application | ✅ Prediction returned | Check response |
| SHAP Explanation | ✅ Feature importance | Check UI/response |

---

## 🗂️ Test Files Location

```
d:/1 UNICA/Projet/ba/front-backup/test-documents/
├── README.md (this file)
├── TESTING_GUIDE.md (complete guide)
├── generate_test_pdfs.py
├── generate_cin_images.py
├── payslip_1_octobre_2024.pdf
├── payslip_2_novembre_2024.pdf
├── payslip_3_decembre_2024.pdf
├── tax_declaration_2024.pdf
├── bank_statement_recent.pdf
├── test_cin_AB123456.jpg
├── test_cin_CD789012.jpg
├── test_cin_EF345678.jpg
└── test_cin_GH901234.jpg
```

---

## ✅ Success Checklist

- [ ] All 3 services running (ML, Backend, Frontend)
- [ ] ML service health check passes
- [ ] Backend health check passes
- [ ] CIN OCR extracts number correctly
- [ ] Pay slips upload successfully (3 files)
- [ ] Tax declaration uploads successfully
- [ ] Documents visible in UI
- [ ] Credit application submission works
- [ ] ML prediction returns result
- [ ] SHAP values displayed correctly
- [ ] All logs show ✅ success messages

---

## 🎉 You're Ready to Test!

All test documents are generated and ready to use. Follow the workflow above to test the complete application flow from registration to credit decision.
