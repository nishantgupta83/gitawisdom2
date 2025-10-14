# Gita Scholar Validation Agent

## Purpose
Automated validation agent to verify the accuracy and quality of Bhagavad Gita content in the Supabase database against 7 authoritative sources.

## Features
- Cross-validates 700 verses against multiple authoritative sources
- Validates 18 chapter metadata fields
- Detects dangerous special characters that could cause runtime errors
- Calculates quality scores (0-100) for each verse and chapter
- Generates SQL fix scripts for detected issues
- Creates visual quality dashboard

## Authoritative Sources (7)
1. BhagavadGita.io API - REST API access
2. IIT Kanpur Gita Supersite - Academic authority
3. ISKCON Vedabase - Prabhupada translation
4. Swami Mukundananda (holy-bhagavad-gita.org)
5. Sri Aurobindo Archive
6. Swami Chidbhavananda (Ramakrishna Mission)
7. Project Gutenberg

## Installation
```bash
cd gita_scholar_agent
pip install -r requirements.txt
```

## Configuration
Create a `.env` file:
```
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
BHAGAVADGITA_IO_CLIENT_ID=your_client_id
BHAGAVADGITA_IO_CLIENT_SECRET=your_client_secret
```

## Usage
```bash
# Run full validation
python gita_scholar_agent.py --mode full

# Validate verses only
python gita_scholar_agent.py --mode verses

# Validate chapters only
python gita_scholar_agent.py --mode chapters

# Generate report only (no validation)
python gita_scholar_agent.py --mode report
```

## Output
- `validation_report.json` - Detailed validation results
- `quality_dashboard.html` - Visual scorecard
- `fix_script.sql` - SQL commands to fix detected issues
- `special_chars_report.json` - Dangerous character locations

## Quality Score Metrics
- **Accuracy** (40 pts): Text similarity across sources
- **Completeness** (25 pts): All fields populated
- **Length Appropriateness** (15 pts): Within expected ranges
- **Character Safety** (10 pts): No dangerous characters
- **Consistency** (10 pts): Verse numbering correct

## License
MIT License - Free for use in GitaWisdom app
