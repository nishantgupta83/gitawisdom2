import 'enhanced_supabase_service.dart';
import 'supabase_auth_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  static ServiceLocator get instance => _instance;

  EnhancedSupabaseService? _enhancedSupabaseService;
  SupabaseAuthService? _supabaseAuthService;

  EnhancedSupabaseService get enhancedSupabaseService {
    _enhancedSupabaseService ??= EnhancedSupabaseService();
    return _enhancedSupabaseService!;
  }

  SupabaseAuthService get supabaseAuthService {
    _supabaseAuthService ??= SupabaseAuthService.instance;
    return _supabaseAuthService!;
  }

  Future<void> initialize() async {
    await Future.wait([
      enhancedSupabaseService.initializeLanguages(),
      supabaseAuthService.initialize(),
    ]);
  }

  void dispose() {
    _enhancedSupabaseService = null;
    _supabaseAuthService = null;
  }
}