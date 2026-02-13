# SPAG App - Production-Ready API Integration Guide

## 📊 Complete Application Flow Architecture

### 👤 CUSTOMER FLOW
```
1. Login → /auth/send-otp → /auth/verify-otp
   ↓
2. Profile → /customer-profile/exists → /customer-profile (POST/GET)
   ↓
3. Product Request → /purifier-models → /purifier-models/product-requests (POST)
   ↓
4. Installation → /installations/ (POST) + Auto-generate Services
   ↓
5. Service History → /services/customer/{customer_id}
   ↓
6. Dashboard → /dashboard/customer/{customer_id}
```

### 🧑‍💼 ADMIN FLOW
```
1. Dashboard → /admin/users, /admin/customers, /admin/product-requests
   ↓
2. Pending Services → /admin/services/pending
   ↓
3. Assign Technician → /admin/services/{service_id}/assign
   ↓
4. Service Assignment creates:
   - ServiceStatusLog (old_status → new_status)
   - TechnicianActivityLog (action: ASSIGNED)
   ↓
5. Monitor & Audit:
   - /admin/technician/services (all service-technician mappings)
   - /admin/services/{service_id}/details (full service details)
   - /admin/services/{service_id}/status-logs (audit trail)
   - /admin/technicians/{technician_id}/activity-logs (technician history)
```

### 👨‍🔧 TECHNICIAN FLOW
```
1. Login → Receive Token
   ↓
2. Assigned Services → /services/upcoming
   (Filtered by technician_id, status IN ['UPCOMING', 'ASSIGNED'])
   ↓
3. Start Service → /technician/services/{service_id}/status?status=IN_PROGRESS
   Creates:
   - ServiceStatusLog
   - TechnicianActivityLog
   ↓
4. Complete Service → /technician/services/{service_id}/status?status=COMPLETED
   Creates:
   - ServiceStatusLog
   - TechnicianActivityLog
   ↓
5. View Updates:
   - Service history auto-updates with status logs
   - Activity logs show all actions with timestamps
```

---

## 🔗 COMPLETE API ENDPOINT REFERENCE

### Authentication
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/send-otp` | Initiate login |
| POST | `/auth/verify-otp` | Complete login |

### Customer Profile
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/customer-profile/exists` | Check if profile exists |
| POST | `/customer-profile` | Create/Update profile |
| GET | `/customers/{customer_id}` | Get customer info |

### Purifier Models & Product Requests
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/purifier-models` | List all purifiers |
| POST | `/purifier-models/product-requests` | Submit request |
| GET | `/admin/product-requests` | Admin: View all requests |
| PUT | `/admin/product-requests/{id}/assign` | Admin: Assign technician |

### Installations
| Method | Endpoint | Purpose | **NEW** |
|--------|----------|---------|--------|
| POST | `/installations/` | Create installation | |
| **GET** | **/installations/customer/{customer_id}** | Get customer installations | ✅ |

### Service History
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/services/customer/{customer_id}` | Customer's services |
| GET | `/services/installation/{installation_id}` | Services for installation |
| PUT | `/services/update` | Update service status |
| GET | `/services/upcoming` | Technician's assigned services |

### Admin Dashboard
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/admin/users` | All users |
| PUT | `/admin/users/{user_id}/role` | Update user role |
| GET | `/admin/customers` | All customers |
| GET | `/admin/services/pending` | Pending services |
| PUT | `/admin/services/{service_id}/assign` | Assign technician |
| GET | `/admin/technician/services` | Technician-service mapping |
| GET | `/admin/services/{service_id}/details` | Service full details |

### Service Status & Activity Logs (**NEW**)
| Method | Endpoint | Purpose | **NEW** |
|--------|----------|---------|--------|
| **GET** | **/admin/services/{service_id}/status-logs** | Service status audit trail | ✅ |
| **GET** | **/admin/technicians/{technician_id}/activity-logs** | Technician activities | ✅ |

### Technician Assignment & Completion
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/technician/services` | Assigned services |
| PUT | `/technician/services/{service_id}/status` | Update service status |

---

## 📱 FLUTTER SERVICES & IMPLEMENTATIONS

### Currently Implemented Services:
✅ `auth_service.dart` - Login/Logout  
✅ `customer_profile_service.dart` - Profile  
✅ `purifier_service.dart` - Purifiers & Product Requests  
✅ `admin_service.dart` - Admin product requests  
✅ `admin_user_service.dart` - User management  
✅ `admin_customer_service.dart` - Customer management  
✅ `pending_service_service.dart` - Pending services & assignment  
✅ `service_detail_service.dart` - Service details  
✅ `technician_service_log_service.dart` - Technician logs  
✅ `technician_api.dart` - Technician services  
✅ `dashboard_service.dart` - Dashboard data  

### **NEW** Services Added:
✅ **`installation_service.dart`** - Get customer installations  
✅ **`service_logs_service.dart`** - Status & Activity logs  

---

## 🔄 DATA FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT REQUESTS                          │
└──────────────┬──────────────────┬──────────────────────┬─────────┘
               │                  │                      │
        ┌──────▼────────┐  ┌─────▼──────┐      ┌───────▼────────┐
        │   CUSTOMER    │  │   ADMIN    │      │  TECHNICIAN    │
        │   Flutter App │  │   Flutter  │      │  Flutter App   │
        └──────┬────────┘  └─────┬──────┘      └───────┬────────┘
               │                  │                      │
               └──────────────────┼──────────────────────┘
                                  │
                          ┌────────▼────────┐
                          │  API_CONFIG.baseUrl
                          │ Uses centralized
                          │ URL management
                          └────────┬────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
            ┌───────▼─────────┐      ┌─────────▼────────┐
            │   FastAPI       │      │  SQLAlchemy ORM  │
            │   Backend       │◄────►│  Database Models │
            │   (Python 3.10) │      └──────────────────┘
            └─────────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
    ┌───▼──┐   ┌───▼──┐   ┌───▼──┐
    │Users │   │ Logs │   │ Data │
    └──────┘   └──────┘   └──────┘
```

---

## ✅ PRODUCTION CHECKLIST

- [x] All API endpoints implemented
- [x] Token-based authentication
- [x] User authorization (customer/admin/technician)
- [x] Status logging system
- [x] Activity tracking
- [x] Centralized URL management
- [x] Error handling & validation
- [x] Service assignment workflow
- [x] Service completion workflow
- [x] Audit trails (status logs, activity logs)

---

## 🚀 DEPLOYMENT INSTRUCTIONS

### Backend Setup:
```bash
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
```

### Frontend Setup:
```bash
cd mobile/spag_app
flutter pub get
flutter run -d chrome
```

### Key Configuration:
- Update `lib/core/api/api_config.dart` with backend URL
- Ensure `.env` or secrets are configured in backend
- Database must be pre-created with schema

---

## 📝 NOTES

1. **Token Management**: All requests include Bearer token via `AuthService.getToken()`
2. **URL Centralization**: All services now use `ApiConfig.baseUrl` for consistency
3. **Status Logs**: Automatically created when:
   - Technician assigned to service
   - Service status changes
4. **Activity Logs**: Automatically created for all technician actions
5. **Role-Based Access**: Admin endpoints require `require_admin` dependency

---

Generated: February 7, 2026
Version: 1.0
Status: ✅ Production Ready
