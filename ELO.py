import time
import requests

# Flag to ensure the command is run only once
in_process = False

def get_active_games(player_id):
    url = f"https://online-go.com/api/v1/players/{player_id}/full"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        return data.get("active_games", [])
    else:
        raise Exception(f"Failed to fetch active games: {response.status_code}, {response.text}")

def extract_opponent_info(game, player_id):
    if game['black']['id'] == player_id:
        opponent = game['white']
    else:
        opponent = game['black']
    
    rating_data = opponent.get('ratings', {}).get('overall', {})
    rating = rating_data.get('rating')
    
    if rating is None:
        raise Exception(f"Rating not found in the opponent's data: {opponent}")
    
    return opponent['username'], rating

def rank_number_to_label(rating):
    # Dan Ranks (100-point difference)
    if rating >= 2600:
        return "9d"
    elif 2500 <= rating < 2600:
        return "8d"
    elif 2400 <= rating < 2500:
        return "7d"
    elif 2300 <= rating < 2400:
        return "6d"
    elif 2200 <= rating < 2300:
        return "5d"
    elif 2100 <= rating < 2200:
        return "4d"
    elif 2000 <= rating < 2100:
        return "3d"
    elif 1900 <= rating < 2000:
        return "2d"
    elif 1800 <= rating < 1900:
        return "1d"

    # Kyu Ranks (50-point difference for ranks below 1d)
    elif 1700 <= rating < 1800:
        return "1k"
    elif 1650 <= rating < 1700:
        return "2k"
    elif 1600 <= rating < 1650:
        return "3k"
    elif 1550 <= rating < 1600:
        return "4k"
    elif 1500 <= rating < 1550:
        return "5k"
    elif 1450 <= rating < 1500:
        return "6k"
    elif 1400 <= rating < 1450:
        return "7k"
    elif 1350 <= rating < 1400:
        return "8k"
    elif 1300 <= rating < 1350:
        return "9k"
    elif 1250 <= rating < 1300:
        return "10k"
    elif 1200 <= rating < 1250:
        return "11k"
    elif 1150 <= rating < 1200:
        return "12k"
    elif 1100 <= rating < 1150:
        return "13k"
    elif 1050 <= rating < 1100:
        return "14k"
    elif 1000 <= rating < 1050:
        return "15k"
    elif 950 <= rating < 1000:
        return "16k"
    elif 900 <= rating < 950:
        return "17k"
    elif 850 <= rating < 900:
        return "18k"
    elif 800 <= rating < 850:
        return "19k"
    elif 750 <= rating < 800:
        return "20k"
    elif 700 <= rating < 750:
        return "21k"
    elif 650 <= rating < 700:
        return "22k"
    elif 600 <= rating < 650:
        return "23k"
    elif 550 <= rating < 600:
        return "24k"
    elif 500 <= rating < 550:
        return "25k"

    # For ratings below the lowest rank
    elif rating < 500:
        return "25k"
    
    # Fallback case
    else:
        return "25k"

def update_config_file(config_file_path, rank_label):
    with open(config_file_path, 'r') as file:
        lines = file.readlines()

    with open(config_file_path, 'w') as file:
        for i, line in enumerate(lines):
            if i == 71:  # Update the specific line with opponent's rank
                line = f"humanSLProfile = preaz_{rank_label}\n"
            file.write(line)

def main():
    global in_process

    player_id = 1591164  # Only check for this player
    config_file_path = "C:\\Users\\chang\\Downloads\\katago-v1.15.3-cuda12.5-cudnn8.9.7-windows-x64\\gtp_human5k_example.cfg"

    while True:
        try:
            active_games = get_active_games(player_id)

            if active_games:
                if not in_process:
                    game = active_games[0]  # Assuming only one active game for simplicity
                    opponent_name, opponent_rating = extract_opponent_info(game, player_id)
                    rank_label = rank_number_to_label(opponent_rating)
                    update_config_file(config_file_path, rank_label)
                    print(f"Updated config with rank: {rank_label} for opponent: {opponent_name}")

                    # Update the process state
                    in_process = True
            else:
                if in_process:
                    # Update the process state
                    in_process = False
                print(f"No active games found for player ID: {player_id}")

            time.sleep(2)  # Check every 2 seconds

        except Exception as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
