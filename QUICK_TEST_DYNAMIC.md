# Quick Test Guide - Dynamic Dashboard & Varied ML Scores

## 🎯 Goal
Test that dashboard shows **real data from ML models** with **different scores** for different financial profiles.

## 🚀 Quick Start (3 Terminals)

### Terminal 1: Backend
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\backend"
mvn spring-boot:run
```
**Wait for:** `Started CreditScoringApplication`

### Terminal 2: ML Service
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\ml"
python main.py
```
**Wait for:** `Uvicorn running on http://0.0.0.0:8000`

### Terminal 3: Frontend
```bash
cd "d:\1 UNICA\Projet\ba\front-backup\frontend"
flutter run -d chrome
```
**Wait for:** Chrome browser opens with app

## 📊 Test Scenario: Different Scores for Different Profiles

### Test 1: Excellent Profile (Expected: 90-100 score)
1. Login/Register
2. Go to "Documents" or "New Application"
3. Upload these files:
   - 📄 `test-documents/excellent_income_consistency.xlsx`
   - 📄 `test-documents/excellent_loan_history.xlsx`
   - 📄 `test-documents/payslip_excellent_senior.pdf`
4. Submit application
5. Go to **Dashboard** → Check:
   - Credit score updated (should be ~750-850)
   - Recent Activity shows this application
6. Go to **Application History** → Check:
   - New application appears at top
   - Loan amount displayed

### Test 2: Poor Profile (Expected: 40-60 score)
1. Create new application
2. Upload:
   - 📄 `test-documents/poor_loan_history.xlsx`
   - 📄 `test-documents/fair_income_inconsistent.xlsx`
3. Submit
4. Go to **Dashboard** → Check:
   - Credit score different from Test 1
   - Recent Activity shows both applications
5. **Verify**: Two different scores for two profiles!

### Test 3: Fair Profile (Expected: 55-70 score)
1. Create new application
2. Upload:
   - 📄 `test-documents/fair_income_inconsistent.xlsx`
   - 📄 `test-documents/payslip_fair_entry_level.pdf`
3. Submit
4. Dashboard should show:
   - Different score again
   - All 3 applications in Recent Activity

## ✅ Success Criteria

### Dashboard (`/user/dashboard`):
- [ ] Credit score changes based on uploaded documents
- [ ] Credit score NOT always 785 (was hardcoded)
- [ ] "Recent Activity" shows real applications (not Chase Bank, American Express, Citi Bank)
- [ ] Application amounts match uploaded profiles
- [ ] Dates show actual submission dates (Today, Yesterday, etc.)
- [ ] Status badges show correct status (Approved, Pending, Rejected)

### Application History (`/user/applications`):
- [ ] All applications displayed (not just 3 hardcoded ones)
- [ ] Sorted by date (newest first)
- [ ] Dates not stuck at "Dec 13, 2025", "Nov 28, 2025", "Oct 15, 2025"
- [ ] Loan amounts match uploaded profiles
- [ ] Application numbers shown
- [ ] Refresh button works (invalidates cache, refetches data)

### ML Model Scoring:
- [ ] Excellent profile → score ~90-100
- [ ] Good profile → score ~75-85
- [ ] Fair profile → score ~55-70
- [ ] Poor profile → score ~40-60
- [ ] Different uploads = different scores (variance confirmed)

## 🔍 Debugging

### If Dashboard Still Shows 785:
1. Check browser console: F12 → Console tab
2. Look for API call: `GET http://localhost:8081/api/applications/user/1`
3. Check response: Should have `success: true, data: [...]`
4. If empty array: No applications in database yet
5. If error: Backend not running or CORS issue

### If Recent Activity Shows Chase Bank:
- **Problem**: Old static data still showing
- **Solution**: Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)

### If ML Scores All Same:
1. Check ML service logs: Should show `/score/cin`, `/score/payslip`, etc.
2. Verify test files uploaded correctly
3. Check file content: `open test-documents/excellent_income_consistency.xlsx`
4. Ensure different profiles: Excellent (18K MAD) vs Poor (8 late payments)

### If Application History Empty:
1. Check if applications submitted successfully
2. Look for submission confirmation in app
3. Check backend logs: `✅ APPLICATION SAVED`
4. Query database: `SELECT * FROM credit_applications;`

## 📁 Test Files Location
```
test-documents/
├── excellent_income_consistency.xlsx    # 18K MAD x 6 months
├── excellent_loan_history.xlsx          # 36/36 on-time payments
├── payslip_excellent_senior.pdf         # 20K gross salary
├── good_income_consistency.xlsx         # 8.5K MAD x 3 months
├── fair_income_inconsistent.xlsx        # Irregular 4.5-5.8K MAD
├── payslip_fair_entry_level.pdf         # 3.5K gross salary
└── poor_loan_history.xlsx               # 8 late payments
```

## 🎥 Video Proof of Dynamic Data
Record screen showing:
1. Upload excellent profile → Dashboard shows score X
2. Upload poor profile → Dashboard shows score Y (different!)
3. Application history shows both with different amounts
4. Refresh button updates data

## 📝 Expected Console Output

### Backend (Terminal 1):
```
🔵 SUBMIT APPLICATION - User ID: 1
✅ APPLICATION SAVED - Application ID: 1, Status: PENDING
🔵 GET USER APPLICATIONS - User ID: 1
✅ Found 1 applications for User ID: 1
```

### ML Service (Terminal 2):
```
INFO: POST /score/cin - Score: 93.28
INFO: POST /score/payslip - Score: 98.80
INFO: POST /score/bank - Score: 83.97
```

### Frontend (Terminal 3 / Browser Console):
```
🔵 Fetching applications from: http://localhost:8081/api/applications/user/1
📡 Response status: 200
✅ Found 2 applications
```

## 🎉 Success!
When you see:
- Dashboard credit score changes with each upload
- Application history grows with real data
- ML scores vary by profile (excellent=90, poor=50)

**You have confirmed**: Dashboard is now DYNAMIC with real ML model results!
