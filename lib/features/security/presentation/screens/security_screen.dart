import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/pdf_picker.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/result_success_sheet.dart';
import '../../../files/presentation/providers/files_providers.dart';
import '../../../files/presentation/widgets/pdf_thumbnail.dart';
import '../providers/security_providers.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _sourcePath;
  bool _isWorking = false;
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _sourcePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Protect'),
        actions: [
          if (path != null && !_isWorking)
            TextButton(onPressed: _pickFile, child: const Text('Change')),
        ],
      ),
      body: path == null ? _buildPicker() : _buildEditor(path),
    );
  }

  Widget _buildPicker() {
    return EmptyState(
      icon: Icons.lock_rounded,
      title: 'Choose a PDF',
      message: 'Add a password to protect a PDF, or remove one you already know.',
      action: FilledButton.icon(
        onPressed: _pickFile,
        icon: const Icon(Icons.folder_open_rounded),
        label: const Text('Select PDF'),
      ),
    );
  }

  Widget _buildEditor(String path) {
    final asyncEncrypted = ref.watch(isPdfEncryptedProvider(path));

    return asyncEncrypted.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorView(
        message: 'Could not read this PDF.',
        onRetry: () => ref.invalidate(isPdfEncryptedProvider(path)),
      ),
      data: (isEncrypted) => Column(
        children: [
          if (_isWorking) const LinearProgressIndicator(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                _buildSourceCard(path, isEncrypted),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  isEncrypted ? 'Remove password' : 'Add password',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isEncrypted
                      ? 'Enter the current password to save an unlocked copy.'
                      : 'Your original file stays unchanged — a protected copy is saved.',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  enabled: !_isWorking,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: isEncrypted ? 'Current password' : 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (!isEncrypted) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscure,
                    enabled: !_isWorking,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      errorText: _confirmError,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildBottomBar(path, isEncrypted),
        ],
      ),
    );
  }

  String? get _confirmError {
    if (_confirmController.text.isEmpty) return null;
    if (_confirmController.text == _passwordController.text) return null;
    return 'Passwords do not match';
  }

  bool get _canSubmitProtect {
    final password = _passwordController.text;
    return password.isNotEmpty && password == _confirmController.text;
  }

  Widget _buildSourceCard(String path, bool isEncrypted) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          PdfThumbnail(path: path, width: 44, height: 56),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.basename(path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall,
                ),
                Row(
                  children: [
                    Icon(
                      isEncrypted ? Icons.lock_rounded : Icons.lock_open_rounded,
                      size: 14,
                      color: isEncrypted
                          ? context.colorScheme.error
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEncrypted ? 'Password protected' : 'Not protected',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String path, bool isEncrypted) {
    final enabled = !_isWorking &&
        (isEncrypted ? _passwordController.text.isNotEmpty : _canSubmitProtect);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: enabled ? () => _submit(path, isEncrypted) : null,
            icon: Icon(isEncrypted ? Icons.lock_open_rounded : Icons.lock_rounded),
            label: Text(
              _isWorking
                  ? 'Working…'
                  : isEncrypted
                      ? 'Remove password'
                      : 'Protect PDF',
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final path = await PdfPicker.pickSingle();
    if (path == null) return;
    setState(() {
      _sourcePath = path;
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  Future<void> _submit(String path, bool isEncrypted) async {
    setState(() => _isWorking = true);

    final password = _passwordController.text;
    final result = isEncrypted
        ? await ref
            .read(removePdfPasswordUseCaseProvider)
            .call(sourcePath: path, password: password)
        : await ref.read(protectPdfUseCaseProvider).call(sourcePath: path, password: password);

    if (!mounted) return;
    setState(() => _isWorking = false);

    result.fold(
      (savedPath) {
        invalidateFilesProviders(ref);
        _passwordController.clear();
        _confirmController.clear();
        showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => ResultSuccessSheet(
            filePaths: [savedPath],
            title: isEncrypted ? 'Password removed' : 'PDF protected',
          ),
        );
      },
      (failure) => context.showSnackBar(failure.message, isError: true),
    );
  }
}
