import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'debug/app_error_console.dart';
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
import '../features/pos/order_alert/presentation/order_alert_overlay.dart';
import '../features/about/data/about_release_info_repository.dart';
import '../features/about/state/shorebird_update_provider.dart';

class JarzPosApp extends ConsumerWidget {
  const JarzPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeNotifierProvider);
    final isAuthenticated = ref.watch(currentAuthStateProvider);

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
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 1),
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
        final routed = isAuthenticated
            ? _AuthenticatedServiceBootstrap(
                child: child ?? const SizedBox.shrink(),
              )
            : child ?? const SizedBox.shrink();
        return AppErrorConsole(
          child: OrderAlertOverlay(
            child: GestureDetector(
              onTap: () {
                final currentScope = FocusScope.of(context);
                if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: LoadingOverlay(
                child: Column(
                  children: [
                    if (isAuthenticated) const _ShorebirdUpdateBanner(),
                    Expanded(child: routed),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthenticatedServiceBootstrap extends ConsumerStatefulWidget {
  const _AuthenticatedServiceBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_AuthenticatedServiceBootstrap> createState() =>
      _AuthenticatedServiceBootstrapState();
}

class _AuthenticatedServiceBootstrapState
    extends ConsumerState<_AuthenticatedServiceBootstrap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(shorebirdUpdateProvider.notifier).recheckStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(posPrinterServiceProvider);
    ref.watch(webSocketServiceProvider);
    ref.watch(offlineSyncServiceProvider);
    ref.watch(userRolesFutureProvider);
    ref.watch(courierWsBridgeProvider);
    ref.watch(orderAlertBridgeProvider);
    ref.watch(shorebirdUpdateProvider);

    return widget.child;
  }
}

class _ShorebirdUpdateBanner extends ConsumerWidget {
  const _ShorebirdUpdateBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(shorebirdUpdateProvider);
    if (statusAsync.valueOrNull != ShorebirdPatchStatus.restartRequired) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.amber.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.shorebirdUpdateBannerMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
