"""
Generate comprehensive training and testing dataset for document analysis
Creates realistic financial document data for CIN, Pay Slip, Tax Declaration, and Bank Statement
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Set random seed for reproducibility
np.random.seed(42)
random.seed(42)

# Moroccan first names and last names
FIRST_NAMES = ['Ahmed', 'Fatima', 'Mohammed', 'Khadija', 'Youssef', 'Amina', 'Hassan', 'Salma', 
               'Omar', 'Nadia', 'Karim', 'Zineb', 'Rachid', 'Leila', 'Said', 'Samira']
LAST_NAMES = ['Alaoui', 'Benani', 'Chraibi', 'Idrissi', 'El Fassi', 'Tazi', 'Benjelloun', 
              'Kettani', 'Berrada', 'Lahlou', 'Mansouri', 'Filali', 'Skalli', 'Ouazzani']

COMPANIES = ['BMCE Bank', 'Attijariwafa Bank', 'Maroc Telecom', 'OCP Group', 'ONCF', 
             'RAM', 'Centrale Danone', 'Lydec', 'Managem', 'COSUMAR']

CITIES = ['Casablanca', 'Rabat', 'Marrakech', 'Fes', 'Tangier', 'Agadir', 'Meknes', 'Oujda']


def generate_cin_data(n_samples=5000):
    """Generate CIN (Moroccan ID Card) data"""
    data = []
    
    for i in range(n_samples):
        # CIN number (1 letter + 6-7 digits)
        cin_prefix = random.choice(['A', 'B', 'D', 'F', 'G', 'J', 'K', 'L', 'M', 'N', 'P', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z'])
        cin_number = f"{cin_prefix}{random.randint(100000, 9999999)}"
        
        # Personal info
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        
        # Birth date (18-70 years old)
        days_ago = random.randint(18*365, 70*365)
        birth_date = datetime.now() - timedelta(days=days_ago)
        
        # ID issue and expiry
        issue_days_ago = random.randint(0, 3650)  # 0-10 years
        issue_date = datetime.now() - timedelta(days=issue_days_ago)
        expiry_date = issue_date + timedelta(days=3650)  # 10 years validity
        
        # Document quality features
        is_expired = expiry_date < datetime.now()
        ocr_confidence = np.random.normal(0.85, 0.15) if not is_expired else np.random.normal(0.65, 0.2)
        ocr_confidence = max(0.3, min(1.0, ocr_confidence))
        
        image_quality = np.random.normal(0.80, 0.15)
        image_quality = max(0.3, min(1.0, image_quality))
        
        # Validation features
        has_photo = random.random() > 0.05  # 95% have photo
        text_legible = random.random() > 0.1  # 90% legible
        correct_format = random.random() > 0.08  # 92% correct format
        
        # Status
        if is_expired or ocr_confidence < 0.5 or not has_photo or not text_legible:
            status = 'INVALID'
        elif ocr_confidence < 0.65 or image_quality < 0.6 or not correct_format:
            status = 'SUSPICIOUS'
        else:
            status = 'VALID'
        
        # Score (0-100)
        score = (ocr_confidence * 40 + image_quality * 30 + 
                (1 if not is_expired else 0) * 20 + 
                (1 if has_photo else 0) * 5 + 
                (1 if text_legible else 0) * 5)
        
        data.append({
            'document_type': 'CIN',
            'cin_number': cin_number,
            'first_name': first_name,
            'last_name': last_name,
            'birth_date': birth_date.strftime('%Y-%m-%d'),
            'issue_date': issue_date.strftime('%Y-%m-%d'),
            'expiry_date': expiry_date.strftime('%Y-%m-%d'),
            'is_expired': is_expired,
            'ocr_confidence': round(ocr_confidence, 3),
            'image_quality': round(image_quality, 3),
            'has_photo': has_photo,
            'text_legible': text_legible,
            'correct_format': correct_format,
            'status': status,
            'score': round(score, 2)
        })
    
    return pd.DataFrame(data)


def generate_payslip_data(n_samples=5000):
    """Generate Pay Slip data"""
    data = []
    
    for i in range(n_samples):
        # Employee info
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        company = random.choice(COMPANIES)
        
        # Salary (2500 - 50000 MAD)
        base_salary = np.random.lognormal(8.5, 0.8) * 100
        base_salary = max(2500, min(50000, base_salary))
        
        # Deductions
        cnss_rate = 0.0448  # CNSS employee contribution
        ir_rate = _calculate_ir_rate(base_salary)
        
        cnss_deduction = base_salary * cnss_rate
        ir_deduction = base_salary * ir_rate
        other_deductions = np.random.uniform(0, 500)
        total_deductions = cnss_deduction + ir_deduction + other_deductions
        
        net_salary = base_salary - total_deductions
        
        # Pay period
        months_ago = random.randint(0, 24)
        pay_date = datetime.now() - timedelta(days=months_ago*30)
        
        # Document quality
        has_company_stamp = random.random() > 0.1  # 90% have stamp
        amounts_match = abs(base_salary - total_deductions - net_salary) < 1  # Check calculation
        has_required_fields = random.random() > 0.12  # 88% complete
        
        # Consistency check
        salary_consistency = np.random.normal(0.85, 0.15)
        salary_consistency = max(0.3, min(1.0, salary_consistency))
        
        # Status
        if not amounts_match or not has_required_fields:
            status = 'INVALID'
        elif not has_company_stamp or salary_consistency < 0.6:
            status = 'SUSPICIOUS'
        elif months_ago > 3:
            status = 'INCOMPLETE'
        else:
            status = 'VALID'
        
        # Score based on salary and document quality
        income_score = min(100, (net_salary / 300))  # Score increases with income
        quality_score = (has_company_stamp * 20 + amounts_match * 30 + 
                        has_required_fields * 30 + salary_consistency * 20)
        score = (income_score * 0.6 + quality_score * 0.4)
        
        data.append({
            'document_type': 'PAY_SLIP',
            'employee_name': f"{first_name} {last_name}",
            'company': company,
            'gross_salary': round(base_salary, 2),
            'cnss_deduction': round(cnss_deduction, 2),
            'ir_deduction': round(ir_deduction, 2),
            'total_deductions': round(total_deductions, 2),
            'net_salary': round(net_salary, 2),
            'pay_month': pay_date.strftime('%Y-%m'),
            'has_company_stamp': has_company_stamp,
            'amounts_match': amounts_match,
            'has_required_fields': has_required_fields,
            'salary_consistency': round(salary_consistency, 3),
            'months_since_issue': months_ago,
            'status': status,
            'score': round(score, 2)
        })
    
    return pd.DataFrame(data)


def _calculate_ir_rate(annual_income):
    """Calculate Moroccan income tax rate"""
    if annual_income < 30000:
        return 0.0
    elif annual_income < 50000:
        return 0.10
    elif annual_income < 60000:
        return 0.20
    elif annual_income < 80000:
        return 0.30
    elif annual_income < 180000:
        return 0.34
    else:
        return 0.38


def generate_tax_declaration_data(n_samples=5000):
    """Generate Tax Declaration data"""
    data = []
    
    for i in range(n_samples):
        # Taxpayer info
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        
        # Fiscal ID (8 digits)
        fiscal_id = f"{random.randint(10000000, 99999999)}"
        
        # Income (30000 - 1000000 MAD annually)
        gross_income = np.random.lognormal(11.0, 0.9) * 100
        gross_income = max(30000, min(1000000, gross_income))
        
        # Deductions (5-20% of gross income)
        deduction_rate = np.random.uniform(0.05, 0.20)
        deductions = gross_income * deduction_rate
        taxable_income = gross_income - deductions
        
        # Tax calculation
        tax_rate = _calculate_ir_rate(taxable_income)
        tax_paid = taxable_income * tax_rate
        
        # Fiscal year
        fiscal_year = datetime.now().year - random.randint(0, 3)
        
        # Document quality
        has_official_stamp = random.random() > 0.08  # 92% have stamp
        calculations_correct = random.random() > 0.15  # 85% correct calculations
        all_fields_filled = random.random() > 0.10  # 90% complete
        
        # Consistency with expected income
        income_reasonable = 0.6 < (taxable_income / gross_income) < 0.95
        
        # Status
        if not calculations_correct or not all_fields_filled:
            status = 'INVALID'
        elif not has_official_stamp or not income_reasonable:
            status = 'SUSPICIOUS'
        elif (datetime.now().year - fiscal_year) > 2:
            status = 'INCOMPLETE'
        else:
            status = 'VALID'
        
        # Score
        income_score = min(100, (taxable_income / 500))
        compliance_score = (has_official_stamp * 25 + calculations_correct * 35 + 
                           all_fields_filled * 25 + income_reasonable * 15)
        score = (income_score * 0.6 + compliance_score * 0.4)
        
        data.append({
            'document_type': 'TAX_DECLARATION',
            'taxpayer_name': f"{first_name} {last_name}",
            'fiscal_id': fiscal_id,
            'fiscal_year': fiscal_year,
            'gross_income': round(gross_income, 2),
            'deductions': round(deductions, 2),
            'taxable_income': round(taxable_income, 2),
            'tax_paid': round(tax_paid, 2),
            'has_official_stamp': has_official_stamp,
            'calculations_correct': calculations_correct,
            'all_fields_filled': all_fields_filled,
            'income_reasonable': income_reasonable,
            'years_since_declaration': datetime.now().year - fiscal_year,
            'status': status,
            'score': round(score, 2)
        })
    
    return pd.DataFrame(data)


def generate_bank_statement_data(n_samples=5000):
    """Generate Bank Statement data"""
    data = []
    
    for i in range(n_samples):
        # Account holder
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        
        # Account number
        account_number = f"MA{random.randint(1000000000000000, 9999999999999999)}"
        
        # Statement period (1-6 months)
        period_months = random.randint(1, 6)
        end_date = datetime.now() - timedelta(days=random.randint(0, 60))
        start_date = end_date - timedelta(days=period_months*30)
        
        # Balances
        opening_balance = np.random.lognormal(8.0, 1.2) * 100
        opening_balance = max(0, min(500000, opening_balance))
        
        # Transactions
        num_transactions = random.randint(10, 200)
        
        # Credits (income)
        monthly_credits = np.random.lognormal(8.2, 0.9) * 100
        monthly_credits = max(1000, min(100000, monthly_credits))
        total_credits = monthly_credits * period_months
        
        # Debits (expenses)
        expense_ratio = np.random.uniform(0.60, 1.20)  # Some save, some overspend
        total_debits = total_credits * expense_ratio
        
        # Closing balance
        closing_balance = opening_balance + total_credits - total_debits
        closing_balance = max(0, closing_balance)
        
        # Average balance
        average_balance = (opening_balance + closing_balance) / 2
        
        # Quality checks
        has_bank_header = random.random() > 0.05  # 95% have header
        balances_match = abs((opening_balance + total_credits - total_debits) - closing_balance) < 100
        regular_income = random.random() > 0.3  # 70% show regular income pattern
        
        # Financial health indicators
        avg_monthly_income = total_credits / period_months
        avg_monthly_expenses = total_debits / period_months
        savings_rate = (avg_monthly_income - avg_monthly_expenses) / avg_monthly_income if avg_monthly_income > 0 else -0.5
        
        low_balance_incidents = random.randint(0, period_months) if closing_balance < 500 else 0
        
        # Status
        if not balances_match or not has_bank_header:
            status = 'INVALID'
        elif closing_balance < 0 or low_balance_incidents > 2 or not regular_income:
            status = 'SUSPICIOUS'
        elif period_months < 3:
            status = 'INCOMPLETE'
        else:
            status = 'VALID'
        
        # Score
        balance_score = min(100, average_balance / 100)
        income_score = min(100, avg_monthly_income / 50)
        stability_score = (regular_income * 30 + (savings_rate > 0) * 30 + 
                          (low_balance_incidents == 0) * 40)
        score = (balance_score * 0.2 + income_score * 0.4 + stability_score * 0.4)
        
        data.append({
            'document_type': 'BANK_STATEMENT',
            'account_holder': f"{first_name} {last_name}",
            'account_number': account_number,
            'period_start': start_date.strftime('%Y-%m-%d'),
            'period_end': end_date.strftime('%Y-%m-%d'),
            'period_months': period_months,
            'opening_balance': round(opening_balance, 2),
            'closing_balance': round(closing_balance, 2),
            'average_balance': round(average_balance, 2),
            'total_credits': round(total_credits, 2),
            'total_debits': round(total_debits, 2),
            'num_transactions': num_transactions,
            'avg_monthly_income': round(avg_monthly_income, 2),
            'avg_monthly_expenses': round(avg_monthly_expenses, 2),
            'savings_rate': round(savings_rate, 3),
            'low_balance_incidents': low_balance_incidents,
            'has_bank_header': has_bank_header,
            'balances_match': balances_match,
            'regular_income': regular_income,
            'status': status,
            'score': round(score, 2)
        })
    
    return pd.DataFrame(data)


def generate_complete_dataset(cin_samples=1000, payslip_samples=1500, 
                              tax_samples=1000, bank_samples=1500):
    """Generate complete dataset with all document types"""
    print("🔄 Generating CIN data...")
    cin_df = generate_cin_data(cin_samples)
    
    print("🔄 Generating Pay Slip data...")
    payslip_df = generate_payslip_data(payslip_samples)
    
    print("🔄 Generating Tax Declaration data...")
    tax_df = generate_tax_declaration_data(tax_samples)
    
    print("🔄 Generating Bank Statement data...")
    bank_df = generate_bank_statement_data(bank_samples)
    
    print("\n✅ Dataset generation complete!")
    print(f"   CIN: {len(cin_df)} samples")
    print(f"   Pay Slips: {len(payslip_df)} samples")
    print(f"   Tax Declarations: {len(tax_df)} samples")
    print(f"   Bank Statements: {len(bank_df)} samples")
    print(f"   Total: {len(cin_df) + len(payslip_df) + len(tax_df) + len(bank_df)} samples")
    
    return {
        'cin': cin_df,
        'payslip': payslip_df,
        'tax': tax_df,
        'bank': bank_df
    }


if __name__ == "__main__":
    # Generate datasets
    datasets = generate_complete_dataset(
        cin_samples=1000,
        payslip_samples=1500,
        tax_samples=1000,
        bank_samples=1500
    )
    
    # Save to CSV files
    print("\n💾 Saving datasets to CSV files...")
    datasets['cin'].to_csv('data/cin_dataset.csv', index=False)
    datasets['payslip'].to_csv('data/payslip_dataset.csv', index=False)
    datasets['tax'].to_csv('data/tax_dataset.csv', index=False)
    datasets['bank'].to_csv('data/bank_dataset.csv', index=False)
    
    # Also save combined dataset
    combined_df = pd.concat([
        datasets['cin'],
        datasets['payslip'],
        datasets['tax'],
        datasets['bank']
    ], ignore_index=True)
    
    combined_df.to_csv('data/combined_documents_dataset.csv', index=False)
    
    print("✅ All datasets saved!")
    print("\nFiles created:")
    print("  - data/cin_dataset.csv")
    print("  - data/payslip_dataset.csv")
    print("  - data/tax_dataset.csv")
    print("  - data/bank_dataset.csv")
    print("  - data/combined_documents_dataset.csv")
    
    # Print statistics
    print("\n📊 Dataset Statistics:")
    for doc_type, df in datasets.items():
        print(f"\n{doc_type.upper()}:")
        print(f"  Status distribution:")
        print(df['status'].value_counts())
        print(f"  Average score: {df['score'].mean():.2f}")
        print(f"  Score range: {df['score'].min():.2f} - {df['score'].max():.2f}")
