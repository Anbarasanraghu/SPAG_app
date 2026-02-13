from datetime import timedelta
from app.models.service_history import ServiceHistory

def generate_services(db, installation, purifier_model):

    if not installation.install_date:
        raise ValueError("Installation date is required")

    if purifier_model.free_services <= 0:
        print("No free services configured")
        return

    services = []

    for i in range(1, purifier_model.free_services + 1):
        service_date = installation.install_date + timedelta(
            days=purifier_model.service_interval_days * i
        )

        service = ServiceHistory(
            customer_id=installation.customer_id,
            installation_id=installation.id,
            service_number=i,
            service_date=service_date,
            status="UPCOMING"
        )

        services.append(service)

    db.add_all(services)
    print(f"Generated {len(services)} services")