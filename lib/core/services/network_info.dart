// lib/core/services/network_info.dart

import 'package:connectivity_plus/connectivity_plus.dart';

/// A simple abstraction over connectivity, so we can mock it reliably.
abstract class NetworkInfo {
  /// Returns true if the device is online (wifi or mobile).
  Future<bool> get isConnected;
}

/// Production implementation, using connectivity_plus under the hood.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
