"""
Test script for document analysis and creditworthiness evaluation
"""
import requests
import json
import os

# Configuration
ML_API_URL = "http://localhost:8000"

def test_analyze_single_document():
    """Test analyzing a single pay slip document"""
    print("\n" + "="*60)
    print("TEST 1: Analyze Single Pay Slip Document")
    print("="*60)
    
    # Test with pay slip
    with open('payslip_1_octobre_2024.pdf', 'rb') as f:
        files = {
            'file': ('payslip_1_octobre_2024.pdf', f, 'application/pdf')
        }
        data = {
            'document_type': 'pay_slip'
        }
        
        response = requests.post(
            f"{ML_API_URL}/documents/analyze",
            files=files,
            data=data
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n✅ Analysis successful!")
            print(f"Document Type: {result.get('document_type')}")
            
            # Show extracted data
            extracted = result.get('extracted_data', {})
            if extracted:
                print(f"\nExtracted Data:")
                print(json.dumps(extracted, indent=2))
            
            # Show scores
            scores = result.get('scores', {})
            if scores:
                print(f"\nScores:")
                for score_name, score_value in scores.items():
                    print(f"  - {score_name}: {score_value}")
            
            print(f"\nRating: {result.get('rating')}")
            
            # Show issues
            if result.get('issues'):
                print(f"\n⚠️ Issues:")
                for issue in result['issues']:
                    print(f"  - {issue}")
            
            # Show recommendations
            if result.get('recommendations'):
                print(f"\n💡 Recommendations:")
                for rec in result['recommendations']:
                    print(f"  - {rec}")
                    
            if result.get('recommendations'):
                print(f"\n💡 Recommendations:")
                for rec in result['recommendations']:
                    print(f"  - {rec}")
        else:
            print(f"\n❌ Failed: {response.status_code}")
            print(response.text)


def test_analyze_tax_declaration():
    """Test analyzing a tax declaration"""
    print("\n" + "="*60)
    print("TEST 2: Analyze Tax Declaration")
    print("="*60)
    
    with open('tax_declaration_2024.pdf', 'rb') as f:
        files = {
            'file': ('tax_declaration_2024.pdf', f, 'application/pdf')
        }
        data = {
            'document_type': 'tax_declaration'
        }
        
        response = requests.post(
            f"{ML_API_URL}/documents/analyze",
            files=files,
            data=data
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n✅ Analysis successful!")
            print(f"Document Type: {result.get('document_type')}")
            
            # Show extracted data
            extracted = result.get('extracted_data', {})
            if extracted:
                print(f"\nExtracted Data:")
                print(json.dumps(extracted, indent=2))
            
            # Show scores
            scores = result.get('scores', {})
            if scores:
                print(f"\nScores:")
                for score_name, score_value in scores.items():
                    print(f"  - {score_name}: {score_value}")
            
            print(f"\nRating: {result.get('rating')}")
            
            # Show issues/recommendations
            if result.get('issues'):
                print(f"\n⚠️ Issues: {result['issues']}")
            if result.get('recommendations'):
                print(f"\n💡 Recommendations:")
                for rec in result['recommendations']:
                    print(f"  - {rec}")
        else:
            print(f"\n❌ Failed: {response.status_code}")
            print(response.text)


def test_evaluate_creditworthiness():
    """Test evaluating creditworthiness with multiple documents"""
    print("\n" + "="*60)
    print("TEST 3: Evaluate Creditworthiness (Full Assessment)")
    print("="*60)
    
    # Prepare all documents
    files = {
        'pay_slip_1': open('payslip_1_octobre_2024.pdf', 'rb'),
        'pay_slip_2': open('payslip_2_novembre_2024.pdf', 'rb'),
        'pay_slip_3': open('payslip_3_décembre_2024.pdf', 'rb'),
        'tax_declaration': open('tax_declaration_2024.pdf', 'rb'),
        'bank_statement': open('bank_statement_recent.pdf', 'rb')
    }
    
    # Credit application details
    data = {
        'requested_credit': 50000.0,  # Requesting 50,000 MAD
        'monthly_payment': 2500.0      # Proposed monthly payment 2,500 MAD
    }
    
    try:
        response = requests.post(
            f"{ML_API_URL}/documents/evaluate-creditworthiness",
            files=files,
            data=data
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n✅ Evaluation complete!")
            print("\n" + "="*60)
            print("CREDITWORTHINESS ASSESSMENT")
            print("="*60)
            
            print(f"\n📊 Overall Score: {result['overall_score']}/100")
            print(f"⭐ Rating: {result['rating']}")
            print(f"📝 Decision: {result['decision']}")
            print(f"⚠️ Risk Level: {result['risk_level']}")
            
            print(f"\n💵 Monthly Income: {result['monthly_income']:,.2f} MAD")
            print(f"📉 Debt Ratio: {result['debt_ratio']:.1f}%")
            
            print(f"\n📈 Score Breakdown:")
            print(f"  Income Score: {result['income_score']}/100")
            print(f"  Consistency Score: {result['consistency_score']}/100")
            print(f"  Debt Ratio Score: {result['debt_ratio_score']}/100")
            print(f"  Document Quality: {result['document_quality_score']}/100")
            
            if result.get('strengths'):
                print(f"\n✅ Strengths:")
                for strength in result['strengths']:
                    print(f"  ✓ {strength}")
            
            if result.get('weaknesses'):
                print(f"\n⚠️ Weaknesses:")
                for weakness in result['weaknesses']:
                    print(f"  ✗ {weakness}")
            
            if result.get('missing_documents'):
                print(f"\n📄 Missing Documents:")
                for doc in result['missing_documents']:
                    print(f"  - {doc}")
            
            if result.get('required_actions'):
                print(f"\n🔔 Required Actions:")
                for action in result['required_actions']:
                    print(f"  • {action}")
        else:
            print(f"\n❌ Failed: {response.status_code}")
            print(response.text)
    finally:
        # Close all files
        for f in files.values():
            f.close()


def test_insufficient_documents():
    """Test with insufficient documents (should suggest what's missing)"""
    print("\n" + "="*60)
    print("TEST 4: Insufficient Documents (Only 1 Pay Slip)")
    print("="*60)
    
    files = {
        'pay_slip_1': open('payslip_1_octobre_2024.pdf', 'rb')
    }
    
    data = {
        'requested_credit': 30000.0,
        'monthly_payment': 1500.0
    }
    
    try:
        response = requests.post(
            f"{ML_API_URL}/documents/evaluate-creditworthiness",
            files=files,
            data=data
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n📊 Score: {result['overall_score']}/100")
            print(f"📝 Decision: {result['decision']}")
            
            if result.get('missing_documents'):
                print(f"\n📄 Missing Documents:")
                for doc in result['missing_documents']:
                    print(f"  ❌ {doc}")
        else:
            print(f"\n❌ Failed: {response.status_code}")
    finally:
        files['pay_slip_1'].close()


if __name__ == "__main__":
    print("\n" + "="*60)
    print("DOCUMENT ANALYSIS & CREDITWORTHINESS TESTING")
    print("="*60)
    print(f"ML API: {ML_API_URL}")
    
    # Check if ML service is running
    try:
        response = requests.get(f"{ML_API_URL}/health")
        if response.status_code == 200:
            print("✅ ML Service is running")
        else:
            print("⚠️ ML Service is not healthy")
            exit(1)
    except Exception as e:
        print(f"❌ Cannot connect to ML service: {e}")
        print("Please start the ML service first: python ml/main.py")
        exit(1)
    
    # Run tests
    test_analyze_single_document()
    test_analyze_tax_declaration()
    test_evaluate_creditworthiness()
    test_insufficient_documents()
    
    print("\n" + "="*60)
    print("ALL TESTS COMPLETED")
    print("="*60)
