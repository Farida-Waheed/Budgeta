import 'package:flutter/material.dart';
import '../modules/dashboard/dashboard_page.dart';

class AppRoutes {
  static const initial = '/';

  static final routes = <String, WidgetBuilder>{
    '/': (context) => const DashboardPage(),
  };
}
