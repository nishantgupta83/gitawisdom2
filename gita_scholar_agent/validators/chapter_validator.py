"""
Chapter Validator - Validates chapter metadata against authoritative sources
"""

from typing import Dict, List
from fuzzywuzzy import fuzz


class ChapterValidator:
    """Validates chapter metadata against multiple sources."""

    # Expected ranges for chapter fields
    MIN_SUMMARY_LENGTH = 200
    IDEAL_SUMMARY_MIN = 300
    IDEAL_SUMMARY_MAX = 1000
    MAX_SUMMARY_LENGTH = 2000

    MIN_KEY_TEACHINGS = 3
    IDEAL_KEY_TEACHINGS_MIN = 3
    IDEAL_KEY_TEACHINGS_MAX = 7
    MAX_KEY_TEACHINGS = 10

    # Title similarity threshold
    MIN_TITLE_SIMILARITY = 60

    def __init__(self, sources: List):
        self.sources = sources

    async def validate(self, chapter_data: Dict) -> Dict:
        """
        Validate a chapter against all authoritative sources.

        Args:
            chapter_data: Chapter from Supabase with all ch_* fields

        Returns:
            Dictionary with validation results
        """
        result = {
            'chapter_id': chapter_data['ch_chapter_id'],
            'title': chapter_data.get('ch_title', ''),
            'subtitle': chapter_data.get('ch_subtitle'),
            'summary_length': len(chapter_data.get('ch_summary', '')),
            'key_teachings_count': len(chapter_data.get('ch_key_teachings', [])),
            'source_comparisons': [],
            'title_matches': {},
            'critical_issues': [],
            'warnings': [],
            'passed_checks': []
        }

        # Check 1: Title validation
        title_check = self._check_title(chapter_data.get('ch_title', ''))
        if title_check['status'] == 'critical':
            result['critical_issues'].append(title_check['message'])
        elif title_check['status'] == 'warning':
            result['warnings'].append(title_check['message'])
        else:
            result['passed_checks'].append('Title present')

        # Check 2: Summary length
        summary_check = self._check_summary_length(chapter_data.get('ch_summary', ''))
        if summary_check['status'] == 'critical':
            result['critical_issues'].append(summary_check['message'])
        elif summary_check['status'] == 'warning':
            result['warnings'].append(summary_check['message'])
        else:
            result['passed_checks'].append('Summary length appropriate')

        # Check 3: Key teachings count
        teachings_check = self._check_key_teachings(chapter_data.get('ch_key_teachings', []))
        if teachings_check['status'] == 'critical':
            result['critical_issues'].append(teachings_check['message'])
        elif teachings_check['status'] == 'warning':
            result['warnings'].append(teachings_check['message'])
        else:
            result['passed_checks'].append('Key teachings count appropriate')

        # Check 4: Theme validation
        if not chapter_data.get('ch_theme'):
            result['warnings'].append('Theme field is empty')
        else:
            result['passed_checks'].append('Theme present')

        # Check 5: Subtitle validation
        if not chapter_data.get('ch_subtitle'):
            result['warnings'].append('Subtitle field is empty')
        else:
            result['passed_checks'].append('Subtitle present')

        # Check 6: Cross-validate with sources
        for source in self.sources:
            try:
                source_chapter = await source.fetch_chapter(chapter_data['ch_chapter_id'])

                if source_chapter:
                    comparison = self._compare_with_source(
                        chapter_data,
                        source_chapter,
                        source.name
                    )
                    result['source_comparisons'].append(comparison)
                    result['title_matches'][source.name] = comparison['title_similarity']
            except Exception as e:
                result['warnings'].append(f"Failed to fetch from {source.name}: {str(e)}")

        # Check 7: Analyze title consensus
        if result['title_matches']:
            matches_above_threshold = sum(
                1 for sim in result['title_matches'].values()
                if sim >= self.MIN_TITLE_SIMILARITY
            )
            match_percentage = (matches_above_threshold / len(result['title_matches'])) * 100

            if match_percentage < 50:
                result['critical_issues'].append(
                    f"Title matches only {matches_above_threshold}/{len(result['title_matches'])} sources"
                )
            else:
                result['passed_checks'].append(
                    f"Title matches {matches_above_threshold}/{len(result['title_matches'])} sources"
                )

        return result

    def _check_title(self, title: str) -> Dict:
        """Check if chapter title is valid."""
        if not title or len(title) < 3:
            return {
                'status': 'critical',
                'message': 'Title is missing or too short'
            }
        return {
            'status': 'pass',
            'message': 'Title valid'
        }

    def _check_summary_length(self, summary: str) -> Dict:
        """Check if summary length is appropriate."""
        length = len(summary) if summary else 0

        if length < self.MIN_SUMMARY_LENGTH:
            return {
                'status': 'critical',
                'message': f"Summary too short ({length} chars, min: {self.MIN_SUMMARY_LENGTH})"
            }
        elif length > self.MAX_SUMMARY_LENGTH:
            return {
                'status': 'warning',
                'message': f"Summary very long ({length} chars, may cause UI issues, max: {self.MAX_SUMMARY_LENGTH})"
            }
        elif length < self.IDEAL_SUMMARY_MIN:
            return {
                'status': 'warning',
                'message': f"Summary shorter than ideal ({length} chars, ideal: {self.IDEAL_SUMMARY_MIN}-{self.IDEAL_SUMMARY_MAX})"
            }
        elif length > self.IDEAL_SUMMARY_MAX:
            return {
                'status': 'warning',
                'message': f"Summary longer than ideal ({length} chars, ideal: {self.IDEAL_SUMMARY_MIN}-{self.IDEAL_SUMMARY_MAX})"
            }
        else:
            return {
                'status': 'pass',
                'message': 'Summary length within ideal range'
            }

    def _check_key_teachings(self, key_teachings: List) -> Dict:
        """Check if key teachings count is appropriate."""
        count = len(key_teachings) if key_teachings else 0

        if count < self.MIN_KEY_TEACHINGS:
            return {
                'status': 'critical',
                'message': f"Too few key teachings ({count}, min: {self.MIN_KEY_TEACHINGS})"
            }
        elif count > self.MAX_KEY_TEACHINGS:
            return {
                'status': 'warning',
                'message': f"Too many key teachings ({count}, may overwhelm users, max: {self.MAX_KEY_TEACHINGS})"
            }
        elif count < self.IDEAL_KEY_TEACHINGS_MIN or count > self.IDEAL_KEY_TEACHINGS_MAX:
            return {
                'status': 'warning',
                'message': f"Key teachings count outside ideal range ({count}, ideal: {self.IDEAL_KEY_TEACHINGS_MIN}-{self.IDEAL_KEY_TEACHINGS_MAX})"
            }
        else:
            return {
                'status': 'pass',
                'message': 'Key teachings count appropriate'
            }

    def _compare_with_source(self, our_chapter: Dict, source_chapter: Dict, source_name: str) -> Dict:
        """Compare our chapter data with a source."""
        # Compare title
        our_title = our_chapter.get('ch_title', '')
        source_title = (
            source_chapter.get('title') or
            source_chapter.get('name') or
            ''
        )

        title_similarity = fuzz.ratio(our_title.lower(), source_title.lower()) if source_title else 0

        # Compare summary if available
        our_summary = our_chapter.get('ch_summary', '')
        source_summary = source_chapter.get('summary', '')
        summary_similarity = fuzz.partial_ratio(our_summary.lower(), source_summary.lower()) if source_summary else 0

        return {
            'source': source_name,
            'source_title': source_title,
            'title_similarity': title_similarity,
            'summary_similarity': summary_similarity if source_summary else None,
            'title_match_quality': self._get_match_quality(title_similarity)
        }

    def _get_match_quality(self, similarity: float) -> str:
        """Get human-readable match quality."""
        if similarity >= 90:
            return 'excellent'
        elif similarity >= 80:
            return 'very_good'
        elif similarity >= 70:
            return 'good'
        elif similarity >= 60:
            return 'fair'
        else:
            return 'poor'
