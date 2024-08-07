import time
import requests

def get_opponent_name(game_id, access_token):
    url = f"https://online-go.com/api/v1/games/{game_id}"
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    response = requests.get(url, headers=headers)
    data = response.json()
    
    if response.status_code == 200:
        opponent_name = data['game']['opponent']  # Adjust based on actual API response structure
        return opponent_name
    else:
        raise Exception(f"Failed to fetch opponent's name: {response.status_code}, {response.text}")

def get_opponent_rank(username, access_token):
    url = f"https://online-go.com/api/v1/users/{username}"
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    response = requests.get(url, headers=headers)
    data = response.json()
    
    if response.status_code == 200:
        rank = data['rank']  # Adjust based on actual API response structure
        return rank
    else:
        raise Exception(f"Failed to fetch opponent's rank: {response.status_code}, {response.text}")

def update_config_file(config_file_path, rank):
    with open(config_file_path, 'r') as file:
        lines = file.readlines()
    
    # Update the specific line (line 72 in this case)
    with open(config_file_path, 'w') as file:
        for i, line in enumerate(lines):
            if i == 71:  # Line numbers are 0-based in Python, so line 72 is index 71
                line = f"humanSLProfile = preaz_{rank}\n"
            file.write(line)

def check_for_new_game():
    # Placeholder for actual implementation to check for new games
    # For demo purposes, we'll just wait for a specified interval
    time.sleep(60)  # Check every 60 seconds

def main():
    access_token = "your_access_token"  # Ensure you have the correct access token
    config_file_path = "C:\\Users\\chang\\Downloads\\katago-v1.15.3-cuda12.5-cudnn8.9.7-windows-x64\\gtp_human5k_example.cfg"

    while True:
        try:
            check_for_new_game()
            game_id = "current_game_id"  # Replace with method to get current game ID
            opponent_name = get_opponent_name(game_id, access_token)
            rank = get_opponent_rank(opponent_name, access_token)
            update_config_file(config_file_path, rank)
            print(f"Config file updated with rank: {rank} for opponent: {opponent_name}")
        except Exception as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
