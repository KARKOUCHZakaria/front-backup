"""
Simple test for document analysis API - Windows compatible
"""
import requests
import json

ML_URL = "http://localhost:8000"

def test_health():
    print("\n=== Testing ML Health ===")
    r = requests.get(f"{ML_URL}/health")
    print(f"Status: {r.status_code}")
    print(f"Response: {r.json()}")

def test_pay_slip():
    print("\n=== Testing Pay Slip Analysis ===")
    with open('payslip_1_octobre_2024.pdf', 'rb') as f:
        files = {'file': f}
        data = {'document_type': 'PAY_SLIP'}
        r = requests.post(f"{ML_URL}/documents/analyze", files=files, data=data)
        print(f"Status: {r.status_code}")
        if r.status_code == 200:
            result = r.json()
            print(f"Type: {result.get('document_type')}")
            print(f"Rating: {result.get('rating')}")
            print(f"Scores: {json.dumps(result.get('scores', {}), indent=2)}")
        else:
            print(f"Error: {r.text}")

def test_tax_declaration():
    print("\n=== Testing Tax Declaration Analysis ===")
    with open('tax_declaration_2024.pdf', 'rb') as f:
        files = {'file': f}
        data = {'document_type': 'TAX_DECLARATION'}
        r = requests.post(f"{ML_URL}/documents/analyze", files=files, data=data)
        print(f"Status: {r.status_code}")
        if r.status_code == 200:
            result = r.json()
            print(f"Type: {result.get('document_type')}")
            print(f"Rating: {result.get('rating')}")
            print(f"Scores: {json.dumps(result.get('scores', {}), indent=2)}")
        else:
            print(f"Error: {r.text}")

def test_bank_statement():
    print("\n=== Testing Bank Statement Analysis ===")
    with open('bank_statement_recent.pdf', 'rb') as f:
        files = {'file': f}
        data = {'document_type': 'BANK_STATEMENT'}
        r = requests.post(f"{ML_URL}/documents/analyze", files=files, data=data)
        print(f"Status: {r.status_code}")
        if r.status_code == 200:
            result = r.json()
            print(f"Type: {result.get('document_type')}")
            print(f"Rating: {result.get('rating')}")
            print(f"Scores: {json.dumps(result.get('scores', {}), indent=2)}")
        else:
            print(f"Error: {r.text}")

def test_creditworthiness():
    print("\n=== Testing Full Creditworthiness Evaluation ===")
    
    files = {
        'pay_slip_1': open('payslip_1_octobre_2024.pdf', 'rb'),
        'pay_slip_2': open('payslip_2_novembre_2024.pdf', 'rb'),
        'pay_slip_3': open('payslip_3_décembre_2024.pdf', 'rb'),
        'tax_declaration': open('tax_declaration_2024.pdf', 'rb'),
        'bank_statement': open('bank_statement_recent.pdf', 'rb')
    }
    
    data = {
        'requested_credit': 50000,
        'monthly_payment': 2000
    }
    
    try:
        r = requests.post(
            f"{ML_URL}/documents/evaluate-creditworthiness",
            files=files,
            data=data
        )
        
        print(f"Status: {r.status_code}")
        if r.status_code == 200:
            result = r.json()
            print(f"\nOverall Score: {result.get('overall_score')}/100")
            print(f"Rating: {result.get('rating')}")
            print(f"Decision: {result.get('decision')}")
            print(f"Reason: {result.get('decision_reason')}")
            print(f"Monthly Income: {result.get('monthly_income')} MAD")
            print(f"Max Credit Limit: {result.get('max_credit_limit')} MAD")
            print(f"Eligible: {result.get('is_eligible')}")
            
            if result.get('recommendations'):
                print(f"\nRecommendations:")
                for rec in result['recommendations']:
                    print(f"  - {rec}")
            
            if result.get('document_scores'):
                print(f"\nDocument Scores:")
                for doc, score in result['document_scores'].items():
                    print(f"  - {doc}: {score}/100")
        else:
            print(f"Error: {r.text}")
    finally:
        for f in files.values():
            f.close()

if __name__ == "__main__":
    try:
        test_health()
        test_pay_slip()
        test_tax_declaration()
        test_bank_statement()
        test_creditworthiness()
        print("\n=== ALL TESTS COMPLETED ===")
    except Exception as e:
        print(f"\nERROR: {e}")
