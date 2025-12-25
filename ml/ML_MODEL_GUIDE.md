# ML Model Training Guide for Document Analysis

This guide explains how to generate datasets, train the ML model, and integrate it with the document analysis system.

## 📁 Files Overview

- **generate_dataset.py**: Generates synthetic training data for all 4 document types
- **train_model.py**: Trains the ML model on the generated datasets
- **evaluate_model.py**: Evaluates model performance and generates reports
- **services/ml_model_service.py**: Service layer for integrating trained model with FastAPI

## 🎯 Document Types

The system handles **4 document types**:

1. **CIN (Moroccan National ID Card)**
   - Features: OCR confidence, image quality, photo presence, expiry status
   - Validates identity documents

2. **Pay Slip**
   - Features: Gross/net salary, deductions, company stamp, field completeness
   - Validates employment and income

3. **Tax Declaration**
   - Features: Income amounts, tax calculations, official stamps
   - Validates annual tax records

4. **Bank Statement**
   - Features: Balances, transactions, income patterns, savings rate
   - Validates financial activity

## 🚀 Quick Start

### Step 1: Generate Training Data

```bash
# From the ml/ directory
python generate_dataset.py
```

This creates:
- `data/cin_dataset.csv` (1,000 samples)
- `data/payslip_dataset.csv` (1,500 samples)
- `data/tax_dataset.csv` (1,000 samples)
- `data/bank_dataset.csv` (1,500 samples)
- `data/combined_documents_dataset.csv` (5,000 total samples)

### Step 2: Train the Model

```bash
python train_model.py
```

This creates:
- `models/trained/classifier.pkl` - Document status classifier
- `models/trained/regressor.pkl` - Document score predictor
- `models/trained/scaler.pkl` - Feature scaler
- `models/trained/label_encoders.pkl` - Label encoders
- `models/trained/metadata.json` - Model metadata
- `models/trained/training_results.csv` - Training metrics
- `models/trained/feature_importance.csv` - Feature importance rankings

### Step 3: Evaluate the Model

```bash
python evaluate_model.py
```

This generates:
- `models/trained/evaluation_report.txt` - Detailed evaluation report
- `models/trained/evaluation_results.json` - Metrics in JSON format
- Console output with confusion matrix and performance metrics

## 📊 Dataset Features

### CIN Dataset
```csv
document_type, cin_number, first_name, last_name, birth_date, issue_date, 
expiry_date, is_expired, ocr_confidence, image_quality, has_photo, 
text_legible, correct_format, status, score
```

### Pay Slip Dataset
```csv
document_type, employee_name, company, gross_salary, cnss_deduction, 
ir_deduction, total_deductions, net_salary, pay_month, has_company_stamp, 
amounts_match, has_required_fields, salary_consistency, months_since_issue, 
status, score
```

### Tax Declaration Dataset
```csv
document_type, taxpayer_name, fiscal_id, fiscal_year, gross_income, 
deductions, taxable_income, tax_paid, has_official_stamp, 
calculations_correct, all_fields_filled, income_reasonable, 
years_since_declaration, status, score
```

### Bank Statement Dataset
```csv
document_type, account_holder, account_number, period_start, period_end, 
period_months, opening_balance, closing_balance, average_balance, 
total_credits, total_debits, num_transactions, avg_monthly_income, 
avg_monthly_expenses, savings_rate, low_balance_incidents, has_bank_header, 
balances_match, regular_income, status, score
```

## 🎓 Model Architecture

### Classification Model (RandomForestClassifier)
- **Purpose**: Predict document status (VALID, SUSPICIOUS, INVALID, INCOMPLETE)
- **Parameters**:
  - n_estimators: 200
  - max_depth: 15
  - Features: Document-specific quality indicators
  - Output: Status label + confidence scores

### Regression Model (GradientBoostingRegressor)
- **Purpose**: Predict document quality score (0-100)
- **Parameters**:
  - n_estimators: 200
  - max_depth: 8
  - learning_rate: 0.1
  - Output: Numeric score

## 📈 Model Performance

Expected performance metrics:
- **Classification Accuracy**: ~85-92%
- **Score Prediction R²**: ~0.85-0.90
- **Mean Absolute Error (MAE)**: ~5-8 points

## 🔧 Integration with FastAPI

The trained model is automatically loaded by `ml_model_service.py` when the FastAPI server starts.

### Usage in Document Analysis

```python
from services.ml_model_service import ml_model_service

# For CIN document
prediction = ml_model_service.predict_cin_document({
    'is_expired': False,
    'ocr_confidence': 0.92,
    'image_quality': 0.88,
    'has_photo': True,
    'text_legible': True,
    'correct_format': True
})
# Returns: {'status': 'VALID', 'score': 85.2, 'confidence': 0.93, ...}

# For Pay Slip
prediction = ml_model_service.predict_payslip_document({
    'gross_salary': 8500,
    'net_salary': 7200,
    'total_deductions': 1300,
    'has_company_stamp': True,
    'amounts_match': True,
    'has_required_fields': True,
    'salary_consistency': 0.85,
    'months_since_issue': 1
})

# For Tax Declaration
prediction = ml_model_service.predict_tax_document({
    'gross_income': 120000,
    'taxable_income': 95000,
    'tax_paid': 18000,
    'has_official_stamp': True,
    'calculations_correct': True,
    'all_fields_filled': True,
    'income_reasonable': True,
    'years_since_declaration': 0
})

# For Bank Statement
prediction = ml_model_service.predict_bank_statement_document({
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
```

## 🔄 Retraining the Model

To retrain with updated data:

1. Modify `generate_dataset.py` to adjust data generation parameters
2. Run `python generate_dataset.py` to create new datasets
3. Run `python train_model.py` to retrain
4. Run `python evaluate_model.py` to verify performance
5. Restart the FastAPI server to load the new model

## 🛠️ Customization

### Adjust Sample Sizes

In `generate_dataset.py`:
```python
datasets = generate_complete_dataset(
    cin_samples=2000,      # Increase CIN samples
    payslip_samples=3000,  # Increase pay slip samples
    tax_samples=2000,
    bank_samples=3000
)
```

### Tune Model Parameters

In `train_model.py`:
```python
self.classifier = RandomForestClassifier(
    n_estimators=300,      # More trees
    max_depth=20,          # Deeper trees
    min_samples_split=5,   # More splitting
    # ... other parameters
)
```

### Add Custom Features

1. Add feature to dataset generation in `generate_dataset.py`
2. Update `prepare_features()` method in `train_model.py`
3. Update prediction methods in `ml_model_service.py`
4. Retrain the model

## 📝 Status Labels

- **VALID**: Document meets all requirements and passes validation
- **SUSPICIOUS**: Document has minor issues or inconsistencies
- **INVALID**: Document has critical errors or missing information
- **INCOMPLETE**: Document lacks required data or is outdated

## 🎯 Score Ranges

- **90-100**: Excellent quality, fully verified
- **70-89**: Good quality, minor issues
- **50-69**: Acceptable quality, some concerns
- **30-49**: Poor quality, significant issues
- **0-29**: Very poor quality, likely invalid

## 🔍 Debugging

If model loading fails, the service falls back to rule-based analysis. Check logs for:
```
⚠️  ML Model not found in models/trained. Using rule-based analysis.
```

To fix:
1. Ensure `models/trained/` directory exists
2. Run `python train_model.py` to create model files
3. Restart FastAPI server

## 📦 Dependencies

All ML packages are in `requirements.txt`:
```
pandas==2.1.3
scikit-learn==1.3.2
joblib==1.3.2
matplotlib==3.8.2
seaborn==0.13.0
```

Install with:
```bash
pip install -r requirements.txt
```

## 🎉 Success Indicators

After training, you should see:
- ✅ Classification Accuracy > 85%
- ✅ R² Score > 0.80
- ✅ MAE < 10 points
- ✅ Model files saved in `models/trained/`
- ✅ FastAPI server loads model without errors

## 🐛 Troubleshooting

**Problem**: Module not found errors
- **Solution**: Run `pip install -r requirements.txt`

**Problem**: Data files not found
- **Solution**: Run `python generate_dataset.py` first

**Problem**: Model files not found
- **Solution**: Run `python train_model.py` after generating data

**Problem**: Low model performance
- **Solution**: Increase sample sizes in `generate_dataset.py` and retrain

## 📧 Support

For issues or questions about the ML model, check:
1. This README
2. Code comments in the Python files
3. Evaluation reports in `models/trained/evaluation_report.txt`
