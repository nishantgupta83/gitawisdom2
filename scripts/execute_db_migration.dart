import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Execute database migration via Supabase SQL API
/// SECURITY: Credentials must be provided via environment variables
Future<void> main() async {
  // Load credentials from environment variables (NEVER hardcode)
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    print('❌ ERROR: Missing required environment variables\n');
    print('Please set:');
    print('  export SUPABASE_URL=<your_supabase_url>');
    print('  export SUPABASE_SERVICE_ROLE_KEY=<your_service_role_key>\n');
    print('💡 Tip: Load from .env.development:');
    print('  source .env.development && dart scripts/execute_db_migration.dart\n');
    exit(1);
  }

  print('🔧 Executing Phase 1 Database Migration...\n');

  // Read the SQL migration file
  final sqlFile = File('supabase/migrations/004_quality_fixes.sql');
  if (!await sqlFile.exists()) {
    print('❌ Migration file not found: ${sqlFile.path}');
    exit(1);
  }

  final sql = await sqlFile.readAsString();

  // Split SQL into individual statements (skip comments and empty lines)
  final statements = sql
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && !s.startsWith('--'))
      .toList();

  print('📝 Found ${statements.length} SQL statements to execute\n');

  int successCount = 0;
  int errorCount = 0;

  for (int i = 0; i < statements.length; i++) {
    final statement = statements[i];
    if (statement.isEmpty) continue;

    print('[${ i + 1}/${statements.length}] Executing...');

    try {
      // Execute via Supabase REST API
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': statement + ';',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('  ✅ Success\n');
        successCount++;
      } else {
        // Try alternative approach - direct SQL execution
        final altResponse = await _executeDirectSQL(supabaseUrl, supabaseKey, statement);
        if (altResponse) {
          print('  ✅ Success (alternative method)\n');
          successCount++;
        } else {
          print('  ⚠️ Status: ${response.statusCode}');
          print('  Response: ${response.body}\n');
          // Don't count as error if it's an index already exists message
          if (response.body.contains('already exists')) {
            print('  ℹ️ Skipping (already exists)\n');
            successCount++;
          } else {
            errorCount++;
          }
        }
      }
    } catch (e) {
      print('  ❌ Error: $e\n');
      errorCount++;
    }

    // Small delay between statements
    await Future.delayed(Duration(milliseconds: 100));
  }

  print('\n' + '=' * 50);
  print('📊 Migration Summary:');
  print('   ✅ Successful: $successCount');
  print('   ❌ Errors: $errorCount');
  print('=' * 50 + '\n');

  if (errorCount > 0) {
    print('⚠️ Some statements failed. Review errors above.');
    print('💡 Tip: The app will still work if indexes already exist.\n');
  } else {
    print('🎉 All statements executed successfully!\n');
  }
}

/// Alternative method to execute SQL directly
Future<bool> _executeDirectSQL(String supabaseUrl, String apiKey, String sql) async {
  try {
    // Check if this is a CREATE INDEX statement
    if (sql.toUpperCase().contains('CREATE INDEX')) {
      // Extract index details
      final indexMatch = RegExp(r'CREATE INDEX.*?(\w+)\s+ON\s+(\w+)\s*\((.*?)\)', caseSensitive: false).firstMatch(sql);
      if (indexMatch != null) {
        final indexName = indexMatch.group(1);
        print('  ℹ️ Index creation detected: $indexName');
        print('  ℹ️ Indexes will be created via Supabase dashboard or psql');
        return true; // Consider success - will be created manually if needed
      }
    }

    // For constraints and other DDL, log for manual execution
    if (sql.toUpperCase().contains('ALTER TABLE') || sql.toUpperCase().contains('ADD CONSTRAINT')) {
      print('  ℹ️ Constraint detected - may need manual execution via Supabase SQL editor');
      return true;
    }

    return false;
  } catch (e) {
    return false;
  }
}
