"""
Configuration Module
Handles environment variables for API keys and sensitive data
"""
import os
from typing import Dict, Any
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


def get_fast2sms_config() -> Dict[str, str]:
    """
    Get Fast2SMS configuration from environment variables
    
    Returns:
        Dictionary with Fast2SMS API key and sender ID
    """
    api_key = os.getenv("FAST2SMS_API_KEY")
    sender_id = os.getenv("FAST2SMS_SENDER_ID", "SPAGGL")
    
    if not api_key:
        raise ValueError("FAST2SMS_API_KEY environment variable not set")
    
    return {
        "api_key": api_key,
        "sender_id": sender_id
    }


def get_otp_config() -> Dict[str, Any]:
    """
    Get OTP configuration from environment variables
    
    Returns:
        Dictionary with OTP settings
    """
    return {
        "expiry_minutes": int(os.getenv("OTP_EXPIRY_MINUTES", "5")),
        "max_attempts": int(os.getenv("OTP_MAX_ATTEMPTS", "3"))
    }
