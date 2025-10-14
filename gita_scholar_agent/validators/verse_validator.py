"""
Verse Validator - Validates individual verses against authoritative sources
"""

from typing import Dict, List
from fuzzywuzzy import fuzz


class VerseValidator:
    """Validates verses against multiple sources."""

    # Expected verse length ranges (characters)
    MIN_VERSE_LENGTH = 30
    IDEAL_MIN_LENGTH = 50
    IDEAL_MAX_LENGTH = 300
    MAX_VERSE_LENGTH = 600

    # Text similarity threshold for accuracy
    MIN_SIMILARITY_THRESHOLD = 70

    def __init__(self, sources: List):
        self.sources = sources

    async def validate(self, verse_data: Dict) -> Dict:
        """
        Validate a verse against all authoritative sources.

        Args:
            verse_data: Verse from Supabase with gv_chapter_id, gv_verses_id, gv_verses

        Returns:
            Dictionary with validation results
        """
        result = {
            'chapter_id': verse_data['gv_chapter_id'],
            'verse_id': verse_data['gv_verses_id'],
            'verse_key': f"{verse_data['gv_chapter_id']}.{verse_data['gv_verses_id']}",
            'text': verse_data['gv_verses'],
            'text_length': len(verse_data['gv_verses']),
            'source_comparisons': [],
            'similarity_scores': {},
            'critical_issues': [],
            'warnings': [],
            'passed_checks': []
        }

        # Check 1: Text length appropriateness
        length_check = self._check_length(verse_data['gv_verses'])
        if length_check['status'] == 'critical':
            result['critical_issues'].append(length_check['message'])
        elif length_check['status'] == 'warning':
            result['warnings'].append(length_check['message'])
        else:
            result['passed_checks'].append('Text length appropriate')

        # Check 2: Cross-validate with sources
        for source in self.sources:
            try:
                source_verse = await source.fetch_verse(
                    verse_data['gv_chapter_id'],
                    verse_data['gv_verses_id']
                )

                if source_verse:
                    comparison = self._compare_with_source(
                        verse_data['gv_verses'],
                        source_verse,
                        source.name
                    )
                    result['source_comparisons'].append(comparison)
                    result['similarity_scores'][source.name] = comparison['similarity_score']
            except Exception as e:
                result['warnings'].append(f"Failed to fetch from {source.name}: {str(e)}")

        # Check 3: Analyze source agreement
        if result['similarity_scores']:
            avg_similarity = sum(result['similarity_scores'].values()) / len(result['similarity_scores'])
            if avg_similarity < self.MIN_SIMILARITY_THRESHOLD:
                result['critical_issues'].append(
                    f"Low source agreement: {avg_similarity:.1f}% (threshold: {self.MIN_SIMILARITY_THRESHOLD}%)"
                )
            else:
                result['passed_checks'].append(f"Good source agreement: {avg_similarity:.1f}%")

        return result

    def _check_length(self, text: str) -> Dict:
        """Check if verse length is appropriate."""
        length = len(text)

        if length < self.MIN_VERSE_LENGTH:
            return {
                'status': 'critical',
                'message': f"Text too short ({length} chars, min: {self.MIN_VERSE_LENGTH})"
            }
        elif length > self.MAX_VERSE_LENGTH:
            return {
                'status': 'critical',
                'message': f"Text too long ({length} chars, max: {self.MAX_VERSE_LENGTH})"
            }
        elif length < self.IDEAL_MIN_LENGTH:
            return {
                'status': 'warning',
                'message': f"Text shorter than ideal ({length} chars, ideal: {self.IDEAL_MIN_LENGTH}-{self.IDEAL_MAX_LENGTH})"
            }
        elif length > self.IDEAL_MAX_LENGTH:
            return {
                'status': 'warning',
                'message': f"Text longer than ideal ({length} chars, ideal: {self.IDEAL_MIN_LENGTH}-{self.IDEAL_MAX_LENGTH})"
            }
        else:
            return {
                'status': 'pass',
                'message': 'Text length within ideal range'
            }

    def _compare_with_source(self, our_text: str, source_verse: Dict, source_name: str) -> Dict:
        """Compare our verse text with a source."""
        # Get the best matching text field from source
        source_text = (
            source_verse.get('translation') or
            source_verse.get('text') or
            source_verse.get('transliteration') or
            ''
        )

        # Calculate similarity using fuzzy matching
        similarity = fuzz.ratio(our_text.lower(), source_text.lower()) if source_text else 0

        return {
            'source': source_name,
            'source_text': source_text[:200] + '...' if len(source_text) > 200 else source_text,
            'similarity_score': similarity,
            'match_quality': self._get_match_quality(similarity)
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
