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
│  login_view, job_details_view, about_page, ...│
└───────────────┬───────────────────────────────┘
                │ reads state / calls methods
┌───────────────▼───────────────────────────────┐
│  Providers (state management)                 │  app logic + UI state
│  AuthProvider, JobProvider, ...               │  lets us refresh content when new update
└───────────────┬───────────────────────────────┘
                │ depends on interfaces (not Firebase!)
┌───────────────▼───────────────────────────────┐
│  Repositories & Services (abstractions)       │  data access contracts
│  JobRepository, AuthService,                  │
│  ImageStorageRepository, ...                  │
└───────────────┬───────────────────────────────┘
                │ implemented by
┌───────────────▼───────────────────────────────┐
│  Concrete implementations                     │  the real integrations
│  FirestoreJobRepository, FirebaseAuthService, │
│  CloudinaryImageRepository, ...               │
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
  `JobProvider`.
- **Dependency injection**: the providers receive their data sources through
  their constructors (`AuthProvider(FirebaseAuthService())`,
  `JobProvider(FirestoreJobRepository())`). This is what makes them testable.

In widgets you typically:

```dart
final user = context.watch<AuthProvider>();   // rebuild on change
context.read<JobProvider>().signOut();        // call once, no rebuild
```

## Data model
### Users
Users can be either students (aka job seekers) and employers (who create job offers).
Their info is stored across multiple documents, as follows: 

**AppUser**: contains common informations about students and employers

| field    | Description                               |
|----------|-------------------------------------------|
| name     | Name of the user                          |
| surname  | Surname of the user                       |
| address  | Home/Company address of the user          |
| email    | Email of the user                         |
| role     | Role of the user (student/employer/admin) |
| imageUrl | URL of their profile picture              |

_Do not confuse `User` (from Firebase) which contains data about Authentication and `AppUser` which contains personal data about the users._

----
**Student**: contains information about a user if they are a student

| field       | Description                                               |
|-------------|-----------------------------------------------------------|
| skills      | List of String containing skills of the student           |
| history     | List of `History` objects representing their previous jobs  |
| degree      | Degree that the student has                               |
| minSalary   | Min salary the student wants (for filtering job offers)   |
| maxDistance | Max distance the student wants to travel (to filter jobs) |

----
**Employer**: contains informations about a user if they are an employer

| field       | Description                                                                   |
|-------------|-------------------------------------------------------------------------------|
| companyName | Name of the company                                                           |
| canton      | Canton where the company is                                                   |
| city        | City where the company is                                                     |
| companySize | Number of employees working for the company (startup, small, medium or large) |

----
**History**: A history item, containing info about a previous job experience.

| field     | Description                 |
|-----------|-----------------------------|
| company   | Name of the company         |
| link      | Link to the company website |
| startDate | Date when the job started   |
| endDate   | Date when the job ended     |

## Job opportunities
**Job opportunities**: Represents a job opportunity, where a student can submit their application

| field              | Description                                                       |
|--------------------|-------------------------------------------------------------------|
| employer_user      | ID of the employer that created the offer                         |
| degree             | Minimal degree the student needs to have to submit an application |
| jobName            | Title of the job                                                  |
| description        | Description of the job                                            |
| languages          | Languages required for the job                                    |
| salary             | Salary of the job (yearly)                                        |
| workloadPercentage | Percentage of workload                                            |
| industry           | Industry of the job                                               |
| timestamp          | DateTime when the job opportunity is created                      |
| deadline           | DateTime representing the deadline to submit an application       |
| imageUrl           | URL of the thumbnail image in the job application                 |
| studentApplication | Map containing the ID and status of student applications          |
| role               | Role of the job                                                   |
| contract           | Duration of the contract                                          |
| holidays           | Number of holidays                                                |


## Review system
**Review**: Students can post a review about their Employers and vice-versa, with a rating and a comment.

| field         | Description                                      |
|---------------|--------------------------------------------------|
| reviewer_user | User that created the review                     |
| reviewee_user | User concerned by the review                     |
| comment       | Message of the review                            |
| note          | Star rating of the review (from 1 to 5 included) |
| timestamp     | Date of creation of the review                   |

## Transport 
**Transport**: Represents data about a trip (with a departure, destination and steps).

| field         | Description                                        |
|---------------|----------------------------------------------------|
| departureTime | DateTime of departure                              |
| arrivalTime   | DateTime of arrival                                |
| sections      | Steps to arrive at destinations (trains, bus, ...) |

# Configuration

## 0. Prerequisites
- Flutter SDK 
- For Android SDK (recommended): 
  - JDK 17
- A Firebase project
- Cloudinary account

*In case an error with jdk version occurs, try changing to the recommended JDK version above.*  
*You can do that by installing another java version (with a tool such as `javm`) and executing `flutter config --jdk-dir "{path_to_the_jdk_folder_you_installed}` in the project root.*

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