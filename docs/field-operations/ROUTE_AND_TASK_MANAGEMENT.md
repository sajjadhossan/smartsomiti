# ROUTE PLANNING & FIELD TASK MANAGEMENT SPECIFICATION

## 1. Route Assignment & Geolocation
Field officers are assigned geographical clusters (e.g., *মিরপুর-১০ সমবায় সমিতি পাড়া* or *পল্লবী ব্লক-সি*).
- **Target Points**: Members with installments due on the designated day.
- **Route Sequencing**: Ordered list of visits optimized by street/village proximity.
- **Visit States**: `SCHEDULED`, `VISITED_COLLECTED`, `ABSENT_FOLLOWUP`, `MISSED`.

## 2. Location Privacy & Ethical Tracking
- **Point-in-Time Capture Only**: Location coordinates (`lat`, `lng`) are recorded **only** at the precise instant a collection or KYC verification button is pressed.
- **No Unsolicited Tracking**: Continuous background GPS polling is disabled by default to respect employee privacy and preserve battery life on rural field visits.
- **Super Admin Governance**: Location requirement can be set to Mandatory, Optional, or Disabled per society.
