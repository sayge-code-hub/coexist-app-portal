import 'package:coexist_app_portal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coexist_app_portal/features/auth/presentation/bloc/auth_state.dart';
import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool isEventAdmin(BuildContext context, EventModel? event) {
  if (event == null) return false;
  final authState = context.read<AuthBloc>().state;
  return authState is Authenticated && authState.userProfile?.role == 'admin';
}
