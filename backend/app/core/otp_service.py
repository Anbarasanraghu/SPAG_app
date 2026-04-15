import secrets
from datetime import datetime, timedelta
import logging
import httpx
from typing import Dict, Any
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.customer import Customer

logger = logging.getLogger(__name__)

# In-memory storage: customer_id -> {'otp': str, 'expiry': datetime, 'attempts': int, 'last_sent': datetime, 'mobile': str}
otp_store: Dict[str, Dict[str, Any]] = {}

def generate_otp() -> str:
    """Generate a secure 6-digit numeric OTP."""
    return ''.join(secrets.choice('0123456789') for _ in range(6))

async def send_sms(phone: str, otp: str) -> Dict[str, Any]:
    """Send SMS via MSG91 Transactional SMS API."""
    url = "https://control.msg91.com/api/v5/sms"
    message = "THIS IS OTP FOR RESET PASSWORD {#numeric#}, AND THANKS FOR REACHING SPAG EAGLE GLOBAL PRIVATE LIMITED".replace("{#numeric#}", otp)
    payload = {
        "authkey": "493513A7e0g1DCcK69df481fP1",
        "mobiles": phone,
        "message": message,
        "sender": "SPAGGL",
        "country": "91",
        "DLT_TE_ID": "1107177607188322509"
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=payload)
        logger.info(f"SMS response for {phone}: {response.status_code} - {response.text}")
        return response.json()

async def send_otp(customer_id: str, db: Session) -> None:
    """Send OTP logic with rate limiting and storage management."""
    # Look up customer mobile number
    try:
        customer = db.query(Customer).filter(Customer.id == int(customer_id)).first()
        if not customer:
            raise ValueError("Customer not found")
        mobile = customer.mobile_number
    except Exception as e:
        logger.error(f"Error looking up customer {customer_id}: {e}")
        raise ValueError("Invalid customer ID")
    
    now = datetime.now()
    if customer_id in otp_store:
        # Check rate limit: 30 seconds
        if now - otp_store[customer_id]['last_sent'] < timedelta(seconds=30):
            raise ValueError("Rate limit exceeded. Please wait 30 seconds before requesting another OTP.")
        # Update existing entry
        otp_store[customer_id]['otp'] = generate_otp()
        otp_store[customer_id]['expiry'] = now + timedelta(minutes=5)
        otp_store[customer_id]['attempts'] = 0
        otp_store[customer_id]['last_sent'] = now
        otp_store[customer_id]['mobile'] = mobile
    else:
        # Create new entry
        otp_store[customer_id] = {
            'otp': generate_otp(),
            'expiry': now + timedelta(minutes=5),
            'attempts': 0,
            'last_sent': now,
            'mobile': mobile
        }
    # Send SMS to customer's mobile number
    await send_sms(f"91{mobile}", otp_store[customer_id]['otp'])

def verify_otp(customer_id: str, otp: str) -> Dict[str, Any]:
    """Verify OTP with attempt tracking and expiry check."""
    if customer_id not in otp_store:
        return {"success": False, "message": "OTP not found. Please request a new OTP."}
    
    entry = otp_store[customer_id]
    now = datetime.now()
    
    if now > entry['expiry']:
        del otp_store[customer_id]
        return {"success": False, "message": "OTP has expired. Please request a new OTP."}
    
    if entry['attempts'] >= 3:
        return {"success": False, "message": "Maximum verification attempts exceeded. Please request a new OTP."}
    
    if entry['otp'] == otp:
        del otp_store[customer_id]
        return {"success": True, "message": "OTP verified successfully."}
    else:
        entry['attempts'] += 1
        remaining = 3 - entry['attempts']
        return {"success": False, "message": f"Invalid OTP. {remaining} attempts remaining."}

# Optional: Background task to clean expired OTPs (can be scheduled with APScheduler or similar)
def clean_expired_otps():
    """Remove expired OTP entries from storage."""
    now = datetime.now()
    expired_phones = [phone for phone, entry in otp_store.items() if now > entry['expiry']]
    for phone in expired_phones:
        del otp_store[phone]
    if expired_phones:
        logger.info(f"Cleaned {len(expired_phones)} expired OTP entries.")

# For future PostgreSQL integration (using existing OTPRequest model):
# Note: The existing OTPRequest model uses mobile_number for backward compatibility
# The new in-memory system uses customer_id for better security
# When migrating to DB storage, create a new table or update the existing one