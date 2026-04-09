import 'package:flutter/material.dart';
import '../features/record/record_create_page.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void navigateToRecord() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const RecordCreatePage(plans: []),
      ),
    );
  }
}