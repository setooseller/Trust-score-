// Application routes for home, product details, bookmarks, admin, and feedback.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/product/presentation/product_detail_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (BuildContext context, GoRouterState state) =>
            const BookmarksScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (BuildContext context, GoRouterState state) =>
            const AdminScreen(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (BuildContext context, GoRouterState state) =>
            const FeedbackScreen(),
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (BuildContext context, GoRouterState state) {
          return ProductDetailScreen(productId: state.pathParameters['productId']!);
        },
      ),
    ],
  );
});
