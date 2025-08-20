-- ===================================================================
-- GitaWisdom Multilingual Performance Monitoring & Analytics
-- File: multilingual_monitoring.sql
-- Purpose: Monitor translation usage, performance, and coverage
-- Date: 2025-08-15
-- ===================================================================

-- ===================================================================
-- LANGUAGE USAGE ANALYTICS
-- ===================================================================

-- Create usage analytics table for tracking language preferences
CREATE TABLE IF NOT EXISTS language_usage_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_session VARCHAR(100), -- Anonymous session identifier
    lang_code VARCHAR(5) NOT NULL REFERENCES supported_languages(lang_code),
    content_type VARCHAR(20), -- 'chapter', 'scenario', 'verse', 'quote'
    action VARCHAR(20), -- 'view', 'search', 'favorite', 'share'
    content_id VARCHAR(50), -- ID of the content accessed
    response_time_ms INTEGER, -- Query response time in milliseconds
    fallback_used BOOLEAN DEFAULT FALSE, -- Whether English fallback was used
    cache_hit BOOLEAN DEFAULT FALSE, -- Whether content was served from cache
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Indexes for performance
    INDEX idx_lang_usage_lang_content (lang_code, content_type),
    INDEX idx_lang_usage_created_at (created_at),
    INDEX idx_lang_usage_session (user_session),
    INDEX idx_lang_usage_performance (response_time_ms, fallback_used)
);

-- ===================================================================
-- PERFORMANCE MONITORING VIEWS
-- ===================================================================

-- Daily language usage summary
CREATE OR REPLACE VIEW daily_language_usage AS
SELECT 
    DATE(created_at) as usage_date,
    lang_code,
    sl.native_name,
    sl.english_name,
    COUNT(*) as total_requests,
    COUNT(DISTINCT user_session) as unique_users,
    AVG(response_time_ms) as avg_response_time,
    COUNT(CASE WHEN fallback_used THEN 1 END) as fallback_requests,
    COUNT(CASE WHEN cache_hit THEN 1 END) as cache_hits,
    ROUND(
        (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as fallback_percentage,
    ROUND(
        (COUNT(CASE WHEN cache_hit THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as cache_hit_percentage
FROM language_usage_analytics lua
JOIN supported_languages sl ON lua.lang_code = sl.lang_code
GROUP BY DATE(created_at), lua.lang_code, sl.native_name, sl.english_name
ORDER BY usage_date DESC, total_requests DESC;

-- Content type performance by language
CREATE OR REPLACE VIEW content_performance_by_language AS
SELECT 
    lang_code,
    sl.native_name,
    content_type,
    COUNT(*) as request_count,
    AVG(response_time_ms) as avg_response_time,
    MIN(response_time_ms) as min_response_time,
    MAX(response_time_ms) as max_response_time,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY response_time_ms) as p95_response_time,
    COUNT(CASE WHEN fallback_used THEN 1 END) as fallback_count,
    ROUND(
        (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as fallback_rate
FROM language_usage_analytics lua
JOIN supported_languages sl ON lua.lang_code = sl.lang_code
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY lua.lang_code, sl.native_name, content_type
ORDER BY request_count DESC;

-- Translation coverage with usage data
CREATE OR REPLACE VIEW translation_coverage_with_usage AS
SELECT 
    tc.content_type,
    tc.lang_code,
    tc.native_name,
    tc.total_items,
    tc.translated_items,
    tc.coverage_percentage,
    COALESCE(usage.request_count, 0) as recent_requests,
    COALESCE(usage.fallback_count, 0) as fallback_requests,
    CASE 
        WHEN tc.coverage_percentage = 100 THEN 'Complete'
        WHEN tc.coverage_percentage >= 80 THEN 'High'
        WHEN tc.coverage_percentage >= 50 THEN 'Medium'
        WHEN tc.coverage_percentage >= 20 THEN 'Low'
        ELSE 'Minimal'
    END as coverage_status,
    CASE 
        WHEN COALESCE(usage.request_count, 0) > 100 THEN 'High Demand'
        WHEN COALESCE(usage.request_count, 0) > 50 THEN 'Medium Demand'
        WHEN COALESCE(usage.request_count, 0) > 10 THEN 'Low Demand'
        ELSE 'No Recent Usage'
    END as demand_level
FROM (
    SELECT * FROM get_translation_coverage()
) tc
LEFT JOIN (
    SELECT 
        lang_code,
        content_type,
        COUNT(*) as request_count,
        COUNT(CASE WHEN fallback_used THEN 1 END) as fallback_count
    FROM language_usage_analytics
    WHERE created_at >= NOW() - INTERVAL '30 days'
    GROUP BY lang_code, content_type
) usage ON tc.lang_code = usage.lang_code AND tc.content_type = usage.content_type
ORDER BY tc.content_type, usage.request_count DESC NULLS LAST;

-- ===================================================================
-- PERFORMANCE OPTIMIZATION FUNCTIONS
-- ===================================================================

-- Function to log language usage with performance metrics
CREATE OR REPLACE FUNCTION log_language_usage(
    p_user_session VARCHAR(100),
    p_lang_code VARCHAR(5),
    p_content_type VARCHAR(20),
    p_action VARCHAR(20),
    p_content_id VARCHAR(50),
    p_response_time_ms INTEGER DEFAULT NULL,
    p_fallback_used BOOLEAN DEFAULT FALSE,
    p_cache_hit BOOLEAN DEFAULT FALSE
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO language_usage_analytics (
        user_session,
        lang_code,
        content_type,
        action,
        content_id,
        response_time_ms,
        fallback_used,
        cache_hit
    ) VALUES (
        p_user_session,
        p_lang_code,
        p_content_type,
        p_action,
        p_content_id,
        p_response_time_ms,
        p_fallback_used,
        p_cache_hit
    );
END;
$$;

-- Function to get performance insights for a language
CREATE OR REPLACE FUNCTION get_language_performance_insights(
    p_lang_code VARCHAR(5),
    p_days INTEGER DEFAULT 7
)
RETURNS TABLE (
    metric VARCHAR(50),
    value NUMERIC,
    unit VARCHAR(20),
    status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Total Requests' as metric,
        COUNT(*)::NUMERIC as value,
        'requests' as unit,
        CASE 
            WHEN COUNT(*) > 1000 THEN 'High'
            WHEN COUNT(*) > 100 THEN 'Medium'
            ELSE 'Low'
        END as status
    FROM language_usage_analytics
    WHERE lang_code = p_lang_code 
      AND created_at >= NOW() - (p_days || ' days')::INTERVAL
    
    UNION ALL
    
    SELECT 
        'Average Response Time' as metric,
        ROUND(AVG(response_time_ms), 2) as value,
        'milliseconds' as unit,
        CASE 
            WHEN AVG(response_time_ms) < 100 THEN 'Excellent'
            WHEN AVG(response_time_ms) < 300 THEN 'Good'
            WHEN AVG(response_time_ms) < 1000 THEN 'Fair'
            ELSE 'Poor'
        END as status
    FROM language_usage_analytics
    WHERE lang_code = p_lang_code 
      AND created_at >= NOW() - (p_days || ' days')::INTERVAL
      AND response_time_ms IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'Fallback Rate' as metric,
        ROUND(
            (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
        ) as value,
        'percentage' as unit,
        CASE 
            WHEN (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100 < 10 THEN 'Excellent'
            WHEN (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100 < 30 THEN 'Good'
            WHEN (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100 < 50 THEN 'Fair'
            ELSE 'Poor'
        END as status
    FROM language_usage_analytics
    WHERE lang_code = p_lang_code 
      AND created_at >= NOW() - (p_days || ' days')::INTERVAL
    
    UNION ALL
    
    SELECT 
        'Cache Hit Rate' as metric,
        ROUND(
            (COUNT(CASE WHEN cache_hit THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
        ) as value,
        'percentage' as unit,
        CASE 
            WHEN (COUNT(CASE WHEN cache_hit THEN 1 END)::NUMERIC / COUNT(*)) * 100 > 80 THEN 'Excellent'
            WHEN (COUNT(CASE WHEN cache_hit THEN 1 END)::NUMERIC / COUNT(*)) * 100 > 60 THEN 'Good'
            WHEN (COUNT(CASE WHEN cache_hit THEN 1 END)::NUMERIC / COUNT(*)) * 100 > 40 THEN 'Fair'
            ELSE 'Poor'
        END as status
    FROM language_usage_analytics
    WHERE lang_code = p_lang_code 
      AND created_at >= NOW() - (p_days || ' days')::INTERVAL;
END;
$$;

-- Function to identify slow queries by language and content type
CREATE OR REPLACE FUNCTION identify_slow_queries(
    p_threshold_ms INTEGER DEFAULT 1000,
    p_days INTEGER DEFAULT 7
)
RETURNS TABLE (
    lang_code VARCHAR(5),
    content_type VARCHAR(20),
    avg_response_time NUMERIC,
    max_response_time INTEGER,
    slow_query_count BIGINT,
    total_queries BIGINT,
    slow_query_percentage NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lua.lang_code,
        lua.content_type,
        ROUND(AVG(lua.response_time_ms), 2) as avg_response_time,
        MAX(lua.response_time_ms) as max_response_time,
        COUNT(CASE WHEN lua.response_time_ms > p_threshold_ms THEN 1 END) as slow_query_count,
        COUNT(*) as total_queries,
        ROUND(
            (COUNT(CASE WHEN lua.response_time_ms > p_threshold_ms THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
        ) as slow_query_percentage
    FROM language_usage_analytics lua
    WHERE lua.created_at >= NOW() - (p_days || ' days')::INTERVAL
      AND lua.response_time_ms IS NOT NULL
    GROUP BY lua.lang_code, lua.content_type
    HAVING COUNT(CASE WHEN lua.response_time_ms > p_threshold_ms THEN 1 END) > 0
    ORDER BY slow_query_count DESC, avg_response_time DESC;
END;
$$;

-- ===================================================================
-- AUTOMATED MAINTENANCE PROCEDURES
-- ===================================================================

-- Function to cleanup old analytics data
CREATE OR REPLACE FUNCTION cleanup_old_analytics(
    p_retention_days INTEGER DEFAULT 90
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM language_usage_analytics
    WHERE created_at < NOW() - (p_retention_days || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RAISE NOTICE 'Cleaned up % old analytics records (older than % days)', 
        deleted_count, p_retention_days;
        
    RETURN deleted_count;
END;
$$;

-- Function to refresh performance statistics
CREATE OR REPLACE FUNCTION refresh_performance_stats()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Refresh materialized views
    PERFORM refresh_multilingual_views();
    
    -- Update table statistics
    ANALYZE language_usage_analytics;
    ANALYZE supported_languages;
    ANALYZE chapter_translations;
    ANALYZE scenario_translations;
    ANALYZE verse_translations;
    ANALYZE daily_quote_translations;
    
    RAISE NOTICE 'Performance statistics refreshed at %', NOW();
END;
$$;

-- ===================================================================
-- MONITORING QUERIES FOR OPERATIONS
-- ===================================================================

-- Daily performance summary
CREATE OR REPLACE VIEW daily_performance_summary AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_requests,
    COUNT(DISTINCT lang_code) as languages_used,
    COUNT(DISTINCT user_session) as unique_users,
    AVG(response_time_ms) as avg_response_time,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY response_time_ms) as p95_response_time,
    COUNT(CASE WHEN fallback_used THEN 1 END) as fallback_requests,
    COUNT(CASE WHEN cache_hit THEN 1 END) as cache_hits,
    ROUND(
        (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as fallback_percentage,
    ROUND(
        (COUNT(CASE WHEN cache_hit THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as cache_hit_percentage
FROM language_usage_analytics
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Language popularity ranking
CREATE OR REPLACE VIEW language_popularity_ranking AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as rank,
    lua.lang_code,
    sl.native_name,
    sl.english_name,
    sl.flag_emoji,
    COUNT(*) as total_requests,
    COUNT(DISTINCT user_session) as unique_users,
    AVG(response_time_ms) as avg_response_time,
    COUNT(CASE WHEN fallback_used THEN 1 END) as fallback_requests,
    ROUND(
        (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as fallback_rate,
    CASE 
        WHEN COUNT(*) > 1000 THEN 'High Usage'
        WHEN COUNT(*) > 100 THEN 'Medium Usage'
        WHEN COUNT(*) > 10 THEN 'Low Usage'
        ELSE 'Minimal Usage'
    END as usage_category
FROM language_usage_analytics lua
JOIN supported_languages sl ON lua.lang_code = sl.lang_code
WHERE lua.created_at >= NOW() - INTERVAL '30 days'
GROUP BY lua.lang_code, sl.native_name, sl.english_name, sl.flag_emoji
ORDER BY total_requests DESC;

-- ===================================================================
-- PERFORMANCE ALERTS
-- ===================================================================

-- Function to check for performance issues
CREATE OR REPLACE FUNCTION check_performance_alerts()
RETURNS TABLE (
    alert_type VARCHAR(50),
    severity VARCHAR(20),
    message TEXT,
    metric_value NUMERIC,
    threshold NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    avg_response_time NUMERIC;
    fallback_rate NUMERIC;
    slow_queries INTEGER;
BEGIN
    -- Check average response time
    SELECT AVG(response_time_ms) INTO avg_response_time
    FROM language_usage_analytics
    WHERE created_at >= NOW() - INTERVAL '1 hour'
      AND response_time_ms IS NOT NULL;
    
    IF avg_response_time > 1000 THEN
        RETURN QUERY SELECT 
            'High Response Time'::VARCHAR(50),
            'Critical'::VARCHAR(20),
            'Average response time is above 1 second'::TEXT,
            avg_response_time,
            1000::NUMERIC;
    ELSIF avg_response_time > 500 THEN
        RETURN QUERY SELECT 
            'Elevated Response Time'::VARCHAR(50),
            'Warning'::VARCHAR(20),
            'Average response time is above 500ms'::TEXT,
            avg_response_time,
            500::NUMERIC;
    END IF;
    
    -- Check fallback rate
    SELECT 
        (COUNT(CASE WHEN fallback_used THEN 1 END)::NUMERIC / COUNT(*)) * 100
    INTO fallback_rate
    FROM language_usage_analytics
    WHERE created_at >= NOW() - INTERVAL '1 hour';
    
    IF fallback_rate > 50 THEN
        RETURN QUERY SELECT 
            'High Fallback Rate'::VARCHAR(50),
            'Critical'::VARCHAR(20),
            'More than 50% of requests are falling back to English'::TEXT,
            fallback_rate,
            50::NUMERIC;
    ELSIF fallback_rate > 25 THEN
        RETURN QUERY SELECT 
            'Elevated Fallback Rate'::VARCHAR(50),
            'Warning'::VARCHAR(20),
            'More than 25% of requests are falling back to English'::TEXT,
            fallback_rate,
            25::NUMERIC;
    END IF;
    
    -- Check for slow queries
    SELECT COUNT(*) INTO slow_queries
    FROM language_usage_analytics
    WHERE created_at >= NOW() - INTERVAL '1 hour'
      AND response_time_ms > 2000;
    
    IF slow_queries > 10 THEN
        RETURN QUERY SELECT 
            'Slow Queries Detected'::VARCHAR(50),
            'Warning'::VARCHAR(20),
            'Multiple queries taking over 2 seconds detected'::TEXT,
            slow_queries::NUMERIC,
            10::NUMERIC;
    END IF;
    
END;
$$;

-- ===================================================================
-- USEFUL MONITORING QUERIES
-- ===================================================================

-- Get real-time performance metrics
COMMENT ON VIEW daily_performance_summary IS 'Daily performance overview showing request volume, response times, and cache effectiveness';

-- Example usage queries:
COMMENT ON FUNCTION get_language_performance_insights IS 'Usage: SELECT * FROM get_language_performance_insights(''hi'', 7);';
COMMENT ON FUNCTION identify_slow_queries IS 'Usage: SELECT * FROM identify_slow_queries(1000, 7);';
COMMENT ON FUNCTION check_performance_alerts IS 'Usage: SELECT * FROM check_performance_alerts();';

-- ===================================================================
-- SCHEDULED MAINTENANCE SETUP
-- ===================================================================

-- Example cron jobs (if using pg_cron extension):
-- Refresh stats every hour
-- SELECT cron.schedule('refresh-multilingual-stats', '0 * * * *', 'SELECT refresh_performance_stats();');

-- Cleanup old analytics daily at 2 AM
-- SELECT cron.schedule('cleanup-analytics', '0 2 * * *', 'SELECT cleanup_old_analytics(90);');

-- Check for performance alerts every 15 minutes
-- SELECT cron.schedule('performance-alerts', '*/15 * * * *', 'SELECT check_performance_alerts();');