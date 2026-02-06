import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart';
import 'package:sep/utils/appUtils.dart';

/// Global GPU error handler to prevent cascading errors when GPU device is lost
class GpuErrorHandler {
  static final GpuErrorHandler instance = GpuErrorHandler._();
  GpuErrorHandler._();

  bool _gpuDeviceLost = false;
  DateTime? _lastGpuErrorTime;
  static const Duration _recoveryDelay = Duration(seconds: 5);

  bool get isGpuDeviceLost => _gpuDeviceLost;

  /// Check if GPU device was lost and if enough time has passed for recovery
  bool canAttemptRecovery() {
    if (!_gpuDeviceLost) return true;
    if (_lastGpuErrorTime == null) return false;
    final timeSinceError = DateTime.now().difference(_lastGpuErrorTime!);
    return timeSinceError >= _recoveryDelay;
  }

  /// Mark GPU device as lost
  void markGpuDeviceLost() {
    if (!_gpuDeviceLost) {
      AppUtils.log('⚠️ GPU device lost detected - stopping all rendering operations');
      _gpuDeviceLost = true;
      _lastGpuErrorTime = DateTime.now();
      
      // Stop all video playback immediately
      try {
        VideoControllerManager.find.disposeAll();
      } catch (e) {
        AppUtils.log('Error disposing video controllers: $e');
      }
    }
  }

  /// Reset GPU device lost state (after recovery delay)
  void resetGpuDeviceLost() {
    if (_gpuDeviceLost && canAttemptRecovery()) {
      AppUtils.log('✅ GPU device recovered - resuming normal operations');
      _gpuDeviceLost = false;
      _lastGpuErrorTime = null;
    }
  }

  /// Handle Flutter errors and check for GPU device lost errors
  /// This runs synchronously on the error thread, so keep it fast!
  void handleFlutterError(FlutterErrorDetails details) {
    // Fast path: if GPU already marked as lost, suppress immediately
    if (_gpuDeviceLost) {
      // Only check if enough time has passed to potentially reset
      if (_lastGpuErrorTime != null) {
        final timeSinceError = DateTime.now().difference(_lastGpuErrorTime!);
        if (timeSinceError.inSeconds < 5) {
          // Still in recovery period, suppress all GPU-related errors
          final errorStr = details.exception.toString().toLowerCase();
          if (errorStr.contains('vulkan') || 
              errorStr.contains('impeller') || 
              errorStr.contains('gpu') ||
              errorStr.contains('devicelost')) {
            return; // Suppress immediately
          }
        }
      }
    }

    final errorStr = details.exception.toString().toLowerCase();
    final stackStr = details.stack.toString().toLowerCase();

    // Quick check for GPU device lost errors (optimized for speed)
    final isGpuDeviceLost = errorStr.contains('devicelost') ||
        errorStr.contains('device lost') ||
        errorStr.contains('no surface available') ||
        errorStr.contains('fence wait failed') ||
        errorStr.contains('vulkan') ||
        errorStr.contains('impeller') ||
        errorStr.contains('swapchain') ||
        errorStr.contains('failed to submit') ||
        errorStr.contains('gpu error') ||
        errorStr.contains('error submitting') ||
        errorStr.contains('command buffer') ||
        stackStr.contains('vulkan') ||
        stackStr.contains('impeller') ||
        stackStr.contains('swapchain') ||
        stackStr.contains('gpu_surface') ||
        stackStr.contains('image_decoder_impeller');

    // Check for image decoding errors that might be GPU-related
    final isImageDecodingError = errorStr.contains('invalid image data') ||
        errorStr.contains('image failed to precache') ||
        errorStr.contains('failed to submit image decoding');

    if (isGpuDeviceLost || (isImageDecodingError && _gpuDeviceLost)) {
      // Mark GPU as lost (this is idempotent, safe to call multiple times)
      if (!_gpuDeviceLost) {
        markGpuDeviceLost();
      }
      
      // Don't log these errors repeatedly to avoid spam (only log once per 10 seconds)
      if (_lastGpuErrorTime == null || 
          DateTime.now().difference(_lastGpuErrorTime!).inSeconds > 10) {
        // Use a microtask to avoid blocking the error handler thread
        Future.microtask(() {
          AppUtils.log('⚠️ GPU error detected: ${details.exception}');
        });
      }
      // Suppress the error to prevent cascade - don't call FlutterError.presentError
      return;
    }
    
    // For non-GPU errors, let Flutter handle them normally
    // But we still want to present them
  }

  /// Safe image precaching that checks GPU state first
  static Future<void> safePrecacheImage(
    ImageProvider provider,
    BuildContext context,
  ) async {
    if (instance._gpuDeviceLost) {
      AppUtils.log('⚠️ Skipping image precache - GPU device lost');
      return;
    }

    try {
      await precacheImage(provider, context);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid image data') ||
          errorStr.contains('gpu error') ||
          errorStr.contains('failed to submit') ||
          errorStr.contains('devicelost')) {
        instance.markGpuDeviceLost();
        AppUtils.log('⚠️ Image precache failed due to GPU error: $e');
      } else {
        // Re-throw non-GPU errors
        rethrow;
      }
    }
  }
}
