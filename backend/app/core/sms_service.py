"""
SMS Service — Fast2SMS only.
Provides a single async function: send_otp_sms(phone, otp)
"""

import logging
import os

import httpx

logger = logging.getLogger(__name__)

FAST2SMS_API_KEY = os.getenv("FAST2SMS_API_KEY")
FAST2SMS_SENDER_ID = os.getenv("FAST2SMS_SENDER_ID", "FSTSMS")
FAST2SMS_URL = "https://www.fast2sms.com/dev/bulkV2"

# DLT-approved message template for Fast2SMS.
# Use {#var#} placeholder (NOT {otp}) for Fast2SMS DLT compliance.
# The actual OTP will be passed via "variables_values" parameter.
OTP_MESSAGE_TEMPLATE = "Your OTP is {#var#}. Valid for 5 minutes. Do not share it with anyone. - SPAG Eagle Global Pvt Ltd"


async def send_otp_sms(phone: str, otp: str) -> bool:
    """
    Send an OTP SMS via Fast2SMS.

    Args:
        phone: 10-digit Indian mobile number (no country code).
        otp:   6-digit OTP string.

    Returns:
        True if the SMS was dispatched successfully, False otherwise.

    Raises:
        ValueError: If FAST2SMS_API_KEY is not configured.
    """
    if not FAST2SMS_API_KEY:
        logger.error("FAST2SMS_API_KEY is not set in environment variables.")
        raise ValueError("SMS service is not configured. Set FAST2SMS_API_KEY.")

    # Sanitise phone — strip leading zeros / country code if accidentally passed
    phone = phone.strip().lstrip("+").lstrip("91")
    if len(phone) != 10 or not phone.isdigit():
        logger.error("Invalid phone number format: %s", phone)
        raise ValueError(f"Invalid phone number: {phone}. Expected 10 digits.")

    headers = {
        "authorization": FAST2SMS_API_KEY,
        "Content-Type": "application/x-www-form-urlencoded",
    }

    # DLT-compliant payload for Fast2SMS
    # DO NOT format message — pass OTP via variables_values parameter
    payload = {
        "sender_id": FAST2SMS_SENDER_ID,
        "message": OTP_MESSAGE_TEMPLATE,
        "language": "english",
        "route": "dlt",
        "numbers": phone,
        "flash": "0",
        "variables_values": otp,
    }

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(FAST2SMS_URL, data=payload, headers=headers)
            response.raise_for_status()
            
            # Handle empty response
            if not response.content:
                logger.warning(
                    "Fast2SMS returned empty response for phone: %s (Sender: %s)",
                    phone, FAST2SMS_SENDER_ID
                )
                return False
            
            try:
                resp_json = response.json()
            except ValueError as e:
                logger.error(
                    "Fast2SMS returned invalid JSON for phone %s: %s (Response: %s)",
                    phone, e, response.text[:200],
                )
                return False

            if resp_json.get("return") is True:
                logger.info("OTP SMS sent successfully to %s", phone)
                return True
            else:
                logger.warning(
                    "Fast2SMS request failed for phone %s: %s",
                    phone, resp_json
                )
                return False

    except httpx.HTTPStatusError as exc:
        logger.error(
            "Fast2SMS HTTP %d error for phone %s: %s",
            exc.response.status_code, phone, exc.response.text,
        )
        return False
    except httpx.RequestError as exc:
        logger.error("Fast2SMS network error for phone %s: %s", phone, str(exc))
        return False