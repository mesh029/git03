# Agent Listings + Orders Upgrade (Step-by-step)

This document breaks the work into small, testable increments. The app should remain runnable after each step.

## Goals

- **Orders**
  - When a user books (especially Laundry), the created order must include:
    - pickup station (if applicable)
    - item counts and/or weight (kg)
    - automatic **turnaround days** + **ready-by date**
  - Admin can see all orders with those details in **Admin Orders**.

- **Properties / BnBs**
  - Normal users only see **available** Apartments/BnBs.
  - Add **Agent users** who can:
    - add/edit/remove listings
    - toggle availability + update prices
    - pick listing location on a map (tap to select)
    - set amenities + house rules + rating/traction
  - Listings drive:
    - the Home “Featured Listings”
    - the Properties/BnBs map markers + property list UI

---

## Step 1 — Orders: Laundry turnaround + richer details (user → admin)

- Add a small helper to compute turnaround days from weight:
  - Example rule (tunable):
    - \(\le 3kg\) → 1 day
    - \(\le 8kg\) → 2 days
    - \(\le 15kg\) → 3 days
    - else → 4 days
- In `LaundryMapBottomSheet`:
  - show “Estimated weight”, “Turnaround”, “Ready by”
  - write these into `order.details`
- In `AdminOrdersScreen`:
  - display `pickupStation`, `weightKg`, `turnaroundDays`, `readyBy`

Acceptance checks:
- Book laundry → open Admin Orders → see pickup station + weight/items + turnaround + ready-by.

---

## Step 2 — Roles: add Agent user + role checks

- Extend `User` with `isAgent` boolean (similar to `isAdmin`).
- Add a dummy agent user in `DummyUsers`.
- Add `AuthProvider.isAgent`.
- Update bottom nav “slot 4”:
  - Admin sees **Admin**
  - Agent sees **Agent**
  - Normal users don’t see slot 4

Acceptance checks:
- Login as agent → Agent tab visible.
- Login as non-agent/non-admin → no Agent/Admin tab visible.

---

## Step 3 — Listings data layer

- Add a model `PropertyListing`:
  - id, title, type (Apartment/BnB), price, isAvailable
  - lat/lng, areaLabel
  - amenities[], houseRules (text)
  - rating + traction
  - agentId (createdBy)
- Add `ListingsProvider`:
  - list of listings
  - `addListing`, `updateListing`, `toggleAvailability`, `removeListing`
  - `availableListings` and filters

Acceptance checks:
- Provider has seed data.
- `availableListings` excludes unavailable ones.

---

## Step 4 — Agent UI: add/edit listings + map location picker

- Add `LocationPickerScreen`:
  - shows map centered on user
  - tap selects a point
  - confirm returns `LatLng` to caller
- Add `AgentDashboardScreen`:
  - list cards with availability toggle + price edit + edit/delete
  - “Add listing” flow:
    - form + amenities + rules + rating/traction
    - “Pick on map” → opens `LocationPickerScreen` → saves selected lat/lng

Acceptance checks:
- Agent adds listing, sets availability true → listing appears for users.
- Agent toggles availability false → listing disappears for users.

---

## Step 5 — User UI: show only available listings

- Home “Featured Listings” uses `ListingsProvider.availableListings`.
- Map Properties mode:
  - markers show only available listings
  - list results show only available listings

Acceptance checks:
- Normal user sees only available units.
- Map markers match inventory.

