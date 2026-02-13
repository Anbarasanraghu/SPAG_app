def extract_user_id(user: dict) -> int:
    return user.get("id") or user.get("user_id") or user.get("sub")
