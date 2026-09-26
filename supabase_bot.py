import os
import time
from supabase import create_client, Client
from smart_bot import SmartAndroidBot

# Supabase configuration
URL: str = "https://wtkfkuvclulmlzltfzcy.supabase.co"
KEY: str = os.environ.get("SUPABASE_KEY")

if not KEY:
    print("Error: SUPABASE_KEY environment variable is not set.")
    print("Please set it before running this script.")
    print("Example: $env:SUPABASE_KEY='your_anon_key'; python supabase_bot.py")
    exit(1)

supabase: Client = create_client(URL, KEY)

# Initialize our Android bot
print("Initializing Android bot...")
bot = SmartAndroidBot()

def process_tasks():
    print("Listening to Supabase for tasks...")
    while True:
        try:
            # Poll for the oldest pending task
            # Ensure you have a 'tasks' table with 'status', 'action', 'target' columns
            response = supabase.table('tasks') \
                .select('*') \
                .eq('status', 'pending') \
                .order('created_at') \
                .limit(1) \
                .execute()
            
            if response.data:
                task = response.data[0]
                task_id = task['id']
                action = task.get('action')
                target = task.get('target')
                
                print(f"\n--- Picked up task {task_id}: {action} -> {target} ---")
                
                # Mark as processing so another worker doesn't grab it
                supabase.table('tasks').update({'status': 'processing'}).eq('id', task_id).execute()
                
                # Execute the automation logic based on the action type
                if action == 'launch_app':
                    bot.launch_app(target)
                elif action == 'click_text':
                    bot.click_button_by_text(target)
                elif action == 'type':
                    # Example target format: {"field": "Email Input", "text": "founder@startup.com"}
                    field = target.get('field', '')
                    text = target.get('text', '')
                    bot.type_into_field(field, text)
                elif action == 'scrape_screen':
                    data = bot.scrape_screen_text()
                    # You could update the task row with the scraped data!
                    supabase.table('tasks').update({'result': str(data)}).eq('id', task_id).execute()
                else:
                    print(f"Unknown action: {action}")
                
                # Mark as completed
                supabase.table('tasks').update({'status': 'completed'}).eq('id', task_id).execute()
                print(f"Task {task_id} completed successfully.")
            else:
                # No tasks found, wait a few seconds before polling again
                time.sleep(3)
                
        except Exception as e:
            print(f"Error checking or executing tasks: {e}")
            time.sleep(5) # Back off if there is a network error

if __name__ == "__main__":
    process_tasks()
