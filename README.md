# flutter-back4app-tasks
Assignment for Cross Platform App Development. It will create a Task application to help perform CRUD (Create, Read, Update, Delete) operations using flutter. The backend is running in Back4app. Client credentials are used to access the backend.

## Create flutter App:
From terminal, run `flutter create <project name>` to create a new flutter App.

## Install dependencies:
Edit `pubspec.yaml` and run `flutter pub get` from terminal to install dependencies.

## Run the app
From terminal, run `flutter run` to run the app, choose `2` to run with chrome.

## Reload the app
From terminal, press `r` or `R` to reload the app while the app is running to show the code changes.

### The main code is present in `main.dart` in `lib/` directory.

## Assignment flow:

#### Step 1: Set Up Back4App

-  Sign up for a Back4App account (if not already done).
  
-  Create a new Back4App app.
  
-  Create a class in Back4App named Task with columns title (String) and description (String).

#### Step 2: Flutter Setup

-  Create a new Flutter project.
  
-  Add the required dependencies to your pubspec.yaml file.
  
-  Initialize the Parse SDK in your Flutter app.

#### Step 3: Task List

-  Create a screen in your Flutter app to display a list of tasks.
  
-  Implement a function to fetch tasks from Back4App using the Back4App API.
  
-  Display the tasks in a list view with titles and descriptions.

#### Step 4: Task Creation

-  Create a screen for adding new tasks.
  
-  Implement functionality to create and save tasks to Back4App.
  
-  Verify that newly created tasks appear in the task list.

#### Step 5: Task Details

-  Add a feature to view task details when a task is tapped in the task list.

-  Display the title and description of the selected task.

#### Step 6: Bonus Features

-  Add a feature to edit and update existing tasks.

-  Implement a feature for task deletion.
