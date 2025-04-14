import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_wealth_news/features/news/news_injection.dart';

/// Service Locator instance using GetIt.
final sl = GetIt.instance;

/// Initializes dependency injection for the application.
Future<void> init() async {
  /// Register third-party dependencies (SharedPreferences and http.Client).
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  /// Initialize dependencies specific to features.
  initNews();
}
