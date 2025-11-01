// Add this to your debug menu or settings screen to access the diagnostic tool

import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/liveStreaming_screen/recording_diagnostic_screen.dart';

class DiagnosticHelper {
  /// Navigate to Recording Diagnostic Screen
  /// Call this from anywhere in your app during development
  static void openRecordingDiagnostic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordingDiagnosticScreen(),
      ),
    );
  }
}

// Example: Add a floating button to your live stream screen
// Or add it to your settings/debug menu:
/*

FloatingActionButton(
  onPressed: () => DiagnosticHelper.openRecordingDiagnostic(context),
  child: Icon(Icons.bug_report),
  backgroundColor: Colors.orange,
  mini: true,
)

*/
