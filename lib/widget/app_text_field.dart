import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable AppTextField to provide consistent styling and behavior across the app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.inputFormatters,
    this.filled = true,
    this.leadingIcon,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.maxLength,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final bool filled;
  final Widget? leadingIcon;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      onSaved: onSaved,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: filled,
        fillColor: theme.colorScheme.surface,
        prefixIcon: leadingIcon,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }
}
