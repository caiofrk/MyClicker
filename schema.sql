-- Create the 'tasks' table
create table public.tasks (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    action text not null,
    target jsonb default '{}'::jsonb,
    status text default 'pending'::text not null,
    result text
);

-- Enable Row Level Security (RLS)
alter table public.tasks enable row level security;

-- Create policies for access control
-- Note: These policies allow full access to anyone with the Anon key for testing purposes. 
-- In a production environment, you should lock this down to authenticated users or service roles.
create policy "Enable all access for testing"
on public.tasks
for all
using (true)
with check (true);

-- Insert a couple of test tasks to get you started!

-- 1. Open the Android Settings app
insert into public.tasks (action, target, status)
values ('launch_app', '"com.android.settings"', 'pending');

-- 2. Scrape the text currently on the screen
insert into public.tasks (action, target, status)
values ('scrape_screen', '{}', 'pending');
