"""
Simple test to verify ML service document analysis
"""
import requests
import json

ML_URL = "http://localhost:8000"

print("=" * 60)
print("Document Analysis API Test")
print("=" * 60)
print()

# Test 1: Health Check
print("Test 1: Health Check...")
try:
    response = requests.get(f"{ML_URL}/health", timeout=5)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print("✅ Health check passed!")
except Exception as e:
    print(f"❌ Error: {e}")
    print("Make sure ML service is running on http://localhost:8000")
    exit(1)

print()
print("=" * 60)
print("ML Service is ready!")
print("=" * 60)
print()
print("Next steps:")
print("1. Upload a PDF document using the /documents/analyze endpoint")
print("2. Or use the complete evaluation with /documents/evaluate-creditworthiness")
print()
print("Example curl command:")
print('curl -X POST http://localhost:8000/documents/analyze \\')
print('  -F "file=@payslip_1_octobre_2024.pdf" \\')
print('  -F "document_type=PAY_SLIP"')
print()
