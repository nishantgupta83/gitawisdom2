# Gita Scholar Agent - Usage Guide

## Quick Start

### 1. Installation

```bash
cd /Users/nishantgupta/Documents/GitaGyan/OldWisdom/gita_scholar_agent

# Install dependencies
pip install -r requirements.txt
```

### 2. Configuration

Create a `.env` file with your credentials:

```bash
cp .env.example .env
# Edit .env with your actual credentials
```

**Required:**
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Your Supabase anonymous key

**Optional (but recommended for better results):**
- `BHAGAVADGITA_IO_CLIENT_ID` - Register at https://bhagavadgita.io/
- `BHAGAVADGITA_IO_CLIENT_SECRET` - From BhagavadGita.io account

### 3. Run Validation

```bash
# Full validation (recommended)
python gita_scholar_agent.py --mode full

# Verses only
python gita_scholar_agent.py --mode verses

# Chapters only
python gita_scholar_agent.py --mode chapters

# Custom output directory
python gita_scholar_agent.py --mode full --output-dir ./my_reports
```

### 4. Review Results

After validation completes, check the `output/` directory:

1. **`validation_report.json`** - Complete validation data
2. **`quality_dashboard.html`** - Visual scorecard (open in browser)
3. **`fix_script.sql`** - SQL commands to fix issues
4. **`special_chars_report.json`** - Dangerous character locations

## Understanding the Reports

### Quality Dashboard (HTML)

Open `quality_dashboard.html` in your browser to see:
- **Overall Score**: 0-100 quality rating
- **Metrics**: Verse count, chapter count, issues, warnings
- **Score Breakdown**: Average scores, min/max scores
- **Status**: Pass/fail for critical checks

**Score Interpretation:**
- **90-100**: Excellent - Production ready
- **80-89**: Very Good - Minor improvements recommended
- **70-79**: Good - Some improvements needed
- **60-69**: Fair - Significant improvements needed
- **<60**: Poor - Major issues require attention

### Validation Report (JSON)

The `validation_report.json` contains:

```json
{
  "validation_date": "2025-10-12T...",
  "sources_used": ["BhagavadGita.io API", "IIT Kanpur", ...],
  "verses": {
    "1.1": {
      "quality_score": 95.5,
      "text_length": 123,
      "similarity_scores": {...},
      "critical_issues": [],
      "warnings": []
    },
    ...
  },
  "chapters": {...},
  "special_chars": {...},
  "quality_scores": {...},
  "summary": {...}
}
```

### Fix Script (SQL)

The `fix_script.sql` contains:
- **Automated Fixes**: SQL UPDATE statements for special characters
- **Manual Review Items**: Critical issues requiring human judgment
- **Verification Queries**: Check that fixes worked correctly

**⚠️ IMPORTANT**: Always backup your database before running the fix script!

```bash
# Review the script first
cat output/fix_script.sql

# Backup your database
pg_dump your_database > backup.sql

# Execute fixes (after review)
psql your_database < output/fix_script.sql
```

### Special Characters Report

Lists all dangerous characters found:
- **BOM (Byte Order Mark)**: `\ufeff`
- **Null bytes**: `\x00`
- **Zero-width spaces**: `\u200b`, `\u200c`, `\u200d`
- **Smart quotes**: `'`, `'`, `"`, `"`
- **Invalid Unicode**: `\ufffe`, `\uffff`

## Quality Score Metrics

### Verse Score (0-100)

| Component | Weight | Criteria |
|-----------|--------|----------|
| **Accuracy** | 40 pts | Text similarity across sources (70%+ required) |
| **Completeness** | 25 pts | All required fields populated |
| **Length** | 15 pts | 50-300 chars ideal |
| **Character Safety** | 10 pts | No dangerous characters |
| **Consistency** | 10 pts | Verse numbering correct |

### Chapter Score (0-100)

| Component | Weight | Criteria |
|-----------|--------|----------|
| **Title Accuracy** | 20 pts | Agreement across sources (60%+ required) |
| **Summary Length** | 20 pts | 300-1000 chars ideal |
| **Key Teachings Count** | 20 pts | 3-7 teachings optimal |
| **Theme Validation** | 20 pts | Verified against commentaries |
| **Character Safety** | 20 pts | All fields clean |

## Validation Sources

The agent validates against 7 authoritative sources:

1. **BhagavadGita.io API** - Primary source (REST API)
2. **IIT Kanpur Gita Supersite** - Academic authority
3. **ISKCON Vedabase** - Prabhupada translation (23M+ copies)
4. **Swami Mukundananda** - Modern commentary
5. **Sri Aurobindo Archive** - Philosophical depth
6. **Swami Chidbhavananda** - Ramakrishna Mission
7. **Project Gutenberg** - Historical reference

## Troubleshooting

### "Less than 3 sources available"

Some sources may be temporarily unavailable. The agent will continue with available sources, but results may be less reliable.

**Solution**: Run validation again later, or check network connectivity.

### "Error fetching from Supabase"

Check your `.env` file credentials:
- `SUPABASE_URL` should be `https://[project-id].supabase.co`
- `SUPABASE_KEY` should be the **anonymous** key, not service role key

### "BhagavadGita.io authentication failed"

The agent will work without BhagavadGita.io, but you'll get better results with API access.

**Solution**:
1. Register at https://bhagavadgita.io/
2. Create an app in your dashboard
3. Add `CLIENT_ID` and `CLIENT_SECRET` to `.env`

### Validation is very slow

Web scraping takes time (3-5 minutes per source).

**Tips**:
- Use `--mode verses` or `--mode chapters` to validate only part of the data
- Ensure good internet connection
- Be patient - thorough validation is worth the wait!

## Example Workflow

### Initial Validation

```bash
# 1. Run full validation
python gita_scholar_agent.py --mode full

# 2. Open quality dashboard
open output/quality_dashboard.html

# 3. Review overall score and issues
cat output/validation_report.json | jq '.summary'
```

### Fixing Issues

```bash
# 4. Review fix script
less output/fix_script.sql

# 5. Backup database
pg_dump your_db > backup_$(date +%Y%m%d).sql

# 6. Apply fixes
psql your_db < output/fix_script.sql

# 7. Re-validate to confirm fixes
python gita_scholar_agent.py --mode full --output-dir ./output_v2
```

### Continuous Monitoring

```bash
# Set up cron job for weekly validation
0 2 * * 0 cd /path/to/gita_scholar_agent && python gita_scholar_agent.py --mode full --output-dir ./weekly_reports/$(date +\%Y\%m\%d)
```

## Advanced Usage

### Custom Validation Logic

Edit `validators/verse_validator.py` or `validators/chapter_validator.py` to customize:
- Similarity thresholds
- Length ranges
- Validation rules

### Adding New Sources

1. Create a new file in `sources/` (e.g., `my_source.py`)
2. Implement `fetch_verse()` and `fetch_chapter()` methods
3. Add to `gita_scholar_agent.py` in `_initialize_sources()`

### Custom Reporting

Edit `reporters/report_generator.py` to customize:
- HTML dashboard styling
- SQL fix script logic
- Report formats

## Support

For issues or questions:
1. Check the `validation_report.json` for detailed error messages
2. Review this usage guide
3. Check the main `README.md` for project overview

## License

MIT License - Free for use in GitaWisdom app
