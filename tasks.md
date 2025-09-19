# MVP Build Plan for Offline To-Do App

This plan outlines granular, testable, and sequential steps for building
the MVP of the offline to-do app.

------------------------------------------------------------------------

## Phase 1: Project Setup

### Task 1.1: Create Flutter Project

-   **Start:** Run `flutter create todo_app`
-   **End:** A new Flutter project scaffold is generated and builds
    successfully on emulator/device.

### Task 1.2: Setup File + Folder Structure

-   **Start:** Add `lib/core`, `lib/models`, `lib/services`,
    `lib/providers`, `lib/screens`, `lib/widgets`, `lib/utils`
-   **End:** Folder structure matches architecture, with empty
    placeholder files.

### Task 1.3: Setup Dependencies

-   **Start:** Add dependencies to `pubspec.yaml` (e.g., `provider`,
    `sqflite`, `path_provider`, `flutter_local_notifications`,
    `image_picker`).
-   **End:** Run `flutter pub get` successfully.

------------------------------------------------------------------------

## Phase 2: Core Models

### Task 2.1: Define Task Model

-   **Start:** Create `task_model.dart` with fields: `id`, `name`,
    `description`, `tag`, `deadline`, `reminder`, `isDone`, `imagePath`.
-   **End:** Task class is defined and test-constructed.

### Task 2.2: Create Tag Enum

-   **Start:** Define `Tag { business, work, school, personal, other }`
    in `tag_enum.dart`.
-   **End:** Enum can be imported and referenced in `TaskModel`.

------------------------------------------------------------------------

## Phase 3: Local Database (Sqflite)

### Task 3.1: Setup Database Helper

-   **Start:** Create `database_service.dart` with init function using
    `sqflite` + `path_provider`.
-   **End:** Can open and close local DB.

### Task 3.2: Create Tasks Table

-   **Start:** Add SQL schema for `tasks` (fields: id, name,
    description, tag, deadline, reminder, isDone, imagePath).
-   **End:** DB creates table on first run.

### Task 3.3: Insert Task Method

-   **Start:** Implement `insertTask(TaskModel)` in `DatabaseService`.
-   **End:** Task successfully stored in DB.

### Task 3.4: Fetch Tasks Method

-   **Start:** Implement `getTasks()` returning `List<TaskModel>`.
-   **End:** Can retrieve tasks from DB.

### Task 3.5: Update Task Method

-   **Start:** Implement `updateTask(TaskModel)`.
-   **End:** Task updates correctly in DB.

### Task 3.6: Delete Task Method

-   **Start:** Implement `deleteTask(int id)`.
-   **End:** Task deleted from DB.

------------------------------------------------------------------------

## Phase 4: State Management (Provider)

### Task 4.1: Create TaskProvider

-   **Start:** Create `task_provider.dart` extending `ChangeNotifier`
    with list of tasks.
-   **End:** Provider exposes `tasks` and notifies on change.

### Task 4.2: Connect Provider to Database

-   **Start:** Use `DatabaseService` inside `TaskProvider` methods
    (`loadTasks`, `addTask`, `editTask`, `removeTask`, `markDone`).
-   **End:** State updates correctly when DB changes.

### Task 4.3: Wrap App with Provider

-   **Start:** Update `main.dart` to use `MultiProvider` with
    `TaskProvider`.
-   **End:** All widgets can access tasks state.

------------------------------------------------------------------------

## Phase 5: Core Screens

### Task 5.1: Create Task List Screen (UI only)

-   **Start:** Scaffold screen with `ListView.builder` displaying
    placeholder tasks.
-   **End:** Static UI visible.

### Task 5.2: Connect Task List Screen to Provider

-   **Start:** Fetch `tasks` from `TaskProvider` and render dynamically.
-   **End:** List updates when provider updates.

### Task 5.3: Add Task Form (UI only)

-   **Start:** Build form with fields: name, description, tag dropdown,
    deadline picker, reminder picker, image picker button.
-   **End:** UI form visible, inputs captured locally.

### Task 5.4: Save Task via Provider

-   **Start:** Connect form submit to `TaskProvider.addTask`.
-   **End:** New task appears in list after save.

### Task 5.5: Edit Task Screen

-   **Start:** Populate form with existing task details.
-   **End:** Changes saved via `TaskProvider.editTask`.

### Task 5.6: Mark Task as Done

-   **Start:** Add checkbox/button in task list item.
-   **End:** Updates `isDone` in DB + provider.

### Task 5.7: Delete Task

-   **Start:** Add delete button per task.
-   **End:** Task removed from list + DB.

------------------------------------------------------------------------

## Phase 6: Notifications

### Task 6.1: Setup Notifications Service

-   **Start:** Create `notification_service.dart` and configure
    `flutter_local_notifications`.
-   **End:** Can show test notification.

### Task 6.2: Schedule Notification for Task

-   **Start:** On task creation/edit, schedule notification based on
    `reminder` time.
-   **End:** Notification appears at correct time, even if app closed.

### Task 6.3: Cancel Notification on Delete

-   **Start:** Cancel scheduled notification when task is deleted.
-   **End:** Deleted tasks no longer notify.

------------------------------------------------------------------------

## Phase 7: Image Handling

### Task 7.1: Setup Image Picker Service

-   **Start:** Create `image_service.dart` with `pickImage()` using
    `image_picker`.
-   **End:** Can select/take an image.

### Task 7.2: Save Image Path to Task

-   **Start:** Store selected image path in task on create/edit.
-   **End:** Image path persists in DB.

### Task 7.3: Display Task Image

-   **Start:** Update task list/detail to show image if available.
-   **End:** Image loads from local path.

------------------------------------------------------------------------

## Phase 8: Polish & Testing

### Task 8.1: Error Handling

-   **Start:** Add try/catch in services and provider methods.
-   **End:** App handles DB/notification/image errors gracefully.

### Task 8.2: UI Polish

-   **Start:** Improve styling, icons, layouts.
-   **End:** App looks clean and user-friendly.

### Task 8.3: Integration Testing

-   **Start:** Write widget tests for task creation, editing, deletion,
    and notifications.
-   **End:** All major flows pass tests.

------------------------------------------------------------------------

## Completion

At this point, the MVP is ready: offline to-do app with task CRUD,
notifications, images, and persistence.
