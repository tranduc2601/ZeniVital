// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Trenx';

  @override
  String get slideOne => 'Trang 1';

  @override
  String get slideTwo => 'Trang 2';

  @override
  String get slideThree => 'Trang 3';

  @override
  String get getStarted => 'Bắt đầu';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get goToRegister => 'Đăng ký';

  @override
  String get invalidCredentials => 'Thông tin đăng nhập không hợp lệ';

  @override
  String get name => 'Họ và tên';

  @override
  String get register => 'Đăng ký';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get nameRequired => 'Vui lòng nhập họ và tên';

  @override
  String get invalidEmailFormat => 'Định dạng email không hợp lệ';

  @override
  String get passwordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get searchExercises => 'Tìm kiếm bài tập';

  @override
  String get noExercisesFound => 'Không tìm thấy bài tập';

  @override
  String get socialFeed => 'Bảng tin';

  @override
  String get userProfile => 'Hồ sơ';

  @override
  String get likedTab => 'Đã thích';

  @override
  String get settings => 'Cài đặt';

  @override
  String get tabDashboard => 'Trang chủ';

  @override
  String get tabExplore => 'Khám phá';

  @override
  String get tabFeed => 'Bảng tin';

  @override
  String get tabProfile => 'Hồ sơ';

  @override
  String get like => 'Thích';

  @override
  String get back => 'Quay lại';

  @override
  String get startWorkout => 'Bắt đầu tập';

  @override
  String exerciseSet(int index) {
    return 'Hiệp $index';
  }

  @override
  String get next => 'Tiếp theo';

  @override
  String get finish => 'Hoàn thành';

  @override
  String get closeSummary => 'Đóng kết quả';

  @override
  String get selectGoal => 'Chọn mục tiêu';

  @override
  String get goalWeightLoss => 'Giảm cân';

  @override
  String get goalConditioning => 'Thể lực tổng thể';

  @override
  String get goalBodybuilding => 'Thể hình nâng cao';

  @override
  String get save => 'Lưu';

  @override
  String get logout => 'Đăng xuất';

  @override
  String unlike(String exercise) {
    return 'Bỏ thích $exercise';
  }

  @override
  String currentPlan(String goal) {
    return 'Kế hoạch $goal';
  }

  @override
  String get workoutOne => 'Buổi tập 1';
}
