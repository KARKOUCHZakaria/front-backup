@echo off
cd /d "%~dp0"
echo ============================================================
echo Testing Document Analysis API
echo ============================================================
echo.

echo Test 1: Health Check
curl -X GET http://localhost:8000/health
echo.
echo.

echo Test 2: Analyze Pay Slip
curl -X POST http://localhost:8000/documents/analyze ^
  -F "file=@payslip_1_octobre_2024.pdf" ^
  -F "document_type=PAY_SLIP"
echo.
echo.

echo Test 3: Complete Creditworthiness Evaluation  
curl -X POST http://localhost:8000/documents/evaluate-creditworthiness ^
  -F "pay_slip_1=@payslip_1_octobre_2024.pdf" ^
  -F "pay_slip_2=@payslip_2_novembre_2024.pdf" ^
  -F "pay_slip_3=@payslip_3_decembre_2024.pdf" ^
  -F "tax_declaration=@tax_declaration_2024.pdf" ^
  -F "bank_statement=@bank_statement_recent.pdf" ^
  -F "requested_credit=50000" ^
  -F "monthly_payment=2000"
echo.
echo.

echo ============================================================
echo Tests Complete!
echo ============================================================
pause
