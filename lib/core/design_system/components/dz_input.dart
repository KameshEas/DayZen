import 'package:flutter/material.dart';
import '../tokens/dz_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzTextField
// ─────────────────────────────────────────────────────────────────────────────

/// A styled text input field following the DayZen Design System.
///
/// ```dart
/// DzTextField(label: 'Task name', hint: 'Enter task...')
/// ```
class DzTextField extends StatelessWidget {
  const DzTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      style: DzTextStyles.body.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzSearchField
// ─────────────────────────────────────────────────────────────────────────────

/// A pre-styled search input with a leading search icon.
class DzSearchField extends StatelessWidget {
  const DzSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DzTextField(
      controller: controller,
      hint: hint,
      prefixIcon: const Icon(Icons.search_rounded, size: 20),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzFormField
// ─────────────────────────────────────────────────────────────────────────────

/// A [TextFormField] variant, compatible with [Form] widgets.
class DzFormField extends StatelessWidget {
  const DzFormField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.initialValue,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool enabled;
  final bool autofocus;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      autofocus: autofocus,
      style: DzTextStyles.body.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
