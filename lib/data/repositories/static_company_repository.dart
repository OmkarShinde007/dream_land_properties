import '../../models/app_models.dart';
import '../static/company_static_data.dart';
import 'company_repository.dart';

class StaticCompanyRepository implements CompanyRepository {
  const StaticCompanyRepository();

  @override
  CompanyProfile getCompanyProfile() {
    return CompanyStaticData.profile;
  }
}
