import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stack_wealth_news/features/news/presentation/bloc/cached_search/cached_search_bloc.dart';
import 'package:stack_wealth_news/features/news/presentation/bloc/news_search/news_search_bloc.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NewsSearchBloc>(create: (context) => sl<NewsSearchBloc>()),
        BlocProvider<CachedSearchBloc>(create: (context) => sl<CachedSearchBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Kite News',
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}


