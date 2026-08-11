# 🏋️ GymLife

> A Flutter fitness membership app. Browse Silver / Gold / Platinum memberships, add them to your cart, and complete payment via QR — with a full profile dashboard.

## 🎬 Demo

https://github.com/user-attachments/assets/48de6210-8f37-42b7-8e91-14228e0a9e54

> 🎬 **Direct link:** [`Video/GymLife.mp4`](Video/GymLife.mp4) — if the player above does not load, open the video directly in the repository.

> 📱 **Try it:** download the latest APK from the [Releases](https://github.com/CodeMelvin/GymLife/releases) page.

---

## ✨ Features

- 🔐 **Sign In / Sign Up** — Secure account creation and login with salted & hashed passwords (SHA-256)
- 🔑 **Forgot Password** — Reset your password from the sign-in screen
- 💎 **Memberships** — Silver, Gold, and Platinum tiers with rich benefit lists and pricing
- 🛒 **Cart** — Add memberships to your cart and checkout per user
- 📱 **QR Payment** — Generate a payment QR code per membership and confirm your payment
- 👤 **Profile** — Avatar image (gallery picker), name, description, gender, active membership card
- ✏️ **Edit Profile** — Update name, description, gender, and profile picture anytime
- 🔒 **Change Password** — Secure password update (old password required)
- 📧 **Contact Us** — Reach the admin directly
- 🗄️ **SQLite Local Database** — All data (users, profiles, cart) stored on-device, no server required

---

## 🛠️ Built With

- 🟦 **Flutter** — Dart 3, Material Design 3
- 🗄️ **SQLite** — Local embedded database via `sqflite`
- 🔐 **Crypto** — SHA-256 password hashing with per-user random salt
- 🎨 **Provider** — State management (Auth, Cart, Profile)
- 🔢 **QR Flutter** — Payment QR code generation
- 🖼️ **Image Picker / Photo View** — Profile avatars
- 📦 **intl** — Date & number formatting

---

## 🔑 Demo Account

| Email | Password |
|---|---|
| `user@demo.com` | `user123` |

You can also register a new account from the **Sign Up** tab.

---

## 🚀 Getting Started

### Option A - Install the APK (fastest)

Download `gymlife-v1.0.apk` from the [Releases](https://github.com/CodeMelvin/GymLife/releases) section and install it on any Android device (Android 7.0+). The database is created and seeded automatically — the demo account works out of the box.

### Option B - Build with Flutter

```bash
flutter pub get
flutter run            # run on emulator or connected device
```

### Option C - Build the APK

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🗄️ Database

The app uses a local SQLite database (`gymlife.db`) created on first launch with three tables:

| Table | Purpose |
|---|---|
| `users` | `id`, `name`, `email` (unique), `password_hash`, `salt` |
| `profiles` | `id`, `email` (unique), `name`, `description`, `gender`, `image_path`, `membership_name`, `membership_end_date` |
| `cart` | `id`, `user_email`, `membership_id`, `name`, `description`, `price`, `image`, `benefits`, `payment_method`, `status` |

> **Note:** Passwords are never stored in plain text — each password is hashed with SHA-256 plus a unique per-user salt.

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry + providers setup
├── models/
│   └── membership.dart            # Membership model + Silver/Gold/Platinum data
├── providers/
│   ├── auth_provider.dart         # Login, register, reset & change password
│   ├── cart_provider.dart         # Per-user cart state & persistence
│   └── profile_provider.dart      # Profile state & persistence
├── screens/
│   ├── auth/
│   │   ├── auth_screen.dart       # Sign In / Sign Up host (tabs)
│   │   ├── sign_in_page.dart
│   │   ├── sign_up_page.dart
│   │   └── forgot_password_page.dart
│   ├── home/
│   │   └── home_page.dart         # MenuScreen: Home / Cart / Settings
│   ├── membership/
│   │   └── membership_detail_page.dart
│   ├── cart/
│   │   └── cart_page.dart
│   ├── invoice/
│   │   └── payment_pending_page.dart  # QR payment confirmation
│   └── profile/
│       └── profile_page.dart      # Profile, edit, change password, logout
├── services/
│   └── database_helper.dart       # SQLite helper + schema + seed demo account
└── utils/
    ├── format.dart                # Rupiah number formatting
    └── form_helpers.dart          # Shared input decoration & validators
Video/
└── GymLife.mp4                   # App demo video (full walkthrough)
```
---

## 🧪 Testing

Unit tests cover the database and authentication flows (seeded demo account, salted hashing, duplicate registration, login, password change/reset):

```bash
flutter test
```

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Melvin** ([@CodeMelvin](https://github.com/CodeMelvin))
