import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/core/router/app_router.dart';
import 'package:mobile_customer/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: DeliveryZamoraApp()));
}

class DeliveryZamoraApp extends StatelessWidget {
  const DeliveryZamoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeliveryZamora',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
