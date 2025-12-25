"""
ML Model Service for Document Analysis
Integrates the trained ML model with document analysis service
"""

import os
import logging
from typing import Dict, Optional
from train_model import DocumentAnalysisModel

logger = logging.getLogger(__name__)


class MLModelService:
    """Service for using trained ML model in document analysis"""
    
    def __init__(self, model_dir='models/trained'):
        self.model = DocumentAnalysisModel()
        self.model_loaded = False
        self.model_dir = model_dir
        
        # Try to load model on initialization
        self._load_model()
    
    def _load_model(self):
        """Load trained model if available"""
        try:
            if os.path.exists(f'{self.model_dir}/classifier.pkl'):
                self.model.load_model(self.model_dir)
                self.model_loaded = True
                logger.info("✅ ML Model loaded successfully")
            else:
                logger.warning(f"⚠️  ML Model not found in {self.model_dir}. Using rule-based analysis.")
        except Exception as e:
            logger.error(f"❌ Failed to load ML model: {e}")
            self.model_loaded = False
    
    def predict_cin_document(self, extracted_data: Dict) -> Dict:
        """
        Predict CIN document validity using ML model
        
        Args:
            extracted_data: Dictionary with CIN features
            
        Returns:
            Prediction with status, score, and confidence
        """
        if not self.model_loaded:
            return self._fallback_cin_analysis(extracted_data)
        
        try:
            # Prepare features
            features = {
                'is_expired': extracted_data.get('is_expired', False),
                'ocr_confidence': extracted_data.get('ocr_confidence', 0.8),
                'image_quality': extracted_data.get('image_quality', 0.8),
                'has_photo': extracted_data.get('has_photo', True),
                'text_legible': extracted_data.get('text_legible', True),
                'correct_format': extracted_data.get('correct_format', True)
            }
            
            # Get prediction
            prediction = self.model.predict_document(features, 'CIN')
            
            logger.info(f"ML Prediction (CIN): {prediction['status']} (score: {prediction['score']})")
            return prediction
            
        except Exception as e:
            logger.error(f"ML prediction failed: {e}. Using fallback.")
            return self._fallback_cin_analysis(extracted_data)
    
    def predict_payslip_document(self, extracted_data: Dict) -> Dict:
        """
        Predict Pay Slip document validity using ML model
        
        Args:
            extracted_data: Dictionary with pay slip features
            
        Returns:
            Prediction with status, score, and confidence
        """
        if not self.model_loaded:
            return self._fallback_payslip_analysis(extracted_data)
        
        try:
            # Prepare features
            features = {
                'gross_salary': extracted_data.get('gross_salary', 0),
                'net_salary': extracted_data.get('net_salary', 0),
                'total_deductions': extracted_data.get('total_deductions', 0),
                'has_company_stamp': extracted_data.get('has_company_stamp', True),
                'amounts_match': extracted_data.get('amounts_match', True),
                'has_required_fields': extracted_data.get('has_required_fields', True),
                'salary_consistency': extracted_data.get('salary_consistency', 0.8),
                'months_since_issue': extracted_data.get('months_since_issue', 0)
            }
            
            # Get prediction
            prediction = self.model.predict_document(features, 'PAY_SLIP')
            
            logger.info(f"ML Prediction (Pay Slip): {prediction['status']} (score: {prediction['score']})")
            return prediction
            
        except Exception as e:
            logger.error(f"ML prediction failed: {e}. Using fallback.")
            return self._fallback_payslip_analysis(extracted_data)
    
    def predict_tax_document(self, extracted_data: Dict) -> Dict:
        """
        Predict Tax Declaration document validity using ML model
        
        Args:
            extracted_data: Dictionary with tax declaration features
            
        Returns:
            Prediction with status, score, and confidence
        """
        if not self.model_loaded:
            return self._fallback_tax_analysis(extracted_data)
        
        try:
            # Prepare features
            features = {
                'gross_income': extracted_data.get('gross_income', 0),
                'taxable_income': extracted_data.get('taxable_income', 0),
                'tax_paid': extracted_data.get('tax_paid', 0),
                'has_official_stamp': extracted_data.get('has_official_stamp', True),
                'calculations_correct': extracted_data.get('calculations_correct', True),
                'all_fields_filled': extracted_data.get('all_fields_filled', True),
                'income_reasonable': extracted_data.get('income_reasonable', True),
                'years_since_declaration': extracted_data.get('years_since_declaration', 0)
            }
            
            # Get prediction
            prediction = self.model.predict_document(features, 'TAX_DECLARATION')
            
            logger.info(f"ML Prediction (Tax): {prediction['status']} (score: {prediction['score']})")
            return prediction
            
        except Exception as e:
            logger.error(f"ML prediction failed: {e}. Using fallback.")
            return self._fallback_tax_analysis(extracted_data)
    
    def predict_bank_statement_document(self, extracted_data: Dict) -> Dict:
        """
        Predict Bank Statement document validity using ML model
        
        Args:
            extracted_data: Dictionary with bank statement features
            
        Returns:
            Prediction with status, score, and confidence
        """
        if not self.model_loaded:
            return self._fallback_bank_analysis(extracted_data)
        
        try:
            # Prepare features
            features = {
                'period_months': extracted_data.get('period_months', 3),
                'opening_balance': extracted_data.get('opening_balance', 0),
                'closing_balance': extracted_data.get('closing_balance', 0),
                'average_balance': extracted_data.get('average_balance', 0),
                'total_credits': extracted_data.get('total_credits', 0),
                'total_debits': extracted_data.get('total_debits', 0),
                'avg_monthly_income': extracted_data.get('avg_monthly_income', 0),
                'avg_monthly_expenses': extracted_data.get('avg_monthly_expenses', 0),
                'savings_rate': extracted_data.get('savings_rate', 0),
                'low_balance_incidents': extracted_data.get('low_balance_incidents', 0),
                'has_bank_header': extracted_data.get('has_bank_header', True),
                'balances_match': extracted_data.get('balances_match', True),
                'regular_income': extracted_data.get('regular_income', True)
            }
            
            # Get prediction
            prediction = self.model.predict_document(features, 'BANK_STATEMENT')
            
            logger.info(f"ML Prediction (Bank): {prediction['status']} (score: {prediction['score']})")
            return prediction
            
        except Exception as e:
            logger.error(f"ML prediction failed: {e}. Using fallback.")
            return self._fallback_bank_analysis(extracted_data)
    
    # Fallback methods (rule-based analysis)
    def _fallback_cin_analysis(self, data: Dict) -> Dict:
        """Fallback rule-based CIN analysis"""
        score = 70.0
        if data.get('is_expired', False):
            score -= 30
        if data.get('ocr_confidence', 1.0) < 0.7:
            score -= 20
        if not data.get('has_photo', True):
            score -= 25
        
        status = 'VALID' if score >= 70 else 'SUSPICIOUS' if score >= 50 else 'INVALID'
        
        return {
            'status': status,
            'score': max(0, min(100, score)),
            'confidence': 0.7,
            'status_probabilities': {status: 0.7}
        }
    
    def _fallback_payslip_analysis(self, data: Dict) -> Dict:
        """Fallback rule-based pay slip analysis"""
        net_salary = data.get('net_salary', 0)
        score = min(100, net_salary / 100)
        
        if not data.get('has_company_stamp', True):
            score -= 20
        if not data.get('amounts_match', True):
            score -= 30
        
        status = 'VALID' if score >= 70 else 'SUSPICIOUS' if score >= 50 else 'INVALID'
        
        return {
            'status': status,
            'score': max(0, min(100, score)),
            'confidence': 0.7,
            'status_probabilities': {status: 0.7}
        }
    
    def _fallback_tax_analysis(self, data: Dict) -> Dict:
        """Fallback rule-based tax declaration analysis"""
        taxable_income = data.get('taxable_income', 0)
        score = min(100, taxable_income / 1000)
        
        if not data.get('has_official_stamp', True):
            score -= 25
        if not data.get('calculations_correct', True):
            score -= 35
        
        status = 'VALID' if score >= 70 else 'SUSPICIOUS' if score >= 50 else 'INVALID'
        
        return {
            'status': status,
            'score': max(0, min(100, score)),
            'confidence': 0.7,
            'status_probabilities': {status: 0.7}
        }
    
    def _fallback_bank_analysis(self, data: Dict) -> Dict:
        """Fallback rule-based bank statement analysis"""
        avg_balance = data.get('average_balance', 0)
        avg_income = data.get('avg_monthly_income', 0)
        
        score = (min(100, avg_balance / 100) * 0.3 + min(100, avg_income / 50) * 0.7)
        
        if not data.get('regular_income', True):
            score -= 20
        if data.get('low_balance_incidents', 0) > 2:
            score -= 25
        
        status = 'VALID' if score >= 70 else 'SUSPICIOUS' if score >= 50 else 'INVALID'
        
        return {
            'status': status,
            'score': max(0, min(100, score)),
            'confidence': 0.7,
            'status_probabilities': {status: 0.7}
        }


# Global instance
ml_model_service = MLModelService()
