"""
BhagavadGita.io API Source - Primary validation source with OAuth2 authentication
"""

import requests
from typing import Dict, Optional
import time


class BhagavadGitaIOSource:
    """Fetches data from BhagavadGita.io API."""

    def __init__(self, config: Dict):
        self.name = "BhagavadGita.io API"
        self.base_url = "https://bhagavadgita.io/api/v1"
        self.client_id = config.get('bhagavadgita_io_client_id')
        self.client_secret = config.get('bhagavadgita_io_client_secret')
        self.access_token = None
        self.token_expiry = 0

        # Authenticate if credentials provided
        if self.client_id and self.client_secret:
            self._authenticate()

    def _authenticate(self):
        """Authenticate with OAuth2 to get access token."""
        try:
            auth_url = f"{self.base_url}/auth/oauth/token"
            response = requests.post(
                auth_url,
                data={
                    'client_id': self.client_id,
                    'client_secret': self.client_secret,
                    'grant_type': 'client_credentials',
                    'scope': 'verse chapter'
                }
            )

            if response.status_code == 200:
                data = response.json()
                self.access_token = data['access_token']
                self.token_expiry = time.time() + data['expires_in']
            else:
                print(f"Warning: BhagavadGita.io authentication failed: {response.status_code}")
        except Exception as e:
            print(f"Warning: BhagavadGita.io authentication error: {e}")

    def _get_headers(self) -> Dict:
        """Get request headers with auth token."""
        # Refresh token if expired
        if self.access_token and time.time() >= self.token_expiry:
            self._authenticate()

        if self.access_token:
            return {'Authorization': f'Bearer {self.access_token}'}
        return {}

    async def fetch_verse(self, chapter_num: int, verse_num: int) -> Optional[Dict]:
        """
        Fetch a specific verse from the API.

        Args:
            chapter_num: Chapter number (1-18)
            verse_num: Verse number

        Returns:
            Dictionary with verse data or None if not found
        """
        try:
            url = f"{self.base_url}/chapters/{chapter_num}/verses/{verse_num}"
            response = requests.get(url, headers=self._get_headers(), timeout=10)

            if response.status_code == 200:
                data = response.json()
                return {
                    'chapter_number': chapter_num,
                    'verse_number': verse_num,
                    'text': data.get('text', ''),
                    'transliteration': data.get('transliteration', ''),
                    'word_meanings': data.get('word_meanings', ''),
                    'translations': data.get('translations', [])
                }
            else:
                return None
        except Exception as e:
            print(f"Error fetching verse {chapter_num}.{verse_num} from BhagavadGita.io: {e}")
            return None

    async def fetch_chapter(self, chapter_num: int) -> Optional[Dict]:
        """
        Fetch chapter metadata from the API.

        Args:
            chapter_num: Chapter number (1-18)

        Returns:
            Dictionary with chapter data or None if not found
        """
        try:
            url = f"{self.base_url}/chapters/{chapter_num}"
            response = requests.get(url, headers=self._get_headers(), timeout=10)

            if response.status_code == 200:
                data = response.json()
                return {
                    'chapter_number': chapter_num,
                    'name': data.get('name', ''),
                    'translation': data.get('translation', ''),
                    'verses_count': data.get('verses_count', 0),
                    'slug': data.get('slug', ''),
                    'meaning': {
                        'en': data.get('meaning', {}).get('en', ''),
                        'hi': data.get('meaning', {}).get('hi', '')
                    }
                }
            else:
                return None
        except Exception as e:
            print(f"Error fetching chapter {chapter_num} from BhagavadGita.io: {e}")
            return None

    async def fetch_all_verses(self) -> Dict[str, Dict]:
        """Fetch all verses from API (rate-limited)."""
        all_verses = {}

        # Known verse counts per chapter
        verse_counts = [47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 35, 27, 20, 24, 28, 78]

        for chapter in range(1, 19):
            for verse in range(1, verse_counts[chapter - 1] + 1):
                verse_key = f"{chapter}.{verse}"
                verse_data = await self.fetch_verse(chapter, verse)
                if verse_data:
                    all_verses[verse_key] = verse_data
                time.sleep(0.1)  # Rate limiting

        return all_verses

    async def fetch_all_chapters(self) -> Dict[int, Dict]:
        """Fetch all 18 chapters from API."""
        all_chapters = {}

        for chapter in range(1, 19):
            chapter_data = await self.fetch_chapter(chapter)
            if chapter_data:
                all_chapters[chapter] = chapter_data
            time.sleep(0.1)  # Rate limiting

        return all_chapters
