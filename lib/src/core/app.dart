import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'localization/localization_extensions.dart';
import 'localization/locale_notifier.dart';
import 'router.dart';
import 'ui/loading_overlay.dart';
import 'websocket/websocket_service.dart';
import 'sync/offline_sync_service.dart';
import '../features/pos/state/courier_ws_bridge.dart';
import '../features/printing/pos_printer_provider.dart';
import 'network/user_service.dart';
import '../features/pos/order_alert/order_alert_bridge.dart';
import '../features/pos/order_alert/presentation/order_alert_listener.dart';

class JarzPosApp extends ConsumerWidget {
  const JarzPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeNotifierProvider);
    
    // Initialize services
    ref.watch(webSocketServiceProvider);
    ref.watch(offlineSyncServiceProvider);
    // Initialize printer service early so it can auto-reconnect if a device was saved
    ref.watch(posPrinterServiceProvider);
    // Prefetch current user roles (safe if unauthenticated; will be retried post-login)
    ref.watch(userRolesFutureProvider);

    // Initialize courier websocket bridge
    ref.watch(courierWsBridgeProvider);
    ref.watch(orderAlertBridgeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supported) {
        if (locale != null) {
          return locale;
        }
        if (deviceLocale == null) {
          return supported.first;
        }
        return supported.firstWhere(
          (element) => element.languageCode == deviceLocale.languageCode,
          orElse: () => supported.first,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final routed = child ?? const SizedBox.shrink();
        return OrderAlertListener(
          child: GestureDetector(
            onTap: () {
              final currentScope = FocusScope.of(context);
              if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: LoadingOverlay(child: routed),
          ),
        );
      },
    );
  }
}
