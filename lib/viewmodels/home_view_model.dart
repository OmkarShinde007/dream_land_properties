import 'package:flutter/material.dart';

import '../data/repositories/company_repository.dart';
import '../models/app_models.dart';
import 'contact_form_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required CompanyRepository repository,
    ContactFormViewModel? contactFormViewModel,
  })  : _repository = repository,
        contactFormViewModel =
            contactFormViewModel ?? ContactFormViewModel();

  final CompanyRepository _repository;
  final ContactFormViewModel contactFormViewModel;

  AppSection _selectedSection = AppSection.home;
  ProjectStatus? _selectedStatus;

  CompanyProfile get profile => _repository.getCompanyProfile();
  AppSection get selectedSection => _selectedSection;
  ProjectStatus? get selectedStatus => _selectedStatus;

  List<PropertyProject> get visibleProjects {
    if (_selectedStatus == null) {
      return profile.projects;
    }

    return profile.projects
        .where((PropertyProject project) => project.status == _selectedStatus)
        .toList();
  }

  PropertyProject get featuredProject => profile.projects.first;

  void selectSection(AppSection section) {
    _selectedSection = section;
    notifyListeners();
  }

  void selectProjectStatus(ProjectStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  bool submitEnquiry() {
    return contactFormViewModel.submit();
  }

  @override
  void dispose() {
    contactFormViewModel.dispose();
    super.dispose();
  }
}
