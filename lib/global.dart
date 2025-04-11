library my_globals; // This must be the first line

import 'package:flutter/material.dart';

double? globalTemp;
ValueNotifier<void> globalNotifier = ValueNotifier<void>(null);

// Function to notify UI when globalTemp changes
void notifyListeners() {
  globalNotifier.value = null; // Triggers UI update
}
