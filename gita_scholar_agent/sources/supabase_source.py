"""
Supabase Source - Fetches verses and chapters from GitaWisdom Supabase database
"""

from typing import Dict, List
from supabase import create_client, Client


class SupabaseSource:
    """Fetches data from Supabase database."""

    def __init__(self, config: Dict):
        self.name = "Supabase Database"
        self.client: Client = create_client(
            config['supabase_url'],
            config['supabase_key']
        )

    async def fetch_all_verses(self) -> List[Dict]:
        """
        Fetch all verses from gita_verses table.

        Returns:
            List of verse dictionaries with gv_verses_id, gv_chapter_id, gv_verses
        """
        try:
            response = self.client.table('gita_verses').select('*').order('gv_chapter_id, gv_verses_id').execute()
            return response.data
        except Exception as e:
            print(f"Error fetching verses from Supabase: {e}")
            return []

    async def fetch_all_chapters(self) -> List[Dict]:
        """
        Fetch all chapters from chapters table.

        Returns:
            List of chapter dictionaries with all fields
        """
        try:
            response = self.client.table('chapters').select('*').order('ch_chapter_id').execute()
            return response.data
        except Exception as e:
            print(f"Error fetching chapters from Supabase: {e}")
            return []

    async def fetch_verse(self, chapter_id: int, verse_id: int) -> Dict:
        """Fetch a specific verse."""
        try:
            response = self.client.table('gita_verses') \
                .select('*') \
                .eq('gv_chapter_id', chapter_id) \
                .eq('gv_verses_id', verse_id) \
                .single() \
                .execute()
            return response.data
        except Exception as e:
            print(f"Error fetching verse {chapter_id}.{verse_id}: {e}")
            return {}

    async def fetch_chapter(self, chapter_id: int) -> Dict:
        """Fetch a specific chapter."""
        try:
            response = self.client.table('chapters') \
                .select('*') \
                .eq('ch_chapter_id', chapter_id) \
                .single() \
                .execute()
            return response.data
        except Exception as e:
            print(f"Error fetching chapter {chapter_id}: {e}")
            return {}
