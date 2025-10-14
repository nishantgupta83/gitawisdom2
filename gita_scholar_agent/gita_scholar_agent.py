#!/usr/bin/env python3
"""
Gita Scholar Validation Agent
Validates Bhagavad Gita content in Supabase against 7 authoritative sources.
"""

import asyncio
import argparse
import json
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime

from dotenv import load_dotenv
from colorama import init, Fore, Style
from tqdm import tqdm

# Initialize colorama for cross-platform colored output
init(autoreset=True)

# Local imports
from sources.supabase_source import SupabaseSource
from sources.bhagavadgita_io_source import BhagavadGitaIOSource
from sources.iit_kanpur_source import IITKanpurSource
from sources.vedabase_source import VedabaseSource
from sources.holy_bhagavad_gita_source import HolyBhagavadGitaSource
from validators.verse_validator import VerseValidator
from validators.chapter_validator import ChapterValidator
from validators.special_char_validator import SpecialCharValidator
from reporters.quality_scorer import QualityScorer
from reporters.report_generator import ReportGenerator


class GitaScholarAgent:
    """
    Main agent class for validating Bhagavad Gita content.
    """

    def __init__(self, config: Dict):
        self.config = config
        self.supabase_source = SupabaseSource(config)
        self.validation_sources = self._initialize_sources()
        self.verse_validator = VerseValidator(self.validation_sources)
        self.chapter_validator = ChapterValidator(self.validation_sources)
        self.special_char_validator = SpecialCharValidator()
        self.quality_scorer = QualityScorer()
        self.report_generator = ReportGenerator()

    def _initialize_sources(self) -> List:
        """Initialize all validation sources."""
        sources = []

        try:
            sources.append(BhagavadGitaIOSource(self.config))
            print(f"{Fore.GREEN}✓ BhagavadGita.io API initialized")
        except Exception as e:
            print(f"{Fore.YELLOW}⚠ BhagavadGita.io API unavailable: {e}")

        try:
            sources.append(IITKanpurSource())
            print(f"{Fore.GREEN}✓ IIT Kanpur Gita Supersite initialized")
        except Exception as e:
            print(f"{Fore.YELLOW}⚠ IIT Kanpur source unavailable: {e}")

        try:
            sources.append(VedabaseSource())
            print(f"{Fore.GREEN}✓ ISKCON Vedabase initialized")
        except Exception as e:
            print(f"{Fore.YELLOW}⚠ Vedabase source unavailable: {e}")

        try:
            sources.append(HolyBhagavadGitaSource())
            print(f"{Fore.GREEN}✓ Holy-Bhagavad-Gita.org initialized")
        except Exception as e:
            print(f"{Fore.YELLOW}⚠ Holy-Bhagavad-Gita.org unavailable: {e}")

        if len(sources) < 3:
            print(f"{Fore.RED}✗ Warning: Less than 3 sources available. Results may be unreliable.")

        return sources

    async def validate_all(self) -> Dict:
        """
        Run full validation on verses and chapters.

        Returns:
            Dict containing validation results
        """
        print(f"\n{Fore.CYAN}{'='*80}")
        print(f"{Fore.CYAN}GITA SCHOLAR VALIDATION AGENT")
        print(f"{Fore.CYAN}{'='*80}\n")

        results = {
            'validation_date': datetime.now().isoformat(),
            'sources_used': [source.name for source in self.validation_sources],
            'verses': {},
            'chapters': {},
            'special_chars': {},
            'quality_scores': {},
            'summary': {}
        }

        # Phase 1: Extract data from Supabase
        print(f"{Fore.CYAN}Phase 1: Extracting data from Supabase...")
        verses_data = await self.supabase_source.fetch_all_verses()
        chapters_data = await self.supabase_source.fetch_all_chapters()

        print(f"{Fore.GREEN}✓ Extracted {len(verses_data)} verses")
        print(f"{Fore.GREEN}✓ Extracted {len(chapters_data)} chapters\n")

        # Check verse count
        if len(verses_data) != 700:
            print(f"{Fore.RED}⚠ CRITICAL: Expected 700 verses, found {len(verses_data)}")
            results['summary']['verse_count_issue'] = True

        # Phase 2: Validate verses
        print(f"{Fore.CYAN}Phase 2: Validating verses against {len(self.validation_sources)} sources...")
        verse_results = await self._validate_verses(verses_data)
        results['verses'] = verse_results

        # Phase 3: Validate chapters
        print(f"\n{Fore.CYAN}Phase 3: Validating chapter metadata...")
        chapter_results = await self._validate_chapters(chapters_data)
        results['chapters'] = chapter_results

        # Phase 4: Special character scan
        print(f"\n{Fore.CYAN}Phase 4: Scanning for dangerous special characters...")
        special_char_results = self._scan_special_chars(verses_data, chapters_data)
        results['special_chars'] = special_char_results

        # Phase 5: Calculate quality scores
        print(f"\n{Fore.CYAN}Phase 5: Calculating quality scores...")
        quality_scores = self._calculate_quality_scores(results)
        results['quality_scores'] = quality_scores

        # Generate summary
        results['summary'] = self._generate_summary(results)

        return results

    async def _validate_verses(self, verses_data: List[Dict]) -> Dict:
        """Validate all verses."""
        results = {}

        for verse in tqdm(verses_data, desc="Validating verses"):
            chapter_id = verse['gv_chapter_id']
            verse_id = verse['gv_verses_id']
            verse_key = f"{chapter_id}.{verse_id}"

            validation_result = await self.verse_validator.validate(verse)
            results[verse_key] = validation_result

        return results

    async def _validate_chapters(self, chapters_data: List[Dict]) -> Dict:
        """Validate all chapter metadata."""
        results = {}

        for chapter in tqdm(chapters_data, desc="Validating chapters"):
            chapter_id = chapter['ch_chapter_id']

            validation_result = await self.chapter_validator.validate(chapter)
            results[chapter_id] = validation_result

        return results

    def _scan_special_chars(self, verses_data: List[Dict], chapters_data: List[Dict]) -> Dict:
        """Scan for dangerous special characters."""
        results = {
            'verses_with_issues': [],
            'chapters_with_issues': [],
            'total_dangerous_chars': 0,
            'char_types': {}
        }

        # Scan verses
        for verse in verses_data:
            issues = self.special_char_validator.validate_text(verse['gv_verses'])
            if issues:
                verse_key = f"{verse['gv_chapter_id']}.{verse['gv_verses_id']}"
                results['verses_with_issues'].append({
                    'verse': verse_key,
                    'issues': issues
                })
                results['total_dangerous_chars'] += len(issues)
                for issue in issues:
                    char_type = issue['type']
                    results['char_types'][char_type] = results['char_types'].get(char_type, 0) + 1

        # Scan chapters
        for chapter in chapters_data:
            fields_to_check = [
                ('ch_title', chapter.get('ch_title', '')),
                ('ch_subtitle', chapter.get('ch_subtitle', '')),
                ('ch_summary', chapter.get('ch_summary', '')),
                ('ch_theme', chapter.get('ch_theme', ''))
            ]

            chapter_issues = []
            for field_name, field_value in fields_to_check:
                if field_value:
                    issues = self.special_char_validator.validate_text(field_value)
                    if issues:
                        chapter_issues.extend([{**issue, 'field': field_name} for issue in issues])

            if chapter_issues:
                results['chapters_with_issues'].append({
                    'chapter_id': chapter['ch_chapter_id'],
                    'issues': chapter_issues
                })
                results['total_dangerous_chars'] += len(chapter_issues)

        return results

    def _calculate_quality_scores(self, validation_results: Dict) -> Dict:
        """Calculate quality scores for all content."""
        scores = {
            'overall_score': 0,
            'verse_scores': {},
            'chapter_scores': {},
            'breakdown': {}
        }

        # Calculate verse scores
        verse_scores = []
        for verse_key, verse_result in validation_results['verses'].items():
            score = self.quality_scorer.calculate_verse_score(
                verse_result,
                validation_results['special_chars']
            )
            scores['verse_scores'][verse_key] = score
            verse_scores.append(score)

        # Calculate chapter scores
        chapter_scores = []
        for chapter_id, chapter_result in validation_results['chapters'].items():
            score = self.quality_scorer.calculate_chapter_score(
                chapter_result,
                validation_results['special_chars']
            )
            scores['chapter_scores'][chapter_id] = score
            chapter_scores.append(score)

        # Overall score
        if verse_scores and chapter_scores:
            scores['overall_score'] = (
                sum(verse_scores) / len(verse_scores) * 0.7 +
                sum(chapter_scores) / len(chapter_scores) * 0.3
            )

        scores['breakdown'] = {
            'avg_verse_score': sum(verse_scores) / len(verse_scores) if verse_scores else 0,
            'avg_chapter_score': sum(chapter_scores) / len(chapter_scores) if chapter_scores else 0,
            'min_verse_score': min(verse_scores) if verse_scores else 0,
            'max_verse_score': max(verse_scores) if verse_scores else 0
        }

        return scores

    def _generate_summary(self, results: Dict) -> Dict:
        """Generate summary statistics."""
        summary = {
            'total_verses_analyzed': len(results['verses']),
            'total_chapters_analyzed': len(results['chapters']),
            'overall_quality_score': results['quality_scores']['overall_score'],
            'critical_issues_count': 0,
            'warnings_count': 0,
            'verse_count_correct': len(results['verses']) == 700
        }

        # Count issues
        for verse_result in results['verses'].values():
            if verse_result.get('critical_issues'):
                summary['critical_issues_count'] += len(verse_result['critical_issues'])
            if verse_result.get('warnings'):
                summary['warnings_count'] += len(verse_result['warnings'])

        for chapter_result in results['chapters'].values():
            if chapter_result.get('critical_issues'):
                summary['critical_issues_count'] += len(chapter_result['critical_issues'])
            if chapter_result.get('warnings'):
                summary['warnings_count'] += len(chapter_result['warnings'])

        # Add special char issues
        summary['dangerous_chars_found'] = results['special_chars']['total_dangerous_chars']

        return summary

    async def generate_reports(self, results: Dict, output_dir: Path):
        """Generate all output reports."""
        print(f"\n{Fore.CYAN}Generating reports...")

        # JSON report
        json_path = output_dir / 'validation_report.json'
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        print(f"{Fore.GREEN}✓ Saved: {json_path}")

        # SQL fix script
        sql_path = output_dir / 'fix_script.sql'
        sql_script = self.report_generator.generate_fix_script(results)
        with open(sql_path, 'w', encoding='utf-8') as f:
            f.write(sql_script)
        print(f"{Fore.GREEN}✓ Saved: {sql_path}")

        # HTML dashboard
        html_path = output_dir / 'quality_dashboard.html'
        html_content = self.report_generator.generate_html_dashboard(results)
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        print(f"{Fore.GREEN}✓ Saved: {html_path}")

        # Special chars report
        chars_path = output_dir / 'special_chars_report.json'
        with open(chars_path, 'w', encoding='utf-8') as f:
            json.dump(results['special_chars'], f, indent=2, ensure_ascii=False)
        print(f"{Fore.GREEN}✓ Saved: {chars_path}")

        # Print summary
        self._print_summary(results['summary'], results['quality_scores'])

    def _print_summary(self, summary: Dict, quality_scores: Dict):
        """Print validation summary to console."""
        print(f"\n{Fore.CYAN}{'='*80}")
        print(f"{Fore.CYAN}VALIDATION SUMMARY")
        print(f"{Fore.CYAN}{'='*80}\n")

        # Overall score
        score = quality_scores['overall_score']
        if score >= 85:
            color = Fore.GREEN
            status = "EXCELLENT"
        elif score >= 70:
            color = Fore.YELLOW
            status = "GOOD"
        else:
            color = Fore.RED
            status = "NEEDS IMPROVEMENT"

        print(f"Overall Quality Score: {color}{score:.2f}/100 ({status}){Style.RESET_ALL}")
        print(f"Verses Analyzed: {summary['total_verses_analyzed']} (Expected: 700)")
        print(f"Chapters Analyzed: {summary['total_chapters_analyzed']} (Expected: 18)")

        # Issues
        if summary['critical_issues_count'] > 0:
            print(f"\n{Fore.RED}Critical Issues: {summary['critical_issues_count']}")
        else:
            print(f"\n{Fore.GREEN}Critical Issues: 0")

        if summary['warnings_count'] > 0:
            print(f"{Fore.YELLOW}Warnings: {summary['warnings_count']}")
        else:
            print(f"{Fore.GREEN}Warnings: 0")

        if summary['dangerous_chars_found'] > 0:
            print(f"{Fore.RED}Dangerous Characters: {summary['dangerous_chars_found']}")
        else:
            print(f"{Fore.GREEN}Dangerous Characters: 0")

        # Verse count check
        if not summary['verse_count_correct']:
            print(f"\n{Fore.RED}⚠ CRITICAL: Verse count mismatch!")
        else:
            print(f"\n{Fore.GREEN}✓ Verse count correct (700 verses)")

        print(f"\n{Fore.CYAN}{'='*80}\n")


async def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Gita Scholar Validation Agent - Validate Bhagavad Gita database content'
    )
    parser.add_argument(
        '--mode',
        choices=['full', 'verses', 'chapters', 'report'],
        default='full',
        help='Validation mode (default: full)'
    )
    parser.add_argument(
        '--output-dir',
        type=str,
        default='./output',
        help='Output directory for reports (default: ./output)'
    )

    args = parser.parse_args()

    # Load environment variables
    load_dotenv()

    config = {
        'supabase_url': os.getenv('SUPABASE_URL'),
        'supabase_key': os.getenv('SUPABASE_KEY'),
        'bhagavadgita_io_client_id': os.getenv('BHAGAVADGITA_IO_CLIENT_ID'),
        'bhagavadgita_io_client_secret': os.getenv('BHAGAVADGITA_IO_CLIENT_SECRET')
    }

    # Validate config
    if not config['supabase_url'] or not config['supabase_key']:
        print(f"{Fore.RED}Error: SUPABASE_URL and SUPABASE_KEY must be set in .env file")
        sys.exit(1)

    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Initialize agent
    agent = GitaScholarAgent(config)

    # Run validation
    results = await agent.validate_all()

    # Generate reports
    await agent.generate_reports(results, output_dir)

    print(f"\n{Fore.GREEN}✓ Validation complete!")
    print(f"Reports saved to: {output_dir.absolute()}")


if __name__ == '__main__':
    import os
    asyncio.run(main())
