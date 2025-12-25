# 🎉 Test Dataset Ready!

## ✅ What's Been Created

### 📄 Financial Documents (5 PDFs)
1. **payslip_1_octobre_2024.pdf** - October 2024 pay slip
2. **payslip_2_novembre_2024.pdf** - November 2024 pay slip
3. **payslip_3_decembre_2024.pdf** - December 2024 pay slip
4. **tax_declaration_2024.pdf** - Annual tax declaration 2024
5. **bank_statement_recent.pdf** - Recent 30-day bank statement

### 🪪 Identity Documents (4 Images)
1. **test_cin_AB123456.jpg** - Test CIN for Ahmed Benali
2. **test_cin_CD789012.jpg** - Test CIN #2
3. **test_cin_EF345678.jpg** - Test CIN #3
4. **test_cin_GH901234.jpg** - Test CIN #4

---

## 🚀 Quick Start Commands

### Option 1: Start All Services Automatically
```bash
# Double-click this file:
start-all.bat
```

### Option 2: Start Services Manually

**Terminal 1 - ML Service:**
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\ml" && python main.py
```

**Terminal 2 - Backend:**
```bash
java -jar "d:\1 UNICA\Projet\ba\front-backup\backend\target\credit-scoring-backend-1.0.0.jar"
```

**Terminal 3 - Frontend:**
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\frontend" && flutter run -d chrome
```

---

## 🧪 Testing Workflow

### 1. Test CIN OCR
- Upload: `test_cin_AB123456.jpg`
- Enter CIN: `AB123456`
- **Expected:** ✅ ML extracts and verifies CIN

### 2. Upload Pay Slips (for Income Verification)
Upload all 3 files:
- `payslip_1_octobre_2024.pdf`
- `payslip_2_novembre_2024.pdf`
- `payslip_3_decembre_2024.pdf`

### 3. Upload Tax Declaration
- `tax_declaration_2024.pdf`

### 4. Submit Credit Application
Use test data:
- Income: 12,000 MAD/month
- Credit Amount: 50,000 MAD
- Monthly Payment: 2,000 MAD

---

## 📊 Test Data Details

### Employee Profile: Ahmed Benali
- **Monthly Salary:** 12,000 MAD (gross), ~10,200 MAD (net)
- **Annual Income:** 150,000 MAD
- **Bank Balance:** 20,230 MAD
- **Employment:** Société Générale Maroc
- **CIN:** AB123456

### Document Contents
- **Pay Slips:** Include CNSS, AMO, CIMR, IR deductions (realistic Moroccan format)
- **Tax Declaration:** Proper IR calculations following Moroccan tax law
- **Bank Statement:** Realistic transactions (salary, rent, bills, withdrawals)
- **CIN Cards:** Moroccan format with proper layout and barcode

---

## 🔗 Service Endpoints

| Service | URL | Health Check |
|---------|-----|--------------|
| ML Service | http://localhost:8000 | http://localhost:8000/health |
| Backend | http://localhost:8081 | http://localhost:8081/actuator/health |
| Frontend | Dynamic port | - |

---

## 📖 Documentation

- **Complete Testing Guide:** `test-documents/TESTING_GUIDE.md`
- **Dataset Details:** `test-documents/README.md`
- **Backend API Docs:** http://localhost:8081/swagger-ui.html

---

## ✅ Success Criteria

After testing, you should see:

✅ CIN extracted: `AB123456`  
✅ 3 pay slips uploaded  
✅ Tax declaration uploaded  
✅ Credit application submitted  
✅ ML prediction received  
✅ SHAP values displayed  

---

## 🛠️ Troubleshooting

### CIN OCR Not Working?
1. Check ML service is running: `curl http://localhost:8000/health`
2. Verify tesseract is installed
3. Check image quality

### Document Upload Failed?
1. Verify backend is running: `curl http://localhost:8081/actuator/health`
2. Check file size (max 10MB)
3. Ensure user is logged in
4. Check uploads directory exists

### Backend Can't Connect to ML?
- Check `application.properties`: `app.ml-service.url=http://localhost:8000`
- Verify ML service logs show "Application startup complete"

---

## 🎯 Next Steps

1. ✅ Generated test documents
2. 🔄 Start all services
3. 🧪 Test CIN OCR with `test_cin_AB123456.jpg`
4. 📄 Upload financial documents
5. 💳 Submit credit application
6. 📊 View prediction results

**Everything is ready for testing!** 🎉

See `TESTING_GUIDE.md` for detailed step-by-step instructions.
