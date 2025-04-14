import 'package:get_it/get_it.dart';
import 'package:stack_wealth_news/features/news/presentation/bloc/cached_search/cached_search_bloc.dart';
import 'package:stack_wealth_news/features/news/presentation/bloc/news_search/news_search_bloc.dart';

import 'data/datasources/local/news_local_datasource.dart';
import 'data/datasources/remote/news_remote_datasource.dart';
import 'data/repositories/news_repository_impl.dart';
import 'domain/repositories/news_repository.dart';
import 'domain/usecases/cache_search_term.dart';
import 'domain/usecases/clear_cached_search_terms.dart';
import 'domain/usecases/get_cached_search_terms.dart';
import 'domain/usecases/get_news.dart';

final sl = GetIt.instance;

void initNews() {
  /// News Data sources Injection
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  /// News Repository Injection
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  /// News Use Cases Injection
  sl.registerLazySingleton(() => GetNews(repository: sl()));
  sl.registerLazySingleton(() => GetCachedSearchTerms(repository: sl()));
  sl.registerLazySingleton(() => CacheSearchTerm(repository: sl()));
  sl.registerLazySingleton(() => ClearCachedSearchTerms(repository: sl()));

  /// Messages Bloc Injection
  sl.registerFactory(
    () => CachedSearchBloc(
      getCachedSearchTerms: sl.call(),
      cacheSearchTerm: sl.call(),
      clearCachedSearchTerms: sl.call(),
    ),
  );
  sl.registerFactory(() => NewsSearchBloc(getNews: sl.call()));
}
