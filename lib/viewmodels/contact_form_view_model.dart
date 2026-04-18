import 'package:flutter/material.dart';

class ContactFormViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool submit() {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return false;
    }

    nameController.clear();
    phoneController.clear();
    emailController.clear();
    projectController.clear();
    messageController.clear();
    notifyListeners();
    return true;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.trim().length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateProject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the project you are interested in';
    }
    return null;
  }

  String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your message';
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    projectController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
