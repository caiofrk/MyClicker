import subprocess
import time
import sys

class AndroidBot:
    def __init__(self, device_id: str = None):
        """
        Initialize the bot. If you have multiple devices connected, 
        pass the device_id (find it by running `adb devices` in terminal).
        """
        self.device_id = device_id
        self._check_connection()

    def _run_adb_command(self, command: list[str]) -> str:
        """Helper to run adb commands safely."""
        import os
        adb_path = os.path.expandvars(r"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe")
        if not os.path.exists(adb_path):
            adb_path = "adb" # fallback to PATH

        base_cmd = [adb_path]
        if self.device_id:
            base_cmd.extend(["-s", self.device_id])
        
        base_cmd.extend(command)
        
        try:
            result = subprocess.run(
                base_cmd, 
                capture_output=True, 
                text=True, 
                check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            print(f"Error running command {' '.join(base_cmd)}: {e.stderr}")
            sys.exit(1)

    def _check_connection(self):
        """Verify a device is actually connected and authorized."""
        import os
        adb_path = os.path.expandvars(r"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe")
        if not os.path.exists(adb_path):
            adb_path = "adb" # fallback to PATH

        output = subprocess.run([adb_path, "devices"], capture_output=True, text=True).stdout
        if "device" not in output.split('\n')[1]: # The first line is "List of devices attached"
            print("No device found! Make sure USB debugging is enabled and authorized.")
            sys.exit(1)
        print("Device connected successfully.")

    def tap(self, x: int, y: int):
        """Simulate a single tap at X, Y coordinates."""
        print(f"Tapping at ({x}, {y})")
        self._run_adb_command(["shell", "input", "tap", str(x), str(y)])

    def swipe(self, x1: int, y1: int, x2: int, y2: int, duration_ms: int = 500):
        """Simulate a swipe from (x1, y1) to (x2, y2)."""
        print(f"Swiping from ({x1}, {y1}) to ({x2}, {y2}) over {duration_ms}ms")
        self._run_adb_command([
            "shell", "input", "swipe", 
            str(x1), str(y1), str(x2), str(y2), str(duration_ms)
        ])

    def type_text(self, text: str):
        """
        Type text. Note: spaces need to be escaped for adb shell,
        so we replace spaces with %s.
        """
        formatted_text = text.replace(" ", "%s")
        print(f"Typing: {text}")
        self._run_adb_command(["shell", "input", "text", formatted_text])

    def press_key(self, keycode: int):
        """
        Press a hardware key. 
        Examples: 3 = HOME, 4 = BACK, 26 = POWER, 66 = ENTER
        """
        print(f"Pressing keycode: {keycode}")
        self._run_adb_command(["shell", "input", "keyevent", str(keycode)])


# --- Usage Example ---
if __name__ == "__main__":
    # Initialize our script (will auto-detect if only one device is connected)
    bot = AndroidBot()

    # Wait a second before starting
    time.sleep(1)

    # Example: Open an app icon at coordinates 500, 1000
    bot.tap(500, 1000)
    time.sleep(2) # Give the UI time to transition

    # Example: Swipe up to scroll
    bot.swipe(500, 1500, 500, 500, duration_ms=300)
    time.sleep(1)

    # Example: Tap a search bar, type something, and hit enter
    bot.tap(500, 200) # Assuming search bar is here
    time.sleep(1)
    bot.type_text("Flutter and Supabase")
    bot.press_key(66) # 66 is the ENTER key
