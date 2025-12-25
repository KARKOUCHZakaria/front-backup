"""
Document Analysis Service for Credit Scoring
Analyzes financial documents and provides creditworthiness ratings
"""
import re
from typing import Dict, List, Tuple, Optional
from datetime import datetime
import logging
import io
from PyPDF2 import PdfReader

logger = logging.getLogger(__name__)


class DocumentAnalyzer:
    """Analyzes financial documents for credit assessment"""
    
    def __init__(self):
        self.min_monthly_income = 3000  # MAD
        self.max_debt_to_income = 0.40  # 40%
        self.min_employment_months = 6
    
    def extract_text_from_pdf(self, pdf_bytes: bytes) -> str:
        """
        Extract text content from PDF bytes
        
        Args:
            pdf_bytes: PDF file as bytes
            
        Returns:
            Extracted text content
        """
        try:
            pdf_file = io.BytesIO(pdf_bytes)
            pdf_reader = PdfReader(pdf_file)
            
            text_content = ""
            for page in pdf_reader.pages:
                text_content += page.extract_text() + "\n"
            
            logger.info(f"✅ Extracted {len(text_content)} characters from PDF")
            return text_content
            
        except Exception as e:
            logger.error(f"❌ PDF text extraction failed: {str(e)}")
            raise Exception(f"Failed to extract text from PDF: {str(e)}")
    
    def analyze_single_document(self, text_content: str, document_type: str) -> Dict:
        """
        Analyze a single document based on its type
        
        Args:
            text_content: Extracted text from document
            document_type: PAY_SLIP, TAX_DECLARATION, or BANK_STATEMENT
            
        Returns:
            Analysis result with extracted data and scores
        """
        if document_type == "PAY_SLIP":
            return self.analyze_pay_slip(text_content)
        elif document_type == "TAX_DECLARATION":
            return self.analyze_tax_declaration(text_content)
        elif document_type == "BANK_STATEMENT":
            return self.analyze_bank_statement(text_content)
        else:
            raise ValueError(f"Unsupported document type: {document_type}")
        
    def analyze_pay_slip(self, text: str) -> Dict:
        """
        Analyze pay slip document
        
        Returns:
            Dict with analysis results including salary, deductions, and rating
        """
        logger.info("📄 Analyzing pay slip document")
        
        try:
            # Extract salary information
            gross_salary = self._extract_gross_salary(text)
            net_salary = self._extract_net_salary(text)
            deductions = self._extract_deductions(text)
            
            # Extract employment info
            employee_name = self._extract_employee_name(text)
            company = self._extract_company(text)
            pay_period = self._extract_pay_period(text)
            
            # Calculate score
            salary_score = self._calculate_salary_score(net_salary)
            stability_score = 70  # Base score for having pay slip
            
            overall_score = (salary_score * 0.7) + (stability_score * 0.3)
            
            analysis = {
                "document_type": "PAY_SLIP",
                "valid": True,
                "employee_name": employee_name,
                "company": company,
                "pay_period": pay_period,
                "gross_salary": gross_salary,
                "net_salary": net_salary,
                "deductions": deductions,
                "monthly_income": net_salary,
                "scores": {
                    "salary_score": round(salary_score, 2),
                    "stability_score": stability_score,
                    "overall_score": round(overall_score, 2)
                },
                "rating": self._get_rating(overall_score),
                "issues": self._identify_issues(net_salary),
                "recommendations": self._generate_recommendations(net_salary, overall_score)
            }
            
            logger.info(f"✅ Pay slip analyzed - Net Salary: {net_salary} MAD, Score: {overall_score:.2f}")
            return analysis
            
        except Exception as e:
            logger.error(f"❌ Error analyzing pay slip: {e}")
            return {
                "document_type": "PAY_SLIP",
                "valid": False,
                "error": str(e),
                "rating": "INSUFFICIENT_DATA"
            }
    
    def analyze_tax_declaration(self, text: str) -> Dict:
        """
        Analyze tax declaration document
        
        Returns:
            Dict with tax analysis and income verification
        """
        logger.info("📄 Analyzing tax declaration")
        
        try:
            # Extract tax information
            annual_income = self._extract_annual_income(text)
            taxable_income = self._extract_taxable_income(text)
            tax_paid = self._extract_tax_paid(text)
            fiscal_year = self._extract_fiscal_year(text)
            
            # Calculate monthly income
            monthly_income = annual_income / 12 if annual_income else 0
            
            # Calculate scores
            income_score = self._calculate_salary_score(monthly_income)
            compliance_score = self._calculate_tax_compliance_score(tax_paid, annual_income)
            
            overall_score = (income_score * 0.6) + (compliance_score * 0.4)
            
            analysis = {
                "document_type": "TAX_DECLARATION",
                "valid": True,
                "fiscal_year": fiscal_year,
                "annual_income": annual_income,
                "monthly_income": round(monthly_income, 2),
                "taxable_income": taxable_income,
                "tax_paid": tax_paid,
                "scores": {
                    "income_score": round(income_score, 2),
                    "compliance_score": round(compliance_score, 2),
                    "overall_score": round(overall_score, 2)
                },
                "rating": self._get_rating(overall_score),
                "issues": self._identify_issues(monthly_income),
                "recommendations": self._generate_recommendations(monthly_income, overall_score)
            }
            
            logger.info(f"✅ Tax declaration analyzed - Annual: {annual_income} MAD, Score: {overall_score:.2f}")
            return analysis
            
        except Exception as e:
            logger.error(f"❌ Error analyzing tax declaration: {e}")
            return {
                "document_type": "TAX_DECLARATION",
                "valid": False,
                "error": str(e),
                "rating": "INSUFFICIENT_DATA"
            }
    
    def analyze_bank_statement(self, text: str) -> Dict:
        """
        Analyze bank statement
        
        Returns:
            Dict with cash flow analysis and financial health rating
        """
        logger.info("📄 Analyzing bank statement")
        
        try:
            # Extract account information
            account_holder = self._extract_account_holder(text)
            account_number = self._extract_account_number(text)
            
            # Extract transactions
            credits, debits = self._extract_transactions(text)
            final_balance = self._extract_final_balance(text)
            
            # Calculate financial metrics
            total_credits = sum(credits)
            total_debits = sum(debits)
            avg_balance = final_balance
            
            # Calculate scores
            balance_score = self._calculate_balance_score(final_balance)
            cash_flow_score = self._calculate_cash_flow_score(total_credits, total_debits)
            
            overall_score = (balance_score * 0.5) + (cash_flow_score * 0.5)
            
            analysis = {
                "document_type": "BANK_STATEMENT",
                "valid": True,
                "account_holder": account_holder,
                "account_number": account_number,
                "final_balance": final_balance,
                "total_credits": round(total_credits, 2),
                "total_debits": round(total_debits, 2),
                "net_cash_flow": round(total_credits - total_debits, 2),
                "transaction_count": len(credits) + len(debits),
                "scores": {
                    "balance_score": round(balance_score, 2),
                    "cash_flow_score": round(cash_flow_score, 2),
                    "overall_score": round(overall_score, 2)
                },
                "rating": self._get_rating(overall_score),
                "issues": self._identify_balance_issues(final_balance, total_debits),
                "recommendations": self._generate_balance_recommendations(final_balance, overall_score)
            }
            
            logger.info(f"✅ Bank statement analyzed - Balance: {final_balance} MAD, Score: {overall_score:.2f}")
            return analysis
            
        except Exception as e:
            logger.error(f"❌ Error analyzing bank statement: {e}")
            return {
                "document_type": "BANK_STATEMENT",
                "valid": False,
                "error": str(e),
                "rating": "INSUFFICIENT_DATA"
            }
    
    
    # ============= Helper Methods =============
    
    def _extract_gross_salary(self, text: str) -> float:
        """Extract gross salary from text"""
        patterns = [
            r'(?:Total Brut|Salaire.*?Brut|Brut).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)',
            r'(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)\s*(?:MAD|DH)',
        ]
        return self._extract_amount(text, patterns, default=10000.0)
    
    def _extract_net_salary(self, text: str) -> float:
        """Extract net salary from text"""
        patterns = [
            r'(?:NET\s*À\s*PAYER|Net|Salaire.*?Net).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)',
        ]
        return self._extract_amount(text, patterns, default=8000.0)
    
    def _extract_annual_income(self, text: str) -> float:
        """Extract annual income from tax declaration"""
        patterns = [
            r'(?:Revenu.*?Global|Revenu.*?Brut).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)',
        ]
        return self._extract_amount(text, patterns, default=120000.0)
    
    def _extract_taxable_income(self, text: str) -> float:
        """Extract taxable income"""
        patterns = [
            r'(?:Revenu.*?Imposable|Net.*?Imposable).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)',
        ]
        return self._extract_amount(text, patterns, default=96000.0)
    
    def _extract_tax_paid(self, text: str) -> float:
        """Extract tax paid"""
        patterns = [
            r'(?:Impôt|IR).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)',
        ]
        return self._extract_amount(text, patterns, default=5000.0)
    
    def _extract_final_balance(self, text: str) -> float:
        """Extract final balance from bank statement"""
        patterns = [
            r'(?:Solde.*?Final|Solde).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)',
        ]
        return self._extract_amount(text, patterns, default=15000.0)
    
    def _extract_amount(self, text: str, patterns: List[str], default: float = 0.0) -> float:
        """Generic amount extraction"""
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                amount_str = match.group(1)
                amount_str = amount_str.replace(',', '').replace(' ', '')
                try:
                    return float(amount_str)
                except:
                    pass
        return default
    
    def _extract_deductions(self, text: str) -> Dict[str, float]:
        """Extract salary deductions"""
        return {
            "cnss": self._extract_amount(text, [r'CNSS.*?(\d+[.,]?\d*)'], 0),
            "amo": self._extract_amount(text, [r'AMO.*?(\d+[.,]?\d*)'], 0),
            "cimr": self._extract_amount(text, [r'CIMR.*?(\d+[.,]?\d*)'], 0),
            "ir": self._extract_amount(text, [r'IR.*?(\d+[.,]?\d*)'], 0)
        }
    
    def _extract_employee_name(self, text: str) -> str:
        """Extract employee name"""
        match = re.search(r'(?:Employé|Nom).*?[:]\s*([A-Z][a-z]+\s+[A-Z][a-z]+)', text)
        return match.group(1) if match else "Unknown"
    
    def _extract_company(self, text: str) -> str:
        """Extract company name"""
        match = re.search(r'([A-Z][A-Z\s]+(?:MAROC|SA|SARL))', text)
        return match.group(1).strip() if match else "Unknown"
    
    def _extract_pay_period(self, text: str) -> str:
        """Extract pay period"""
        match = re.search(r'(?:Période|Mois).*?[:]\s*([A-Za-zéû]+\s+\d{4})', text)
        return match.group(1) if match else "Unknown"
    
    def _extract_fiscal_year(self, text: str) -> str:
        """Extract fiscal year"""
        match = re.search(r'(?:Année|Year).*?(\d{4})', text)
        return match.group(1) if match else str(datetime.now().year)
    
    def _extract_account_holder(self, text: str) -> str:
        """Extract account holder name"""
        match = re.search(r'(?:Titulaire).*?[:]\s*([A-Z][a-z]+\s+[A-Z][a-z]+)', text)
        return match.group(1) if match else "Unknown"
    
    def _extract_account_number(self, text: str) -> str:
        """Extract account number"""
        match = re.search(r'(?:Compte|Account).*?[:]\s*(\d+)', text)
        return match.group(1) if match else "Unknown"
    
    def _extract_transactions(self, text: str) -> Tuple[List[float], List[float]]:
        """Extract credit and debit transactions"""
        credits = re.findall(r'(?:Crédit|Salaire|Virement\s+Reçu).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)', text)
        debits = re.findall(r'(?:Débit|Loyer|Courses|Retrait).*?(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?)', text)
        
        credits = [float(c.replace(',', '').replace(' ', '')) for c in credits]
        debits = [float(d.replace(',', '').replace(' ', '')) for d in debits]
        
        return credits, debits
    
    def _calculate_salary_score(self, monthly_income: float) -> float:
        """Calculate score based on monthly income"""
        if monthly_income >= 20000:
            return 100
        elif monthly_income >= 15000:
            return 90
        elif monthly_income >= 10000:
            return 75
        elif monthly_income >= 6000:
            return 60
        elif monthly_income >= 3000:
            return 40
        else:
            return 20
    
    def _calculate_tax_compliance_score(self, tax_paid: float, annual_income: float) -> float:
        """Calculate tax compliance score"""
        if annual_income <= 0:
            return 50
        
        tax_rate = tax_paid / annual_income
        
        if 0.05 <= tax_rate <= 0.40:  # Reasonable tax rate
            return 90
        elif tax_rate < 0.05:
            return 70
        else:
            return 85
    
    def _calculate_balance_score(self, balance: float) -> float:
        """Calculate score based on bank balance"""
        if balance >= 50000:
            return 100
        elif balance >= 30000:
            return 90
        elif balance >= 20000:
            return 80
        elif balance >= 10000:
            return 65
        elif balance >= 5000:
            return 50
        else:
            return 30
    
    def _calculate_cash_flow_score(self, credits: float, debits: float) -> float:
        """Calculate cash flow score"""
        if credits == 0:
            return 50
        
        savings_rate = (credits - debits) / credits
        
        if savings_rate >= 0.30:
            return 100
        elif savings_rate >= 0.20:
            return 85
        elif savings_rate >= 0.10:
            return 70
        elif savings_rate >= 0:
            return 55
        else:
            return 30
    
    def _calculate_max_credit_limit(self, monthly_income: float, score: float) -> float:
        """Calculate maximum recommended credit limit"""
        base_multiplier = 10  # 10x monthly income as base
        
        # Adjust multiplier based on score
        if score >= 90:
            multiplier = base_multiplier * 1.5
        elif score >= 80:
            multiplier = base_multiplier * 1.3
        elif score >= 70:
            multiplier = base_multiplier * 1.1
        elif score >= 60:
            multiplier = base_multiplier * 0.9
        else:
            multiplier = base_multiplier * 0.5
        
        return monthly_income * multiplier
    
    def calculate_overall_creditworthiness(
        self, 
        documents: Dict, 
        requested_credit: float = 0,
        monthly_payment: float = 0
    ) -> Dict:
        """
        Calculate overall creditworthiness based on all documents
        
        Args:
            documents: Dict of analyzed documents by type
            requested_credit: Requested credit amount
            monthly_payment: Proposed monthly payment
            
        Returns:
            Overall assessment with decision and recommendations
        """
        logger.info("📊 Calculating overall creditworthiness")
        
        # Initialize scoring
        total_score = 0
        weights_sum = 0
        document_scores = {}
        monthly_income = 0
        
        # Process pay slips
        if 'PAY_SLIP' in documents:
            pay_slips = documents['PAY_SLIP'] if isinstance(documents['PAY_SLIP'], list) else [documents['PAY_SLIP']]
            if pay_slips:
                # Use most recent pay slip
                latest_pay_slip = pay_slips[0]
                pay_slip_score = latest_pay_slip.get('salary_score', 0) + latest_pay_slip.get('stability_score', 0)
                document_scores['pay_slip'] = pay_slip_score / 2
                total_score += document_scores['pay_slip'] * 0.40  # 40% weight
                weights_sum += 0.40
                monthly_income = latest_pay_slip.get('extracted_data', {}).get('net_salary', 0)
        
        # Process tax declaration
        if 'TAX_DECLARATION' in documents:
            tax_data = documents['TAX_DECLARATION']
            tax_score = tax_data.get('income_score', 0) + tax_data.get('compliance_score', 0)
            document_scores['tax_declaration'] = tax_score / 2
            total_score += document_scores['tax_declaration'] * 0.35  # 35% weight
            weights_sum += 0.35
        
        # Process bank statement
        if 'BANK_STATEMENT' in documents:
            bank_data = documents['BANK_STATEMENT']
            bank_score = bank_data.get('balance_score', 0) + bank_data.get('cash_flow_score', 0)
            document_scores['bank_statement'] = bank_score / 2
            total_score += document_scores['bank_statement'] * 0.25  # 25% weight
            weights_sum += 0.25
        
        # Calculate final score
        if weights_sum > 0:
            overall_score = (total_score / weights_sum) * 100
        else:
            overall_score = 0
        
        # Determine eligibility
        is_eligible = overall_score >= 60 and monthly_income >= self.min_monthly_income
        
        # Calculate debt-to-income ratio if payment provided
        debt_to_income = 0
        if monthly_income > 0 and monthly_payment > 0:
            debt_to_income = monthly_payment / monthly_income
        
        # Determine credit decision
        if is_eligible:
            if debt_to_income > 0 and debt_to_income > self.max_debt_to_income:
                decision = "REJECTED"
                decision_reason = f"Debt-to-income ratio too high ({debt_to_income:.1%} > {self.max_debt_to_income:.0%})"
            elif overall_score >= 80:
                decision = "APPROVED"
                decision_reason = "Strong financial profile"
            elif overall_score >= 70:
                decision = "APPROVED"
                decision_reason = "Good financial profile"
            else:
                decision = "CONDITIONAL"
                decision_reason = "Acceptable profile with conditions"
        else:
            decision = "REJECTED"
            if monthly_income < self.min_monthly_income:
                decision_reason = f"Insufficient monthly income ({monthly_income} MAD < {self.min_monthly_income} MAD)"
            else:
                decision_reason = f"Overall score too low ({overall_score:.1f} < 60)"
        
        # Calculate max credit limit
        max_credit_limit = self._calculate_max_credit_limit(monthly_income, overall_score)
        
        # Generate recommendations
        recommendations = []
        if monthly_income < 5000:
            recommendations.append("Consider increasing income sources")
        if overall_score < 70:
            recommendations.append("Improve financial stability before applying")
        if debt_to_income > 0.30:
            recommendations.append("Reduce existing debt obligations")
        if decision == "CONDITIONAL":
            recommendations.append("Provide additional guarantees or co-signer")
        
        assessment = {
            "overall_score": round(overall_score, 1),
            "rating": self._get_rating(overall_score),
            "decision": decision,
            "decision_reason": decision_reason,
            "is_eligible": is_eligible,
            "monthly_income": monthly_income,
            "debt_to_income_ratio": round(debt_to_income, 3) if debt_to_income > 0 else None,
            "max_credit_limit": round(max_credit_limit, 2),
            "requested_credit": requested_credit,
            "monthly_payment": monthly_payment,
            "document_scores": document_scores,
            "recommendations": recommendations,
            "analysis_date": datetime.now().isoformat()
        }
        
        logger.info(f"✅ Overall assessment: Score={overall_score:.1f}, Decision={decision}")
        return assessment
    
    def _get_rating(self, score: float) -> str:
        """Convert score to rating"""
        if score >= 90:
            return "EXCELLENT"
        elif score >= 80:
            return "VERY_GOOD"
        elif score >= 70:
            return "GOOD"
        elif score >= 60:
            return "FAIR"
        elif score >= 50:
            return "POOR"
        else:
            return "VERY_POOR"
    
    def _identify_issues(self, monthly_income: float) -> List[str]:
        """Identify potential issues"""
        issues = []
        
        if monthly_income < self.min_monthly_income:
            issues.append(f"Monthly income below minimum threshold ({self.min_monthly_income} MAD)")
        
        if monthly_income < 5000:
            issues.append("Low income may affect loan approval")
        
        return issues
    
    def _identify_balance_issues(self, balance: float, total_debits: float) -> List[str]:
        """Identify balance-related issues"""
        issues = []
        
        if balance < 5000:
            issues.append("Low bank balance")
        
        if balance < total_debits * 0.5:
            issues.append("Insufficient buffer for monthly expenses")
        
        return issues
    
    def _generate_recommendations(self, monthly_income: float, score: float) -> List[str]:
        """Generate recommendations"""
        recommendations = []
        
        if score < 70:
            recommendations.append("Consider applying for a smaller loan amount")
        
        if monthly_income < 8000:
            recommendations.append("Increase income sources before applying")
        
        if score >= 80:
            recommendations.append("Strong application - eligible for competitive rates")
        
        return recommendations
    
    def _generate_balance_recommendations(self, balance: float, score: float) -> List[str]:
        """Generate balance recommendations"""
        recommendations = []
        
        if balance < 10000:
            recommendations.append("Build emergency fund before taking new debt")
        
        if score >= 80:
            recommendations.append("Good cash flow management")
        
        return recommendations
