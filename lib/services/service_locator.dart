import 'enhanced_supabase_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  static ServiceLocator get instance => _instance;

  EnhancedSupabaseService? _enhancedSupabaseService;

  EnhancedSupabaseService get enhancedSupabaseService {
    _enhancedSupabaseService ??= EnhancedSupabaseService();
    return _enhancedSupabaseService!;
  }

  Future<void> initialize() async {
    await enhancedSupabaseService.initializeLanguages();
  }

  void dispose() {
    _enhancedSupabaseService = null;
  }
}