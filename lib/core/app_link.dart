// lib/core/app_link.dart
class AppLink {
  // عنوان السيرفر
  static const String server = "https://handasiasw.com/ms_company_api";

  // رفع الفيديو
  static const String uploadVideo = "$server/upload_video.php";

  // الحصول على الفيديوهات كلها
  static const String getAllVideos = "$server/get_all_videos.php";

  // الحصول على الفيديو الحالي فقط
  static const String getCurrentVideo = "$server/get_current_video.php";

  // تعيين فيديو كالفيديو المعروض
  static const String setCurrentVideo = "$server/set_current_video.php";

  // تسجيل الدخول كأدمن
  static const String adminLogin = "$server/login.php";

  static const String cachedVideoName = "$server/cached_video_name.php";

  // 🚍 روابط إدارة الأتوبيسات
  static const String checkBusNumber = "$server/check_bus_number.php";
  static const String updateBusStatus = "$server/update_bus_status.php";
  static const String getAllBuses = "$server/get_all_buses.php";
  static const String enterBusesCode = "$server/get_all_buses.php";
  static const String logo = "$server/logo.jpg";


}
