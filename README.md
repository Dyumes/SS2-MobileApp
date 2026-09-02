# SS2-MobileApp
A small app letting employers post job offers, and students to apply for them.

# Structure
```sh
📁 lib
├─ 📁 models        # To store data in object format
├─ 📁 providers     # State management and business logic
├─ 📁 repositories  # Data access interfaces and abstractions
│  ├─ 📄 {object}_repository             # Interface
│  ├─ 📄 firestore_{object}_repository   # Implementation of the abstract repository
│  └─ ...
├─ 📁 services      # External services
│  ├─ 📄 auth_repository                 # Interface
│  ├─ 📄 firestore_auth_repository       # Implementation of the abstract auth repo
│  └─ ...
├─ 📁 templates     # Reusable templates for pages or UI structures
├─ 📁 utils         # Shared utilities + config (theme, Firebase options, etc.)
├─ 📁 view          # App pages/screens
├─ 📁 widgets       # Components reused across the app
📁 test             # Test folder
📄 .env.example     # template for your local .env
```

# Configuration

## 0. Prerequisites
- Flutter SDK 
- A Firebase project
- Cloudinary account

## 1. Firebase
Before anything, make sure to create a project on Firebase.

Install the FlutterFire CLI and run the following:
```bash
flutterfire configure
```

In the Firebase console: 
- Enable **Email/Password** authentication
- Create a **Cloud Firestore** database

## 2. Cloudinary
// TODO

## 3. Run the project
Get necessary dependencies by running the following: 
```bash
flutter pub get
```
_In case of problem, try `flutter clear` and again `flutter pub get` to reinstall dependencies._

Then, to run the project:
```bash
flutter run
```
_Make sure that the right device is selected before running the command._