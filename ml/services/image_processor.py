"""
Image preprocessing service for CIN cards
"""
import cv2
import numpy as np
from PIL import Image
import io
import logging

logger = logging.getLogger(__name__)


class ImageProcessor:
    """Process and enhance images for better OCR results"""
    
    def preprocess_cin_image(self, image_bytes: bytes, enhance: bool = True) -> np.ndarray:
        """
        Preprocess CIN image for OCR
        
        Args:
            image_bytes: Raw image bytes
            enhance: Whether to apply enhancement
            
        Returns:
            Preprocessed image as numpy array
        """
        try:
            # Convert bytes to PIL Image
            image = Image.open(io.BytesIO(image_bytes))
            
            # Convert to RGB if needed
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Convert to numpy array
            img_array = np.array(image)
            
            # Convert to grayscale
            gray = cv2.cvtColor(img_array, cv2.COLOR_RGB2GRAY)
            
            if enhance:
                # Apply preprocessing steps
                gray = self._enhance_image(gray)
            
            logger.info(f"✅ Image preprocessed - Shape: {gray.shape}")
            return gray
            
        except Exception as e:
            logger.error(f"❌ Image preprocessing failed: {str(e)}")
            raise ValueError(f"Failed to preprocess image: {str(e)}")
    
    def _enhance_image(self, image: np.ndarray) -> np.ndarray:
        """
        Enhance image quality for better OCR
        
        Args:
            image: Grayscale image
            
        Returns:
            Enhanced image
        """
        # Resize if too small
        h, w = image.shape
        if h < 500 or w < 500:
            scale = max(500 / h, 500 / w)
            new_w = int(w * scale)
            new_h = int(h * scale)
            image = cv2.resize(image, (new_w, new_h), interpolation=cv2.INTER_CUBIC)
            logger.info(f"📐 Image resized to {new_w}x{new_h}")
        
        # Apply bilateral filter to reduce noise while keeping edges sharp
        image = cv2.bilateralFilter(image, 9, 75, 75)
        
        # Apply adaptive thresholding
        image = cv2.adaptiveThreshold(
            image,
            255,
            cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            cv2.THRESH_BINARY,
            11,
            2
        )
        
        # Denoise
        image = cv2.fastNlMeansDenoising(image, None, 10, 7, 21)
        
        # Enhance contrast
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        image = clahe.apply(image)
        
        return image
    
    def detect_text_regions(self, image: np.ndarray) -> list:
        """
        Detect text regions in the image
        
        Args:
            image: Input image
            
        Returns:
            List of bounding boxes for text regions
        """
        # Find contours
        contours, _ = cv2.findContours(
            image,
            cv2.RETR_EXTERNAL,
            cv2.CHAIN_APPROX_SIMPLE
        )
        
        # Filter and sort contours
        text_regions = []
        for contour in contours:
            x, y, w, h = cv2.boundingRect(contour)
            # Filter by size (adjust thresholds as needed)
            if w > 20 and h > 10:
                text_regions.append((x, y, w, h))
        
        return text_regions
