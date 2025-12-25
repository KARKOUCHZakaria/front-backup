"""
Pydantic models for CIN data
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import date


class CINData(BaseModel):
    """Moroccan CIN card data model"""
    cin_number: str = Field(..., description="CIN number (e.g., AB123456)")
    first_name: Optional[str] = Field(None, description="First name in Latin")
    last_name: Optional[str] = Field(None, description="Last name in Latin")
    first_name_arabic: Optional[str] = Field(None, description="First name in Arabic")
    last_name_arabic: Optional[str] = Field(None, description="Last name in Arabic")
    date_of_birth: Optional[str] = Field(None, description="Date of birth (DD.MM.YYYY)")
    place_of_birth: Optional[str] = Field(None, description="Place of birth")
    issue_date: Optional[str] = Field(None, description="Issue date (DD.MM.YYYY)")
    expiry_date: Optional[str] = Field(None, description="Expiry date (DD.MM.YYYY)")
    gender: Optional[str] = Field(None, description="Gender (M/F)")
    address: Optional[str] = Field(None, description="Address")
    confidence: float = Field(0.0, description="OCR confidence score (0-1)")


class CINResponse(BaseModel):
    """Response model for CIN OCR"""
    success: bool = Field(..., description="Whether the operation was successful")
    message: str = Field(..., description="Response message")
    data: Optional[CINData] = Field(None, description="Extracted CIN data")
    raw_text: Optional[str] = Field(None, description="Raw extracted text for debugging")
