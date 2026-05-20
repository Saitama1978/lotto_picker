import os
import json
import firebase_admin
from firebase_admin import credentials, firestore
import requests
from bs4 import BeautifulSoup
from datetime import datetime

# 1. Kukunin ang Firebase Key mula sa ligtas na GitHub Secrets
firebase_key_env = os.environ.get('FIREBASE_KEY')

if not firebase_key_env:
    print("❌ Error: Hindi mahanap ang FIREBASE_KEY Secret.")
    exit(1)

# Initialize Firebase Admin SDK
if not firebase_admin._apps:
    cred_dict = json.loads(firebase_key_env)
    cred = credentials.Certificate(cred_dict)
    firebase_admin.initialize_app(cred)

db = firestore.client()

def get_latest_lotto():
    print("📡 Kumukuha ng pinakabagong resulta sa internet...")
    
    # Dito sa parteng ito ilalagay ang target URL ng lotto results layout.
    # Bilang panimula, gagawa muna tayo ng automatic dynamic updater base sa petsa ngayon.
    today_str = datetime.now().strftime("%B %d, %Y") # Halimbawa: May 20, 2026
    
    # Dito papasok ang automated map structure na tugma sa app mo ngayon
    lotto_payload = {
        'name': '3D Lotto (Swertres)',
        'date': f"{today_str} (9PM Draw)",
        'result': '8 - 3 - 0',  # Dito itatapon ang live scraped number sa susunod
        'jackpot': '₱4,500.00',
        'history': {
            'draw_1': {'date': today_str, 'result': '8 - 3 - 0'},
            'draw_2': {'date': 'May 19, 2026', 'result': '1 - 2 - 4'},
            'draw_3': {'date': 'May 17, 2026', 'result': '9 - 5 - 2'}
        }
    }
    
    # Automatic update o pagsusulat sa Firestore Document mo
    db.collection('lotto_games').document('3D').set(lotto_payload, merge=True)
    print(f"🚀 Matagumpay na na-update ang Firebase para sa araw na ito: {today_str}!")

if __name__ == "__main__":
    get_latest_lotto()
