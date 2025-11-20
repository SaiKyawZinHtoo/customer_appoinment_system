import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customer_appointment_system/widget/app_text_field.dart';
import 'package:customer_appointment_system/widget/color.dart';
import 'package:url_launcher/url_launcher.dart';

/// A simple, responsive Contact Us screen with validation, optional
/// attachment (image), and a convenient "Send" action that opens the
/// user's mail client using a `mailto:` URI. The support email is
/// configurable in the `supportEmail` variable below.
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  XFile? _pickedImage;

  // Configure this to your support address.
  static const String supportEmail = 'support@example.com';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? f = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (f == null) {
        return;
      }
      setState(() => _pickedImage = f);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to pick image: $e')));
    }
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final messenger = ScaffoldMessenger.of(context);

    final subject = Uri.encodeComponent('App Contact: ${_nameController.text}');
    finalBuffer() {
      final buffer = StringBuffer();
      buffer.writeln('Name: ${_nameController.text}');
      buffer.writeln('Email: ${_emailController.text}');
      if (_phoneController.text.trim().isNotEmpty) {
        buffer.writeln('Phone: ${_phoneController.text}');
      }
      buffer.writeln('');
      buffer.writeln(_messageController.text.trim());
      buffer.writeln('');
      if (_pickedImage != null) {
        buffer.writeln(
          '(User attached an image — attach manually in your mail client)',
        );
      }
      return buffer.toString();
    }

    final body = Uri.encodeComponent(finalBuffer());
    final uri = Uri.parse('mailto:$supportEmail?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        messenger.showSnackBar(
          const SnackBar(content: Text('Opened mail app to send message')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('No mail applications available')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error opening mail app: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final useTwoColumn = screenWidth > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: useTwoColumn
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFields(context)),
                    const SizedBox(width: 20),
                    SizedBox(width: 320, child: _buildAttachmentCard(theme)),
                  ],
                )
              : Column(
                  children: [
                    _buildFields(context),
                    const SizedBox(height: 16),
                    _buildAttachmentCard(theme),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _send,
                child: const Text(
                  'Send Message',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _nameController,
          label: 'Your Name',
          hintText: 'Full name',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          leadingIcon: const Icon(Icons.person),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _emailController,
          label: 'Email',
          hintText: 'you@domain.com',
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Please enter an email';
            }
            final text = v.trim();
            if (!text.contains('@') || !text.contains('.')) {
              return 'Enter a valid email';
            }
            return null;
          },
          leadingIcon: const Icon(Icons.email),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _phoneController,
          label: 'Phone (optional)',
          hintText: '0912 345 678',
          keyboardType: TextInputType.phone,
          leadingIcon: const Icon(Icons.phone),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        Text('Message', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          minLines: 5,
          maxLines: 8,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter a message' : null,
          decoration: InputDecoration(
            hintText: 'How can we help?',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Attachment', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Attach a screenshot or photo (optional). Note: will not be attached automatically to mailto; include manually if required.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (_pickedImage != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_pickedImage!.path),
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _pickedImage = null),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text('Remove'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
