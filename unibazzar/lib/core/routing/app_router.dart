import 'package:flutter/material.dart';
import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/listing/presentation/views/add_listing_page.dart';

import '../../features/listing/presentation/views/product_details_page.dart';
import '../../features/profile/presentation/views/profile_page.dart';
import '../../features/admin/presentation/views/admin_dashboard_page.dart';
import '../../features/listing/domain/entities/listing.dart';
import '../../features/splash/presentation/views/splash_page.dart';
import '../widgets/main_scaffold.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productDetails = '/product-details';
  static const String addListing = '/add-listing';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(settings, const SplashPage());
      case AppRoutes.register:
        return _fade(settings, const RegisterPage());
      case AppRoutes.home:
        return _fade(settings, const MainScaffold());
      case AppRoutes.productDetails:
        final listing = settings.arguments as Listing?;
        return _fade(settings, ProductDetailsPage(listing: listing));
      case AppRoutes.addListing:
        return _fade(settings, const AddListingPage());
      case AppRoutes.profile:
        return _fade(settings, const ProfilePage());
      case AppRoutes.adminDashboard:
        return _fade(settings, const AdminDashboardPage());
      case AppRoutes.login:
      default:
        return _fade(settings, const LoginPage());
    }
  }

  static PageRouteBuilder _fade(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
