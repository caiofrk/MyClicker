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
        
        try:
            element = self.device(text=text)
            if element.wait(timeout=timeout):
                element.click()
                print(f"Clicked '{text}'.")
            else:
                print(f"Timeout: Could not find '{text}' within {timeout} seconds.")
        except Exception as e:
            print(f"Error clicking '{text}': {e}")

    def type_into_field(self, field_description: str, input_text: str):
        """Finds an input field by its content description and types into it."""
        try:
            element = self.device(description=field_description)
            if element.wait(timeout=5):
                element.clear_text()
                element.set_text(input_text)
                print(f"Typed into {field_description}.")
            else:
                print(f"Could not find field: {field_description}")
        except Exception as e:
            print(f"Error typing into '{field_description}': {e}")

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

    def run_macro(self, macro_steps: list[dict], loop_count: int = 1):
        """
        Executes a sequence of actions.
        Supported actions: 'launch_app', 'click_text', 'type_desc', 'sleep'
        """
        if loop_count == 0:
            print(f"\n--- Running Macro infinitely ---")
        else:
            print(f"\n--- Running Macro {loop_count} times ---")
            
        iteration = 0
        while True:
            iteration += 1
            if loop_count != 0 and iteration > loop_count:
                break
            
            print(f"\n--- Iteration {iteration} ---")
            for i, step in enumerate(macro_steps, 1):
                action = step.get("action")
                print(f"Step {i}: {action}")
                
                if action == "launch_app":
                    self.launch_app(step.get("package_name"))
                elif action == "click_text":
                    self.click_button_by_text(step.get("text"), timeout=step.get("timeout", 10))
                elif action == "type_desc":
                    self.type_into_field(step.get("field_description"), step.get("input_text"))
                elif action == "sleep":
                    time.sleep(step.get("duration", 1))
                else:
                    print(f"Unknown action: {action}")
                    
        print("--- Macro Finished ---\n")

# --- Usage Example ---
if __name__ == "__main__":
    bot = SmartAndroidBot()

    # Example macro definition
    my_macro = [
        {"action": "launch_app", "package_name": "com.android.settings"},
        {"action": "sleep", "duration": 2},
        # We can dynamically pass parameters to our bot methods!
        {"action": "click_text", "text": "Display", "timeout": 5},
        {"action": "sleep", "duration": 2}
    ]

    # Run the macro instead of hardcoding steps in main
    bot.run_macro(my_macro)
