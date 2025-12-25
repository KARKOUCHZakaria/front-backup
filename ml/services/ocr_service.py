"""
OCR service using Tesseract for text extraction from CIN cards
"""
import pytesseract
import re
import numpy as np
from typing import Optional
import logging

from models.cin_data import CINData

logger = logging.getLogger(__name__)


class OCRService:
    """OCR service for extracting text from images"""
    
    def __init__(self):
        """Initialize OCR service"""
        # Set Tesseract path BEFORE checking if it's available (Windows fix)
        import os
        windows_paths = [
            r'C:\Program Files\Tesseract-OCR\tesseract.exe',
            r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
        ]
        
        for path in windows_paths:
            if os.path.exists(path):
                pytesseract.pytesseract.tesseract_cmd = path
                logger.info(f"✅ Tesseract configured at: {path}")
                break
        
        # Now check if Tesseract is available
        self.tesseract_available = self._check_tesseract()
    
    def _check_tesseract(self) -> bool:
        """Check if Tesseract is available"""
        try:
            version = pytesseract.get_tesseract_version()
            logger.info(f"✅ Tesseract OCR available: v{version}")
            return True
        except Exception as e:
            logger.warning(f"⚠️ Tesseract OCR not available: {e}")
            logger.warning("⚠️ OCR functionality will be limited. See TESSERACT_SETUP.md")
            return False
    
    def extract_text_from_image(self, image: np.ndarray, lang: str = 'eng+ara') -> str:
        """
        Extract text from image using Tesseract OCR
        
        Args:
            image: Preprocessed image
            lang: Language codes (default: English + Arabic)
            
        Returns:
            Extracted text
        """
        if not self.tesseract_available:
            logger.error("❌ Tesseract not available - cannot extract text")
            raise Exception(
                "Tesseract OCR is not installed. "
                "Please install Tesseract or see TESSERACT_SETUP.md for instructions. "
                "Alternative: Disable OCR verification in backend AuthController."
            )
        
        try:
            # Configure Tesseract
            custom_config = r'--oem 3 --psm 6'
            
            # Extract text
            text = pytesseract.image_to_string(
                image,
                lang=lang,
                config=custom_config
            )
            
            logger.info(f"📄 Extracted {len(text)} characters")
            return text.strip()
            
        except Exception as e:
            logger.error(f"❌ Text extraction failed: {str(e)}")
            raise ValueError(f"Failed to extract text: {str(e)}")
    
    def parse_cin_data(self, text: str) -> CINData:
        """
        Parse CIN information from extracted text
        
        Args:
            text: Extracted text from OCR
            
        Returns:
            Parsed CIN data
        """
        logger.info("🔍 Parsing CIN data from extracted text")
        
        # Clean text
        text = text.replace('\n', ' ').replace('  ', ' ')
        
        # Extract CIN number (format: AB123456 or A123456)
        cin_number = self._extract_cin_number(text)
        if not cin_number:
            logger.warning("⚠️ CIN number not found in text")
            raise ValueError("CIN number not found in the image")
        
        # Extract other fields
        first_name = self._extract_field(text, ['prénom', 'prenom', 'first name', 'الإسم'])
        last_name = self._extract_field(text, ['nom', 'last name', 'النسب'])
        date_of_birth = self._extract_date(text, ['né', 'ne', 'birth', 'الميلاد'])
        gender = self._extract_gender(text)
        
        # Calculate confidence based on extracted fields
        confidence = self._calculate_confidence(
            cin_number, first_name, last_name, date_of_birth
        )
        
        logger.info(f"✅ CIN parsed - Number: {cin_number}, Confidence: {confidence:.2f}")
        
        return CINData(
            cin_number=cin_number,
            first_name=first_name,
            last_name=last_name,
            date_of_birth=date_of_birth,
            gender=gender,
            confidence=confidence
        )
    
    def _extract_cin_number(self, text: str) -> Optional[str]:
        """Extract CIN number from text"""
        # Moroccan CIN format: 1-2 letters followed by 5-6 digits
        patterns = [
            r'\b([A-Z]{1,2}\d{5,6})\b',  # AB123456 or A123456
            r'CIN[:\s]*([A-Z]{1,2}\d{5,6})',
            r'N°[:\s]*([A-Z]{1,2}\d{5,6})',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text.upper())
            if match:
                return match.group(1)
        
        return None
    
    def _extract_field(self, text: str, keywords: list) -> Optional[str]:
        """Extract field value after keywords"""
        for keyword in keywords:
            pattern = rf'{keyword}[:\s]+([A-Za-zÀ-ÿ\u0600-\u06FF\s]+)'
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                value = match.group(1).strip()
                # Clean up - take only the first reasonable name
                value = re.split(r'[0-9\n\r]', value)[0].strip()
                if len(value) > 2 and len(value) < 50:
                    return value
        return None
    
    def _extract_date(self, text: str, keywords: list) -> Optional[str]:
        """Extract date from text"""
        # Date patterns: DD.MM.YYYY, DD/MM/YYYY, DD-MM-YYYY
        date_patterns = [
            r'(\d{2}[./\-]\d{2}[./\-]\d{4})',
            r'(\d{1,2}\s+[A-Za-z]+\s+\d{4})',
        ]
        
        for pattern in date_patterns:
            match = re.search(pattern, text)
            if match:
                return match.group(1)
        
        return None
    
    def _extract_gender(self, text: str) -> Optional[str]:
        """Extract gender from text"""
        text_upper = text.upper()
        if any(word in text_upper for word in ['MASCULIN', 'MALE', 'M', 'ذكر']):
            return 'M'
        elif any(word in text_upper for word in ['FEMININ', 'FEMALE', 'F', 'أنثى']):
            return 'F'
        return None
    
    def _calculate_confidence(
        self,
        cin_number: Optional[str],
        first_name: Optional[str],
        last_name: Optional[str],
        date_of_birth: Optional[str]
    ) -> float:
        """Calculate OCR confidence based on extracted fields"""
        score = 0.0
        
        if cin_number:
            score += 0.4  # CIN is most important
        if first_name:
            score += 0.2
        if last_name:
            score += 0.2
        if date_of_birth:
            score += 0.2
        
        return min(score, 1.0)
