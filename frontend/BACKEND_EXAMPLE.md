# 🐍 Python Backend Example for ML Integration

## Flask API Example

```python
from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import pandas as pd
import numpy as np
import shap
from datetime import datetime

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Load the trained model
model = joblib.load('credit_model.pkl')

# Load SHAP explainer (if using tree-based model)
explainer = shap.TreeExplainer(model)

# Feature names expected by the model
EXPECTED_FEATURES = [
    'CODE_GENDER', 'DAYS_BIRTH', 'AMT_INCOME_TOTAL', 'AMT_CREDIT',
    'AMT_ANNUITY', 'AMT_GOODS_PRICE', 'DAYS_EMPLOYED', 'CNT_CHILDREN',
    # Add all features your model expects
]


@app.route('/api/ml/predict', methods=['POST'])
def predict():
    """Predict credit score for a given application"""
    try:
        data = request.json
        
        # Convert to DataFrame
        df = pd.DataFrame([data])
        
        # Ensure all expected features are present
        for feature in EXPECTED_FEATURES:
            if feature not in df.columns:
                df[feature] = None  # or default value
        
        # Preprocess (encode categorical, handle missing, etc.)
        df_processed = preprocess_features(df)
        
        # Predict
        prediction_proba = model.predict_proba(df_processed)[0]
        default_probability = prediction_proba[1]  # Probability of default
        
        # Convert to credit score (0-900)
        credit_score = int((1 - default_probability) * 900)
        
        # Decision
        decision = 'approved' if credit_score >= 500 else 'rejected'
        confidence = max(prediction_proba)
        
        # Risk level
        risk_level = 'low' if credit_score >= 700 else 'medium' if credit_score >= 500 else 'high'
        
        response = {
            'application_id': data.get('SK_ID_CURR', str(datetime.now().timestamp())),
            'prediction_probability': float(default_probability),
            'credit_score': credit_score,
            'decision': decision,
            'confidence': float(confidence),
            'risk_level': risk_level,
            'timestamp': datetime.now().isoformat()
        }
        
        return jsonify(response), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/ml/explain', methods=['POST'])
def explain():
    """Get SHAP values for feature importance"""
    try:
        data = request.json
        
        # Convert to DataFrame
        df = pd.DataFrame([data])
        df_processed = preprocess_features(df)
        
        # Calculate SHAP values
        shap_values = explainer.shap_values(df_processed)
        
        # For binary classification, take values for positive class
        if isinstance(shap_values, list):
            shap_values = shap_values[1]
        
        # Convert to dictionary {feature_name: shap_value}
        feature_names = df_processed.columns.tolist()
        shap_dict = {
            feature_names[i]: float(shap_values[0][i])
            for i in range(len(feature_names))
        }
        
        # Sort by absolute value and return top 10
        sorted_shap = dict(sorted(
            shap_dict.items(),
            key=lambda x: abs(x[1]),
            reverse=True
        )[:10])
        
        return jsonify(sorted_shap), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/ml/fairness', methods=['GET'])
def fairness_metrics():
    """Calculate fairness metrics for protected attributes"""
    try:
        protected_attr = request.args.get('protected_attribute', 'CODE_GENDER')
        
        # Load validation data (you should have this stored)
        validation_data = pd.read_csv('validation_data.csv')
        
        # Calculate metrics using AIF360 or custom implementation
        metrics = calculate_fairness_metrics(
            validation_data,
            protected_attr
        )
        
        return jsonify(metrics), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/ml/health', methods=['GET'])
def health_check():
    """Check if model is loaded and healthy"""
    try:
        # Simple health check
        healthy = model is not None
        
        response = {
            'healthy': healthy,
            'model_version': '1.0.0',
            'model_type': 'LightGBM',
            'last_trained': '2024-12-01T00:00:00',
            'metrics': {
                'accuracy': 0.92,
                'auc_roc': 0.88
            }
        }
        
        return jsonify(response), 200
        
    except Exception as e:
        return jsonify({'error': str(e), 'healthy': False}), 500


@app.route('/api/ml/info', methods=['GET'])
def model_info():
    """Get model information"""
    try:
        info = {
            'name': 'Home Credit Scoring Model',
            'version': '1.0.0',
            'algorithm': 'LightGBM',
            'features_count': len(EXPECTED_FEATURES),
            'training_date': '2024-12-01',
            'performance': {
                'auc_roc': 0.88,
                'accuracy': 0.92,
                'precision': 0.85,
                'recall': 0.80
            }
        }
        
        return jsonify(info), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/ml/feature-importance', methods=['GET'])
def feature_importance():
    """Get global feature importance from model"""
    try:
        # For tree-based models
        if hasattr(model, 'feature_importances_'):
            importances = model.feature_importances_
            feature_names = EXPECTED_FEATURES[:len(importances)]
            
            importance_dict = {
                feature_names[i]: float(importances[i])
                for i in range(len(feature_names))
            }
            
            # Sort by importance
            sorted_importance = dict(sorted(
                importance_dict.items(),
                key=lambda x: x[1],
                reverse=True
            )[:15])
            
            return jsonify(sorted_importance), 200
        else:
            return jsonify({'error': 'Model does not support feature importance'}), 400
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def preprocess_features(df):
    """Preprocess features before prediction"""
    # Make a copy
    df = df.copy()
    
    # Encode categorical variables
    categorical_cols = ['CODE_GENDER', 'NAME_EDUCATION_TYPE', 
                       'NAME_FAMILY_STATUS', 'NAME_CONTRACT_TYPE',
                       'NAME_INCOME_TYPE', 'NAME_HOUSING_TYPE',
                       'OCCUPATION_TYPE', 'ORGANIZATION_TYPE',
                       'FLAG_OWN_CAR', 'FLAG_OWN_REALTY']
    
    for col in categorical_cols:
        if col in df.columns:
            # Simple label encoding (use proper encoder in production)
            df[col] = df[col].astype('category').cat.codes
    
    # Handle missing values
    df = df.fillna(df.mean(numeric_only=True))
    
    # Ensure column order matches training
    df = df[EXPECTED_FEATURES]
    
    return df


def calculate_fairness_metrics(data, protected_attr):
    """Calculate fairness metrics"""
    # This is a simplified example
    # Use AIF360 or Fairlearn for proper implementation
    
    from sklearn.metrics import confusion_matrix
    
    # Split by protected attribute
    groups = data[protected_attr].unique()
    
    metrics = {}
    
    for group in groups:
        group_data = data[data[protected_attr] == group]
        y_true = group_data['TARGET']
        y_pred = group_data['PREDICTION']
        
        # Calculate metrics
        tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()
        
        tpr = tp / (tp + fn) if (tp + fn) > 0 else 0  # True Positive Rate
        fpr = fp / (fp + tn) if (fp + tn) > 0 else 0  # False Positive Rate
        
        metrics[f'{group}_tpr'] = tpr
        metrics[f'{group}_fpr'] = fpr
    
    # Calculate disparate impact
    if len(groups) >= 2:
        group_approval_rates = [
            metrics.get(f'{group}_tpr', 0) for group in groups
        ]
        disparate_impact = min(group_approval_rates) / max(group_approval_rates) \
            if max(group_approval_rates) > 0 else 0
    else:
        disparate_impact = 1.0
    
    return {
        'demographic_parity': 0.05,  # Example value
        'equal_opportunity': 0.03,   # Example value
        'disparate_impact': disparate_impact,
        'fairness_score': 85.0,
        'protected_attribute': protected_attr
    }


if __name__ == '__main__':
    print("🚀 Starting ML API Server...")
    print("📊 Model loaded successfully")
    print("🔗 API running at: http://localhost:8080")
    app.run(host='0.0.0.0', port=8080, debug=True)
```

## Requirements.txt

```
flask==3.0.0
flask-cors==4.0.0
pandas==2.1.4
numpy==1.26.2
scikit-learn==1.3.2
lightgbm==4.1.0
xgboost==2.0.3
shap==0.43.0
joblib==1.3.2
aif360==0.5.0
```

## Installation

```bash
# Create virtual environment
python -m venv venv

# Activate
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
python app.py
```

## Testing the API

```bash
# Test health
curl http://localhost:8080/api/ml/health

# Test prediction
curl -X POST http://localhost:8080/api/ml/predict \
  -H "Content-Type: application/json" \
  -d '{
    "CODE_GENDER": "M",
    "DAYS_BIRTH": -12775,
    "AMT_INCOME_TOTAL": 50000,
    "AMT_CREDIT": 15000,
    "AMT_ANNUITY": 1250
  }'
```

## Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

CMD ["python", "app.py"]
```

```bash
# Build
docker build -t credit-ml-api .

# Run
docker run -p 8080:8080 credit-ml-api
```
