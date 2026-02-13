"""
Debug script to trace the service history issue in the dashboard endpoint.
Run this to inspect database state and query results.
"""

import sys
sys.path.insert(0, '/backend')

from sqlalchemy import text
from app.database import SessionLocal
from app.models.customer import Customer
from app.models.installation import Installation
from app.models.service_history import ServiceHistory
from app.models.user import User

db = SessionLocal()

print("=" * 80)
print("DEBUG: Customer Dashboard Service History Issue")
print("=" * 80)

try:
    # 1. Check if customers exist
    print("\n1️⃣ CUSTOMERS IN DATABASE:")
    customers = db.query(Customer).all()
    print(f"   Total customers: {len(customers)}")
    for c in customers[:5]:  # Show first 5
        print(f"   - Customer ID: {c.id}, User ID: {c.user_id}, Name: {c.full_name}")

    # 2. Check if installations exist
    print("\n2️⃣ INSTALLATIONS IN DATABASE:")
    installations = db.query(Installation).all()
    print(f"   Total installations: {len(installations)}")
    for inst in installations[:5]:  # Show first 5
        print(f"   - Installation ID: {inst.id}, Customer ID: {inst.customer_id}")

    # 3. Check ServiceHistory records
    print("\n3️⃣ SERVICE_HISTORY RECORDS IN DATABASE:")
    services = db.query(ServiceHistory).all()
    print(f"   Total service records: {len(services)}")
    
    # Count by status
    status_counts = {}
    for s in services:
        status = s.status or "NULL"
        status_counts[status] = status_counts.get(status, 0) + 1
    print(f"   Status breakdown: {status_counts}")
    
    # Show sample records
    print("\n   Sample records:")
    for s in services[:10]:  # Show first 10
        print(f"   - ID: {s.id}, Customer: {s.customer_id}, Installation: {s.installation_id}, "
              f"Status: {s.status}, Service#: {s.service_number}, Technician: {s.technician_id}")

    # 4. Test the actual query used in dashboard endpoint
    print("\n4️⃣ TESTING DASHBOARD QUERY:")
    if customers:
        test_customer = customers[0]
        print(f"   Testing with Customer ID: {test_customer.id}")
        
        # Query installation like the endpoint does
        installation = db.query(Installation).filter(
            Installation.customer_id == test_customer.id
        ).first()
        
        if installation:
            print(f"   Found Installation ID: {installation.id}")
            
            # Query services like endpoint does
            services_query = (
                db.query(ServiceHistory)
                .filter(ServiceHistory.installation_id == installation.id)
                .order_by(ServiceHistory.service_number)
                .all()
            )
            print(f"   Services for this installation: {len(services_query)}")
            for s in services_query:
                print(f"       - Service {s.service_number}: Status={s.status}, Date={s.service_date}")
        else:
            print(f"   ❌ No installation found for customer {test_customer.id}")

    # 5. Raw SQL verification
    print("\n5️⃣ RAW SQL QUERY VERIFICATION:")
    result = db.execute(text("""
        SELECT COUNT(*) as total FROM service_history;
    """)).fetchone()
    print(f"   Total service_history rows (raw SQL): {result[0]}")
    
    result = db.execute(text("""
        SELECT status, COUNT(*) as count FROM service_history GROUP BY status;
    """)).fetchone()
    print(f"   Status breakdown (raw SQL): {result}")
    
    # Show service history with customer and installation joins
    print("\n6️⃣ SERVICE_HISTORY WITH CUSTOMER/INSTALLATION INFO (SQL):")
    result = db.execute(text("""
        SELECT sh.id, sh.customer_id, sh.installation_id, sh.status, sh.service_number, c.id as cust_actual_id
        FROM service_history sh
        LEFT JOIN customers c ON c.id = sh.customer_id
        LEFT JOIN installations i ON i.id = sh.installation_id
        LIMIT 10;
    """)).fetchall()
    for row in result:
        print(f"   Service ID: {row[0]}, Customer ID: {row[1]}, Installation ID: {row[2]}, "
              f"Status: {row[3]}, Service#: {row[4]}, Customer Match: {row[1] == row[5]}")

except Exception as e:
    print(f"\n❌ ERROR: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()

finally:
    db.close()

print("\n" + "=" * 80)
