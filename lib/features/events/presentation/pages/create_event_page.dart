// import 'package:coexist_app_portal/core/common_widgets/app_button.dart';
// import 'package:coexist_app_portal/core/common_widgets/app_text_field.dart';
// import 'package:coexist_app_portal/core/theme/app_colors.dart';
// import 'package:coexist_app_portal/core/theme/app_text_styles.dart';
// import 'package:coexist_app_portal/core/utils/app_router.dart';
// import 'package:coexist_app_portal/core/utils/validators.dart';
// import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
// import 'package:coexist_app_portal/features/events/presentation/bloc/event_bloc.dart';
// import 'package:coexist_app_portal/features/events/presentation/bloc/event_event.dart';
// import 'package:coexist_app_portal/features/events/presentation/bloc/event_state.dart';
// import 'package:coexist_app_portal/features/events/presentation/widgets/web_form_section.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// class CreateEventPage extends StatefulWidget {
//   const CreateEventPage({super.key});

//   @override
//   State<CreateEventPage> createState() => _CreateEventPageState();
// }

// class _CreateEventPageState extends State<CreateEventPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _organizerController = TextEditingController();
//   final _organizerEmailController = TextEditingController();
//   final _organizerPhoneController = TextEditingController();
//   final _imageUrlController = TextEditingController();
//   final _priceController = TextEditingController();

//   DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
//   TimeOfDay _selectedTime = TimeOfDay.now();

//   bool _isCreating = false;
//   bool _isPaid = false;

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _locationController.dispose();
//     _organizerController.dispose();
//     _organizerEmailController.dispose();
//     _organizerPhoneController.dispose();
//     _imageUrlController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primaryGreen,
//               onPrimary: Colors.white,
//               onSurface: AppColors.neutralDarkerGrey,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = DateTime(
//           picked.year,
//           picked.month,
//           picked.day,
//           _selectedTime.hour,
//           _selectedTime.minute,
//         );
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primaryGreen,
//               onPrimary: Colors.white,
//               onSurface: AppColors.neutralDarkerGrey,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//         _selectedDate = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           _selectedTime.hour,
//           _selectedTime.minute,
//         );
//       });
//     }
//   }

//   void _createEvent() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isCreating = true;
//       });

//       // Parse price if event is paid
//       double? price;
//       if (_isPaid && _priceController.text.isNotEmpty) {
//         price = double.tryParse(_priceController.text.trim());
//         if (price == null) {
//           setState(() {
//             _isCreating = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Please enter a valid price'),
//               backgroundColor: AppColors.error,
//             ),
//           );
//           return;
//         }
//       }

//       // Create event model
//       final event = EventModel(
//         id: '', // Will be generated by Supabase
//         title: _titleController.text.trim(),
//         description: _descriptionController.text.trim(),
//         date: _selectedDate,
//         location: _locationController.text.trim(),
//         organizer: _organizerController.text.trim(),
//         organizerEmail: _organizerEmailController.text.trim(),
//         organizerPhone: _organizerPhoneController.text.trim(),
//         imageUrl: _imageUrlController.text.trim(),
//         category: 'Event', // Default category
//         createdBy: '', // Will be set by repository
//         createdAt: DateTime.now(),
//         status: 'Needs Approval', // All new events need approval
//         isPaid: _isPaid,
//         price: price,
//       );

//       // Create event
//       // context.read<EventBloc>().add(CreateEventEvent(event: event, imageData: _eventImageBytes));
//     } else {
//       // Show error message if validation fails
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill in all required fields correctly'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<EventBloc, EventState>(
//       listener: (context, state) {
//         if (state is EventCreated) {
//           setState(() {
//             _isCreating = false;
//           });

//           // Show success message with approval notice
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 'Event submitted successfully and is pending approval',
//               ),
//               backgroundColor: AppColors.success,
//             ),
//           );

//           // Navigate back to events page
//           Navigator.of(context).pushNamed(AppRoutes.events);
//         } else if (state is EventError) {
//           setState(() {
//             _isCreating = false;
//           });

//           // Show error message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               backgroundColor: AppColors.error,
//             ),
//           );
//         }
//       },
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           // Use LayoutBuilder to determine wide layout (desktop/web) vs narrow (mobile)

//           return Scaffold(
//             body: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: CreateEventForm(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
