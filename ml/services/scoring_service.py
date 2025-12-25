"""
Document Scoring Service - Simple score prediction for each document type
"""

import os
import logging
from typing import Dict
import joblib
import pandas as pd
import json

logger = logging.getLogger(__name__)


class DocumentScoringService:
    """Service for scoring documents using trained models"""
    
    def __init__(self, models_dir='models/scored'):
        self.models_dir = models_dir
        self.models = {}
        self.scalers = {}
        self.features = {}
        self._load_all_models()
    
    def _load_all_models(self):
        """Load all 4 document models"""
        document_types = ['cin', 'payslip', 'tax', 'bank']
        
        for doc_type in document_types:
            try:
                model_path = f"{self.models_dir}/{doc_type}_model.pkl"
                scaler_path = f"{self.models_dir}/{doc_type}_scaler.pkl"
                meta_path = f"{self.models_dir}/{doc_type}_meta.json"
                
                if os.path.exists(model_path):
                    self.models[doc_type] = joblib.load(model_path)
                    self.scalers[doc_type] = joblib.load(scaler_path)
                    
                    with open(meta_path, 'r') as f:
                        metadata = json.load(f)
                    self.features[doc_type] = metadata['feature_columns']
                    
                    logger.info(f"✅ {doc_type.upper()} model loaded")
                else:
                    logger.warning(f"⚠️  {doc_type.upper()} model not found")
            except Exception as e:
                logger.error(f"❌ Failed to load {doc_type} model: {e}")
    
    def score_cin(self, features: Dict) -> float:
        """
        Score CIN document
        
        Args:
            features: Dict with keys:
                - is_expired: bool
                - ocr_confidence: float (0-1)
                - image_quality: float (0-1)
                - has_photo: bool
                - text_legible: bool
                - correct_format: bool
        
        Returns:
            Score from 0-100
        """
        if 'cin' not in self.models:
            logger.warning("CIN model not available, using fallback")
            return self._fallback_cin_score(features)
        
        try:
            # Prepare features
            X = pd.DataFrame([features])[self.features['cin']]
            X = X.fillna(0)
            
            # Convert bool to int
            bool_cols = X.select_dtypes(include=['bool']).columns
            X[bool_cols] = X[bool_cols].astype(int)
            
            # Scale and predict
            X_scaled = self.scalers['cin'].transform(X)
            score = self.models['cin'].predict(X_scaled)[0]
            
            return max(0, min(100, float(score)))
        except Exception as e:
            logger.error(f"CIN scoring failed: {e}")
            return self._fallback_cin_score(features)
    
    def score_payslip(self, features: Dict) -> float:
        """
        Score Pay Slip document
        
        Args:
            features: Dict with keys:
                - gross_salary: float
                - net_salary: float
                - total_deductions: float
                - has_company_stamp: bool
                - amounts_match: bool
                - has_required_fields: bool
                - salary_consistency: float (0-1)
                - months_since_issue: int
        
        Returns:
            Score from 0-100
        """
        if 'payslip' not in self.models:
            logger.warning("Pay Slip model not available, using fallback")
            return self._fallback_payslip_score(features)
        
        try:
            X = pd.DataFrame([features])[self.features['payslip']]
            X = X.fillna(0)
            
            bool_cols = X.select_dtypes(include=['bool']).columns
            X[bool_cols] = X[bool_cols].astype(int)
            
            X_scaled = self.scalers['payslip'].transform(X)
            score = self.models['payslip'].predict(X_scaled)[0]
            
            return max(0, min(100, float(score)))
        except Exception as e:
            logger.error(f"Pay Slip scoring failed: {e}")
            return self._fallback_payslip_score(features)
    
    def score_tax(self, features: Dict) -> float:
        """
        Score Tax Declaration document
        
        Args:
            features: Dict with keys:
                - gross_income: float
                - taxable_income: float
                - tax_paid: float
                - has_official_stamp: bool
                - calculations_correct: bool
                - all_fields_filled: bool
                - income_reasonable: bool
                - years_since_declaration: int
        
        Returns:
            Score from 0-100
        """
        if 'tax' not in self.models:
            logger.warning("Tax model not available, using fallback")
            return self._fallback_tax_score(features)
        
        try:
            X = pd.DataFrame([features])[self.features['tax']]
            X = X.fillna(0)
            
            bool_cols = X.select_dtypes(include=['bool']).columns
            X[bool_cols] = X[bool_cols].astype(int)
            
            X_scaled = self.scalers['tax'].transform(X)
            score = self.models['tax'].predict(X_scaled)[0]
            
            return max(0, min(100, float(score)))
        except Exception as e:
            logger.error(f"Tax scoring failed: {e}")
            return self._fallback_tax_score(features)
    
    def score_bank(self, features: Dict) -> float:
        """
        Score Bank Statement document
        
        Args:
            features: Dict with keys:
                - period_months: int
                - opening_balance: float
                - closing_balance: float
                - average_balance: float
                - total_credits: float
                - total_debits: float
                - avg_monthly_income: float
                - avg_monthly_expenses: float
                - savings_rate: float
                - low_balance_incidents: int
                - has_bank_header: bool
                - balances_match: bool
                - regular_income: bool
        
        Returns:
            Score from 0-100
        """
        if 'bank' not in self.models:
            logger.warning("Bank model not available, using fallback")
            return self._fallback_bank_score(features)
        
        try:
            X = pd.DataFrame([features])[self.features['bank']]
            X = X.fillna(0)
            
            bool_cols = X.select_dtypes(include=['bool']).columns
            X[bool_cols] = X[bool_cols].astype(int)
            
            X_scaled = self.scalers['bank'].transform(X)
            score = self.models['bank'].predict(X_scaled)[0]
            
            return max(0, min(100, float(score)))
        except Exception as e:
            logger.error(f"Bank scoring failed: {e}")
            return self._fallback_bank_score(features)
    
    # Fallback scoring methods (simple rule-based)
    def _fallback_cin_score(self, features: Dict) -> float:
        score = 70.0
        if features.get('is_expired', False):
            score -= 30
        if features.get('ocr_confidence', 1.0) < 0.7:
            score -= 20
        if not features.get('has_photo', True):
            score -= 25
        if not features.get('text_legible', True):
            score -= 15
        return max(0, min(100, score))
    
    def _fallback_payslip_score(self, features: Dict) -> float:
        net_salary = features.get('net_salary', 0)
        score = min(100, net_salary / 100)
        
        if not features.get('has_company_stamp', True):
            score -= 20
        if not features.get('amounts_match', True):
            score -= 30
        if features.get('months_since_issue', 0) > 3:
            score -= 15
        
        return max(0, min(100, score))
    
    def _fallback_tax_score(self, features: Dict) -> float:
        taxable_income = features.get('taxable_income', 0)
        score = min(100, taxable_income / 1000)
        
        if not features.get('has_official_stamp', True):
            score -= 25
        if not features.get('calculations_correct', True):
            score -= 35
        if features.get('years_since_declaration', 0) > 2:
            score -= 20
        
        return max(0, min(100, score))
    
    def _fallback_bank_score(self, features: Dict) -> float:
        avg_balance = features.get('average_balance', 0)
        avg_income = features.get('avg_monthly_income', 0)
        
        score = (min(100, avg_balance / 100) * 0.3 + min(100, avg_income / 50) * 0.7)
        
        if not features.get('regular_income', True):
            score -= 20
        if features.get('low_balance_incidents', 0) > 2:
            score -= 25
        if features.get('savings_rate', 0) < 0:
            score -= 15
        
        return max(0, min(100, score))


# Global instance
document_scoring_service = DocumentScoringService()
