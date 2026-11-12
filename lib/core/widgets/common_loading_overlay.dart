// import 'package:flutter/material.dart';
//
// class CommonLoadingOverlay extends StatelessWidget {
//   final bool isLoading;
//   final Widget child;
//
//   const CommonLoadingOverlay({
//     super.key,
//     required this.isLoading,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         child,
//         if (isLoading)
//           Container(
//             color: Colors.black.withValues(alpha: 0.5), // Dimmed background
//             child: Center(
//               child: Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.1),
//                       blurRadius: 10,
//                       spreadRadius: 3,
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 5.0,
//                     // Uses your app's primary color (blue)
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';

/// Blocks taps while something loads (so nothing is pressed twice) and shows a
/// spinner only if the wait is long enough to notice. It uses a plain dim layer:
/// the full-screen blur it had before is very slow to draw on low-end phones.
class CommonLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const CommonLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  State<CommonLoadingOverlay> createState() => _CommonLoadingOverlayState();
}

class _CommonLoadingOverlayState extends State<CommonLoadingOverlay> {
  static const Duration _showAfter = Duration(milliseconds: 250);

  Timer? _timer;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) _startTimer();
  }

  @override
  void didUpdateWidget(CommonLoadingOverlay old) {
    super.didUpdateWidget(old);
    if (widget.isLoading && !old.isLoading) {
      _startTimer();
    } else if (!widget.isLoading && old.isLoading) {
      _timer?.cancel();
      _showSpinner = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(_showAfter, () {
      if (mounted) setState(() => _showSpinner = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: _showSpinner
                  ? ColoredBox(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}
