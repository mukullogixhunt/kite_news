import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';
import 'package:stack_wealth_news/features/news/presentation/screens/news_detail_screen.dart';
import 'package:stack_wealth_news/features/news/presentation/screens/search_screen.dart';

import 'features/news/presentation/screens/news_screen.dart';

/// Configures the application's navigation using GoRouter with custom transitions.

final rootNavigatorKey = GlobalKey<NavigatorState>();

const Duration transitionDuration = Duration(milliseconds: 600);
const Offset slideInFromRight = Offset(1.0, 0.0);
const Offset slideUpFromBottom = Offset(0.0, 1.0);
const Curve transitionCurve = Curves.easeInOut;

/// Builds a custom page transition with a slide animation.
CustomTransitionPage buildTransitionPage(Widget child, Offset begin) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: transitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(
        begin: begin,
        end: Offset.zero,
      ).chain(CurveTween(curve: transitionCurve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

/// Defines the main application router and its routes.
final GoRouter router = GoRouter(
  initialLocation: NewsScreen.path,
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(
      path: NewsScreen.path,
      pageBuilder: (context, state) =>
          buildTransitionPage(const NewsScreen(), slideInFromRight),
    ),
    GoRoute(
      path: SearchScreen.path,
      pageBuilder: (context, state) =>
          buildTransitionPage(const SearchScreen(), slideInFromRight),
    ),
    GoRoute(
      path: NewsDetailScreen.path,
      pageBuilder: (context, state) {
        ArticleEntity article = state.extra as ArticleEntity;
        return buildTransitionPage(
            NewsDetailScreen(article: article), slideUpFromBottom);
      },
    ),
  ],
);