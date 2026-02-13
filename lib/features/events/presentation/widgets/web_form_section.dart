import 'dart:convert';
import 'dart:typed_data';

import 'package:coexist_app_portal/core/common_widgets/app_button.dart';
import 'package:coexist_app_portal/core/common_widgets/app_text_field.dart';
import 'package:coexist_app_portal/core/theme/app_colors.dart';
import 'package:coexist_app_portal/core/theme/app_text_styles.dart';
import 'package:coexist_app_portal/core/utils/app_router.dart';
import 'package:coexist_app_portal/core/utils/validators.dart';
import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_bloc.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_event.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateEventForm extends StatefulWidget {
  final String? eventId;

  const CreateEventForm({super.key, this.eventId});

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  Uint8List _eventImageBytes = Uint8List(0);

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();
  final _organizerEmailController = TextEditingController();
  final _organizerPhoneController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isPaid = false;
  bool _isCreating = false;
  bool _isEditMode = false;
  String? _originalCreatedBy; // Store original created_by for edit mode

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.eventId != null;

    if (_isEditMode) {
      // Load existing event data for editing
      _loadEventData();
    }
  }

  void _loadEventData() {
    // For now, we'll need to fetch the event data
    // In a real implementation, you might want to pass the event data directly
    // or fetch it using the eventId
    context.read<EventBloc>().add(const FetchEventsEvent());
  }

  void _populateFormFields(EventModel event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _organizerController.text = event.organizer;
    _organizerEmailController.text = event.organizerEmail;
    _organizerPhoneController.text = event.organizerPhone;
    _imageUrlController.text = event.imageUrl;
    _priceController.text = event.price?.toString() ?? '';
    _selectedDate = event.date;
    _selectedEndDate = event.endDate ?? event.date;
    _selectedTime = TimeOfDay.fromDateTime(event.date);
    _isPaid = event.isPaid;
    _originalCreatedBy = event.createdBy; // Store original created_by
  }

  // Pickers
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate.isBefore(now)
        ? now
        : _selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now, // Always restrict to future dates
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Update end date to match start date
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime initialDate = _selectedEndDate.isBefore(_selectedDate)
        ? _selectedDate.add(const Duration(days: 1))
        : _selectedEndDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _selectedDate, // End date must be after start date
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() => _selectedEndDate = picked);
    }
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreating = true;
      });

      // Debug: Check if we have the event ID in edit mode
      if (_isEditMode) {
        print('🔍 EDIT MODE: Event ID = ${widget.eventId}');
        if (widget.eventId == null || widget.eventId!.isEmpty) {
          setState(() {
            _isCreating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event ID is missing. Cannot update event.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      // Create event model
      final event = EventModel(
        id: _isEditMode ? widget.eventId! : '', // Use existing ID for edit mode
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        endDate: _selectedEndDate,
        location: _locationController.text.trim(),
        organizer: _organizerController.text.trim(),
        organizerEmail: _organizerEmailController.text.trim(),
        organizerPhone: _organizerPhoneController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        category: 'Environment', // Default category
        createdBy: _isEditMode
            ? (_originalCreatedBy ?? '')
            : 'current_user', // Preserve original in edit mode
        createdAt: DateTime.now(),
        status: 'Needs Approval', // All new events need approval
        isPaid: _isPaid,
        price: _priceController.text.isNotEmpty
            ? double.parse(_priceController.text.trim())
            : 0,
        isBanner: false,
      );

      print('🔍 EVENT MODEL: ID = ${event.id}, Title = ${event.title}');
      print('event data ${jsonEncode(event.toSupabase())}');
      print('time: ${_selectedTime.hour}:${_selectedTime.minute}');
      if (_isEditMode) {
        // Update existing event
        context.read<EventBloc>().add(
          UpdateEventEvent(
            event: event,
            imageData: _imageUrlController.text == "Image selected"
                ? _eventImageBytes
                : null,
          ),
        );
      } else {
        // Create new event
        context.read<EventBloc>().add(
          CreateEventEvent(event: event, imageData: _eventImageBytes),
        );
      }
    } else {
      // Show error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> pickEventImage(BuildContext context) async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _eventImageBytes = bytes;
      _imageUrlController.text = "Image selected"; // Just a placeholder text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreated || state is EventUpdated) {
            setState(() {
              _isCreating = false;
            });

            // Navigate back to dashboard
            context.go(AppRoutes.dashboard);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Event updated successfully!'
                      : 'Event submitted successfully and is pending approval',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is EventError) {
            setState(() {
              _isCreating = false;
            });

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is EventsLoaded && _isEditMode) {
            // Find and populate the event data for editing
            try {
              final event = state.events.firstWhere(
                (e) => e.id == widget.eventId,
              );
              // Use addPostFrameCallback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _populateFormFields(event);
                  });
                }
              });
            } catch (e) {
              // Event not found, show error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event not found'),
                  backgroundColor: AppColors.error,
                ),
              );
              context.pop();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? 'Edit Event' : 'Create New Event',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditMode
                          ? 'Update the details of your community event'
                          : 'Fill in the details to create a new community event',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutralDarkerGrey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildEventDetailsCard(context),
                    const SizedBox(height: 15),

                    _buildOrganizerInfoCard(),
                    const SizedBox(height: 15),

                    _buildEventSettingsCard(context),
                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 350,
                        height: 50,
                        child: AppButton(
                          text: _isEditMode ? 'Update Event' : 'Create Event',
                          onPressed: _isCreating ? null : _createEvent,
                          isLoading: _isCreating,
                          type: ButtonType.primary,
                          size: ButtonSize.large,
                          icon: _isEditMode
                              ? Icons.edit
                              : Icons.add_circle_outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Section 1: Event Details ---
  Widget _buildEventDetailsCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event Details', style: AppTextStyles.h3),
                const SizedBox(height: 20),

                // Title + Location (side by side on wide screens)
                isWide
                    ? Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Event Title',
                              controller: _titleController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an event title';
                                }
                                if (value.length < 3) {
                                  return 'Title must be at least 3 characters long';
                                }
                                if (value.length > 100) {
                                  return 'Title must be less than 100 characters';
                                }
                                return null;
                              },
                              enabled: !_isCreating,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Location',
                              controller: _locationController,
                              validator: Validators.validateRequired,
                              enabled: !_isCreating,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          AppTextField(
                            label: 'Event Title',
                            controller: _titleController,
                            validator: Validators.validateRequired,
                            enabled: !_isCreating,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Location',
                            controller: _locationController,
                            validator: Validators.validateRequired,
                            enabled: !_isCreating,
                          ),
                        ],
                      ),
                const SizedBox(height: 16),

                // Description
                AppTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event description';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters long';
                    }
                    return null;
                  },
                  enabled: !_isCreating,
                ),
                const SizedBox(height: 16),

                // Date + End Date + Time
                isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildDatePicker(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildEndDatePicker(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTimePicker(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildDatePicker(context),
                          const SizedBox(height: 16),
                          _buildEndDatePicker(context),
                          const SizedBox(height: 16),
                          _buildTimePicker(context),
                        ],
                      ),

                const SizedBox(height: 16),
                AppTextField(
                  label: 'Image (optional)',
                  enabled: !_isCreating,
                  controller: _imageUrlController,
                  onTap: () => pickEventImage(context),
                  readOnly: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Section 2: Organizer Info ---
  Widget _buildOrganizerInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Organizer Information', style: AppTextStyles.h3),
                const SizedBox(height: 20),
                isWide
                    ? Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Organizer Name',
                              controller: _organizerController,
                              validator: Validators.validateRequired,
                              enabled: !_isCreating,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Organizer Email',
                              controller: _organizerEmailController,
                              validator: Validators.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_isCreating,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          AppTextField(
                            label: 'Organizer Name',
                            controller: _organizerController,
                            validator: Validators.validateRequired,
                            enabled: !_isCreating,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Organizer Email',
                            controller: _organizerEmailController,
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isCreating,
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Organizer Contact Number',
                  controller: _organizerPhoneController,
                  validator: Validators.validatePhone,
                  keyboardType: TextInputType.phone,
                  enabled: !_isCreating,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Section 3: Event Settings ---
  Widget _buildEventSettingsCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Settings', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Event Type:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _isPaid,
                        onChanged: _isCreating
                            ? null
                            : (value) => setState(() => _isPaid = value!),
                        activeColor: AppColors.primaryGreen,
                      ),
                      const Text('Free'),
                      const SizedBox(width: 16),
                      Radio<bool>(
                        value: true,
                        groupValue: _isPaid,
                        onChanged: _isCreating
                            ? null
                            : (value) => setState(() => _isPaid = value!),
                        activeColor: AppColors.primaryGreen,
                      ),
                      const Text('Paid'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isPaid)
              AppTextField(
                label: 'Price',
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixText: '₹ ',
                validator: (value) {
                  if (_isPaid) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                  }
                  return null;
                },
                enabled: !_isCreating,
              ),
          ],
        ),
      ),
    );
  }

  // --- Date & Time Fields ---
  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Start Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(_selectedDate),
              style: AppTextStyles.bodyMedium,
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedTime.format(context),
              style: AppTextStyles.bodyMedium,
            ),
            const Icon(Icons.access_time, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEndDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectEndDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'End Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(_selectedEndDate),
              style: AppTextStyles.bodyMedium,
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
