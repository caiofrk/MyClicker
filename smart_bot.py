import uiautomator2 as u2
import time
import sys

class SmartAndroidBot:
    def __init__(self, device_serial: str = None):
        """
        Connect to the device. 
        Leave device_serial None to auto-connect to the only plugged-in device.
        """
        try:
            print("Connecting to device...")
            # u2.connect() automatically handles adb routing
            self.device = u2.connect(device_serial)
            print(f"Connected to {self.device.info.get('model', 'Unknown Device')}")
        except Exception as e:
            print(f"Failed to connect: {e}")
            sys.exit(1)

    def launch_app(self, package_name: str):
        """Starts an application by its package name (e.g., com.example.app)"""
        print(f"Launching {package_name}...")
        self.device.app_start(package_name)

    def click_button_by_text(self, text: str, timeout: int = 10):
        """Waits for an element with specific text to appear, then clicks it."""
        print(f"Waiting for '{text}' button...")
        
        # .wait() blocks until the element exists or the timeout hits
        element = self.device(text=text)
        if element.wait(timeout=timeout):
            element.click()
            print(f"Clicked '{text}'.")
        else:
            print(f"Timeout: Could not find '{text}' within {timeout} seconds.")
            # Handle failure (e.g., log to Supabase, restart app)

    def type_into_field(self, field_description: str, input_text: str):
        """Finds an input field by its content description and types into it."""
        element = self.device(description=field_description)
        if element.wait(timeout=5):
            # clear_text clears the field first, set_text types without opening the virtual keyboard
            element.clear_text()
            element.set_text(input_text)
            print(f"Typed into {field_description}.")
        else:
            print(f"Could not find field: {field_description}")

    def scrape_screen_text(self) -> list[str]:
        """Scrapes all visible text from the current screen."""
        # Dump the UI hierarchy and extract text attributes
        # This is great for verifying data made it from your Supabase DB to the UI
        xml_dump = self.device.dump_hierarchy()
        
        # A quick way to get all text elements currently visible
        visible_texts = []
        for elem in self.device(textMatches=".*"):
            text = elem.info.get('text')
            if text:
                visible_texts.append(text)
        return visible_texts

# --- Usage Example ---
if __name__ == "__main__":
    bot = SmartAndroidBot()

    # Example: Let's automate the default Android Settings app for testing!
    bot.launch_app("com.android.settings")

    # Give the app a moment to render
    time.sleep(2) 

    # 1. Let's read the screen text first
    screen_data = bot.scrape_screen_text()
    safe_text = str(screen_data[:5]).encode('ascii', 'ignore').decode('ascii')
    print(f"Text found on screen: {safe_text}... (truncated)")

    # 2. Click on the 'Display' setting by its visible text
    bot.click_button_by_text("Display")

    # 3. Wait for the new screen, read the text again to prove we navigated
    time.sleep(2)
    display_screen_data = bot.scrape_screen_text()
    print("Navigated to Display settings successfully!")
