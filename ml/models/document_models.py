"""
Document Analysis Models for Financial Documents
Extracts and validates information from pay slips, tax declarations, and bank statements
"""
from pydantic import BaseModel
from typing import Optional, List, Dict
from datetime import datetime
from enum import Enum

class DocumentType(str, Enum):
    PAY_SLIP = "pay_slip"
    TAX_DECLARATION = "tax_declaration"
    BANK_STATEMENT = "bank_statement"
    INCOME_CONSISTENCY = "income_consistency"
    LOAN_PAYMENTS = "loan_payments"

class DocumentStatus(str, Enum):
    VALID = "valid"
    INVALID = "invalid"
    SUSPICIOUS = "suspicious"
    INCOMPLETE = "incomplete"

class PaySlipData(BaseModel):
    gross_salary: Optional[float] = None
    net_salary: Optional[float] = None
    employer_name: Optional[str] = None
    employee_name: Optional[str] = None
    month: Optional[str] = None
    year: Optional[int] = None
    cnss_deduction: Optional[float] = None
    ir_deduction: Optional[float] = None
    total_deductions: Optional[float] = None

class TaxDeclarationData(BaseModel):
    gross_annual_income: Optional[float] = None
    taxable_income: Optional[float] = None
    tax_paid: Optional[float] = None
    fiscal_year: Optional[int] = None
    taxpayer_name: Optional[str] = None
    fiscal_id: Optional[str] = None

class BankStatementData(BaseModel):
    account_holder: Optional[str] = None
    account_number: Optional[str] = None
    opening_balance: Optional[float] = None
    closing_balance: Optional[float] = None
    total_credits: Optional[float] = None
    total_debits: Optional[float] = None
    average_balance: Optional[float] = None
    num_transactions: Optional[int] = None
    period_start: Optional[str] = None
    period_end: Optional[str] = None

class DocumentAnalysisResult(BaseModel):
    document_type: DocumentType
    status: DocumentStatus
    confidence: float
    extracted_data: Dict
    validation_issues: List[str] = []
    score: float  # 0-100
    risk_flags: List[str] = []
    recommendations: List[str] = []

class CreditworthinessScore(BaseModel):
    overall_score: float  # 0-100
    income_score: float
    consistency_score: float
    debt_ratio_score: float
    document_quality_score: float
    rating: str  # "Excellent", "Good", "Fair", "Poor", "Rejected"
    decision: str  # "Approved", "Review", "Rejected"
    confidence: float
    risk_level: str  # "Low", "Medium", "High"
    monthly_income: float
    debt_to_income_ratio: float
    strengths: List[str]
    weaknesses: List[str]
    required_documents: List[str]
    missing_documents: List[str]
