import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../localization/locale_provider.dart';
import 'app_colors.dart';

/// Shows a slim notice at the bottom of every screen while the device has no
/// network. It only informs; nothing is blocked or retried automatically.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child, this.changes, this.check});

  final Widget child;

  /// Overridable for tests; default is the device's connectivity.
  final Stream<List<ConnectivityResult>>? changes;
  final Future<List<ConnectivityResult>> Function()? check;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;

  static bool _isOffline(List<ConnectivityResult> r) => r.isEmpty || r.every((c) => c == ConnectivityResult.none);

  @override
  void initState() {
    super.initState();
    final connectivity = (widget.changes == null || widget.check == null) ? Connectivity() : null;
    final changes = widget.changes ?? connectivity!.onConnectivityChanged;
    final check = widget.check ?? connectivity!.checkConnectivity;
    _sub = changes.listen(_update, onError: (_) {});
    check().then(_update).catchError((_) {});
  }

  void _update(List<ConnectivityResult> results) {
    final offline = _isOffline(results);
    if (mounted && offline != _offline) setState(() => _offline = offline);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _offline
              ? Material(
                  color: AppColors.ink,
                  child: Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              L10n.current.offlineBanner,
                              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
