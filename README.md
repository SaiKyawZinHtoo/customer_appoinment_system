# customer_appointment_system

Customer Appointment System — a lightweight Flutter app to create and
manage customer appointments, view them on a calendar, and surface
in-app notifications for upcoming appointments.

This README documents the project structure (notably the `lib/` folder),
how to set up and run the app locally, and a summary of the UI/UX
features implemented and next-improvement suggestions.

---

## Quick Start

- Prerequisites: Flutter SDK (compatible with SDK in `pubspec.yaml`),
  Xcode / Android SDK when targeting mobile platforms.
- Fetch packages:

```bash
flutter pub get
```

- Run analyzer (optional but recommended):

```bash
flutter analyze
```

- Run on a connected device or emulator:

```bash
flutter run
```

- Build an APK (Android):

```bash
flutter build apk --release
```

---

## What this project includes

Core features implemented in this repo:

- Create and manage customers, including optional photo selection
  (image picker) and location text.
- Add an appointment date/time for each customer.
- Calendar view of appointments and quick access to customers for a
  selected date.
- In-app notifications derived from upcoming appointments with
  per-item "View" and "Dismiss" actions.
- Customer list with search, filters (gender), phone-call action,
  and a Done/Remaining marker (Done is irreversible by design).
- Small utility screens: Contact Us, FAQ, About Us.

Notes about data and notifications:

- Appointment and notification data are implemented as in-memory
  singleton `ChangeNotifier` services (`AppointmentRepository` and
  `NotificationRepository`). Dismissed notifications and appointments
  are not persisted across app restarts in the current implementation.

---

## `lib/` folder overview

Below is a guided map of the `lib/` directory with important files and
what they do. Use this as a developer cheat-sheet.

- `main.dart` — App entry; wires up the top-level MaterialApp.

- `model/customer.dart` — `Customer` model (fields include `id`,
  `name`, `phone`, `gender`, `dob`, `appointmentDate`, `photoPath`,
  `location`, `completed`). Serialization helpers included.

- `service/appointment_repository.dart` — In-memory repository that
  stores customers keyed by date. Public API highlights:
  - `addCustomer(Customer)`
  - `getForDate(DateTime)`
  - `getAll()`
  - `setCustomerCompleted(DateTime, id, bool)`
  - `removeCustomer(DateTime, id)`

- `service/notification_repository.dart` — Produces a list of pending
  notifications derived from `AppointmentRepository`. Supports:
  - `pending({daysAhead})`
  - `pendingCount({daysAhead})`
  - `dismiss(id)` and `dismissForDate(date)`
  - Notifies listeners when source appointment data changes.

- `screen/home/home_screen.dart` — App home with large action tiles.
  Includes the Notification tile with an embedded badge and a small
  AppBar pill showing total pending notifications.

- `screen/customer/customer_information_screen.dart` — Customer form.
  - Uses `image_picker` for photo selection (Android/iOS).
  - Full-width Add button styled with the app accent color.

- `screen/customer/customer_list_information_screen.dart` — Customer
  list view with search, gender filter, phone-call action and the
  ability to view customer details by appointment date.

- `screen/appoinment/appoinment_screen.dart` — Calendar view showing
  markers for active (not completed) appointments and selecting a
  date shows customers scheduled for that day.

- `screen/notification/notification_screen.dart` — Lists pending
  notifications grouped by date. Each notification uses an animated
  item widget which fades/expands on entrance and collapses/fades on
  dismiss.

- `screen/contactUs/contact_us_screen.dart`,
  `screen/FAQ/faq_screen.dart`, `screen/aboutUs/about_us_screen.dart`
  — simple informational screens.

- `widget/customer_card.dart` — Reusable card used in lists to show
  customer details, appointment date and actions.

- `widget/app_text_field.dart`, `widget/color.dart` — UI helpers
  (text field wrappers and color constants).

---

## Dependencies

Key dependencies declared in `pubspec.yaml`:

- `image_picker` — pick photos from camera/gallery for customer
  profile pictures.
- `url_launcher` — launch phone dialer (tel:) for quick call actions.
- `cupertino_icons` — iOS icon set.

If you add persistence later (recommended), consider:

- `shared_preferences` — small key/value store for simple flags.
- `hive` or `sqflite` — local structured storage if you need to
  persist customer or notification data.

---

## UI / UX notes (what's implemented)

- Image picker for customer photos with preview & remove option in the
  Customer form.
- Add button in the form is full-width and styled with the app
  accent color for visibility.
- Notifications are surfaced in two places:
  - Small red pill in the AppBar showing total pending notifications.
  - Notification action tile in Home showing a badge inside the tile.
- The notifications list is reactive: it listens to the
  `NotificationRepository` and updates immediately when appointments
  are added or dismissed.
- Per-notification animations: items animate in (fade+expand) and
  animate out (fade+collapse) on dismiss to improve feedback.
- Language selector in the AppBar was replaced by a compact popup to
  avoid a large dropdown overlay that covered the screen.

---

## Known limitations & recommended improvements

- Currently the data is in-memory only:
  - Dismissed notifications and appointments are not persisted across
    app restarts. To keep dismissed state, persist the dismissed IDs
    (`_dismissed` set in `NotificationRepository`) via `shared_preferences`
    or `hive`.
- "Dismiss all" per-date removes entries immediately — if you prefer
  nicer UX consider playing each item's dismiss animation (staggered
  or in parallel) before removing them.
- Consider adding localization via Flutter's Intl tooling so the
  language selector actually changes strings across the app.
- Add unit/widget tests around the repositories and the notification
  UI to guard regressions (e.g., `flutter_test`).

---

## How to exercise the main flows (quick manual tests)

1. Open the app (Home).
2. Tap `Customer` tile → fill in name, phone, choose an image (optional),
   set an appointment date and tap the full-width `Add` button.
3. Open `Appointment` (calendar) and pick the same date — the added
  customer should appear.
4. If appointment is within the upcoming window (default 30 days),
  Home's notification badge and AppBar pill should increment.
5. Open `Notification` tile → list items grouped by date. Tap `View`
  to jump to the customer list pre-filtered by date, or `Dismiss` to
  animate and remove the notification.

If notifications do not appear:

- Confirm the appointment date is within the next 30 days.
- Check that the customer was saved (search in `Customer` list by
  name or filter by date).

---

## Developer tips

- Use `flutter analyze` frequently to catch lints and issues early.
- Keep repository code minimal and testable — the `ChangeNotifier`
  singletons are easy to refactor to a persistence-backed
  implementation later.
- When adding persistence, load saved dismissed IDs early (e.g., in
  `NotificationRepository` constructor) so the UI reflects known
  state immediately.

---

If you'd like, I can:

- Add persistent storage for dismissed notifications (`shared_preferences` or `hive`).
- Animate the "Dismiss all" action so each item plays its exit animation before removal.
- Add a small integration test that creates a customer, adds an appointment, and asserts the notification count increases.

If you want me to update the README further (e.g., add screenshots or
translate to Burmese), tell me which screenshots or translation you'd
like and I'll add them.

---

Happy hacking — open an issue or a message with the next change you'd
like and I can implement it.

Author: repo contributor (local development copy)
