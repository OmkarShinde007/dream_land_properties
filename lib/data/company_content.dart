import '../models/app_models.dart';
import 'static/company_static_data.dart';

class CompanyContent {
  static CompanyProfile get _profile => CompanyStaticData.profile;

  static String get companyName => _profile.companyName;
  static String get companyTagline => _profile.companyTagline;
  static String get homeHeadline => _profile.homeHeadline;
  static String get about => _profile.about;
  static String get mission => _profile.mission;
  static String get vision => _profile.vision;
  static String get aboutExtended => _profile.aboutExtended;
  static String get phone => _profile.phone;
  static String get email => _profile.email;
  static String get office => _profile.office;
  static String get officeHours => _profile.officeHours;
  static String get addressLineOne => _profile.addressLineOne;
  static String get addressLineTwo => _profile.addressLineTwo;
  static String get mapCaption => _profile.mapCaption;
  static List<String> get stats => _profile.stats;
  static List<String> get services => _profile.services;
  static List<String> get userFeatures => _profile.userFeatures;
  static List<String> get buyerJourney => _profile.buyerJourney;
  static List<String> get trustPoints => _profile.trustPoints;
  static List<KeyFigure> get keyFigures => _profile.keyFigures;
  static List<String> get amenities => _profile.amenities;
  static List<String> get processHighlights => _profile.processHighlights;
  static List<String> get serviceAreas => _profile.serviceAreas;
  static List<String> get compliance => _profile.compliance;
  static List<CompanyMilestone> get timeline => _profile.timeline;
  static List<String> get galleryImages => _profile.galleryImages;
  static List<TestimonialItem> get testimonials => _profile.testimonials;
  static List<FaqItem> get faqs => _profile.faqs;
  static List<DirectorProfile> get directors => _profile.directors;
  static List<PropertyProject> get projects => _profile.projects;
}
