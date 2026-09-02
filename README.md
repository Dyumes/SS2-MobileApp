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
# Tech stack

| Concern              | Technology                          |
| -------------------- | ----------------------------------- |
| UI framework         | Flutter (Material)                  |
| State management     | `provider` (`ChangeNotifier`)       |
| Authentication       | `firebase_auth`                     |
| Database             | `cloud_firestore` (real-time)       |
| Image hosting        | Cloudinary (withs `http` upload)    |
| Image picking        | `image_picker`                      |
| Configuration        | `flutter_dotenv` (`.env` file)      |
| Tests                | `flutter_test` + fakes files        |

## Architecture overview

The app uses a **layered architecture**. Each layer has a single
responsibility and only talks to the layer directly below it. The UI never
talks to Firebase or Cloudinary directly.

```
┌───────────────────────────────────────────────┐
│  Views & Widgets (UI)                         │  what the user sees
│  login_screen, task_list_screen, task_form…   │
└───────────────┬───────────────────────────────┘
                │ reads state / calls methods
┌───────────────▼───────────────────────────────┐
│  Providers (state management)                 │  app logic + UI state
│  AuthProvider, TaskProvider                   │  lets us refresh content when new update
└───────────────┬───────────────────────────────┘
                │ depends on interfaces (not Firebase!)
┌───────────────▼───────────────────────────────┐
│  Repositories & Services (abstractions)       │  data access contracts
│  TaskRepository, AuthService,                 │
│  ImageStorageRepository                       │
└───────────────┬───────────────────────────────┘
                │ implemented by
┌───────────────▼───────────────────────────────┐
│  Concrete implementations                     │  the real integrations
│  FirestoreTaskRepository, FirebaseAuthService,│
│  CloudinaryImageRepository                    │
└───────────────┬───────────────────────────────┘
                │
┌───────────────▼───────────────────────────────┐
│  External services: Firebase, Cloudinary      │
└───────────────────────────────────────────────┘
```

## State management with Provider

This project uses the **`provider`** package. The two key objects are
`ChangeNotifier`registered in `main.dart`:

```dart
MultiProvider(
  providers: [
    Provider<ImageStorageRepository>(
      create: (_) => CloudinaryImageRepository(
        cloudName: CloudinaryConfig.cloudName,
        uploadPreset: CloudinaryConfig.uploadPreset,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => AuthProvider(FirebaseAuthService()),
    ),
    ChangeNotifierProxyProvider<AuthProvider, JobProvider>(
      create: (_) => JobProvider(FirestoreJobRepository()),
      update: (_, auth, jobProvider) => jobProvider!..updateAuth(auth),
    ),
  ],
  ...
)
```

- **`ChangeNotifierProvider`** exposes a `ChangeNotifier` to the widget tree.
  When it calls `notifyListeners()`, listening widgets rebuild.
- **`ChangeNotifierProxyProvider`** is used because `JobProvider` *depends on*
  `AuthProvider`: it needs the current user's id to know whose data to load.
  Whenever auth changes, the proxy hands the latest `AuthProvider` to
  `TaskProvider`.
- **Dependency injection**: the providers receive their data sources through
  their constructors (`AuthProvider(FirebaseAuthService())`,
  `JobProvider(FirestoreTaskRepository())`). This is what makes them testable.

In widgets you typically:

```dart
final tasks = context.watch<JobProvider>().tasks;   // rebuild on change
context.read<JobProvider>().deleteTask(id);         // call once, no rebuild
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
Images are uploaded directly from the app using an **unsigned upload preset**,
so no secret key is ever stored in the app.

1. Create a free Cloudinary account.
2. In **Settings → Upload → Upload presets**, create a preset with
   **Signing Mode = Unsigned**.
3. Copy the example env file and fill in your values:

   ```bash
   cp .env.example .env
   ```

   ```env
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_unsigned_upload_preset
   ```

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

# Testing
Tests are stored in the `test` folder. In order to launch the tests, execute the following:
```bash
flutter test
``` 
Tests use a combination of fakes (in `fakes.dart`) and helpers (in `helpers/` folder), instead of doing the requests directly on Firebase.