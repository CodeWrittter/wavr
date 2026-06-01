import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits true when the device has any network connection.
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  return connectivity.onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
});

/// Simple synchronous bool — convenient for guards in services.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        data: (online) => online,
        orElse: () => true, // assume online until proven otherwise
      );
});
