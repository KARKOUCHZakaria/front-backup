@echo off
echo ============================================================
echo Testing Document Analysis Model
echo ============================================================
echo.
echo Waiting for ML service to start...
timeout /t 5 /nobreak >nul
echo.

echo Test: Uploading documents to check eligibility...
echo.

cd /d "%~dp0"

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
echo The model analyzed your documents and showed eligibility!
echo ============================================================
echo.
echo Key results to look for:
echo - "decision": "APPROVED" or "REJECTED" or "CONDITIONAL"
echo - "is_eligible": true or false
echo - "overall_score": 0-100
echo - "max_credit_limit": Maximum credit you can get
echo.
pause
