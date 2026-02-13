# SPAG App Implementation Checklist - Phase 2

## 📋 Current Status Summary

**Completed in Current Session:**
- ✅ Fixed 3 compilation errors (technician_api.dart)
- ✅ Centralized baseUrl to ApiConfig
- ✅ Fixed token authentication across 6 service files
- ✅ Created 3 new backend endpoints (installations, status logs, activity logs)
- ✅ Created 2 new Flutter services (InstallationService, ServiceLogsService)
- ✅ Verified all services compile without errors

**Total APIs Implemented:** 16+ endpoints across 3 user roles

---

## 🎯 Phase 2: UI Implementation Required

### CUSTOMER FEATURE: Installation Management
**Status:** ⏳ Needs UI  
**Service:** `installation_service.dart` ✅ (Ready)

**Tasks:**
- [ ] Create `customer_installations_screen.dart`
  - Call `InstallationService.getCustomerInstallations(currentCustomerId)`
  - Display list with purifier model, installation date, status
  - Add "New Installation" button linking to purifier selection
  - Add tap action to view service history for that installation

- [ ] Update customer dashboard
  - Display active installations count
  - Quick link to installations list

- [ ] Create `create_installation_screen.dart`
  - Select from purifier models dropdown
  - Set installation date
  - Call `InstallationService.createInstallation()`
  - Redirect to installations list on success

**Estimated Effort:** 3-4 hours

---

### ADMIN FEATURE: Service Status Audit Trail
**Status:** ⏳ Needs UI  
**Service:** `service_logs_service.dart` ✅ (Ready)

**Tasks:**
- [ ] Create `service_status_logs_screen.dart`
  - Accepts `service_id` parameter
  - Call `ServiceLogsService.getServiceStatusLogs(service_id)`
  - Display timeline showing:
    - Old status → New status
    - Changed by (admin/technician name)
    - Timestamp
    - Reason (if provided)
  
- [ ] Create `service_detail_with_logs_screen.dart`
  - Embed status_logs_screen as tab
  - Show current service details
  - Show audit trail below

- [ ] Update admin dashboard
  - Add "View Logs" button on service cards
  - Link to status logs screen

**Estimated Effort:** 2-3 hours

---

### ADMIN FEATURE: Technician Activity Report
**Status:** ⏳ Needs UI  
**Service:** `service_logs_service.dart` ✅ (Ready)

**Tasks:**
- [ ] Create `technician_activity_logs_screen.dart`
  - Accepts `technician_id` parameter
  - Call `ServiceLogsService.getTechnicianActivityLogs(technician_id)`
  - Display list showing:
    - Service ID & customer name
    - Action (ASSIGNED, IN_PROGRESS, COMPLETED)
    - Timestamp
    - Service duration (if completed)

- [ ] Create `technician_performance_report_screen.dart`
  - List all technicians
  - Show:
      - Active services
      - Completed services (today/week/month)
      - Average service duration
      - Quick link to activity logs

- [ ] Update admin dashboard
  - Add "Technician Reports" section
  - Link to performance report

**Estimated Effort:** 3-4 hours

---

### CORE FLOW: Verify Pending Service Assignment
**Status:** ⏳ Needs Verification  
**Service:** `pending_service_service.dart` ✅ (Implemented)

**Tasks:**
- [ ] Test `pending_services_screen.dart`
  - Verify calls `/admin/services/pending`
  - Verify assignment dialog sends request to `/admin/services/{id}/assign`
  - **FIX:** After successful assignment, refresh list by calling API again
  - Verify assigned technician name displays in list

- [ ] Update `pending_services_screen.dart`
  - Add loading state after assignment
  - Auto-refresh list after 1-2 second delay
  - Show success snackbar with technician name

- [ ] Test end-to-end
  - Create product request as customer
  - View in admin pending list
  - Assign technician
  - Verify appears in technician's `/services/upcoming`

**Estimated Effort:** 1-2 hours

---

### TECHNICIAN FEATURE: Service Completion Flow
**Status:** ⏳ Needs Testing  
**Service:** `technician_api.dart` ✅ (Fixed)

**Tasks:**
- [ ] Test `technician_home_screen.dart`
  - Verify calls `/services/upcoming`
  - Verify receives list filtered by technician_id
  - Verify includes customer name, address, purifier model

- [ ] Create `service_completion_screen.dart`
  - Display service details
  - "Mark as Completed" button
  - Optional notes field
  - Call `TechnicianApi.completeService(service_id, notes)`
  - Success message with automatic return to home

- [ ] Verify automatic logging
  - Backend creates `ServiceStatusLog` when status changes
  - Backend creates `TechnicianActivityLog` on completion
  - Admin can view logs via `ServiceLogsService`

- [ ] Test end-to-end
  - Login as technician
  - View assigned service
  - Mark as completed
  - Verify admin sees status change in logs

**Estimated Effort:** 2-3 hours

---

### CUSTOMER FEATURE: Service History View
**Status:** ⏳ Needs Development  
**API:** `/services/customer/{customer_id}` (Implemented)

**Tasks:**
- [ ] Create `customer_service_history_screen.dart`
  - Call `ServiceHistoryService.getCustomerServices(customer_id)`
  - Display list grouped by purifier installation
  - Show:
    - Service date
    - Status (PENDING, UPCOMING, COMPLETED)
    - Assigned technician
    - Service notes

- [ ] Create `service_details_screen.dart` (Customer view)
  - Display full service information
  - Show status change history
  - Display assigned technician rating/contact
  - Add optional feedback section

- [ ] Update customer dashboard
  - Show "Services Completed" counter
  - Show "Upcoming Services" count
  - Quick link to view all

**Estimated Effort:** 2-3 hours

---

## 🔧 Code Examples for Quick Reference

### Using InstallationService
```dart
// In initState or button handler
final installations = 
  await InstallationService.getCustomerInstallations(customerId);

// Display in ListView
ListView.builder(
  itemCount: installations.length,
  itemBuilder: (context, index) {
    final install = installations[index];
    return ListTile(
      title: Text(install['purifier_model']),
      subtitle: Text('Installed: ${install['installation_date']}'),
      trailing: Icon(Icons.arrow_forward),
    );
  },
)
```

### Using ServiceLogsService
```dart
// Get status log for service
final logs = 
  await ServiceLogsService.getServiceStatusLogs(serviceId);

// Display as timeline
ListView.builder(
  itemCount: logs.length,
  itemBuilder: (context, index) {
    final log = logs[index];
    return ListTile(
      title: Text('${log['old_status']} → ${log['new_status']}'),
      subtitle: Text('by ${log['changed_by_user']}'),
      trailing: Text(log['timestamp']),
    );
  },
)
```

---

## 📊 Implementation Priority

**High Priority (Day 1):**
1. Pending Service Assignment verification (1-2 hours) - Core flow
2. Service Completion flow (2-3 hours) - Technician workflow

**Medium Priority (Day 2):**
3. Customer Installations UI (3-4 hours) - Customer dashboard
4. Status Logs UI (2-3 hours) - Admin visibility

**Low Priority (Day 3+):**
5. Technician Activity Report (3-4 hours) - Reporting
6. Service History View (2-3 hours) - Customer details

**Total Estimated:** 18-24 hours of development

---

## 🧪 Testing Strategy

### Unit Tests
- [ ] Test each service's error handling
- [ ] Mock API responses
- [ ] Verify token inclusion in headers

### Integration Tests
- [ ] Test complete customer flow (request → installation → service)
- [ ] Test complete admin flow (pending → assign → logs)
- [ ] Test complete technician flow (assigned → complete → logs)

### Manual Testing
- [ ] Create real product request
- [ ] Assign to technician
- [ ] Verify admin sees logs
- [ ] Mark service complete
- [ ] Verify status changes

---

## 🚨 Known Issues & Mitigations

**Issue 1:** Empty lists return
**Solution:** All services handle empty arrays, UI should show "No data" message

**Issue 2:** Token expiration during long operations
**Solution:** Implement token refresh in auth_service.dart

**Issue 3:** Concurrent status updates conflicting
**Solution:** Backend uses version/timestamp checking, frontend should prevent double-submit

---

## 📞 Troubleshooting Guide

**Service returns 401?**
→ Check `AuthService.getToken()` not null  
→ Verify token hasn't expired in backend  
→ Test in admin dashboard (logged in check)

**Service returns empty list?**
→ Check filters in API call match backend expectations  
→ Verify user has access (customer_id match, role check)  
→ Check API response format matches service parsing

**UI doesn't update after API call?**
→ Wrap in `FutureBuilder` or call `setState`  
→ Check service method returns data correctly  
→ Verify no parsing errors in try-catch

---

## ✨ Next Steps

1. **Immediate:** Run pending service test - verify UI refresh after assignment
2. **Then:** Build Installation UI for customers
3. **Then:** Build Status Log UI for admins
4. **Finally:** Comprehensive integration testing

All backend infrastructure is ready. Focus is on UI/UX implementation.

---

**Last Updated:** February 7, 2026  
**Next Review:** After completing Phase 2 tasks
