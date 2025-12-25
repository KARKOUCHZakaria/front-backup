"""
CIN OCR Service - FastAPI application for reading Moroccan CIN cards
"""
from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
from typing import Optional, List
import logging

from services.ocr_service import OCRService
from services.image_processor import ImageProcessor
from services.document_analyzer import DocumentAnalyzer
from services.scoring_service import document_scoring_service
from models.cin_data import CINData, CINResponse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="CIN OCR Service",
    description="Optical Character Recognition service for Moroccan CIN cards",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
ocr_service = OCRService()
image_processor = ImageProcessor()
document_analyzer = DocumentAnalyzer()


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "CIN OCR Service",
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "cin-ocr",
        "version": "1.0.0"
    }


@app.post("/ocr/cin", response_model=CINResponse)
async def extract_cin_info(
    file: UploadFile = File(...),
    enhance: bool = True
):
    """
    Extract information from CIN image
    
    Args:
        file: Image file of the CIN card
        enhance: Whether to apply image enhancement (default: True)
        
    Returns:
        CINResponse with extracted information
    """
    logger.info(f"🔵 Received CIN OCR request - File: {file.filename}, Size: {file.size} bytes")
    
    try:
        # Validate file type
        if not file.content_type.startswith('image/'):
            logger.error(f"❌ Invalid file type: {file.content_type}")
            raise HTTPException(
                status_code=400,
                detail="File must be an image"
            )
        
        # Read image file
        image_bytes = await file.read()
        logger.info(f"📷 Image loaded - {len(image_bytes)} bytes")
        
        # Process image
        processed_image = image_processor.preprocess_cin_image(
            image_bytes,
            enhance=enhance
        )
        logger.info("✅ Image preprocessed successfully")
        
        # Extract text using OCR
        extracted_text = ocr_service.extract_text_from_image(processed_image)
        logger.info(f"📄 Extracted text: {len(extracted_text)} characters")
        
        # Parse CIN information
        cin_data = ocr_service.parse_cin_data(extracted_text)
        logger.info(f"✅ CIN data parsed - CIN: {cin_data.cin_number}")
        
        return CINResponse(
            success=True,
            message="CIN information extracted successfully",
            data=cin_data,
            raw_text=extracted_text if cin_data.confidence < 0.8 else None
        )
        
    except ValueError as e:
        logger.error(f"❌ Validation error: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    
    except Exception as e:
        logger.error(f"❌ OCR processing failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process CIN image: {str(e)}"
        )


@app.post("/ocr/verify")
async def verify_cin(
    file: UploadFile = File(...),
    expected_cin: Optional[str] = None
):
    """
    Verify CIN image and optionally check against expected CIN number
    
    Args:
        file: Image file of the CIN card
        expected_cin: Expected CIN number to verify against
        
    Returns:
        Verification result
    """
    logger.info(f"🔵 Received CIN verification request - Expected: {expected_cin}")
    
    try:
        # Extract CIN info
        image_bytes = await file.read()
        processed_image = image_processor.preprocess_cin_image(image_bytes)
        extracted_text = ocr_service.extract_text_from_image(processed_image)
        cin_data = ocr_service.parse_cin_data(extracted_text)
        
        # Verify if expected CIN is provided
        matches = True
        if expected_cin:
            matches = cin_data.cin_number == expected_cin.upper().replace(" ", "")
            logger.info(f"🔍 CIN match: {matches} (Expected: {expected_cin}, Found: {cin_data.cin_number})")
        
        return {
            "success": True,
            "verified": matches,
            "cin_number": cin_data.cin_number,
            "confidence": cin_data.confidence,
            "message": "CIN verified successfully" if matches else "CIN does not match"
        }
        
    except Exception as e:
        logger.error(f"❌ Verification failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Verification failed: {str(e)}"
        )


@app.post("/documents/analyze")
async def analyze_document(
    file: UploadFile = File(...),
    document_type: str = Form(...)
):
    """
    Analyze a single financial document and extract information
    
    Args:
        file: PDF document file
        document_type: Type of document (PAY_SLIP, TAX_DECLARATION, BANK_STATEMENT)
        
    Returns:
        Analysis result with extracted data and credit scoring
    """
    logger.info(f"🔵 Received document analysis request - Type: {document_type}, File: {file.filename}")
    
    try:
        # Validate file type
        if not file.content_type or 'pdf' not in file.content_type.lower():
            raise HTTPException(
                status_code=400,
                detail="Only PDF files are supported"
            )
        
        # Read file
        file_bytes = await file.read()
        logger.info(f"📄 Document loaded - {len(file_bytes)} bytes")
        
        # Extract text from PDF
        text_content = document_analyzer.extract_text_from_pdf(file_bytes)
        logger.info(f"📝 Extracted {len(text_content)} characters from PDF")
        
        # Analyze document based on type
        result = document_analyzer.analyze_single_document(text_content, document_type.upper())
        logger.info(f"✅ Document analyzed - Extracted data: {len(result.get('extracted_data', {}))} fields")
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Document analysis failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Failed to analyze document: {str(e)}"
        )


@app.post("/documents/evaluate-creditworthiness")
async def evaluate_creditworthiness(
    requested_credit: float = Form(0),
    monthly_payment: float = Form(0),
    pay_slip_1: Optional[UploadFile] = File(None),
    pay_slip_2: Optional[UploadFile] = File(None),
    pay_slip_3: Optional[UploadFile] = File(None),
    tax_declaration: Optional[UploadFile] = File(None),
    bank_statement: Optional[UploadFile] = File(None)
):
    """
    Evaluate creditworthiness based on multiple uploaded documents
    
    Args:
        requested_credit: Amount of credit requested
        monthly_payment: Proposed monthly payment
        pay_slip_1, pay_slip_2, pay_slip_3: Recent pay slips (3 months)
        tax_declaration: Annual tax declaration
        bank_statement: Recent bank statement
        
    Returns:
        Complete creditworthiness assessment with decision
    """
    logger.info(f"🔵 Creditworthiness evaluation - Credit: {requested_credit} MAD, Payment: {monthly_payment} MAD")
    
    try:
        documents = {}
        
        # Analyze pay slips
        pay_slips_data = []
        for i, pay_slip in enumerate([pay_slip_1, pay_slip_2, pay_slip_3], 1):
            if pay_slip and pay_slip.filename:
                logger.info(f"📄 Analyzing pay slip {i}: {pay_slip.filename}")
                file_bytes = await pay_slip.read()
                text_content = document_analyzer.extract_text_from_pdf(file_bytes)
                result = document_analyzer.analyze_single_document(text_content, "PAY_SLIP")
                pay_slips_data.append(result)
        
        if pay_slips_data:
            documents['PAY_SLIP'] = pay_slips_data
        
        # Analyze tax declaration
        if tax_declaration and tax_declaration.filename:
            logger.info(f"📄 Analyzing tax declaration: {tax_declaration.filename}")
            file_bytes = await tax_declaration.read()
            text_content = document_analyzer.extract_text_from_pdf(file_bytes)
            result = document_analyzer.analyze_single_document(text_content, "TAX_DECLARATION")
            documents['TAX_DECLARATION'] = result
        
        # Analyze bank statement
        if bank_statement and bank_statement.filename:
            logger.info(f"📄 Analyzing bank statement: {bank_statement.filename}")
            file_bytes = await bank_statement.read()
            text_content = document_analyzer.extract_text_from_pdf(file_bytes)
            result = document_analyzer.analyze_single_document(text_content, "BANK_STATEMENT")
            documents['BANK_STATEMENT'] = result
        
        if not documents:
            raise HTTPException(
                status_code=400,
                detail="No valid documents provided"
            )
        
        # Calculate overall creditworthiness
        assessment = document_analyzer.calculate_overall_creditworthiness(
            documents,
            requested_credit,
            monthly_payment
        )
        
        logger.info(f"✅ Creditworthiness evaluated - Score: {assessment['overall_score']:.1f}, Decision: {assessment['decision']}")
        
        return assessment
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Creditworthiness evaluation failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Failed to evaluate creditworthiness: {str(e)}"
        )


@app.post("/score/cin")
async def score_cin(
    is_expired: bool = Form(False),
    ocr_confidence: float = Form(0.85),
    image_quality: float = Form(0.85),
    has_photo: bool = Form(True),
    text_legible: bool = Form(True),
    correct_format: bool = Form(True)
):
    """
    Score CIN document
    Returns a score from 0-100
    """
    try:
        features = {
            'is_expired': is_expired,
            'ocr_confidence': ocr_confidence,
            'image_quality': image_quality,
            'has_photo': has_photo,
            'text_legible': text_legible,
            'correct_format': correct_format
        }
        
        score = document_scoring_service.score_cin(features)
        
        return {
            "document_type": "CIN",
            "score": round(score, 2),
            "features": features
        }
    except Exception as e:
        logger.error(f"CIN scoring failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/score/payslip")
async def score_payslip(
    gross_salary: float = Form(...),
    net_salary: float = Form(...),
    total_deductions: float = Form(...),
    has_company_stamp: bool = Form(True),
    amounts_match: bool = Form(True),
    has_required_fields: bool = Form(True),
    salary_consistency: float = Form(0.85),
    months_since_issue: int = Form(0)
):
    """
    Score Pay Slip document
    Returns a score from 0-100
    """
    try:
        features = {
            'gross_salary': gross_salary,
            'net_salary': net_salary,
            'total_deductions': total_deductions,
            'has_company_stamp': has_company_stamp,
            'amounts_match': amounts_match,
            'has_required_fields': has_required_fields,
            'salary_consistency': salary_consistency,
            'months_since_issue': months_since_issue
        }
        
        score = document_scoring_service.score_payslip(features)
        
        return {
            "document_type": "PAY_SLIP",
            "score": round(score, 2),
            "features": features
        }
    except Exception as e:
        logger.error(f"Pay slip scoring failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/score/tax")
async def score_tax(
    gross_income: float = Form(...),
    taxable_income: float = Form(...),
    tax_paid: float = Form(...),
    has_official_stamp: bool = Form(True),
    calculations_correct: bool = Form(True),
    all_fields_filled: bool = Form(True),
    income_reasonable: bool = Form(True),
    years_since_declaration: int = Form(0)
):
    """
    Score Tax Declaration document
    Returns a score from 0-100
    """
    try:
        features = {
            'gross_income': gross_income,
            'taxable_income': taxable_income,
            'tax_paid': tax_paid,
            'has_official_stamp': has_official_stamp,
            'calculations_correct': calculations_correct,
            'all_fields_filled': all_fields_filled,
            'income_reasonable': income_reasonable,
            'years_since_declaration': years_since_declaration
        }
        
        score = document_scoring_service.score_tax(features)
        
        return {
            "document_type": "TAX_DECLARATION",
            "score": round(score, 2),
            "features": features
        }
    except Exception as e:
        logger.error(f"Tax scoring failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/score/bank")
async def score_bank(
    period_months: int = Form(...),
    opening_balance: float = Form(...),
    closing_balance: float = Form(...),
    average_balance: float = Form(...),
    total_credits: float = Form(...),
    total_debits: float = Form(...),
    avg_monthly_income: float = Form(...),
    avg_monthly_expenses: float = Form(...),
    savings_rate: float = Form(...),
    low_balance_incidents: int = Form(0),
    has_bank_header: bool = Form(True),
    balances_match: bool = Form(True),
    regular_income: bool = Form(True)
):
    """
    Score Bank Statement document
    Returns a score from 0-100
    """
    try:
        features = {
            'period_months': period_months,
            'opening_balance': opening_balance,
            'closing_balance': closing_balance,
            'average_balance': average_balance,
            'total_credits': total_credits,
            'total_debits': total_debits,
            'avg_monthly_income': avg_monthly_income,
            'avg_monthly_expenses': avg_monthly_expenses,
            'savings_rate': savings_rate,
            'low_balance_incidents': low_balance_incidents,
            'has_bank_header': has_bank_header,
            'balances_match': balances_match,
            'regular_income': regular_income
        }
        
        score = document_scoring_service.score_bank(features)
        
        return {
            "document_type": "BANK_STATEMENT",
            "score": round(score, 2),
            "features": features
        }
    except Exception as e:
        logger.error(f"Bank scoring failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/analyze/document")
async def analyze_document_file(file: UploadFile = File(...), document_type: str = Form(...)):
    """
    Analyze uploaded document file and return score
    Accepts: PAY_SLIP, TAX_DECLARATION, BANK_STATEMENT
    Returns score from 0-100 based on file analysis
    """
    logger.info(f"📄 Analyzing {document_type}: {file.filename}")
    
    try:
        # Read file
        content = await file.read()
        file_size = len(content)
        
        # Basic validation
        if file_size == 0:
            return {"document_type": document_type, "score": 0.0, "error": "Empty file"}
        
        # Score based on document type and basic heuristics
        base_score = 75.0
        
        # File size bonus (larger files often have more content)
        if file_size > 50000:  # > 50KB
            base_score += 10.0
        elif file_size > 10000:  # > 10KB
            base_score += 5.0
        
        # Check file extension
        filename = file.filename.lower()
        if filename.endswith('.pdf'):
            base_score += 10.0  # PDFs are typically more complete
        elif filename.endswith(('.jpg', '.jpeg', '.png')):
            base_score += 5.0
        
        # Document type specific bonuses
        if document_type == "PAY_SLIP":
            # Check for common payslip keywords in filename
            if any(word in filename for word in ['salary', 'payslip', 'salaire', 'fiche']):
                base_score += 5.0
        elif document_type == "TAX_DECLARATION":
            if any(word in filename for word in ['tax', 'declaration', 'fiscal', 'impot']):
                base_score += 5.0
        elif document_type == "BANK_STATEMENT":
            if any(word in filename for word in ['bank', 'statement', 'releve', 'bancaire']):
                base_score += 5.0
        
        # Cap at 100
        final_score = min(base_score, 100.0)
        
        logger.info(f"✅ {document_type} score: {final_score}")
        
        return {
            "document_type": document_type,
            "score": round(final_score, 2),
            "file_size": file_size,
            "filename": file.filename
        }
        
    except Exception as e:
        logger.error(f"❌ Error analyzing {document_type}: {e}")
        return {"document_type": document_type, "score": 50.0, "error": str(e)}


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
