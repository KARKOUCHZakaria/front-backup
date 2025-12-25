"""
Document Credit Scoring Service
Analyzes multiple documents and provides creditworthiness rating
"""
from typing import List, Dict
import logging
from models.document_models import (
    DocumentAnalysisResult, CreditworthinessScore, DocumentType
)

logger = logging.getLogger(__name__)

class DocumentCreditScorer:
    """Score creditworthiness based on analyzed documents"""
    
    def __init__(self):
        self.min_required_documents = {
            'pay_slips': 2,  # At least 2 recent pay slips
            'tax_declaration': 1,
            'bank_statement': 0  # Optional but recommended
        }
    
    def calculate_income_score(self, documents: List[DocumentAnalysisResult]) -> tuple[float, Dict]:
        """Calculate income stability and level score"""
        pay_slips = [d for d in documents if d.document_type == DocumentType.PAY_SLIP]
        tax_declarations = [d for d in documents if d.document_type == DocumentType.TAX_DECLARATION]
        
        income_score = 0
        income_data = {
            'monthly_income': 0,
            'annual_income': 0,
            'income_sources': 0
        }
        
        if pay_slips:
            # Extract net salaries
            salaries = []
            for ps in pay_slips:
                net_sal = ps.extracted_data.get('net_salary')
                if net_sal:
                    salaries.append(net_sal)
            
            if salaries:
                avg_salary = sum(salaries) / len(salaries)
                income_data['monthly_income'] = avg_salary
                
                # Score based on income level (Moroccan context)
                if avg_salary >= 15000:
                    income_score += 40  # High income
                elif avg_salary >= 10000:
                    income_score += 30  # Good income
                elif avg_salary >= 7000:
                    income_score += 20  # Moderate income
                elif avg_salary >= 4000:
                    income_score += 10  # Low income
                else:
                    income_score += 5   # Very low income
                
                # Income consistency bonus
                if len(salaries) >= 2:
                    variance = max(salaries) - min(salaries)
                    consistency_ratio = variance / avg_salary if avg_salary > 0 else 1
                    
                    if consistency_ratio < 0.05:  # Very consistent
                        income_score += 20
                    elif consistency_ratio < 0.15:  # Consistent
                        income_score += 15
                    elif consistency_ratio < 0.25:  # Moderately consistent
                        income_score += 10
                    else:  # Inconsistent
                        income_score += 5
        
        if tax_declarations:
            for td in tax_declarations:
                annual = td.extracted_data.get('gross_annual_income')
                if annual:
                    income_data['annual_income'] = annual
                    income_score += 10  # Bonus for having tax declaration
        
        return min(income_score, 100), income_data
    
    def calculate_consistency_score(self, documents: List[DocumentAnalysisResult]) -> float:
        """Calculate document consistency and quality score"""
        if not documents:
            return 0
        
        consistency_score = 0
        
        # Quality of documents
        valid_docs = [d for d in documents if d.status.value == 'valid']
        consistency_score += (len(valid_docs) / len(documents)) * 40
        
        # Average document score
        avg_doc_score = sum(d.score for d in documents) / len(documents)
        consistency_score += (avg_doc_score / 100) * 30
        
        # Average confidence
        avg_confidence = sum(d.confidence for d in documents) / len(documents)
        consistency_score += avg_confidence * 30
        
        return min(consistency_score, 100)
    
    def calculate_debt_ratio_score(self, monthly_income: float, requested_credit: float = 0,
                                   monthly_payment: float = 0) -> tuple[float, float]:
        """Calculate debt-to-income ratio score"""
        if monthly_income <= 0:
            return 0, 0
        
        # Calculate debt-to-income ratio
        debt_ratio = (monthly_payment / monthly_income) * 100 if monthly_income > 0 else 100
        
        # Score based on debt ratio
        if debt_ratio <= 25:
            score = 100  # Excellent
        elif debt_ratio <= 33:
            score = 80   # Good
        elif debt_ratio <= 40:
            score = 60   # Acceptable
        elif debt_ratio <= 50:
            score = 40   # Risky
        else:
            score = 20   # High risk
        
        return score, debt_ratio
    
    def evaluate_creditworthiness(self, 
                                 documents: List[DocumentAnalysisResult],
                                 requested_credit: float = 0,
                                 monthly_payment: float = 0) -> CreditworthinessScore:
        """Comprehensive creditworthiness evaluation"""
        
        # Calculate component scores
        income_score, income_data = self.calculate_income_score(documents)
        consistency_score = self.calculate_consistency_score(documents)
        debt_score, debt_ratio = self.calculate_debt_ratio_score(
            income_data['monthly_income'], 
            requested_credit, 
            monthly_payment
        )
        
        # Document quality score
        doc_quality_score = sum(d.score for d in documents) / len(documents) if documents else 0
        
        # Weighted overall score
        overall_score = (
            income_score * 0.35 +
            consistency_score * 0.25 +
            debt_score * 0.30 +
            doc_quality_score * 0.10
        )
        
        # Determine rating
        if overall_score >= 80:
            rating = "Excellent"
            decision = "Approved"
            risk_level = "Low"
        elif overall_score >= 65:
            rating = "Good"
            decision = "Approved"
            risk_level = "Low"
        elif overall_score >= 50:
            rating = "Fair"
            decision = "Review"
            risk_level = "Medium"
        elif overall_score >= 35:
            rating = "Poor"
            decision = "Review"
            risk_level = "High"
        else:
            rating = "Rejected"
            decision = "Rejected"
            risk_level = "High"
        
        # Calculate confidence
        confidence = min((consistency_score + doc_quality_score) / 200, 1.0)
        
        # Identify strengths and weaknesses
        strengths = []
        weaknesses = []
        
        if income_score >= 70:
            strengths.append("Strong income level")
        elif income_score < 40:
            weaknesses.append("Low income level")
        
        if debt_score >= 80:
            strengths.append("Low debt-to-income ratio")
        elif debt_score < 50:
            weaknesses.append("High debt-to-income ratio")
        
        if consistency_score >= 70:
            strengths.append("Consistent documentation")
        elif consistency_score < 50:
            weaknesses.append("Inconsistent or incomplete documentation")
        
        if doc_quality_score >= 75:
            strengths.append("High quality documents")
        elif doc_quality_score < 50:
            weaknesses.append("Poor quality or suspicious documents")
        
        # Check required documents
        pay_slip_count = len([d for d in documents if d.document_type == DocumentType.PAY_SLIP])
        tax_decl_count = len([d for d in documents if d.document_type == DocumentType.TAX_DECLARATION])
        
        required_docs = []
        missing_docs = []
        
        required_docs.append(f"{self.min_required_documents['pay_slips']} recent pay slips")
        if pay_slip_count < self.min_required_documents['pay_slips']:
            missing_docs.append(f"Pay slips ({pay_slip_count}/{self.min_required_documents['pay_slips']})")
        
        required_docs.append("Tax declaration")
        if tax_decl_count < self.min_required_documents['tax_declaration']:
            missing_docs.append("Tax declaration")
        
        return CreditworthinessScore(
            overall_score=round(overall_score, 2),
            income_score=round(income_score, 2),
            consistency_score=round(consistency_score, 2),
            debt_ratio_score=round(debt_score, 2),
            document_quality_score=round(doc_quality_score, 2),
            rating=rating,
            decision=decision,
            confidence=round(confidence, 3),
            risk_level=risk_level,
            monthly_income=income_data['monthly_income'],
            debt_to_income_ratio=round(debt_ratio, 2),
            strengths=strengths,
            weaknesses=weaknesses,
            required_documents=required_docs,
            missing_documents=missing_docs
        )
