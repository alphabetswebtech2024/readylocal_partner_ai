import 'package:flutter/material.dart';

import '../../main.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class LoadingDialog {
  LoadingDialog(this.context);

  final BuildContext context;

  void showLoadingIndicator([String? text]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              backgroundColor: Colors.white,
              content: LoadingIndicator(text: text != null ? text : ""),
              insetPadding: const EdgeInsets.symmetric(horizontal: 100),
            ));
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key, this.text = ''});

  final String text;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animationController.repeat();

    // startTimer();
  }

  @override
  void dispose() {
    animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var displayedText = widget.text;

    return Container(
      padding: const EdgeInsets.all(0),
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16.0),
          _getLoadingIndicator(),
          const SizedBox(height: 8.0),
          _getHeading(context),
          _getText(displayedText),
        ],
      ),
    );
  }

  Padding _getLoadingIndicator() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          width: 32,
          height: 32,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ));
  }

  Widget _getHeading(context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(
          L10n.current.commonPleaseWait,
          style: const TextStyle(
            color: mainColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ));
  }

  Widget _getText(String displayedText) {
    return Text(
      displayedText,
      style: const TextStyle(
        color: mainColor,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}
