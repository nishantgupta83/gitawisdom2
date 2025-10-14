"""
IIT Kanpur Gita Supersite Source - Academic authority for Sanskrit validation
"""

import requests
from bs4 import BeautifulSoup
from typing import Dict, Optional
import time


class IITKanpurSource:
    """Fetches data from IIT Kanpur Gita Supersite."""

    def __init__(self):
        self.name = "IIT Kanpur Gita Supersite"
        self.base_url = "https://www.gitasupersite.iitk.ac.in"

    async def fetch_verse(self, chapter_num: int, verse_num: int) -> Optional[Dict]:
        """
        Fetch a specific verse from IIT Kanpur Gita Supersite.

        Args:
            chapter_num: Chapter number (1-18)
            verse_num: Verse number

        Returns:
            Dictionary with verse data or None if not found
        """
        try:
            # IIT Kanpur URL structure: /srimad?language=dv&field_chapter_value={chapter}&field_nsutra_value={verse}
            url = f"{self.base_url}/srimad?language=dv&field_chapter_value={chapter_num}&field_nsutra_value={verse_num}"

            response = requests.get(url, timeout=15)
            if response.status_code != 200:
                return None

            soup = BeautifulSoup(response.content, 'html.parser')

            # Extract Sanskrit text (Devanagari)
            sanskrit_text = ""
            verse_content = soup.find('div', class_='field-item')
            if verse_content:
                sanskrit_text = verse_content.get_text(strip=True)

            # Extract transliteration
            transliteration = ""
            roman_link = soup.find('a', string='Roman')
            if roman_link:
                roman_url = self.base_url + roman_link['href']
                roman_response = requests.get(roman_url, timeout=10)
                if roman_response.status_code == 200:
                    roman_soup = BeautifulSoup(roman_response.content, 'html.parser')
                    roman_content = roman_soup.find('div', class_='field-item')
                    if roman_content:
                        transliteration = roman_content.get_text(strip=True)

            return {
                'chapter_number': chapter_num,
                'verse_number': verse_num,
                'sanskrit': sanskrit_text,
                'transliteration': transliteration,
                'source': self.name
            }

        except Exception as e:
            print(f"Error fetching verse {chapter_num}.{verse_num} from IIT Kanpur: {e}")
            return None

    async def fetch_chapter(self, chapter_num: int) -> Optional[Dict]:
        """
        Fetch chapter information from IIT Kanpur.

        Args:
            chapter_num: Chapter number (1-18)

        Returns:
            Dictionary with chapter data or None if not found
        """
        try:
            url = f"{self.base_url}/srimad?language=dv&field_chapter_value={chapter_num}"

            response = requests.get(url, timeout=15)
            if response.status_code != 200:
                return None

            soup = BeautifulSoup(response.content, 'html.parser')

            # Extract chapter title
            title = ""
            h1_tag = soup.find('h1')
            if h1_tag:
                title = h1_tag.get_text(strip=True)

            # Count verses on the page
            verse_count = 0
            verse_links = soup.find_all('a', href=lambda x: x and 'field_nsutra_value' in x)
            verse_count = len(set([link['href'] for link in verse_links]))

            return {
                'chapter_number': chapter_num,
                'title': title,
                'verse_count': verse_count,
                'source': self.name
            }

        except Exception as e:
            print(f"Error fetching chapter {chapter_num} from IIT Kanpur: {e}")
            return None
