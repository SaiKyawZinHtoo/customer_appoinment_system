import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:customer_appointment_system/widget/app_text_field.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';
import 'package:customer_appointment_system/widget/color.dart';
// Colors and theme values are provided from `lib/widget/color.dart` via ThemeData

class CustomerInformationScreen extends StatefulWidget {
  /// Optionally pass an initial appointment date (e.g. when opening from
  /// the calendar FAB for a selected date).
  const CustomerInformationScreen({super.key, this.initialAppointmentDate});

  final DateTime? initialAppointmentDate;

  @override
  State<CustomerInformationScreen> createState() =>
      _CustomerInformationScreenState();
}

class _CustomerInformationScreenState extends State<CustomerInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Male';
  DateTime? _dob;
  DateTime? _appointmentDate;

  // Controllers for the fields — using controllers avoids building new
  // TextEditingController instances multiple times and provides a consistent
  // API for clearing, updating and extracting values on save.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _appointmentController = TextEditingController();
  XFile? _pickedImage;

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initial,
    ValueChanged<DateTime> onSelected, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? today,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(today.year + 5),
      builder: (ctx, child) {
        // Use current theme values for date picker so it aligns with the theme
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: Theme.of(ctx).colorScheme.primary,
              onPrimary: Theme.of(ctx).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onSelected(picked);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    _appointmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // If the screen was opened with an initial appointment date, set it.
    if (widget.initialAppointmentDate != null) {
      _appointmentDate = widget.initialAppointmentDate;
      _appointmentController.text = _formatDateDisplay(_appointmentDate);
    }
    // Update the UI when controllers change so clear/suffix buttons update
    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _locationController.addListener(() => setState(() {}));
    _dobController.addListener(() => setState(() {}));
    _appointmentController.addListener(() => setState(() {}));
  }

  bool get _canSave {
    // Require a non-empty name and phone and a selected appointment date
    final nameOk = _nameController.text.trim().isNotEmpty;
    final phoneOk = _phoneController.text.trim().isNotEmpty;
    final appointmentOk = _appointmentController.text.trim().isNotEmpty;
    return nameOk && phoneOk && appointmentOk;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    // Persist: create a full Customer record and add to repository.
    if (_appointmentDate == null) return;
    final customer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      gender: _gender,
      dob: _dob,
      appointmentDate: _appointmentDate!,
      photoPath: _pickedImage?.path,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    );
    AppointmentRepository.instance.addCustomer(customer);
    // Return the created customer to the caller (calendar will update via repo)
    Navigator.of(context).pop(customer);
  }

  Future<void> _pickImageFrom(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return; // user canceled
      setState(() => _pickedImage = file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to pick image: $e')));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImageFrom(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImageFrom(ImageSource.gallery);
              },
            ),
            if (_pickedImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  setState(() => _pickedImage = null);
                  Navigator.of(ctx).pop();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool useTwoColumn = screenWidth > 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Navigator.canPop(context) ? null : const SizedBox.shrink(),
        elevation: 2,
        centerTitle: true,
        title: Text(
          'Customer Information',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            children: [
              useTwoColumn
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFields(context, theme)),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 260,
                          child: _buildPhotoBox(context, theme),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFields(context, theme),
                        const SizedBox(height: 16),
                        _buildPhotoBox(context, theme),
                      ],
                    ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.disabled)) {
                                return AppColors.accent.withAlpha(
                                  (0.28 * 255).round(),
                                );
                              }
                              return AppColors.accent;
                            }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.white.withAlpha(
                                  (0.7 * 255).round(),
                                );
                              }
                              return Colors.white;
                            }),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      onPressed: _canSave ? _save : null,
                      child: const Text('Add', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format a date as 'D Mon YYYY' (e.g. '20 Nov 2025').
  String _formatDateDisplay(DateTime? d) {
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = d.day;
    final monthName = months[d.month - 1];
    final year = d.year;
    return '$day $monthName $year';
  }

  Widget _buildFields(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        // Use our shared AppTextField for consistent styling
        AppTextField(
          controller: _nameController,
          label: 'Name',
          hintText: 'Enter customer name',
          onSaved: (v) => _nameController.text = v ?? '',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Please enter a name' : null,
          leadingIcon: const Icon(Icons.person),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          suffix: _nameController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _nameController.clear()),
                )
              : null,
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 6),
        AppTextField(
          controller: _phoneController,
          label: 'Phone',
          hintText: 'Enter phone number',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          maxLength: 20,
          leadingIcon: const Icon(Icons.phone),
          suffix: _phoneController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _phoneController.clear()),
                )
              : null,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _locationController,
          label: 'Location',
          hintText: 'Enter location or address',
          leadingIcon: const Icon(Icons.location_on),
          textInputAction: TextInputAction.next,
          maxLength: 120,
          suffix: _locationController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _locationController.clear()),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text('Gender', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Male', label: Text('Male')),
            ButtonSegment(value: 'Female', label: Text('Female')),
          ],
          selected: <String>{_gender},
          onSelectionChanged: (newSelection) =>
              setState(() => _gender = newSelection.first),
          multiSelectionEnabled: false,
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(
            context,
            _dob,
            (d) => setState(() {
              _dob = d;
              _dobController.text = _formatDateDisplay(d);
            }),
          ),
          child: AbsorbPointer(
            child: AppTextField(
              controller: _dobController,
              label: 'Date of Birth',
              hintText: 'Select date of birth',
              readOnly: true,
              leadingIcon: const Icon(Icons.cake),
              textInputAction: TextInputAction.next,
              suffix: _dobController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _dob = null;
                        _dobController.clear();
                      }),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            final today = DateTime.now();
            _pickDate(
              context,
              (_appointmentDate != null && !_appointmentDate!.isBefore(today))
                  ? _appointmentDate
                  : today,
              (d) => setState(() {
                _appointmentDate = d;
                _appointmentController.text = _formatDateDisplay(d);
              }),
              firstDate: DateTime(today.year, today.month, today.day),
            );
          },
          child: AbsorbPointer(
            child: AppTextField(
              controller: _appointmentController,
              label: 'Appointment Date',
              hintText: 'Select appointment date',
              readOnly: true,
              leadingIcon: const Icon(Icons.calendar_today),
              textInputAction: TextInputAction.done,
              suffix: _appointmentController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _appointmentDate = null;
                        _appointmentController.clear();
                      }),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // Gender selection implemented with SegmentedButton in build (no helper needed)

  Widget _buildPhotoBox(BuildContext context, ThemeData theme) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: _showImagePickerOptions,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // If user has selected an image, show it; otherwise show camera UI
            if (_pickedImage != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          File(_pickedImage!.path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            onPressed: () =>
                                setState(() => _pickedImage = null),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Icon(
                Icons.camera_alt,
                size: 42,
                color: theme.colorScheme.onSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                '+',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontSize: 28,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
