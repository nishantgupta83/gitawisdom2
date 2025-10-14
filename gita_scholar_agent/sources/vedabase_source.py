"""
ISKCON Vedabase Source - Swami Prabhupada's "As It Is" translation
"""

import requests
from bs4 import BeautifulSoup
from typing import Dict, Optional


class VedabaseSource:
    """Fetches data from ISKCON Vedabase."""

    def __init__(self):
        self.name = "ISKCON Vedabase (Prabhupada)"
        self.base_url = "https://vedabase.io/en/library/bg"

    async def fetch_verse(self, chapter_num: int, verse_num: int) -> Optional[Dict]:
        """
        Fetch a specific verse from Vedabase.

        Args:
            chapter_num: Chapter number (1-18)
            verse_num: Verse number

        Returns:
            Dictionary with verse data or None if not found
        """
        try:
            # Vedabase URL structure: /bg/{chapter}/{verse}
            url = f"{self.base_url}/{chapter_num}/{verse_num}"

            response = requests.get(url, timeout=15)
            if response.status_code != 200:
                return None

            soup = BeautifulSoup(response.content, 'html.parser')

            # Extract Sanskrit text
            sanskrit_text = ""
            devanagari_div = soup.find('div', class_='devanagari')
            if devanagari_div:
                sanskrit_text = devanagari_div.get_text(strip=True)

            # Extract transliteration
            transliteration = ""
            trans_div = soup.find('div', class_='verse-text')
            if trans_div:
                transliteration = trans_div.get_text(strip=True)

            # Extract translation
            translation = ""
            translation_div = soup.find('div', class_='translation')
            if translation_div:
                translation = translation_div.get_text(strip=True)

            # Extract synonyms (word meanings)
            synonyms = ""
            synonyms_div = soup.find('div', class_='synonyms')
            if synonyms_div:
                synonyms = synonyms_div.get_text(strip=True)

            # Extract purport (commentary)
            purport = ""
            purport_div = soup.find('div', class_='purport')
            if purport_div:
                purport = purport_div.get_text(strip=True)

            return {
                'chapter_number': chapter_num,
                'verse_number': verse_num,
                'sanskrit': sanskrit_text,
                'transliteration': transliteration,
                'translation': translation,
                'synonyms': synonyms,
                'purport': purport,
                'source': self.name
            }

        except Exception as e:
            print(f"Error fetching verse {chapter_num}.{verse_num} from Vedabase: {e}")
            return None

    async def fetch_chapter(self, chapter_num: int) -> Optional[Dict]:
        """
        Fetch chapter information from Vedabase.

        Args:
            chapter_num: Chapter number (1-18)

        Returns:
            Dictionary with chapter data or None if not found
        """
        try:
            url = f"{self.base_url}/{chapter_num}"

            response = requests.get(url, timeout=15)
            if response.status_code != 200:
                return None

            soup = BeautifulSoup(response.content, 'html.parser')

            # Extract chapter title
            title = ""
            h1_tag = soup.find('h1')
            if h1_tag:
                title = h1_tag.get_text(strip=True)

            # Extract chapter summary
            summary = ""
            summary_div = soup.find('div', class_='chapter-summary')
            if summary_div:
                summary = summary_div.get_text(strip=True)

            return {
                'chapter_number': chapter_num,
                'title': title,
                'summary': summary,
                'source': self.name
            }

        except Exception as e:
            print(f"Error fetching chapter {chapter_num} from Vedabase: {e}")
            return None
