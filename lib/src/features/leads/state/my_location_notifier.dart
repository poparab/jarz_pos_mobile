import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Why the app has no position, in terms a rep can act on.
enum MyLocationStatus {
  /// Never asked yet — the map simply has no blue dot.
  idle,

  /// Waiting on the OS prompt or the first fix.
  locating,

  /// We have a position.
  ready,

  /// Denied this once. Asking again is allowed.
  denied,

  /// Denied permanently (Android "don't ask again") — only Settings fixes it,
  /// so the UI must offer that rather than a retry that can never succeed.
  deniedForever,

  /// Location services are switched off device-wide.
  serviceDisabled,

  /// Permission was granted but no fix arrived (indoors, timeout, web denial).
  unavailable,
}

/// The device's own position, used to show "you are here" and to measure
/// straight-line distance to each lead.
class MyLocationState {
  const MyLocationState({
    this.status = MyLocationStatus.idle,
    this.position,
    this.accuracyMetres,
  });

  final MyLocationStatus status;
  final LatLng? position;
  final double? accuracyMetres;

  bool get hasPosition => position != null;
  bool get isBusy => status == MyLocationStatus.locating;

  /// Whether a retry could plausibly succeed. False for [deniedForever],
  /// where the only route is the system settings screen.
  bool get canRetry => status != MyLocationStatus.deniedForever;

  MyLocationState copyWith({
    MyLocationStatus? status,
    LatLng? position,
    double? accuracyMetres,
  }) {
    return MyLocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      accuracyMetres: accuracyMetres ?? this.accuracyMetres,
    );
  }
}

/// Holds the device position. Never throws: every failure resolves to a status
/// the UI can explain, because a map that silently shows no dot is
/// indistinguishable from a broken one.
///
/// Deliberately NOT a continuous stream. A rep planning a route needs "where am
/// I now", and a background position stream on a shop phone is a battery cost
/// with no matching benefit. [locate] is called on demand.
class MyLocationNotifier extends Notifier<MyLocationState> {
  @override
  MyLocationState build() => const MyLocationState();

  /// Requests permission if needed and takes one fix.
  Future<void> locate() async {
    if (state.isBusy) return;
    state = state.copyWith(status: MyLocationStatus.locating);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        state = const MyLocationState(status: MyLocationStatus.serviceDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        state = const MyLocationState(status: MyLocationStatus.deniedForever);
        return;
      }
      if (permission == LocationPermission.denied) {
        state = const MyLocationState(status: MyLocationStatus.denied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          // A fix good enough to say "which of these is nearest" does not need
          // to be perfect, and a rep should never watch a spinner forever
          // because they walked into a back room.
          timeLimit: Duration(seconds: 15),
        ),
      );

      state = MyLocationState(
        status: MyLocationStatus.ready,
        position: LatLng(position.latitude, position.longitude),
        accuracyMetres: position.accuracy,
      );
    } catch (_) {
      // Timeout, web permission dismissal, or an OS that simply refuses.
      // Keep any position already held — a slightly old fix still answers
      // "roughly how far is this" better than nothing does.
      state = state.copyWith(
        status: state.hasPosition
            ? MyLocationStatus.ready
            : MyLocationStatus.unavailable,
      );
    }
  }

  /// Opens the OS settings page so a permanently-denied permission can be
  /// fixed. Returns false when the platform will not open it (e.g. web).
  Future<bool> openSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Forgets the position (used when a rep explicitly turns the dot off).
  void clear() => state = const MyLocationState();
}

final myLocationProvider =
    NotifierProvider<MyLocationNotifier, MyLocationState>(
  MyLocationNotifier.new,
);
