# Quick Testing Guide

## ✅ Generated Test Files

### XLSX Files (Financial Documents)
Located in `test-documents/`

1. **income_consistency_3months.xlsx**
   - Bank statement with 3 months of salary deposits
   - Employee: Ahmed Benali
   - Monthly salary: 12,000 MAD
   - Total 3-month income: 36,000 MAD
   - Multiple expense transactions included
   - Use for: "Income Consistency" document upload

2. **loan_payment_history.xlsx**
   - 24 months of mortgage payment history
   - Loan: 500,000 MAD (20 years @ 4.25%)
   - Monthly payment: 3,096.17 MAD
   - Excellent payment record (1 minor 2-day delay)
   - Use for: "Loan Payments" document upload

### PDF Files
Generate with: `python generate_test_pdfs.py`
- Pay slips (3 months)
- Tax declarations
- Bank statements

### CIN Images
Generate with: `python generate_cin_images.py`
- Test CIN numbers: AB123456, CD789012, EF345678, GH901234

## 🚨 CIN Verification Issue - TESSERACT

### Problem
```
Failed to extract text: tesseract is not installed
```

### Quick Solutions

**Option 1: Install Tesseract (Recommended)**
1. Download: https://github.com/UB-Mannheim/tesseract/wiki
2. Install to: `C:\Program Files\Tesseract-OCR`
3. Restart ML service: `cd ml && python main.py`
4. See `ml/TESSERACT_SETUP.md` for full instructions

**Option 2: Disable OCR Verification (Testing Only)**
1. Edit `backend/src/main/java/com/ethicalai/creditscoring/controller/AuthController.java`
2. Line ~96, change:
   ```java
   boolean ocrAvailable = cinOcrService.isOcrServiceAvailable();
   ```
   to:
   ```java
   boolean ocrAvailable = false;  // Skip OCR for testing
   ```
3. Rebuild & restart backend:
   ```cmd
   cd backend
   mvn clean package -DskipTests
   java -jar target\credit-scoring-backend-1.0.0.jar
   ```

## 📋 Complete Testing Workflow

### 1. Start All Services
```cmd
cd "d:\1 UNICA\Projet\ba\front-backup"
start-all.bat
```

Or manually:
```cmd
# Terminal 1 - ML Service
cd ml
python main.py

# Terminal 2 - Backend
cd backend
java -jar target\credit-scoring-backend-1.0.0.jar

# Terminal 3 - Frontend
cd frontend
flutter run -d chrome
```

### 2. Test Document Uploads

**Step 1: Register User**
- Email: test@example.com
- Password: Test123!
- CIN: AB123456 (or any from generated CINs)
- Upload CIN photo (if OCR disabled, any image works)

**Step 2: Complete Profile**
- Phone: +212612345678
- Country: Morocco

**Step 3: Upload Financial Documents**

Income Documents:
- ✅ Pay Slip (3 months) → Use generated PDFs
- ✅ Tax Declaration → Use generated PDFs
- ✅ **Income Consistency** → Use `income_consistency_3months.xlsx` ⭐

Financial Documents:
- Bank statements → Use generated PDFs

Loan History:
- ✅ **Loan Payments** → Use `loan_payment_history.xlsx` ⭐

### 3. Verify Model Scoring

Once documents uploaded, the backend should call:
```
POST http://localhost:8000/score/cin
POST http://localhost:8000/score/payslip
POST http://localhost:8000/score/tax
POST http://localhost:8000/score/bank
```

Each returns a score 0-100 based on the trained models.

## 🔍 Troubleshooting

### XLSX Upload Error
- ✅ Fixed - Now supports bytes on web
- Make sure files are < 10MB
- Verify `.xlsx` extension

### CIN Verification Failed
- Install Tesseract OR disable OCR (see above)
- Check ML service is running on port 8000
- Verify backend can reach `http://localhost:8000`

### Document Upload Stuck
- Check browser console for errors
- Verify all services are running
- Check backend logs: `backend/logs/application.log`

## 📊 Expected Results

After uploading all documents with the test files:

1. **Income Consistency**: Score ~95-100
   - 3 months of consistent 12,000 MAD salary
   - Regular income pattern

2. **Loan History**: Score ~95-100
   - 24 months on-time payments
   - Only 1 minor delay
   - Good payment discipline

3. **Overall Credit Score**: 85-95
   - Based on all uploaded documents
   - Moroccan financial context applied

## 🎯 Test Scenarios

### Scenario 1: Perfect Applicant
- Use all generated test files
- All documents complete
- Expected: High approval score (90+)

### Scenario 2: Self-Employed
- Toggle "Self-Employed" option
- Additional business documents required
- Expected: Different scoring criteria

### Scenario 3: Missing Documents
- Upload only some documents
- Expected: Lower score, warnings

## 📁 File Locations

```
test-documents/
├── income_consistency_3months.xlsx     ⭐ NEW
├── loan_payment_history.xlsx          ⭐ NEW
├── generate_test_xlsx.py               ⭐ NEW
├── generate_test_pdfs.py
├── generate_cin_images.py
└── *.pdf (generated)

ml/
├── TESSERACT_SETUP.md                  ⭐ NEW
├── main.py
└── models/scored/
    ├── cin_model.pkl
    ├── payslip_model.pkl
    ├── tax_model.pkl
    └── bank_model.pkl
```

## 🚀 Next Steps

1. Install Tesseract (5 minutes)
2. Generate test XLSX files (done!)
3. Test document upload flow
4. Verify ML model scoring
5. Check credit application results

**For detailed Tesseract setup**: See `ml/TESSERACT_SETUP.md`
