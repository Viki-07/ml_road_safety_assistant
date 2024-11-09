import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class QuickAlertsDialog {
  int _countdownTime = 10;
  Timer? _countdownTimer;

  final Function onCountdownUpdate;
  final Function onCountdownComplete;
  final Function onDialogClose;

  final BuildContext context;

  QuickAlertsDialog({
    required this.context,
    required this.onCountdownUpdate,
    required this.onCountdownComplete,
    required this.onDialogClose,
  });

  void showGForceAlert({
    required double gForce,
  }) {
    _startCountdown();

    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Potential Crash detected!',
      text: 'G-force: ' +
          gForce.toStringAsFixed(1) +
          ' G.\nPress button within $_countdownTime seconds to stop emergency action.',
      onConfirmBtnTap: () {
        _cancelCountdown();
      },
      // showCancelBtn: true,

      cancelBtnText: 'Cancel',
      confirmBtnText: 'Stop Alert',
      barrierDismissible:
          false, // Prevent dialog from closing by tapping outside
    );
  }

  void _startCountdown() {
    _countdownTime = 10;
    _countdownTimer?.cancel(); // Cancel any previous timers
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _countdownTime--;
      onCountdownUpdate(_countdownTime); // Notify about countdown updates

      if (_countdownTime == 0) {
        timer.cancel();
        onCountdownComplete(); // Notify that countdown is complete
        onDialogClose(); // Trigger dialog close
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel(); // Cancel the timer
    onDialogClose(); // Notify to close the dialog
  }
}
