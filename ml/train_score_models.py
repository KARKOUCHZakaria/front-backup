"""
Train separate regression models for each document type
Each model predicts a creditworthiness score (0-100)
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
import joblib
import os
import json
from datetime import datetime


class DocumentScoreModel:
    """Individual scoring model for a specific document type"""
    
    def __init__(self, document_type):
        self.document_type = document_type
        self.model = GradientBoostingRegressor(
            n_estimators=200,
            max_depth=8,
            learning_rate=0.1,
            min_samples_split=10,
            min_samples_leaf=5,
            random_state=42
        )
        self.scaler = StandardScaler()
        self.feature_columns = []
        
    def train(self, X, y):
        """Train the model"""
        # Store feature columns
        self.feature_columns = X.columns.tolist()
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train model
        print(f"  Training {self.document_type} model...")
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate
        y_pred = self.model.predict(X_test_scaled)
        mse = mean_squared_error(y_test, y_pred)
        mae = mean_absolute_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        
        print(f"  ✅ {self.document_type} - MAE: {mae:.2f}, R²: {r2:.3f}")
        
        return {
            'mse': mse,
            'mae': mae,
            'r2': r2
        }
    
    def predict(self, features):
        """Predict score for given features"""
        X = pd.DataFrame([features])[self.feature_columns]
        X = X.fillna(0)
        
        # Convert boolean to int
        bool_cols = X.select_dtypes(include=['bool']).columns
        X[bool_cols] = X[bool_cols].astype(int)
        
        X_scaled = self.scaler.transform(X)
        score = self.model.predict(X_scaled)[0]
        return max(0, min(100, score))
    
    def save(self, directory):
        """Save model, scaler, and metadata"""
        os.makedirs(directory, exist_ok=True)
        
        model_path = f"{directory}/{self.document_type}_model.pkl"
        scaler_path = f"{directory}/{self.document_type}_scaler.pkl"
        meta_path = f"{directory}/{self.document_type}_meta.json"
        
        joblib.dump(self.model, model_path)
        joblib.dump(self.scaler, scaler_path)
        
        metadata = {
            'document_type': self.document_type,
            'feature_columns': self.feature_columns,
            'trained_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'version': '1.0.0'
        }
        
        with open(meta_path, 'w') as f:
            json.dump(metadata, f, indent=2)
    
    def load(self, directory):
        """Load model, scaler, and metadata"""
        model_path = f"{directory}/{self.document_type}_model.pkl"
        scaler_path = f"{directory}/{self.document_type}_scaler.pkl"
        meta_path = f"{directory}/{self.document_type}_meta.json"
        
        self.model = joblib.load(model_path)
        self.scaler = joblib.load(scaler_path)
        
        with open(meta_path, 'r') as f:
            metadata = json.load(f)
        
        self.feature_columns = metadata['feature_columns']


def prepare_cin_features(df):
    """Prepare CIN features"""
    features = [
        'is_expired',
        'ocr_confidence',
        'image_quality',
        'has_photo',
        'text_legible',
        'correct_format'
    ]
    X = df[features].copy()
    X = X.fillna(0)
    
    # Convert boolean to int
    bool_cols = X.select_dtypes(include=['bool']).columns
    X[bool_cols] = X[bool_cols].astype(int)
    
    return X, df['score']


def prepare_payslip_features(df):
    """Prepare Pay Slip features"""
    features = [
        'gross_salary',
        'net_salary',
        'total_deductions',
        'has_company_stamp',
        'amounts_match',
        'has_required_fields',
        'salary_consistency',
        'months_since_issue'
    ]
    X = df[features].copy()
    X = X.fillna(0)
    
    bool_cols = X.select_dtypes(include=['bool']).columns
    X[bool_cols] = X[bool_cols].astype(int)
    
    return X, df['score']


def prepare_tax_features(df):
    """Prepare Tax Declaration features"""
    features = [
        'gross_income',
        'taxable_income',
        'tax_paid',
        'has_official_stamp',
        'calculations_correct',
        'all_fields_filled',
        'income_reasonable',
        'years_since_declaration'
    ]
    X = df[features].copy()
    X = X.fillna(0)
    
    bool_cols = X.select_dtypes(include=['bool']).columns
    X[bool_cols] = X[bool_cols].astype(int)
    
    return X, df['score']


def prepare_bank_features(df):
    """Prepare Bank Statement features"""
    features = [
        'period_months',
        'opening_balance',
        'closing_balance',
        'average_balance',
        'total_credits',
        'total_debits',
        'avg_monthly_income',
        'avg_monthly_expenses',
        'savings_rate',
        'low_balance_incidents',
        'has_bank_header',
        'balances_match',
        'regular_income'
    ]
    X = df[features].copy()
    X = X.fillna(0)
    
    bool_cols = X.select_dtypes(include=['bool']).columns
    X[bool_cols] = X[bool_cols].astype(int)
    
    return X, df['score']


def train_all_models():
    """Train all 4 document scoring models"""
    print("🚀 Training Document Scoring Models...\n")
    
    # Load datasets
    print("📂 Loading datasets...")
    cin_df = pd.read_csv('data/cin_dataset.csv')
    payslip_df = pd.read_csv('data/payslip_dataset.csv')
    tax_df = pd.read_csv('data/tax_dataset.csv')
    bank_df = pd.read_csv('data/bank_dataset.csv')
    
    print(f"  CIN: {len(cin_df)} samples")
    print(f"  Pay Slip: {len(payslip_df)} samples")
    print(f"  Tax: {len(tax_df)} samples")
    print(f"  Bank: {len(bank_df)} samples")
    print()
    
    results = {}
    
    # Train CIN model
    print("1️⃣  Training CIN Model...")
    cin_model = DocumentScoreModel('cin')
    X_cin, y_cin = prepare_cin_features(cin_df)
    results['cin'] = cin_model.train(X_cin, y_cin)
    cin_model.save('models/scored')
    print()
    
    # Train Pay Slip model
    print("2️⃣  Training Pay Slip Model...")
    payslip_model = DocumentScoreModel('payslip')
    X_payslip, y_payslip = prepare_payslip_features(payslip_df)
    results['payslip'] = payslip_model.train(X_payslip, y_payslip)
    payslip_model.save('models/scored')
    print()
    
    # Train Tax model
    print("3️⃣  Training Tax Declaration Model...")
    tax_model = DocumentScoreModel('tax')
    X_tax, y_tax = prepare_tax_features(tax_df)
    results['tax'] = tax_model.train(X_tax, y_tax)
    tax_model.save('models/scored')
    print()
    
    # Train Bank model
    print("4️⃣  Training Bank Statement Model...")
    bank_model = DocumentScoreModel('bank')
    X_bank, y_bank = prepare_bank_features(bank_df)
    results['bank'] = bank_model.train(X_bank, y_bank)
    bank_model.save('models/scored')
    print()
    
    # Save overall results
    print("💾 Saving training results...")
    results_df = pd.DataFrame(results).T
    results_df.to_csv('models/scored/training_results.csv')
    
    print("\n✅ All models trained and saved!")
    print(f"\nModel files saved in: models/scored/")
    print("  - cin_model.pkl, cin_scaler.pkl, cin_meta.json")
    print("  - payslip_model.pkl, payslip_scaler.pkl, payslip_meta.json")
    print("  - tax_model.pkl, tax_scaler.pkl, tax_meta.json")
    print("  - bank_model.pkl, bank_scaler.pkl, bank_meta.json")
    
    return results


if __name__ == "__main__":
    # Check if data exists
    if not os.path.exists('data/cin_dataset.csv'):
        print("❌ Error: Dataset files not found!")
        print("   Please run generate_dataset.py first.")
        exit(1)
    
    # Train models
    results = train_all_models()
    
    # Test predictions
    print("\n🧪 Testing Models...\n")
    
    # Test CIN
    cin_model = DocumentScoreModel('cin')
    cin_model.load('models/scored')
    cin_score = cin_model.predict({
        'is_expired': False,
        'ocr_confidence': 0.92,
        'image_quality': 0.88,
        'has_photo': True,
        'text_legible': True,
        'correct_format': True
    })
    print(f"CIN Score: {cin_score:.2f}/100")
    
    # Test Pay Slip
    payslip_model = DocumentScoreModel('payslip')
    payslip_model.load('models/scored')
    payslip_score = payslip_model.predict({
        'gross_salary': 8500,
        'net_salary': 7200,
        'total_deductions': 1300,
        'has_company_stamp': True,
        'amounts_match': True,
        'has_required_fields': True,
        'salary_consistency': 0.85,
        'months_since_issue': 1
    })
    print(f"Pay Slip Score: {payslip_score:.2f}/100")
    
    # Test Tax
    tax_model = DocumentScoreModel('tax')
    tax_model.load('models/scored')
    tax_score = tax_model.predict({
        'gross_income': 120000,
        'taxable_income': 95000,
        'tax_paid': 18000,
        'has_official_stamp': True,
        'calculations_correct': True,
        'all_fields_filled': True,
        'income_reasonable': True,
        'years_since_declaration': 0
    })
    print(f"Tax Declaration Score: {tax_score:.2f}/100")
    
    # Test Bank
    bank_model = DocumentScoreModel('bank')
    bank_model.load('models/scored')
    bank_score = bank_model.predict({
        'period_months': 3,
        'opening_balance': 15000,
        'closing_balance': 12500,
        'average_balance': 13750,
        'total_credits': 25000,
        'total_debits': 27500,
        'avg_monthly_income': 8333,
        'avg_monthly_expenses': 9166,
        'savings_rate': -0.10,
        'low_balance_incidents': 0,
        'has_bank_header': True,
        'balances_match': True,
        'regular_income': True
    })
    print(f"Bank Statement Score: {bank_score:.2f}/100")
    
    print(f"\n✅ All models tested successfully!")
