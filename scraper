import csv
import time
import random
from urllib.parse import quote_plus
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException

import gspread
from google.oauth2.service_account import Credentials

# ==== CONFIG ====
CHROMEDRIVER_PATH = r"C:\Users\JOBIAK\Downloads\google-keywords-api\chromedriver-win64\chromedriver-win64\chromedriver.exe"
SPREADSHEET_ID = "1jB-UmC-EFLeXozX1UKD2NXYbB-PL-weuPOpWj-4n_w0"  # <--- Put your sheet ID here
SHEET_NAME = "Sheet1"

# ==== GOOGLE SHEETS SETUP ====
SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]
CREDS = Credentials.from_service_account_file("credentials.json", scopes=SCOPES)
GC = gspread.authorize(CREDS)
sheet = GC.open_by_key(SPREADSHEET_ID).worksheet(SHEET_NAME)

# ==== BROWSER SETUP ====
options = Options()
options.add_argument("--start-maximized")
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--disable-infobars")
options.add_argument("--disable-extensions")
options.add_argument("--incognito")

driver = webdriver.Chrome(service=Service(CHROMEDRIVER_PATH), options=options)

# ==== SELENIUM UTILITY FUNCTIONS ====

def search_google(query):
    search_url = f"https://www.google.com/search?q={quote_plus(query)}&hl=en"
    driver.get(search_url)
    time.sleep(random.uniform(2, 4))

def check_jobs_in_location(loc):
    parts = loc.split(",")
    city = parts[0].strip()
    state = parts[1].strip()
    job_query = f"{city}, {state} jobs"
    search_google(job_query)

    try:
        driver.find_element(By.CSS_SELECTOR, "div.wHYlTd.FqK3wc.MKCbgd")
        return "Yes"
    except NoSuchElementException:
        return "No"


def check_zip_validity(loc):
    parts = loc.split(",")
    city = parts[0].strip()
    state = parts[1].strip()
    zipcode = parts[3].strip()

    zip_query = f"{city}, {state} postal code"
    search_google(zip_query)
    time.sleep(random.uniform(2, 4))

    page_text = driver.page_source.lower()
    if zipcode.lower() in page_text:
        return "Valid"
    else:
        # Try fallback search
        search_google(f"{zipcode} zip code")
        time.sleep(random.uniform(2, 4))
        page_text = driver.page_source.lower()
        return "Valid" if zipcode.lower() in page_text else "Invalid"

def get_population(loc):
    search_google(f"{loc} population")
    time.sleep(random.uniform(2, 4))

    try:
        pop_elem = driver.find_element(By.CSS_SELECTOR, "div.ayqGOc.kno-fb-ctx.KBXm4e")
        population = pop_elem.text.split(" ")[0].replace(",", "")
        return population
    except NoSuchElementException:
        return "Not Found"

# ==== MAIN LOGIC ====

def main():
    analyst_name = input("Enter Analyst Name: ").strip().lower()

    # Get all records as list of dicts
    expected_headers = ["Analyst Name", "Location", "Zip Validity", "Population", "Jobs Available"]
    all_records = sheet.get_all_records(expected_headers=expected_headers)


    # Find rows where Analyst Name matches and Location is NOT empty
    # and where either Population or Jobs Available or Zip Code or Zip Validity is empty or missing
    rows_to_process = []
    for idx, record in enumerate(all_records, start=2):  # Google Sheets rows start at 1 + header row
        rec_analyst = str(record.get("Analyst Name", "")).strip().lower()
        location = str(record.get("Location", "")).strip()
        population = str(record.get("Population", "")).strip()
        jobs_available = str(record.get("Jobs Available", "")).strip()
        zip_code = str(record.get("Zip Code", "")).strip()
        zip_validity = str(record.get("Zip Validity", "")).strip()


        if rec_analyst == analyst_name and location != "":
            if not population or not jobs_available or not zip_code or not zip_validity:
                rows_to_process.append((idx, location))

    print(f"Found {len(rows_to_process)} rows to process for analyst '{analyst_name}'.")

    for row_idx, location in rows_to_process:
        print(f"\n🔍 Processing row {row_idx}: {location}")

        # Extract zip code for writing (assuming last part after last comma)
        zipcode = location.split(",")[-1].strip()

        # Check ZIP validity
        zip_status = check_zip_validity(location)

        # Get population
        population = get_population(location)

        # Check jobs availability
        jobs = check_jobs_in_location(location)

        # Write results back to the sheet
        sheet.update(f"C{row_idx}", [[zipcode]])          # Zip Code
        sheet.update(f"D{row_idx}", [[zip_status]])       # Zip Validity
        sheet.update(f"E{row_idx}", [[population]])       # Population
        sheet.update(f"F{row_idx}", [[jobs]])             # Jobs Available


        print(f"✅ Row {row_idx} | ZIP: {zipcode} ({zip_status}) | Population: {population} | Jobs: {jobs}")

        # Be polite with Google, slow it down
        time.sleep(random.uniform(2, 5))

    print("\n✅ All done. Closing browser.")
    driver.quit()

if __name__ == "__main__":
    main()
