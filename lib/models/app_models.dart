enum AppSection { home, about, projects, contact }

enum ProjectStatus { upcoming, completed, pending }

class CompanyMilestone {
  const CompanyMilestone({
    required this.year,
    required this.title,
    required this.description,
  });

  final String year;
  final String title;
  final String description;
}

class KeyFigure {
  const KeyFigure({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class TestimonialItem {
  const TestimonialItem({
    required this.name,
    required this.role,
    required this.message,
  });

  final String name;
  final String role;
  final String message;
}

class FaqItem {
  const FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class DirectorProfile {
  const DirectorProfile({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.bio,
    required this.details,
  });

  final String name;
  final String role;
  final String imageUrl;
  final String bio;
  final List<String> details;
}

class PropertyProject {
  const PropertyProject({
    required this.name,
    required this.location,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.progressLabel,
    required this.units,
    required this.deliveryWindow,
    required this.highlights,
  });

  final String name;
  final String location;
  final ProjectStatus status;
  final String imageUrl;
  final String description;
  final String progressLabel;
  final int units;
  final String deliveryWindow;
  final List<String> highlights;
}

class CompanyProfile {
  const CompanyProfile({
    required this.companyName,
    required this.companyTagline,
    required this.homeHeadline,
    required this.about,
    required this.mission,
    required this.vision,
    required this.aboutExtended,
    required this.phone,
    required this.email,
    required this.office,
    required this.officeHours,
    required this.addressLineOne,
    required this.addressLineTwo,
    required this.mapCaption,
    required this.stats,
    required this.services,
    required this.userFeatures,
    required this.buyerJourney,
    required this.trustPoints,
    required this.keyFigures,
    required this.amenities,
    required this.processHighlights,
    required this.serviceAreas,
    required this.compliance,
    required this.timeline,
    required this.galleryImages,
    required this.testimonials,
    required this.faqs,
    required this.directors,
    required this.projects,
  });

  final String companyName;
  final String companyTagline;
  final String homeHeadline;
  final String about;
  final String mission;
  final String vision;
  final String aboutExtended;
  final String phone;
  final String email;
  final String office;
  final String officeHours;
  final String addressLineOne;
  final String addressLineTwo;
  final String mapCaption;
  final List<String> stats;
  final List<String> services;
  final List<String> userFeatures;
  final List<String> buyerJourney;
  final List<String> trustPoints;
  final List<KeyFigure> keyFigures;
  final List<String> amenities;
  final List<String> processHighlights;
  final List<String> serviceAreas;
  final List<String> compliance;
  final List<CompanyMilestone> timeline;
  final List<String> galleryImages;
  final List<TestimonialItem> testimonials;
  final List<FaqItem> faqs;
  final List<DirectorProfile> directors;
  final List<PropertyProject> projects;
}
