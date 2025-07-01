// lib/utils/toast_utils.dart
import 'package:flutter/material.dart';
import 'package:ftoast/ftoast.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import '../utils/strings.dart';
import '../../main.dart';

void emptyFieldsWarning(BuildContext context) {
  FToast.toast(
    context,
    msg: MyString.oopsMsg,
    subMsg: "You must fill all fields!",
    corner: 20.0,
    duration: 2000,
    padding: const EdgeInsets.all(20),
  );
}

void nothingEnterOnUpdateTaskMode(BuildContext context) {
  FToast.toast(
    context,
    msg: MyString.oopsMsg,
    subMsg: "You must edit the tasks then try to update it!",
    corner: 20.0,
    duration: 3000,
    padding: const EdgeInsets.all(20),
  );
}

void warningNoTask(BuildContext context) {
  PanaraInfoDialog.showAnimatedGrow(
    context,
    title: MyString.oopsMsg,
    message:
        "There is no task to delete!\nTry adding some and then try to delete it!",
    buttonText: "Okay",
    onTapDismiss: () {
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.warning,
  );
}

void deleteAllTask(BuildContext context) {
  PanaraConfirmDialog.show(
    context,
    title: MyString.areYouSure,
    message:
        "Do you really want to delete all tasks? You will not be able to undo this action!",
    confirmButtonText: "Yes",
    cancelButtonText: "No",
    onTapCancel: () {
      Navigator.pop(context);
    },
    onTapConfirm: () async {
      await BaseWidget.of(context).dataStore.deleteAllTasks();
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.error,
    barrierDismissible: false,
  );
}

const String lottieURL = 'assets/lottie/animation.json';