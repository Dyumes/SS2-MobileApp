// widgets/profile_edit_dialog.dart
import 'package:flutter/material.dart';

String? requiredValidator(String? value) {
  return (value == null || value.trim().isEmpty) ? 'Field required' : null;
}

class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
  });

  final String title;
  final List<Widget> fields;

  /// Doit lever une exception en cas d'échec (elle sera affichée à l'utilisateur).
  final Future<void> Function() onSave;

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _errorMessage = 'Error occured while saving : $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.fields,
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}