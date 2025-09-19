#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys

def run_command(command, cwd=None):
    """Run a shell command and return success status"""
    try:
        result = subprocess.run(command, shell=True, cwd=cwd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error running command: {command}")
            print(f"Error output: {result.stderr}")
            return False
        return True
    except Exception as e:
        print(f"Exception running command {command}: {e}")
        return False

def create_directory(path):
    """Create directory if it doesn't exist"""
    os.makedirs(path, exist_ok=True)
    print(f"Created directory: {path}")

def create_file(path, content=""):
    """Create file with optional content"""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created file: {path}")

def main():
    # Check if we're in todo_app directory
    current_dir = os.getcwd()
    if not current_dir.endswith('to_do'):
        print("Please run this script from within the to_do directory")
        print(f"Current directory: {current_dir}")
        sys.exit(1)
    
    print("Setting up Flutter To-Do App folder structure...")
    
    # Remove default files we don't need
    files_to_remove = ['lib/main.dart', 'test']
    for file_path in files_to_remove:
        if os.path.exists(file_path):
            if os.path.isdir(file_path):
                shutil.rmtree(file_path)
                print(f"Removed directory: {file_path}")
            else:
                os.remove(file_path)
                print(f"Removed file: {file_path}")
    
    # Create folder structure
    folders = [
        'lib/app',
        'lib/core/constants',
        'lib/core/utils', 
        'lib/core/widgets',
        'lib/data/local',
        'lib/data/models',
        'lib/data/services',
        'lib/state',
        'lib/presentation/screens',
        'lib/presentation/widgets'
    ]
    
    for folder in folders:
        create_directory(folder)
    
    # Create main.dart with minimal content
    main_dart_content = '''import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: Container(), // Placeholder
    );
  }
}
'''
    
    create_file('lib/main.dart', main_dart_content)
    
    # Create all placeholder files
    placeholder_files = [
        # App layer
        'lib/app/app.dart',
        'lib/app/router.dart', 
        'lib/app/theme.dart',
        
        # Core layer
        'lib/core/constants/app_strings.dart',
        'lib/core/utils/date_time_helper.dart',
        'lib/core/utils/notification_helper.dart',
        'lib/core/widgets/custom_text_field.dart',
        'lib/core/widgets/task_card.dart',
        'lib/core/widgets/empty_state.dart',
        
        # Data layer
        'lib/data/local/database_helper.dart',
        'lib/data/local/task_dao.dart',
        'lib/data/models/task_model.dart',
        'lib/data/services/notification_service.dart',
        'lib/data/services/image_service.dart',
        'lib/data/services/task_service.dart',
        
        # State layer
        'lib/state/task_store.dart',
        'lib/state/notification_store.dart',
        
        # Presentation layer
        'lib/presentation/screens/home_screen.dart',
        'lib/presentation/screens/add_edit_task_screen.dart',
        'lib/presentation/screens/task_detail_screen.dart',
        'lib/presentation/screens/settings_screen.dart',
        'lib/presentation/widgets/task_form.dart',
        'lib/presentation/widgets/deadline_picker.dart',
        'lib/presentation/widgets/tag_selector.dart'
    ]
    
    for file_path in placeholder_files:
        create_file(file_path)
    
    print("\n✅ Folder structure setup complete!")
    print("\nNext steps:")
    print("1. Run 'flutter run' to verify the app builds")
    print("2. Confirm you see a blank screen (this is expected)")
    print("3. Let me know when Task 1.2 is complete!")

if __name__ == "__main__":
    main()