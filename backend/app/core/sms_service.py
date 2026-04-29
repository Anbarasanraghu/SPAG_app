"""
SMS Service — Fast2SMS with Indian DLT Compliance.
Provides a single async function: send_otp_sms(phone: str, otp: str) -> bool

DLT Compliance:
- Uses Fast2SMS Message ID (integer) in the `message` field — NOT the template text
- Uses registered sender_id (SPAGGL)
- Follows route=dlt with variables_values parameter for OTP substitution
- Per Fast2SMS API docs: `message` = Message_ID like "214154" (integer, not template string)
"""

import logging
import os
import re

import httpx
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

FAST2SMS_URL = "https://www.fast2sms.com/dev/bulkV2"
FAST2SMS_TIMEOUT = 10.0  # seconds


def _validate_phone(phone: str) -> str:
    """
    Validate and normalize Indian phone number.

    Args:
        phone: Raw phone input (may include +91, leading zeros, spaces)

    Returns:
        Normalized 10-digit phone number

    Raises:
        ValueError: If phone format is invalid
    """
    if not phone:
        raise ValueError("Phone number cannot be empty")

    normalized = phone.strip()

    if normalized.startswith("+91"):
        normalized = normalized[3:]
    elif normalized.startswith("91") and len(normalized) > 10:
        normalized = normalized[2:]

    normalized = normalized.lstrip("0")

    if not re.match(r"^\d{10}$", normalized):
        raise ValueError(
            f"Invalid phone number: {phone}. Expected 10-digit Indian mobile number."
        )

    return normalized


async def send_otp_sms(phone: str, otp: str) -> bool:
    """
    Send an OTP SMS via Fast2SMS with DLT compliance.

    Per Fast2SMS API docs, the `message` field must be the Message ID integer
    (e.g. 214154), NOT the template text string. The template text is already
    stored on Fast2SMS servers against that Message ID.

    Args:
        phone: Indian mobile number (10 digits, with/without +91)
        otp:   4-6 digit OTP string

    Returns:
        True if SMS was dispatched successfully, False otherwise
    """
    # Read env vars inside the function so load_dotenv() timing doesn't matter
    api_key    = os.getenv("FAST2SMS_API_KEY")
    sender_id  = os.getenv("FAST2SMS_SENDER_ID", "SPAGGL")
    message_id = os.getenv("FAST2SMS_MESSAGE_ID", "214154")

    # Validate configuration
    if not api_key:
        logger.error("FAST2SMS_API_KEY is not configured in environment variables")
        raise ValueError("SMS service not configured: FAST2SMS_API_KEY is required")

    # Validate phone
    try:
        phone = _validate_phone(phone)
    except ValueError as exc:
        logger.error("Phone validation failed: %s", exc)
        return False

    # Validate OTP format (4-6 digits)
    if not re.match(r"^\d{4,6}$", otp):
        logger.error("Invalid OTP format: %s (expected 4-6 digits)", otp)
        return False

    # ------------------------------------------------------------------ #
    # KEY FIX: Per Fast2SMS API docs, `message` field = Message ID integer
    # Do NOT send the template text — send only the numeric Message ID.
    # The template text is stored on Fast2SMS servers against this ID.
    # ------------------------------------------------------------------ #
    payload = {
        "sender_id": sender_id,
        "message": message_id,        # ← Message ID integer (e.g. 214154), NOT template text
        "variables_values": otp,      # ← OTP substituted into {#VAR#} in the stored template
        "route": "dlt",
        "numbers": phone,
        "flash": "0",
    }

    headers = {
        "authorization": api_key,
        "Content-Type": "application/x-www-form-urlencoded",
    }

    debug_msg = (
        f"\nSENDING SMS DEBUG:\n"
        f"sender_id={sender_id}\n"
        f"message (Message ID)={message_id}\n"
        f"variables_values={otp}\n"
        f"phone={phone}\n"
    )
    logger.info(debug_msg)
    print(debug_msg)

    try:
        async with httpx.AsyncClient(timeout=FAST2SMS_TIMEOUT) as client:
            response = await client.post(
                FAST2SMS_URL,
                data=payload,
                headers=headers,
            )

            # Parse response WITHOUT raising on HTTP errors
            # Fast2SMS may return HTTP 400/424 with JSON error details we need to check
            
            if not response.content:
                logger.warning("Fast2SMS returned empty response for phone: %s", phone)
                return False

            try:
                resp_json = response.json()
            except ValueError as exc:
                logger.error(
                    "Fast2SMS returned invalid JSON for phone %s: %s. HTTP Status: %d. Response: %s",
                    phone,
                    exc,
                    response.status_code,
                    response.text[:300],
                )
                return False

            if resp_json.get("return") is True:
                logger.info(
                    "OTP SMS sent successfully to %s (message_id=%s, sender_id=%s)",
                    phone,
                    message_id,
                    sender_id,
                )
                return True
            else:
                error_msg  = resp_json.get("message", "Unknown error")
                error_code = resp_json.get("status_code", "N/A")
                
                # Log all failures
                logger.warning(
                    "Fast2SMS DLT request failed for phone %s. Error: %s (Code: %s). "
                    "Response: %s. message_id=%s, sender_id=%s",
                    phone,
                    error_msg,
                    error_code,
                    resp_json,
                    message_id,
                    sender_id,
                )
                return False

    except httpx.TimeoutException as exc:
        logger.error("Fast2SMS timeout (%.1fs) for phone %s: %s", FAST2SMS_TIMEOUT, phone, exc)
        return False

    except httpx.RequestError as exc:
        logger.error("Fast2SMS network error for phone %s: %s", phone, exc)
        return False

    except Exception as exc:
        logger.exception("Unexpected error sending OTP SMS to %s: %s", phone, exc)
        return False