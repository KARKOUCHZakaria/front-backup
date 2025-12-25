"""
Model Evaluation and Testing Utilities
Test the trained model on various document types and generate performance reports
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix, classification_report, mean_absolute_error, mean_squared_error, r2_score
import json
from train_model import DocumentAnalysisModel
import os


def evaluate_model_on_test_data(model, test_datasets):
    """
    Evaluate model on test datasets
    
    Args:
        model: Trained DocumentAnalysisModel
        test_datasets: Dictionary with test data for each document type
    
    Returns:
        Dictionary with evaluation metrics
    """
    print("\n📊 Evaluating Model Performance...")
    
    results = {
        'overall': {},
        'by_document_type': {}
    }
    
    all_true_status = []
    all_pred_status = []
    all_true_scores = []
    all_pred_scores = []
    
    # Evaluate each document type
    for doc_type, df in test_datasets.items():
        doc_type_upper = doc_type.upper().replace('PAYSLIP', 'PAY_SLIP').replace('TAX', 'TAX_DECLARATION').replace('BANK', 'BANK_STATEMENT')
        
        print(f"\n📄 Evaluating {doc_type}...")
        
        predictions = []
        true_statuses = []
        true_scores = []
        
        # Get predictions for each sample
        for idx, row in df.iterrows():
            features = row.to_dict()
            
            try:
                pred = model.predict_document(features, doc_type_upper)
                predictions.append(pred)
                true_statuses.append(row['status'])
                true_scores.append(row['score'])
            except Exception as e:
                print(f"  ⚠️  Prediction failed for row {idx}: {e}")
                continue
        
        # Extract predictions
        pred_statuses = [p['status'] for p in predictions]
        pred_scores = [p['score'] for p in predictions]
        confidences = [p['confidence'] for p in predictions]
        
        # Calculate metrics
        accuracy = sum([1 for t, p in zip(true_statuses, pred_statuses) if t == p]) / len(true_statuses)
        mae = mean_absolute_error(true_scores, pred_scores)
        mse = mean_squared_error(true_scores, pred_scores)
        r2 = r2_score(true_scores, pred_scores)
        avg_confidence = np.mean(confidences)
        
        results['by_document_type'][doc_type] = {
            'accuracy': round(accuracy, 3),
            'mae': round(mae, 2),
            'mse': round(mse, 2),
            'r2': round(r2, 3),
            'avg_confidence': round(avg_confidence, 3),
            'num_samples': len(true_statuses)
        }
        
        # Add to overall results
        all_true_status.extend(true_statuses)
        all_pred_status.extend(pred_statuses)
        all_true_scores.extend(true_scores)
        all_pred_scores.extend(pred_scores)
        
        print(f"  ✅ Accuracy: {accuracy:.3f}")
        print(f"  ✅ MAE: {mae:.2f}")
        print(f"  ✅ R²: {r2:.3f}")
        print(f"  ✅ Avg Confidence: {avg_confidence:.3f}")
    
    # Calculate overall metrics
    overall_accuracy = sum([1 for t, p in zip(all_true_status, all_pred_status) if t == p]) / len(all_true_status)
    overall_mae = mean_absolute_error(all_true_scores, all_pred_scores)
    overall_mse = mean_squared_error(all_true_scores, all_pred_scores)
    overall_r2 = r2_score(all_true_scores, all_pred_scores)
    
    results['overall'] = {
        'accuracy': round(overall_accuracy, 3),
        'mae': round(overall_mae, 2),
        'mse': round(overall_mse, 2),
        'r2': round(overall_r2, 3),
        'total_samples': len(all_true_status)
    }
    
    print("\n📊 Overall Performance:")
    print(f"  ✅ Accuracy: {overall_accuracy:.3f}")
    print(f"  ✅ MAE: {overall_mae:.2f}")
    print(f"  ✅ MSE: {overall_mse:.2f}")
    print(f"  ✅ R²: {overall_r2:.3f}")
    
    # Print confusion matrix
    print("\n📊 Confusion Matrix:")
    cm = confusion_matrix(all_true_status, all_pred_status)
    labels = sorted(set(all_true_status))
    print(f"\n{' ':12} | {' | '.join([f'{l:10}' for l in labels])}")
    print("-" * (15 + 13 * len(labels)))
    for i, label in enumerate(labels):
        print(f"{label:12} | {' | '.join([f'{cm[i][j]:10}' for j in range(len(labels))])}")
    
    return results, all_true_status, all_pred_status, all_true_scores, all_pred_scores


def test_sample_predictions(model):
    """Test model with sample data for each document type"""
    print("\n🧪 Testing Sample Predictions...")
    
    # CIN Sample
    print("\n1️⃣  CIN Document:")
    cin_features = {
        'is_expired': False,
        'ocr_confidence': 0.92,
        'image_quality': 0.88,
        'has_photo': True,
        'text_legible': True,
        'correct_format': True
    }
    cin_pred = model.predict_document(cin_features, 'CIN')
    print(f"   Status: {cin_pred['status']}")
    print(f"   Score: {cin_pred['score']}")
    print(f"   Confidence: {cin_pred['confidence']}")
    
    # Pay Slip Sample
    print("\n2️⃣  Pay Slip Document:")
    payslip_features = {
        'gross_salary': 8500,
        'net_salary': 7200,
        'total_deductions': 1300,
        'has_company_stamp': True,
        'amounts_match': True,
        'has_required_fields': True,
        'salary_consistency': 0.85,
        'months_since_issue': 1
    }
    payslip_pred = model.predict_document(payslip_features, 'PAY_SLIP')
    print(f"   Status: {payslip_pred['status']}")
    print(f"   Score: {payslip_pred['score']}")
    print(f"   Confidence: {payslip_pred['confidence']}")
    
    # Tax Declaration Sample
    print("\n3️⃣  Tax Declaration Document:")
    tax_features = {
        'gross_income': 120000,
        'taxable_income': 95000,
        'tax_paid': 18000,
        'has_official_stamp': True,
        'calculations_correct': True,
        'all_fields_filled': True,
        'income_reasonable': True,
        'years_since_declaration': 0
    }
    tax_pred = model.predict_document(tax_features, 'TAX_DECLARATION')
    print(f"   Status: {tax_pred['status']}")
    print(f"   Score: {tax_pred['score']}")
    print(f"   Confidence: {tax_pred['confidence']}")
    
    # Bank Statement Sample
    print("\n4️⃣  Bank Statement Document:")
    bank_features = {
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
    }
    bank_pred = model.predict_document(bank_features, 'BANK_STATEMENT')
    print(f"   Status: {bank_pred['status']}")
    print(f"   Score: {bank_pred['score']}")
    print(f"   Confidence: {bank_pred['confidence']}")


def generate_evaluation_report(results, model_dir='models/trained'):
    """Generate evaluation report and save to file"""
    print("\n📝 Generating Evaluation Report...")
    
    report = []
    report.append("=" * 80)
    report.append("DOCUMENT ANALYSIS MODEL - EVALUATION REPORT")
    report.append("=" * 80)
    report.append("")
    
    # Overall metrics
    report.append("OVERALL PERFORMANCE:")
    report.append("-" * 80)
    for metric, value in results['overall'].items():
        report.append(f"  {metric:20}: {value}")
    report.append("")
    
    # Per document type
    report.append("PERFORMANCE BY DOCUMENT TYPE:")
    report.append("-" * 80)
    for doc_type, metrics in results['by_document_type'].items():
        report.append(f"\n{doc_type.upper()}:")
        for metric, value in metrics.items():
            report.append(f"  {metric:20}: {value}")
    
    report.append("")
    report.append("=" * 80)
    
    # Print report
    report_text = "\n".join(report)
    print(report_text)
    
    # Save report
    os.makedirs(model_dir, exist_ok=True)
    with open(f'{model_dir}/evaluation_report.txt', 'w') as f:
        f.write(report_text)
    
    # Save as JSON
    with open(f'{model_dir}/evaluation_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n✅ Report saved to {model_dir}/evaluation_report.txt")


def run_complete_evaluation():
    """Run complete model evaluation pipeline"""
    print("🚀 Starting Model Evaluation Pipeline...")
    
    # Load model
    model = DocumentAnalysisModel()
    
    if not os.path.exists('models/trained/classifier.pkl'):
        print("❌ Error: Trained model not found!")
        print("   Please run train_model.py first.")
        return
    
    model.load_model()
    
    # Load test datasets (use 20% of data for testing)
    print("\n📂 Loading test datasets...")
    test_datasets = {}
    
    for doc_type in ['cin', 'payslip', 'tax', 'bank']:
        df = pd.read_csv(f'data/{doc_type}_dataset.csv')
        # Use last 20% for testing
        test_size = int(len(df) * 0.2)
        test_datasets[doc_type] = df.tail(test_size)
    
    print(f"✅ Loaded {sum(len(df) for df in test_datasets.values())} test samples")
    
    # Evaluate model
    results, true_status, pred_status, true_scores, pred_scores = evaluate_model_on_test_data(
        model, test_datasets
    )
    
    # Generate report
    generate_evaluation_report(results)
    
    # Test sample predictions
    test_sample_predictions(model)
    
    print("\n✅ Evaluation Complete!")
    return results


if __name__ == "__main__":
    # Check if model exists
    if not os.path.exists('models/trained/classifier.pkl'):
        print("❌ Error: Trained model not found!")
        print("   Please run the following commands in order:")
        print("   1. python generate_dataset.py")
        print("   2. python train_model.py")
        print("   3. python evaluate_model.py")
        exit(1)
    
    # Run evaluation
    results = run_complete_evaluation()
