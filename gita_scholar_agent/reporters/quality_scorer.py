"""
Quality Scorer - Calculates quality scores for verses and chapters
"""

from typing import Dict


class QualityScorer:
    """Calculates quality scores (0-100) for Gita content."""

    # Scoring weights
    VERSE_WEIGHTS = {
        'accuracy': 40,
        'completeness': 25,
        'length': 15,
        'char_safety': 10,
        'consistency': 10
    }

    CHAPTER_WEIGHTS = {
        'title_accuracy': 20,
        'summary_length': 20,
        'key_teachings_count': 20,
        'theme_validation': 20,
        'char_safety': 20
    }

    def calculate_verse_score(self, verse_result: Dict, special_chars_data: Dict) -> float:
        """
        Calculate quality score for a verse (0-100).

        Args:
            verse_result: Result from VerseValidator
            special_chars_data: Special character scan results

        Returns:
            Score from 0-100
        """
        score = 0.0

        # 1. Accuracy Score (40 points) - Based on source agreement
        if verse_result.get('similarity_scores'):
            avg_similarity = sum(verse_result['similarity_scores'].values()) / len(verse_result['similarity_scores'])
            score += (avg_similarity / 100) * self.VERSE_WEIGHTS['accuracy']
        else:
            # No sources available, give benefit of doubt
            score += self.VERSE_WEIGHTS['accuracy'] * 0.7

        # 2. Completeness Score (25 points) - All required fields present
        has_text = bool(verse_result.get('text'))
        has_chapter = bool(verse_result.get('chapter_id'))
        has_verse_num = bool(verse_result.get('verse_id'))

        completeness = (has_text + has_chapter + has_verse_num) / 3
        score += completeness * self.VERSE_WEIGHTS['completeness']

        # 3. Length Appropriateness (15 points)
        length = verse_result.get('text_length', 0)
        if 50 <= length <= 300:
            score += self.VERSE_WEIGHTS['length']
        elif 30 <= length < 50 or 300 < length <= 500:
            score += self.VERSE_WEIGHTS['length'] * 0.7
        elif length < 30 or length > 500:
            score += self.VERSE_WEIGHTS['length'] * 0.3

        # 4. Character Safety (10 points)
        verse_key = verse_result.get('verse_key')
        has_char_issues = any(
            v['verse'] == verse_key
            for v in special_chars_data.get('verses_with_issues', [])
        )
        if not has_char_issues:
            score += self.VERSE_WEIGHTS['char_safety']
        else:
            # Partial credit based on severity
            critical_issues = sum(
                1 for v in special_chars_data.get('verses_with_issues', [])
                if v['verse'] == verse_key and any(i['severity'] == 'critical' for i in v['issues'])
            )
            if critical_issues == 0:
                score += self.VERSE_WEIGHTS['char_safety'] * 0.5
            else:
                score += self.VERSE_WEIGHTS['char_safety'] * 0.2

        # 5. Consistency (10 points) - No critical validation issues
        critical_count = len(verse_result.get('critical_issues', []))
        if critical_count == 0:
            score += self.VERSE_WEIGHTS['consistency']
        elif critical_count == 1:
            score += self.VERSE_WEIGHTS['consistency'] * 0.5
        else:
            score += self.VERSE_WEIGHTS['consistency'] * 0.2

        return round(score, 2)

    def calculate_chapter_score(self, chapter_result: Dict, special_chars_data: Dict) -> float:
        """
        Calculate quality score for a chapter (0-100).

        Args:
            chapter_result: Result from ChapterValidator
            special_chars_data: Special character scan results

        Returns:
            Score from 0-100
        """
        score = 0.0

        # 1. Title Accuracy (20 points) - Agreement across sources
        if chapter_result.get('title_matches'):
            title_scores = list(chapter_result['title_matches'].values())
            avg_title_similarity = sum(title_scores) / len(title_scores)
            score += (avg_title_similarity / 100) * self.CHAPTER_WEIGHTS['title_accuracy']
        else:
            # No sources available
            score += self.CHAPTER_WEIGHTS['title_accuracy'] * 0.7

        # 2. Summary Length (20 points)
        summary_length = chapter_result.get('summary_length', 0)
        if 300 <= summary_length <= 1000:
            score += self.CHAPTER_WEIGHTS['summary_length']
        elif 200 <= summary_length < 300 or 1000 < summary_length <= 1500:
            score += self.CHAPTER_WEIGHTS['summary_length'] * 0.8
        elif 100 <= summary_length < 200 or 1500 < summary_length <= 2000:
            score += self.CHAPTER_WEIGHTS['summary_length'] * 0.5
        else:
            score += self.CHAPTER_WEIGHTS['summary_length'] * 0.3

        # 3. Key Teachings Count (20 points)
        teachings_count = chapter_result.get('key_teachings_count', 0)
        if 3 <= teachings_count <= 7:
            score += self.CHAPTER_WEIGHTS['key_teachings_count']
        elif 2 <= teachings_count < 3 or 7 < teachings_count <= 10:
            score += self.CHAPTER_WEIGHTS['key_teachings_count'] * 0.7
        elif teachings_count == 1 or teachings_count > 10:
            score += self.CHAPTER_WEIGHTS['key_teachings_count'] * 0.4
        else:
            score += self.CHAPTER_WEIGHTS['key_teachings_count'] * 0.1

        # 4. Theme Validation (20 points) - Based on passed checks
        passed_count = len(chapter_result.get('passed_checks', []))
        total_checks = passed_count + len(chapter_result.get('warnings', [])) + len(chapter_result.get('critical_issues', []))
        if total_checks > 0:
            validation_rate = passed_count / total_checks
            score += validation_rate * self.CHAPTER_WEIGHTS['theme_validation']
        else:
            score += self.CHAPTER_WEIGHTS['theme_validation'] * 0.5

        # 5. Character Safety (20 points)
        chapter_id = chapter_result.get('chapter_id')
        has_char_issues = any(
            c['chapter_id'] == chapter_id
            for c in special_chars_data.get('chapters_with_issues', [])
        )
        if not has_char_issues:
            score += self.CHAPTER_WEIGHTS['char_safety']
        else:
            # Partial credit
            critical_issues = sum(
                1 for c in special_chars_data.get('chapters_with_issues', [])
                if c['chapter_id'] == chapter_id and any(i['severity'] == 'critical' for i in c['issues'])
            )
            if critical_issues == 0:
                score += self.CHAPTER_WEIGHTS['char_safety'] * 0.6
            else:
                score += self.CHAPTER_WEIGHTS['char_safety'] * 0.3

        return round(score, 2)

    def get_score_grade(self, score: float) -> str:
        """Get letter grade for a score."""
        if score >= 95:
            return 'A+'
        elif score >= 90:
            return 'A'
        elif score >= 85:
            return 'A-'
        elif score >= 80:
            return 'B+'
        elif score >= 75:
            return 'B'
        elif score >= 70:
            return 'B-'
        elif score >= 65:
            return 'C+'
        elif score >= 60:
            return 'C'
        else:
            return 'D'

    def get_score_description(self, score: float) -> str:
        """Get descriptive text for a score."""
        if score >= 90:
            return 'Excellent - Production ready'
        elif score >= 80:
            return 'Very Good - Minor improvements recommended'
        elif score >= 70:
            return 'Good - Some improvements needed'
        elif score >= 60:
            return 'Fair - Significant improvements needed'
        else:
            return 'Poor - Major issues require attention'
