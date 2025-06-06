git clone https://github.com/saidixit123/location-validator.git
cd location-validator/scraper
python -m venv venv
.\venv\Scripts\activate
pip install selenium gspread google-auth
python main.py
