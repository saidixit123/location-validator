# Clone the repo
git clone https://github.com/saidixit123/location-validator.git
cd location-validator/scraper

# Set up virtual environment
python -m venv venv
.\venv\Scripts\activate

# Install required packages
pip install selenium gspread google-auth

# Run the scraper
python main.py
