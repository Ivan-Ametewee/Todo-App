Here’s a **complete Flutter offline To-Do App architecture** documented in markdown:

---

# 📌 Offline To-Do App Architecture (Flutter)

This document outlines the **file + folder structure**, **responsibilities of each part**, and **state management flow** for building an offline-first to-do application with Flutter.

---

## 📂 File & Folder Structure

```
lib/
│── main.dart
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   │   └── app_strings.dart
│   ├── utils/
│   │   ├── date_time_helper.dart
│   │   └── notification_helper.dart
│   └── widgets/
│       ├── custom_text_field.dart
│       ├── task_card.dart
│       └── empty_state.dart
│
├── data/
│   ├── local/
│   │   ├── database_helper.dart
│   │   └── task_dao.dart
│   ├── models/
│   │   └── task_model.dart
│   └── services/
│       ├── notification_service.dart
│       ├── image_service.dart
│       └── task_service.dart
│
├── state/
│   ├── task_store.dart
│   └── notification_store.dart
│
└── presentation/
    ├── screens/
    │   ├── home_screen.dart
    │   ├── add_edit_task_screen.dart
    │   ├── task_detail_screen.dart
    │   └── settings_screen.dart
    └── widgets/
        ├── task_form.dart
        ├── deadline_picker.dart
        └── tag_selector.dart
```

---

## 📖 Explanation of Each Part

### 1. **Main Entry**

* `main.dart`

  * Initializes the app.
  * Sets up state management (e.g., Riverpod, Provider, or Bloc).
  * Ensures notifications and local database are initialized before `runApp()`.

---

### 2. **App Layer (`app/`)**

* **`app.dart`**: Root widget, configures themes, providers, and routing.
* **`router.dart`**: Central navigation setup using `GoRouter` or `Navigator 2.0`.
* **`theme.dart`**: Defines light/dark theme, typography, and global styles.

---

### 3. **Core Layer (`core/`)**

* **`constants/`**: Reusable constants (tags, strings, etc.).
* **`utils/`**: Helper classes (date formatting, notification scheduling).
* **`widgets/`**: Generic widgets (e.g., task cards, empty state UI, reusable text fields).

---

### 4. **Data Layer (`data/`)**

* **`models/`**

  * `task_model.dart`: Defines the `Task` entity with fields:

    ```dart
    class Task {
      final int? id;
      String name;
      String description;
      String tag;
      DateTime deadline;
      Duration notifyBefore;
      bool isDone;
      String? imagePath;
    }
    ```
* **`local/`**

  * `database_helper.dart`: Initializes SQLite (using `sqflite` or `drift`).
  * `task_dao.dart`: Handles CRUD operations on the `tasks` table.
* **`services/`**

  * `notification_service.dart`: Handles scheduling + canceling local notifications (using `flutter_local_notifications`).
  * `image_service.dart`: Handles picking/taking images (`image_picker`).
  * `task_service.dart`: Acts as a middle layer, combining DAO + Notification service.

---

### 5. **State Layer (`state/`)**

This layer manages **business logic and app state**.

* **`task_store.dart`**

  * Holds a list of tasks.
  * Provides methods:

    * `addTask()`
    * `updateTask()`
    * `deleteTask()`
    * `markAsDone()`
    * `loadTasks()`
  * Syncs changes with local DB.
* **`notification_store.dart`**

  * Manages active notifications.
  * Updates alarms when tasks change.

💡 Recommended State Management: **Riverpod** or **Bloc** (clean separation).

---

### 6. **Presentation Layer (`presentation/`)**

UI layer broken into **screens** and **widgets**.

#### Screens:

* **`home_screen.dart`**

  * Shows list of tasks.
  * Allows marking as done or deleting.
* **`add_edit_task_screen.dart`**

  * Form for adding or editing tasks.
  * Includes **task\_form**, **deadline\_picker**, and **tag\_selector** widgets.
* **`task_detail_screen.dart`**

  * Displays full task details (image, description, deadline).
* **`settings_screen.dart`**

  * Allows user to configure app preferences (e.g., default notify times).

#### Widgets:

* **`task_form.dart`**

  * Fields for name, description, tag, deadline, notification lead time.
* **`deadline_picker.dart`**

  * Date + time picker widget.
* **`tag_selector.dart`**

  * Chip-based selector (Business, Work, School, Personal, etc.).

---

## ⚡ State & Service Flow

Here’s how everything connects:

1. **User creates/edits a task**

   * `AddEditTaskScreen` → `task_store.addTask()`.
   * Store updates **local DB** via `task_service`.
   * Store triggers `notification_service.scheduleNotification()`.
   * UI updates via state listeners.

2. **User marks a task as done**

   * `HomeScreen` → `task_store.markAsDone()`.
   * Store updates DB and cancels notification.

3. **Notifications (background/foreground)**

   * `notification_service` schedules alarms.
   * Even if app is closed, OS delivers local notification.
   * When tapped, notification routes user to `TaskDetailScreen`.

4. **Images**

   * `image_service` handles capturing or picking.
   * File path is stored in the `Task` model.
   * Shown in `task_detail_screen`.

5. **Offline Persistence**

   * All tasks stored in **SQLite**.
   * UI always reads from `task_store`, which syncs from DB.

---

## 🔑 Key Libraries

* **State Management**: Riverpod or Bloc
* **Database**: `sqflite` or `drift`
* **Notifications**: `flutter_local_notifications`
* **Image Picker**: `image_picker`
* **Routing**: `go_router` (or Navigator 2.0)

---

✅ With this architecture, you get:

* Offline-first reliability
* Clean separation of concerns
* Background notifications
* Extensible design (easy to add sync with cloud later)

---

