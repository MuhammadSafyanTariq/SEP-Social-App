import 'package:flutter/material.dart';

import '../error.dart';

class ScreenListenerModel{
  bool loading;
  bool isError;
  Failure? failure;
  Exception? exception;
  Widget? pushScreen;

  ScreenListenerModel({
    this.loading = false,
    this.isError = false,
    this.failure,
    this.exception,
    this.pushScreen
  });

  static ScreenListenerModel get loaderState => ScreenListenerModel(loading: true);
  static ScreenListenerModel get finishState => ScreenListenerModel();
  static ScreenListenerModel  errorState(Exception e) => ScreenListenerModel(
      isError: true,
    failure: e is Failure ? e : null,
    exception: e
  );
}