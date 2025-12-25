# Test Documents Dataset

This folder contains realistic test documents for testing the credit scoring application.

## 📄 Available Test Documents

### 1. Pay Slips (Recent 3 months)
- `payslip_1_octobre_2024.pdf` - October 2024
- `payslip_2_novembre_2024.pdf` - November 2024  
- `payslip_3_decembre_2024.pdf` - December 2024

**Content:** Moroccan pay slips with:
- Base salary: 12,000 MAD
- CNSS, AMO, CIMR deductions
- Net salary: ~10,200 MAD
- Company: Société Générale Maroc

### 2. Tax Declaration
- `tax_declaration_2024.pdf` - Annual 2024

**Content:** Moroccan tax declaration with:
- Gross annual income: 150,000 MAD
- Professional expenses deduction (20%)
- IR calculation
- Tax payments

### 3. Bank Statement
- `bank_statement_recent.pdf` - Last 30 days

**Content:** Bank account statement with:
- Account holder: Ahmed Benali
- Bank: Attijariwafa Bank
- Transactions: Salary, rent, bills, withdrawals
- Current balance: 20,230 MAD

## 🧪 How to Use for Testing

### 1. Upload Pay Slips (for Income Verification)
```
Document Type: PAY_SLIP
Files to upload:
  - payslip_1_octobre_2024.pdf
  - payslip_2_novembre_2024.pdf
  - payslip_3_decembre_2024.pdf
```

### 2. Upload Tax Declaration
```
Document Type: TAX_DECLARATION
File: tax_declaration_2024.pdf
```

### 3. Upload Bank Statement
```
Document Type: BANK_STATEMENT
File: bank_statement_recent.pdf
```

## 🎯 Test Scenarios

### Scenario 1: Complete Application (Good Credit)
```json
{
  "personal_info": {
    "name": "Ahmed Benali",
    "cin": "AB123456",
    "monthly_income": 12000,
    "employment_status": "employed"
  },
  "documents": {
    "pay_slips": 3,
    "tax_declaration": 1,
    "bank_statement": 1
  }
}
```

### Scenario 2: Moderate Income Application
```json
{
  "monthly_income": 8000,
  "requested_amount": 50000,
  "existing_loans": 15000
}
```

### Scenario 3: High Income Application
```json
{
  "monthly_income": 20000,
  "requested_amount": 150000,
  "existing_loans": 0
}
```

## 🔄 Regenerate Documents

To regenerate documents with different values:

```bash
cd test-documents
python generate_test_pdfs.py
```

Modify the script to change:
- Salary amounts
- Tax calculations
- Bank balances
- Employee names

## 📊 Expected Document Upload API

### Upload Endpoint
```
POST /api/documents/upload
```

### Request
```
Content-Type: multipart/form-data

file: [PDF file]
documentType: PAY_SLIP | TAX_DECLARATION | BANK_STATEMENT
applicationId: [optional] (Long)
Authorization: Bearer [JWT token]
```

### Response
```json
{
  "success": true,
  "message": "Document uploaded successfully",
  "data": {
    "id": 1,
    "fileName": "payslip_1_octobre_2024.pdf",
    "filePath": "./uploads/general/123456_abc123.pdf",
    "fileSize": 12345,
    "documentType": "PAY_SLIP",
    "uploadedAt": "2024-12-24T20:00:00"
  }
}
```

## 🔐 Test User Credentials

Use these test accounts:

```
User 1 (Regular):
Email: ahmed.benali@test.com
Password: Test123!
CIN: AB123456

User 2 (High Income):
Email: fatima.alami@test.com  
Password: Test123!
CIN: CD789012
```

## 📝 Notes

- All PDFs are generated with realistic Moroccan formats
- Amounts are in Moroccan Dirhams (MAD)
- Tax calculations follow Moroccan IR rules (simplified)
- CNSS and AMO rates are accurate as of 2024
- Documents include proper headers and signatures

## 🛠️ Troubleshooting

### Document Upload Fails
1. Check file size (max 10MB)
2. Verify file type is PDF
3. Ensure user is authenticated
4. Check backend logs for detailed errors

### Document Not Visible After Upload
1. Check `/api/documents/user/{userId}` endpoint
2. Verify documentType matches enum values
3. Check uploads directory permissions

## 📦 Directory Structure

```
test-documents/
├── README.md
├── generate_test_pdfs.py
├── payslip_1_octobre_2024.pdf
├── payslip_2_novembre_2024.pdf
├── payslip_3_decembre_2024.pdf
├── tax_declaration_2024.pdf
└── bank_statement_recent.pdf
```
