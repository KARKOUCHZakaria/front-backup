# Document Analysis Model - Complete Guide

## 🎯 Overview

This ML service analyzes financial documents (pay slips, tax declarations, bank statements) and provides **automated credit eligibility decisions** based on:
- Income verification
- Employment stability
- Tax compliance
- Cash flow analysis
- Financial health scoring

## 📋 What the Model Does

The model reads your financial documents and **automatically determines if you're eligible for credit** by:

1. **Extracting Key Information**:
   - Pay Slips: Gross/net salary, deductions (CNSS, AMO, CIMR, IR), employment details
   - Tax Declarations: Annual income, taxable income, tax paid, compliance
   - Bank Statements: Balance, credits, debits, cash flow patterns

2. **Calculating Scores** (0-100):
   - **Salary Score**: Based on monthly income level
   - **Stability Score**: Employment consistency
   - **Compliance Score**: Tax payment history
   - **Balance Score**: Bank account health
   - **Cash Flow Score**: Savings and spending patterns

3. **Making Credit Decisions**:
   - **APPROVED**: Score ≥ 70, income ≥ 3,000 MAD
   - **CONDITIONAL**: Score 60-69, income ≥ 3,000 MAD (requires guarantees)
   - **REJECTED**: Score < 60 or income < 3,000 MAD

## 🚀 Quick Start

### Step 1: Start the ML Service

**Windows**:
```bash
start-ml-service.bat
```

**Linux/Mac**:
```bash
cd ml
python main.py
```

The service will start on **http://localhost:8000**

### Step 2: Test with Sample Documents

We've generated realistic test documents for you:

```
test-documents/
├── payslip_1_octobre_2024.pdf      # October salary: 12,000 MAD
├── payslip_2_novembre_2024.pdf     # November salary: 12,000 MAD
├── payslip_3_decembre_2024.pdf     # December salary: 12,000 MAD
├── tax_declaration_2024.pdf        # Annual income: 150,000 MAD
├── bank_statement_recent.pdf       # Balance: 20,230 MAD
└── test_cin_AB123456.jpg           # CIN card image
```

### Step 3: Test the API

**Option A: Using the Test Script (Windows)**:
```bash
cd test-documents
test-api.bat
```

**Option B: Using curl (Any OS)**:
```bash
# Health Check
curl http://localhost:8000/health

# Analyze Single Document
curl -X POST http://localhost:8000/documents/analyze \
  -F "file=@payslip_1_octobre_2024.pdf" \
  -F "document_type=PAY_SLIP"

# Complete Credit Evaluation
curl -X POST http://localhost:8000/documents/evaluate-creditworthiness \
  -F "pay_slip_1=@payslip_1_octobre_2024.pdf" \
  -F "pay_slip_2=@payslip_2_novembre_2024.pdf" \
  -F "pay_slip_3=@payslip_3_decembre_2024.pdf" \
  -F "tax_declaration=@tax_declaration_2024.pdf" \
  -F "bank_statement=@bank_statement_recent.pdf" \
  -F "requested_credit=50000" \
  -F "monthly_payment=2000"
```

## 📊 API Endpoints

### 1. Health Check
```http
GET /health
```

**Response**:
```json
{
  "status": "healthy",
  "service": "Credit Scoring ML Service"
}
```

### 2. Analyze Single Document
```http
POST /documents/analyze
```

**Parameters**:
- `file`: PDF file (multipart/form-data)
- `document_type`: PAY_SLIP | TAX_DECLARATION | BANK_STATEMENT

**Response Example** (Pay Slip):
```json
{
  "document_type": "PAY_SLIP",
  "valid": true,
  "extracted_data": {
    "employee_name": "Ahmed Benali",
    "company": "TECH SOLUTIONS MAROC",
    "pay_period": "Octobre 2024",
    "gross_salary": 14500.00,
    "net_salary": 12000.00,
    "deductions": {
      "cnss": 800.00,
      "amo": 350.00,
      "cimr": 600.00,
      "ir": 750.00
    }
  },
  "scores": {
    "salary_score": 75,
    "stability_score": 85
  },
  "monthly_income": 12000.00,
  "rating": "GOOD",
  "issues": []
}
```

### 3. Evaluate Creditworthiness (Multiple Documents)
```http
POST /documents/evaluate-creditworthiness
```

**Parameters**:
- `pay_slip_1`: PDF file (optional)
- `pay_slip_2`: PDF file (optional)
- `pay_slip_3`: PDF file (optional)
- `tax_declaration`: PDF file (optional)
- `bank_statement`: PDF file (optional)
- `requested_credit`: float (default: 0)
- `monthly_payment`: float (default: 0)

**Response Example**:
```json
{
  "overall_score": 78.5,
  "rating": "VERY_GOOD",
  "decision": "APPROVED",
  "decision_reason": "Good financial profile",
  "is_eligible": true,
  "monthly_income": 12000.00,
  "debt_to_income_ratio": 0.167,
  "max_credit_limit": 132000.00,
  "requested_credit": 50000.00,
  "monthly_payment": 2000.00,
  "document_scores": {
    "pay_slip": 80.0,
    "tax_declaration": 78.0,
    "bank_statement": 75.0
  },
  "recommendations": [],
  "analysis_date": "2024-12-24T21:00:00"
}
```

## 🎯 Scoring System

### Overall Score Calculation
```
Overall Score = (Pay Slip × 40%) + (Tax Declaration × 35%) + (Bank Statement × 25%)
```

### Rating Scale
- **90-100**: EXCELLENT - Top creditworthiness
- **80-89**: VERY_GOOD - Strong financial profile
- **70-79**: GOOD - Reliable borrower
- **60-69**: FAIR - Acceptable with conditions
- **50-59**: POOR - High risk
- **0-49**: VERY_POOR - Rejected

### Eligibility Criteria
✅ **APPROVED** if:
- Overall Score ≥ 70
- Monthly Income ≥ 3,000 MAD
- Debt-to-Income Ratio ≤ 40%

⚠️ **CONDITIONAL** if:
- Overall Score 60-69
- Monthly Income ≥ 3,000 MAD
- May require co-signer or additional guarantees

❌ **REJECTED** if:
- Overall Score < 60
- Monthly Income < 3,000 MAD
- Debt-to-Income Ratio > 40%

### Maximum Credit Limit Calculation
```
Base Credit = Monthly Income × 10

Multiplier:
- Score ≥ 90: 1.5x (150% of base)
- Score 80-89: 1.3x (130% of base)
- Score 70-79: 1.1x (110% of base)
- Score 60-69: 0.9x (90% of base)
- Score < 60: 0.5x (50% of base)
```

**Example**:
- Monthly Income: 12,000 MAD
- Score: 78 (VERY_GOOD)
- Max Credit = 12,000 × 10 × 1.1 = **132,000 MAD**

## 📝 Document Requirements

### Pay Slip (Bulletin de Paie)
Must contain:
- ✅ Employee name and company
- ✅ Gross salary (Salaire Brut)
- ✅ Net salary (Net à Payer)
- ✅ Deductions (CNSS, AMO, CIMR, IR)
- ✅ Pay period (month/year)

### Tax Declaration (Déclaration Fiscale)
Must contain:
- ✅ Taxpayer identification
- ✅ Annual income (Revenu Global)
- ✅ Taxable income (Revenu Imposable)
- ✅ Tax paid (Impôt payé)
- ✅ Fiscal year

### Bank Statement (Relevé Bancaire)
Must contain:
- ✅ Account holder name
- ✅ Account number
- ✅ Transaction history
- ✅ Credits (incoming)
- ✅ Debits (outgoing)
- ✅ Final balance (Solde Final)

## 🧪 Testing Scenarios

### Scenario 1: Strong Profile (Approved)
```bash
Monthly Income: 12,000 MAD
Annual Income: 150,000 MAD
Bank Balance: 20,230 MAD

Expected Result:
- Score: 78-82
- Decision: APPROVED
- Max Credit: ~132,000 MAD
```

### Scenario 2: Moderate Profile (Conditional)
```bash
Monthly Income: 8,000 MAD
Annual Income: 100,000 MAD
Bank Balance: 8,000 MAD

Expected Result:
- Score: 62-68
- Decision: CONDITIONAL
- Max Credit: ~72,000 MAD
```

### Scenario 3: Weak Profile (Rejected)
```bash
Monthly Income: 2,500 MAD
Annual Income: 35,000 MAD
Bank Balance: 1,200 MAD

Expected Result:
- Score: 45-55
- Decision: REJECTED
- Reason: Insufficient income
```

## 🔧 Integration with Backend

The backend automatically calls the ML service when documents are uploaded:

```java
// Backend: DocumentController.java
@PostMapping("/upload")
public ResponseEntity<?> uploadDocument(@RequestParam("file") MultipartFile file) {
    // Save document
    Document doc = documentService.save(file);
    
    // Call ML service for analysis
    MLAnalysisResult analysis = mlService.analyzeDocument(file, doc.getType());
    
    // Store analysis results
    doc.setAnalysisScore(analysis.getScore());
    doc.setEligibilityDecision(analysis.getDecision());
    
    return ResponseEntity.ok(doc);
}
```

## 📈 Response Time

- **Single Document**: ~1-2 seconds
- **Complete Evaluation (5 docs)**: ~3-5 seconds

## 🐛 Troubleshooting

### ML Service Won't Start
```bash
# Check if port 8000 is in use
netstat -ano | findstr :8000

# Install missing dependencies
cd ml
pip install -r requirements.txt
```

### "Failed to extract text from PDF"
- Ensure PDF is not encrypted
- Verify PDF contains actual text (not just images)
- Check file size (< 10MB recommended)

### "Invalid document type"
Valid types:
- `PAY_SLIP`
- `TAX_DECLARATION`
- `BANK_STATEMENT`

Case-sensitive! Use uppercase.

## 🎯 Next Steps

1. ✅ **Test the API** with provided sample documents
2. ✅ **Integrate with backend** - Backend calls ML endpoints after document upload
3. ✅ **Update frontend** - Display analysis results and credit decisions
4. 📊 **View results** - Check creditworthiness scores and eligibility

## 📞 Support

For issues or questions:
1. Check the logs in ML terminal
2. Verify all services are running:
   - ML Service: http://localhost:8000/health
   - Backend: http://localhost:8081/actuator/health
   - Frontend: http://localhost:3000 (Flutter)

---

**Ready to test?** Run `start-ml-service.bat` and then `test-documents/test-api.bat`!
