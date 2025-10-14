"""
Holy-Bhagavad-Gita.org Source - Swami Mukundananda's commentary
"""

import requests
from bs4 import BeautifulSoup
from typing import Dict, Optional


class HolyBhagavadGitaSource:
    """Fetches data from holy-bhagavad-gita.org."""

    def __init__(self):
        self.name = "Holy-Bhagavad-Gita.org (Mukundananda)"
        self.base_url = "https://www.holy-bhagavad-gita.org"

    async def fetch_verse(self, chapter_num: int, verse_num: int) -> Optional[Dict]:
        """
        Fetch a specific verse from holy-bhagavad-gita.org.

        Args:
            chapter_num: Chapter number (1-18)
            verse_num: Verse number

        Returns:
            Dictionary with verse data or None if not found
        """
        try:
            # URL structure: /chapter/{chapter}/verse/{verse}
            url = f"{self.base_url}/chapter/{chapter_num}/verse/{verse_num}"

            response = requests.get(url, timeout=15)
            if response.status_code != 200:
                return None

            soup = BeautifulSoup(response.content, 'html.parser')

            # Extract Sanskrit text
            sanskrit_text = ""
            sanskrit_div = soup.find('div', {'id': 'originalVerse'})
            if sanskrit_div:
                sanskrit_text = sanskrit_div.get_text(strip=True)

            # Extract transliteration
            transliteration = ""
            trans_div = soup.find('div', {'id': 'transliteration'})
            if trans_div:
                transliteration = trans_div.get_text(strip=True)

            # Extract word meanings
            word_meanings = ""
            meanings_div = soup.find('div', {'id': 'wordMeanings'})
            if meanings_div:
                word_meanings = meanings_div.get_text(strip=True)

            # Extract translation
            translation = ""
            translation_div = soup.find('div', {'id': 'translation'})
            if translation_div:
                translation = translation_div.get_text(strip=True)

            # Extract commentary
            commentary = ""
            commentary_div = soup.find('div', {'id': 'commentary'})
            if commentary_div:
                commentary = commentary_div.get_text(strip=True)

            return {
                'chapter_number': chapter_num,
                'verse_number': verse_num,
                'sanskrit': sanskrit_text,
                'transliteration': transliteration,
                'word_meanings': word_meanings,
                'translation': translation,
                'commentary': commentary,
                'source': self.name
            }

        except Exception as e:
            print(f"Error fetching verse {chapter_num}.{verse_num} from holy-bhagavad-gita.org: {e}")
            return None

    async def fetch_chapter(self, chapter_num: int) -> Optional[Dict]:
        """
        Fetch chapter information from holy-bhagavad-gita.org.

        Args:
            chapter_num: Chapter number (1-18)

        Returns:
            Dictionary with chapter data or None if not found
        """
        try:
            url = f"{self.base_url}/chapter/{chapter_num}/"

            response = requests.get(url, timeout=15)
            if response.status_code != 200:
                return None

            soup = BeautifulSoup(response.content, 'html.parser')

            # Extract chapter title
            title = ""
            title_div = soup.find('h1', class_='chapterName')
            if title_div:
                title = title_div.get_text(strip=True)

            # Extract chapter meaning
            meaning = ""
            meaning_div = soup.find('div', class_='chapterMeaning')
            if meaning_div:
                meaning = meaning_div.get_text(strip=True)

            # Extract chapter summary
            summary = ""
            summary_div = soup.find('div', class_='chapterSummary')
            if summary_div:
                summary = summary_div.get_text(strip=True)

            return {
                'chapter_number': chapter_num,
                'title': title,
                'meaning': meaning,
                'summary': summary,
                'source': self.name
            }

        except Exception as e:
            print(f"Error fetching chapter {chapter_num} from holy-bhagavad-gita.org: {e}")
            return None
