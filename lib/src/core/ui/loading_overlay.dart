import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logo.dart';

// Loading state model
class LoadingState {
  final bool isLoading;
  final String? message;
  final double? progress;

  const LoadingState({
    this.isLoading = false,
    this.message,
    this.progress,
  });

  LoadingState copyWith({
    bool? isLoading,
    String? message,
    double? progress,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      progress: progress ?? this.progress,
    );
  }
}

// Loading notifier
class LoadingOverlayNotifier extends StateNotifier<LoadingState> {
  LoadingOverlayNotifier() : super(const LoadingState());

  void show([String? message]) {
    state = LoadingState(isLoading: true, message: message);
  }

  void showWithProgress(double progress, [String? message]) {
    state = LoadingState(isLoading: true, message: message, progress: progress);
  }

  void updateMessage(String message) {
    if (state.isLoading) {
      state = state.copyWith(message: message);
    }
  }

  void updateProgress(double progress, [String? message]) {
    if (state.isLoading) {
      state = state.copyWith(progress: progress, message: message);
    }
  }

  void hide() {
    state = const LoadingState();
  }
}

// Provider
final loadingOverlayProvider = StateNotifierProvider<LoadingOverlayNotifier, LoadingState>((ref) {
  return LoadingOverlayNotifier();
});

// Loading overlay widget
class LoadingOverlay extends ConsumerWidget {
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(loadingOverlayProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (loadingState.isLoading)
          GestureDetector(
            onTap: () {
              // Allow keyboard dismissal even when loading overlay is visible
              final FocusScopeNode currentScope = FocusScope.of(context);
              if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 110),
                        const SizedBox(height: 12),
                        if (loadingState.progress != null) ...[
                          CircularProgressIndicator(
                            value: loadingState.progress,
                            strokeWidth: 6,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${(loadingState.progress! * 100).toInt()}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else const CircularProgressIndicator(strokeWidth: 6),
                        const SizedBox(height: 16),
                        Text(
                          loadingState.message ?? 'Processing...',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Extension for easy access
extension LoadingOverlayExtension on WidgetRef {
  LoadingOverlayNotifier get loading => read(loadingOverlayProvider.notifier);
}
