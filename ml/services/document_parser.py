"""
Document Parser Service
Extracts text and data from financial documents (PDFs)
"""
import PyPDF2
import re
from typing import Dict, List, Optional
import logging
from models.document_models import (
    PaySlipData, TaxDeclarationData, BankStatementData,
    DocumentAnalysisResult, DocumentStatus, DocumentType
)

logger = logging.getLogger(__name__)

class DocumentParser:
    """Parse and extract information from financial documents"""
    
    def __init__(self):
        self.currency_patterns = [
            r'(\d+[,\s]*\d*\.?\d*)\s*(MAD|DH|Dhs)',
            r'(\d+[,\s]*\d*\.?\d*)',
        ]
        
    def extract_text_from_pdf(self, pdf_bytes: bytes) -> str:
        """Extract text from PDF file"""
        try:
            import io
            pdf_file = io.BytesIO(pdf_bytes)
            pdf_reader = PyPDF2.PdfReader(pdf_file)
            
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text() + "\n"
            
            return text
        except Exception as e:
            logger.error(f"Failed to extract text from PDF: {e}")
            return ""
    
    def parse_pay_slip(self, text: str) -> PaySlipData:
        """Parse pay slip document"""
        data = PaySlipData()
        
        # Extract salary information
        salary_patterns = [
            r'Salaire\s+de\s+Base[:\s]*(\d+[,\s]*\d*\.?\d*)',
            r'Total\s+Brut[:\s]*(\d+[,\s]*\d*\.?\d*)',
            r'NET\s+À\s+PAYER[:\s]*(\d+[,\s]*\d*\.?\d*)',
        ]
        
        for pattern in salary_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                value = float(match.group(1).replace(',', '').replace(' ', ''))
                if 'Brut' in pattern or 'Base' in pattern:
                    data.gross_salary = value
                elif 'NET' in pattern:
                    data.net_salary = value
        
        # Extract employer name
        employer_match = re.search(r'(SOCIETE|ENTREPRISE|BANK)[^\n]*', text, re.IGNORECASE)
        if employer_match:
            data.employer_name = employer_match.group(0).strip()
        
        # Extract month and year
        month_match = re.search(r'(Janvier|Février|Mars|Avril|Mai|Juin|Juillet|Août|Septembre|Octobre|Novembre|Décembre)\s+(\d{4})', text, re.IGNORECASE)
        if month_match:
            data.month = month_match.group(1)
            data.year = int(month_match.group(2))
        
        # Extract CNSS deduction
        cnss_match = re.search(r'CNSS[:\s]*[^\d]*(\d+[,\s]*\d*\.?\d*)', text, re.IGNORECASE)
        if cnss_match:
            data.cnss_deduction = float(cnss_match.group(1).replace(',', '').replace(' ', ''))
        
        # Extract IR deduction
        ir_match = re.search(r'IR[:\s]*[^\d]*(\d+[,\s]*\d*\.?\d*)', text, re.IGNORECASE)
        if ir_match:
            data.ir_deduction = float(ir_match.group(1).replace(',', '').replace(' ', ''))
        
        return data
    
    def parse_tax_declaration(self, text: str) -> TaxDeclarationData:
        """Parse tax declaration document"""
        data = TaxDeclarationData()
        
        # Extract annual income
        income_patterns = [
            r'Revenu\s+Brut\s+Global[:\s]*(\d+[,\s]*\d*\.?\d*)',
            r'Revenu\s+Net\s+Imposable[:\s]*(\d+[,\s]*\d*\.?\d*)',
        ]
        
        for pattern in income_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                value = float(match.group(1).replace(',', '').replace(' ', ''))
                if 'Brut' in pattern:
                    data.gross_annual_income = value
                elif 'Imposable' in pattern:
                    data.taxable_income = value
        
        # Extract tax paid
        tax_match = re.search(r'Impôt\s+sur\s+le\s+Revenu[:\s]*[^\d]*(\d+[,\s]*\d*\.?\d*)', text, re.IGNORECASE)
        if tax_match:
            data.tax_paid = float(tax_match.group(1).replace(',', '').replace(' ', ''))
        
        # Extract fiscal year
        year_match = re.search(r'Année\s+Fiscale[:\s]*(\d{4})', text, re.IGNORECASE)
        if year_match:
            data.fiscal_year = int(year_match.group(1))
        
        return data
    
    def parse_bank_statement(self, text: str) -> BankStatementData:
        """Parse bank statement document"""
        data = BankStatementData()
        
        # Extract account number
        account_match = re.search(r'N°?\s*Compte[:\s]*(\d+)', text, re.IGNORECASE)
        if account_match:
            data.account_number = account_match.group(1)
        
        # Extract balances
        balance_patterns = [
            r'Solde\s+Final[:\s]*(\d+[,\s]*\d*\.?\d*)',
            r'Solde[:\s]*(\d+[,\s]*\d*\.?\d*)',
        ]
        
        for pattern in balance_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                data.closing_balance = float(match.group(1).replace(',', '').replace(' ', ''))
                break
        
        # Extract account holder
        holder_match = re.search(r'Titulaire[:\s]*([^\n]+)', text, re.IGNORECASE)
        if holder_match:
            data.account_holder = holder_match.group(1).strip()
        
        return data
    
    def analyze_document(self, pdf_bytes: bytes, document_type: DocumentType) -> DocumentAnalysisResult:
        """Analyze document and return structured result"""
        text = self.extract_text_from_pdf(pdf_bytes)
        
        if not text or len(text) < 50:
            return DocumentAnalysisResult(
                document_type=document_type,
                status=DocumentStatus.INVALID,
                confidence=0.0,
                extracted_data={},
                validation_issues=["Failed to extract text from document"],
                score=0,
                risk_flags=["Unreadable document"],
                recommendations=["Upload a clearer, high-quality document"]
            )
        
        # Parse based on document type
        extracted_data = {}
        validation_issues = []
        score = 50  # Base score
        
        if document_type == DocumentType.PAY_SLIP:
            pay_slip = self.parse_pay_slip(text)
            extracted_data = pay_slip.dict()
            
            # Validate pay slip
            if not pay_slip.net_salary:
                validation_issues.append("Net salary not found")
                score -= 20
            if not pay_slip.employer_name:
                validation_issues.append("Employer name not found")
                score -= 10
            if pay_slip.net_salary and pay_slip.gross_salary:
                if pay_slip.net_salary > pay_slip.gross_salary:
                    validation_issues.append("Net salary greater than gross salary - suspicious")
                    score -= 30
            
            # Calculate deduction ratio
            if pay_slip.net_salary and pay_slip.gross_salary:
                deduction_ratio = (pay_slip.gross_salary - pay_slip.net_salary) / pay_slip.gross_salary
                if deduction_ratio > 0.40:
                    validation_issues.append("Unusually high deductions")
                    score -= 10
                elif deduction_ratio < 0.10:
                    validation_issues.append("Unusually low deductions")
                    score -= 5
                else:
                    score += 10
        
        elif document_type == DocumentType.TAX_DECLARATION:
            tax_decl = self.parse_tax_declaration(text)
            extracted_data = tax_decl.dict()
            
            # Validate tax declaration
            if not tax_decl.gross_annual_income:
                validation_issues.append("Annual income not found")
                score -= 20
            if not tax_decl.fiscal_year:
                validation_issues.append("Fiscal year not found")
                score -= 10
            if tax_decl.gross_annual_income and tax_decl.taxable_income:
                if tax_decl.taxable_income > tax_decl.gross_annual_income:
                    validation_issues.append("Taxable income exceeds gross income - suspicious")
                    score -= 30
        
        elif document_type == DocumentType.BANK_STATEMENT:
            bank_stmt = self.parse_bank_statement(text)
            extracted_data = bank_stmt.dict()
            
            # Validate bank statement
            if not bank_stmt.closing_balance:
                validation_issues.append("Balance not found")
                score -= 20
            if not bank_stmt.account_holder:
                validation_issues.append("Account holder not found")
                score -= 10
        
        # Determine status
        if score < 30:
            status = DocumentStatus.INVALID
        elif len(validation_issues) > 3:
            status = DocumentStatus.SUSPICIOUS
        elif len(validation_issues) > 0:
            status = DocumentStatus.INCOMPLETE
        else:
            status = DocumentStatus.VALID
            score += 20
        
        # Generate risk flags and recommendations
        risk_flags = []
        recommendations = []
        
        if validation_issues:
            risk_flags.extend(validation_issues)
            recommendations.append("Verify document authenticity")
        
        if score < 50:
            recommendations.append("Submit additional supporting documents")
        
        confidence = min(score / 100, 1.0)
        
        return DocumentAnalysisResult(
            document_type=document_type,
            status=status,
            confidence=confidence,
            extracted_data=extracted_data,
            validation_issues=validation_issues,
            score=max(0, min(100, score)),
            risk_flags=risk_flags,
            recommendations=recommendations
        )
