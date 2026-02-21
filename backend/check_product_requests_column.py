from app.database import engine
from sqlalchemy import text

with engine.connect() as conn:
    try:
        res = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='product_requests' AND column_name='user_id'"))
        row = res.first()
        print('postgres_check_firstrow=', row)
    except Exception as e:
        print('postgres_check_error=', repr(e))
        try:
            res = conn.execute(text("PRAGMA table_info('product_requests')"))
            cols = [r[1] for r in res.fetchall()]
            print('sqlite_cols=', cols)
        except Exception as e2:
            print('sqlite_check_error=', repr(e2))
