# MyClicker

Welcome to MyClicker! This project contains a set of Python scripts to automate Android devices (either physical devices connected via USB or Android Studio emulators). 

## Prerequisites

1. **Python 3.x** installed.
2. **Android Studio** (for the emulator) or a physical Android device with **USB Debugging** enabled.
3. An active **Android Emulator** running.

---

## 1. The Basic ADB Bot (`bot.py`)

This script uses standard Python and raw ADB shell commands to interact with the device via hardcoded X/Y coordinates.

**How to run:**
1. Ensure your emulator is running.
2. Run the script:
   ```bash
   python bot.py
   ```
*(Note: It automatically finds `adb.exe` in the default Android Studio SDK location. If you are using a physical device or a custom setup, make sure `adb` is in your system PATH.)*

---

## 2. The Smart UI Bot (`smart_bot.py`)

This upgraded script uses `uiautomator2` to interact with the device natively by reading UI elements (like text and descriptions) instead of blindly tapping coordinates.

**Setup:**
1. Install the required package:
   ```bash
   pip install uiautomator2
   ```
2. Initialize the background service on your connected device/emulator:
   ```bash
   python -m uiautomator2 init
   ```

**How to run:**
1. Run the script to see it automatically open the Android Settings app and tap on the "Display" menu!
   ```bash
   python smart_bot.py
   ```

---

## 3. The Remote Supabase Bot (`supabase_bot.py`)

This script hooks your `smart_bot.py` into a Supabase database. It continuously polls a `tasks` table and executes any pending automation tasks remotely!

**Setup:**
1. Log into your [Supabase](https://supabase.com/) project.
2. Go to the **SQL Editor** and paste the contents of `schema.sql` to create the table, set up permissions, and queue some initial test tasks.
3. Install the Supabase Python client:
   ```bash
   pip install supabase
   ```

**How to run:**
1. Set your Supabase anon/public key as an environment variable in your terminal:
   - **Windows (PowerShell):** 
     ```powershell
     $env:SUPABASE_KEY="your_anon_key_here"
     ```
   - **Mac/Linux:**
     ```bash
     export SUPABASE_KEY="your_anon_key_here"
     ```
2. Run the polling script:
   ```bash
   python supabase_bot.py
   ```
3. Watch it instantly pick up the tasks from the database and execute them on your emulator! You can add new rows to your Supabase table from anywhere, and your local bot will handle the rest.
