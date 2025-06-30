import re
import requests
from bs4 import BeautifulSoup
import pandas as pd
import logging
import time
import random
from datetime import datetime


def get_all_urls(soup: BeautifulSoup) -> list[str]:
    """Return a list with all weekly urls from the main soup object"""
    select_tag = soup.find("select", id="dateWeek-filter")
    date_tags = select_tag.find_all("option")
    dates = [
        (
            date_tag["value"]
            if not "Current" in date_tag["value"]
            else "Current+Date"
        )
        for date_tag in date_tags
    ]
    base_url = "https://www.atptour.com/en/rankings/singles?dateWeek="
    return sorted([f"{base_url}{date}" for date in dates])


def get_with_retry(url, headers, max_retries=5, backoff_factor=1):
    for attempt in range(max_retries):
        try:
            session = requests.Session()
            response = session.get(url, headers=headers)
            if response.status_code == 200:
                return response
            else:
                raise ValueError(
                    f"Bad status code: {response.status_code}"
                )
        except Exception as e:
            wait = backoff_factor * (2**attempt)
            logger.info(
                f"Attempt {attempt+1} failed: {e}. Retrying in {wait}s..."
            )
            time.sleep(wait)
    raise RuntimeError(
        f"Failed to get {url} after {max_retries} retries"
    )


def get_active_week(soup: BeautifulSoup) -> str:
    """
    returns the active week, directly through scraping and not through the url
    unlike the get_all_urls it will extract the text contents instead of
    the value attribute, otherwise we would get date 'Current-Date' for our
    most recent date.
    """

    select_tag = soup.find("select", id="dateWeek-filter")
    return select_tag.find("option", selected=True).text


def get_player_names(soup: BeautifulSoup) -> list[str]:
    """
    returns a list of the top-100 players names ordered by rank
    """
    li_tags = soup.find_all("li", class_="name center")
    return [li.find("span").text for li in li_tags]


def get_countries(soup: BeautifulSoup) -> list[str]:
    """
    returns a list of the top-100 players countries ordered by rank
    """
    svg_tags = soup.find_all("svg", class_="atp-flag")[:100]
    use_tags = [svg_tag.find("use") for svg_tag in svg_tags]
    links = [use_tag["href"] for use_tag in use_tags]
    countries = [_extract_flag_abbr(link) for link in links]
    return _convert_flag_abbr(soup, countries)


def _extract_flag_abbr(string: str) -> str:
    """
    extract the flag abbreviation out of a link to the flag png
    """
    return re.search(r"(?<=#flag-)[A-Za-z]{3}$", string).group(0)


def _convert_flag_abbr(
    soup: BeautifulSoup, countries: list[str]
) -> str:
    """
    helper function to convert a flag/country abbreviation to the
    actual country name. The relationship between the can be find inside
    the source code and I did not have rely on external sources
    """
    select_region_filter = soup.find("select", id="region-filter")
    region_option_tags = select_region_filter.find_all("option")
    countries_tuple = [
        (region_option_tag["value"], region_option_tag.text)
        for region_option_tag in region_option_tags
    ]
    country_dict = {k.lower(): v for k, v in countries_tuple}
    return [
        country_dict.get(country_abbr, country_abbr)
        for country_abbr in countries
    ]


def get_points(soup: BeautifulSoup) -> list[str]:
    """
    after some debugging a edge case failures, I adjusted and tested
    the points extraction to the following code.
    I essentially had to find the tag before the one I was looking for,
    and the seek the sibling.
    The reason for picking the slice is that I sometimes get 101 results
    instead of 100 and in that case the first one does not lead to any points.
    Taking the slice of the last 100 seems safe.
    """
    points_tds = soup.find_all("td", class_="age small-cell")
    return [
        points_td.find_next_sibling("td").find("a").text.strip()
        for points_td in points_tds[-100:]
    ]


headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Accept-Language": "en-US,en;q=0.9",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Connection": "keep-alive",
    "Referer": "https://www.google.com/",
    "DNT": "1",
    "Upgrade-Insecure-Requests": "1",
}

url = "https://www.atptour.com/en/rankings/singles"


session = requests.Session()
response = session.get(url, headers=headers)

# Check status code
if response.status_code != 200:
    print(response.status_code, response.reason)
try:
    soup = BeautifulSoup(response.content, "html.parser")
except AttributeError:
    print("Server returned empty content")

logger = logging.getLogger(__name__)
logger.addHandler(logging.FileHandler("log.txt"))
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.INFO)

# gather all responses
urls = get_all_urls(soup)
urls_length = len(urls)

response_list = []

for i, url in enumerate(urls):
    logger.info(f"processing request {i + 1} out of {urls_length}")
    try:
        response = get_with_retry(
            url, headers=headers, backoff_factor=915, max_retries=3
        )
    except RuntimeError:
        response_list = []
        raise ConnectionError(f"failed to fetch data from {url}")
    response_list.append(response)
    # Delay between 2 and 6 seconds
    delay = random.uniform(1, 3)
    print(f"Sleeping for {delay:.2f} seconds...")
    time.sleep(delay)

# save html to files
for i, response in enumerate(response_list):
    if response and response.status_code == 200:
        with open(f"pages/page_{i}.html", "wb") as f:
            f.write(response.content)

# load files to a list of html text
import glob

content_list = []
file_paths = sorted(glob.glob("pages/page_*.html"))

for file_path in file_paths:
    with open(file_path, "r", encoding="utf-8") as f:
        content_list.append(f.read())

# convert all elements of the html list to a list of soup objects (parsed)
# extract data and load them into a list of dictionaries
content_length = len(content_list)
results_list = []

for i, content in enumerate(content_list):
    logger.info(f"processing response {i + 1} out of {content_length}")
    soup = BeautifulSoup(content, "html.parser")
    week = get_active_week(soup)
    ranks = list(range(1, 101))
    player_names = get_player_names(soup)
    countries = get_countries(soup)
    points_all = get_points(soup)
    sizes = map(len, [ranks, player_names, countries, points_all])
    # if not len(set(sizes)) == 1 or not all(v > 0 for v in sizes):
    if not all(v > 0 for v in sizes):
        logger.info(
            f"week {week} error\nranks: {ranks}\nplayer_names: {player_names}\ncountries: {countries} \n points_all: {points_all}"
        )

    results_list.extend(
        [
            {
                "week": week,
                "rank": rank,
                "player_name": player_name,
                "country": country,
                "points": points,
            }
            for rank, player_name, country, points in zip(
                ranks, player_names, countries, points_all
            )
        ]
    )

df = pd.DataFrame(results_list)
# Convert types as necessary
df["week"] = pd.to_datetime(df["week"]).dt.date
df["points"] = df["points"].str.replace(",", "").astype("Int64")
df["rank"] = df["rank"].astype("Int64")

df.to_csv(
    f"csv/all-time-atp-top-100-{datetime.now().strftime('%Y-%m-%dT%H:%M')}.csv",
    index=False,
)
