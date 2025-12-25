"""
Machine Learning Model for Document Analysis and Credit Scoring
Trains models on financial document data for classification and risk assessment
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier, GradientBoostingRegressor
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import classification_report, confusion_matrix, mean_squared_error, r2_score
import joblib
import os
import json
from datetime import datetime


class DocumentAnalysisModel:
    """ML model for analyzing financial documents and predicting creditworthiness"""
    
    def __init__(self):
        self.classifier = None  # For document status classification
        self.regressor = None   # For document score prediction
        self.scaler = StandardScaler()
        self.label_encoders = {}
        self.feature_columns = []
        self.model_trained = False
        
    def prepare_features(self, df, document_type):
        """Prepare features for model training based on document type"""
        features = []
        
        if document_type == 'CIN':
            features = [
                'is_expired',
                'ocr_confidence',
                'image_quality',
                'has_photo',
                'text_legible',
                'correct_format'
            ]
        elif document_type == 'PAY_SLIP':
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
        elif document_type == 'TAX_DECLARATION':
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
        elif document_type == 'BANK_STATEMENT':
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
        
        return features
    
    def train_model(self, datasets_dict):
        """
        Train model on all document types
        
        Args:
            datasets_dict: Dictionary with keys 'cin', 'payslip', 'tax', 'bank'
        """
        print("🤖 Training Document Analysis Model...")
        
        all_features = []
        all_labels = []
        all_scores = []
        all_doc_types = []
        
        # Process each document type
        for doc_type, df in datasets_dict.items():
            doc_type_upper = doc_type.upper().replace('PAYSLIP', 'PAY_SLIP').replace('TAX', 'TAX_DECLARATION').replace('BANK', 'BANK_STATEMENT')
            
            print(f"\n📄 Processing {doc_type} data ({len(df)} samples)...")
            
            # Get features for this document type
            feature_cols = self.prepare_features(df, doc_type_upper)
            
            # Extract features
            X = df[feature_cols].copy()
            
            # Handle missing values
            X = X.fillna(0)
            
            # Convert boolean columns to int
            bool_cols = X.select_dtypes(include=['bool']).columns
            X[bool_cols] = X[bool_cols].astype(int)
            
            # Add document type as a feature
            doc_type_encoded = ['CIN', 'PAY_SLIP', 'TAX_DECLARATION', 'BANK_STATEMENT'].index(doc_type_upper)
            X['doc_type_encoded'] = doc_type_encoded
            
            # Get labels and scores
            y_status = df['status'].values
            y_score = df['score'].values
            
            all_features.append(X)
            all_labels.extend(y_status)
            all_scores.extend(y_score)
            all_doc_types.extend([doc_type_upper] * len(df))
        
        # Combine all features
        print("\n🔄 Combining all features...")
        X_combined = pd.concat(all_features, axis=0, ignore_index=True)
        
        # Fill NaN values with 0 (for features not present in all document types)
        X_combined = X_combined.fillna(0)
        
        # Ensure all features are present
        self.feature_columns = X_combined.columns.tolist()
        
        # Scale features
        X_scaled = self.scaler.fit_transform(X_combined)
        
        # Encode labels
        self.label_encoders['status'] = LabelEncoder()
        y_labels_encoded = self.label_encoders['status'].fit_transform(all_labels)
        
        # Split data
        X_train, X_test, y_train_class, y_test_class, y_train_score, y_test_score = train_test_split(
            X_scaled, y_labels_encoded, all_scores, test_size=0.2, random_state=42, stratify=y_labels_encoded
        )
        
        # Train classification model (for document status)
        print("\n🎯 Training classification model...")
        self.classifier = RandomForestClassifier(
            n_estimators=200,
            max_depth=15,
            min_samples_split=10,
            min_samples_leaf=5,
            random_state=42,
            n_jobs=-1
        )
        self.classifier.fit(X_train, y_train_class)
        
        # Evaluate classifier
        y_pred_class = self.classifier.predict(X_test)
        accuracy = (y_pred_class == y_test_class).mean()
        print(f"✅ Classification Accuracy: {accuracy:.3f}")
        
        print("\n📊 Classification Report:")
        print(classification_report(
            y_test_class, 
            y_pred_class,
            target_names=self.label_encoders['status'].classes_
        ))
        
        # Train regression model (for document score)
        print("\n🎯 Training regression model...")
        self.regressor = GradientBoostingRegressor(
            n_estimators=200,
            max_depth=8,
            learning_rate=0.1,
            min_samples_split=10,
            min_samples_leaf=5,
            random_state=42
        )
        self.regressor.fit(X_train, y_train_score)
        
        # Evaluate regressor
        y_pred_score = self.regressor.predict(X_test)
        mse = mean_squared_error(y_test_score, y_pred_score)
        r2 = r2_score(y_test_score, y_pred_score)
        print(f"✅ Score Prediction MSE: {mse:.3f}")
        print(f"✅ Score Prediction R²: {r2:.3f}")
        
        # Feature importance
        print("\n📊 Top 10 Feature Importances (Classification):")
        feature_importance = pd.DataFrame({
            'feature': self.feature_columns,
            'importance': self.classifier.feature_importances_
        }).sort_values('importance', ascending=False)
        print(feature_importance.head(10))
        
        self.model_trained = True
        print("\n✅ Model training complete!")
        
        return {
            'classification_accuracy': accuracy,
            'regression_mse': mse,
            'regression_r2': r2,
            'feature_importance': feature_importance
        }
    
    def predict_document(self, features_dict, document_type):
        """
        Predict document status and score
        
        Args:
            features_dict: Dictionary of document features
            document_type: 'CIN', 'PAY_SLIP', 'TAX_DECLARATION', or 'BANK_STATEMENT'
            
        Returns:
            Dictionary with predicted status, score, and confidence
        """
        if not self.model_trained:
            raise Exception("Model not trained yet. Call train_model() first.")
        
        # Prepare feature vector
        feature_cols = self.prepare_features(pd.DataFrame([features_dict]), document_type)
        
        # Create feature dataframe
        X = pd.DataFrame([features_dict])[feature_cols].copy()
        X = X.fillna(0)
        
        # Convert boolean columns to int
        bool_cols = X.select_dtypes(include=['bool']).columns
        X[bool_cols] = X[bool_cols].astype(int)
        
        # Add document type
        doc_type_encoded = ['CIN', 'PAY_SLIP', 'TAX_DECLARATION', 'BANK_STATEMENT'].index(document_type)
        X['doc_type_encoded'] = doc_type_encoded
        
        # Ensure all required features are present
        for col in self.feature_columns:
            if col not in X.columns:
                X[col] = 0
        
        X = X[self.feature_columns]
        
        # Scale features
        X_scaled = self.scaler.transform(X)
        
        # Predict status
        status_encoded = self.classifier.predict(X_scaled)[0]
        status_proba = self.classifier.predict_proba(X_scaled)[0]
        status = self.label_encoders['status'].inverse_transform([status_encoded])[0]
        confidence = status_proba.max()
        
        # Predict score
        score = self.regressor.predict(X_scaled)[0]
        score = max(0, min(100, score))  # Clip to 0-100
        
        return {
            'status': status,
            'confidence': round(confidence, 3),
            'score': round(score, 2),
            'status_probabilities': {
                cls: round(prob, 3) 
                for cls, prob in zip(self.label_encoders['status'].classes_, status_proba)
            }
        }
    
    def save_model(self, model_dir='models/trained'):
        """Save trained model and preprocessors"""
        os.makedirs(model_dir, exist_ok=True)
        
        print(f"\n💾 Saving model to {model_dir}...")
        
        # Save models
        joblib.dump(self.classifier, f'{model_dir}/classifier.pkl')
        joblib.dump(self.regressor, f'{model_dir}/regressor.pkl')
        joblib.dump(self.scaler, f'{model_dir}/scaler.pkl')
        joblib.dump(self.label_encoders, f'{model_dir}/label_encoders.pkl')
        
        # Save feature columns and metadata
        metadata = {
            'feature_columns': self.feature_columns,
            'model_trained': self.model_trained,
            'training_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model_version': '1.0.0'
        }
        
        with open(f'{model_dir}/metadata.json', 'w') as f:
            json.dump(metadata, f, indent=2)
        
        print("✅ Model saved successfully!")
    
    def load_model(self, model_dir='models/trained'):
        """Load trained model and preprocessors"""
        print(f"\n📂 Loading model from {model_dir}...")
        
        self.classifier = joblib.load(f'{model_dir}/classifier.pkl')
        self.regressor = joblib.load(f'{model_dir}/regressor.pkl')
        self.scaler = joblib.load(f'{model_dir}/scaler.pkl')
        self.label_encoders = joblib.load(f'{model_dir}/label_encoders.pkl')
        
        with open(f'{model_dir}/metadata.json', 'r') as f:
            metadata = json.load(f)
        
        self.feature_columns = metadata['feature_columns']
        self.model_trained = metadata['model_trained']
        
        print(f"✅ Model loaded successfully! (Version: {metadata['model_version']}, Trained: {metadata['training_date']})")


def train_and_save_model():
    """Complete training pipeline"""
    # Load datasets
    print("📂 Loading datasets...")
    datasets = {
        'cin': pd.read_csv('data/cin_dataset.csv'),
        'payslip': pd.read_csv('data/payslip_dataset.csv'),
        'tax': pd.read_csv('data/tax_dataset.csv'),
        'bank': pd.read_csv('data/bank_dataset.csv')
    }
    
    print(f"\n✅ Loaded {sum(len(df) for df in datasets.values())} total samples")
    
    # Create and train model
    model = DocumentAnalysisModel()
    results = model.train_model(datasets)
    
    # Save model
    model.save_model()
    
    # Save training results
    print("\n💾 Saving training results...")
    results_df = pd.DataFrame([{
        'training_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'classification_accuracy': results['classification_accuracy'],
        'regression_mse': results['regression_mse'],
        'regression_r2': results['regression_r2'],
        'total_samples': sum(len(df) for df in datasets.values())
    }])
    results_df.to_csv('models/trained/training_results.csv', index=False)
    
    # Save feature importance
    results['feature_importance'].to_csv('models/trained/feature_importance.csv', index=False)
    
    print("\n✅ Training pipeline complete!")
    return model, results


if __name__ == "__main__":
    # Check if data exists
    if not os.path.exists('data/cin_dataset.csv'):
        print("❌ Error: Dataset files not found!")
        print("   Please run generate_dataset.py first to create the training data.")
        exit(1)
    
    # Train and save model
    model, results = train_and_save_model()
    
    # Test prediction
    print("\n🧪 Testing prediction...")
    test_features = {
        'is_expired': False,
        'ocr_confidence': 0.92,
        'image_quality': 0.88,
        'has_photo': True,
        'text_legible': True,
        'correct_format': True
    }
    
    prediction = model.predict_document(test_features, 'CIN')
    print("\nTest Prediction (CIN):")
    print(f"  Status: {prediction['status']}")
    print(f"  Score: {prediction['score']}")
    print(f"  Confidence: {prediction['confidence']}")
    print(f"  Probabilities: {prediction['status_probabilities']}")
