#!/usr/bin/env python3
"""
Database Clean Script for Llama.io API
Removes all users and tasks from the database
"""

import requests
import argparse

def main():
    parser = argparse.ArgumentParser(description='Clean all data from database')
    parser.add_argument('-u', '--url', required=True, help='API URL (e.g., localhost)')
    parser.add_argument('-p', '--port', required=True, help='Port number (e.g., 3000)')
    
    args = parser.parse_args()
    
    # Build base URL
    base_url = f"http://{args.url}:{args.port}/api"
    
    print(f"🧹 Starting database cleanup...")
    print(f"📍 API: {base_url}")
    print()
    
    # Get all users
    try:
        response = requests.get(f"{base_url}/users")
        users = response.json()['data']
        print(f"Found {len(users)} users")
    except Exception as e:
        print(f"❌ Error fetching users: {e}")
        users = []
    
    # Get all tasks
    try:
        response = requests.get(f"{base_url}/tasks")
        tasks = response.json()['data']
        print(f"Found {len(tasks)} tasks")
    except Exception as e:
        print(f"❌ Error fetching tasks: {e}")
        tasks = []
    
    print()
    
    # Delete all tasks
    if tasks:
        print("Deleting tasks...")
        deleted_tasks = 0
        for task in tasks:
            try:
                response = requests.delete(f"{base_url}/tasks/{task['_id']}")
                if response.status_code == 204:
                    deleted_tasks += 1
                    print(f"✓ Deleted task: {task['name'][:50]}")
                else:
                    print(f"✗ Failed to delete task {task['_id']}")
            except Exception as e:
                print(f"✗ Error deleting task: {e}")
        print(f"\n✅ Deleted {deleted_tasks}/{len(tasks)} tasks\n")
    
    # Delete all users
    if users:
        print("Deleting users...")
        deleted_users = 0
        for user in users:
            try:
                response = requests.delete(f"{base_url}/users/{user['_id']}")
                if response.status_code == 204:
                    deleted_users += 1
                    print(f"✓ Deleted user: {user['name']}")
                else:
                    print(f"✗ Failed to delete user {user['_id']}")
            except Exception as e:
                print(f"✗ Error deleting user: {e}")
        print(f"\n✅ Deleted {deleted_users}/{len(users)} users\n")
    
    print("=" * 60)
    print("📊 Summary:")
    print(f"  Tasks deleted: {deleted_tasks if tasks else 0}")
    print(f"  Users deleted: {deleted_users if users else 0}")
    print("=" * 60)
    print()
    print("🎉 Database cleanup complete!")

if __name__ == '__main__':
    main()

