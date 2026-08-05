import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionResult { granted, denied, permanentlyDenied }

/// Wraps `permission_handler` so features ask for permissions through one
/// place with a consistent result type, instead of every screen importing
/// the plugin directly and re-deriving denied/permanently-denied handling.
class PermissionService {
  const PermissionService();

  Future<AppPermissionResult> requestCamera() => _request(Permission.camera);

  /// Photo/media access for picking images (Android 13+ uses the granular
  /// `photos` permission; older Android falls back to `storage`).
  Future<AppPermissionResult> requestPhotos() async {
    final sdkPermission = Permission.photos;
    final result = await _request(sdkPermission);
    if (result != AppPermissionResult.denied) return result;
    return _request(Permission.storage);
  }

  /// Broad storage access so the File Manager feature can list PDFs across
  /// the device, not just files the app itself created. Falls back to a
  /// scoped SAF directory pick (handled by the caller) if declined.
  Future<AppPermissionResult> requestManageExternalStorage() =>
      _request(Permission.manageExternalStorage);

  Future<bool> openSettings() => openAppSettings();

  Future<AppPermissionResult> _request(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted || status.isLimited) return AppPermissionResult.granted;
    if (status.isPermanentlyDenied) return AppPermissionResult.permanentlyDenied;
    return AppPermissionResult.denied;
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionService();
});
