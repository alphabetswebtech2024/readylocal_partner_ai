import 'package:flutter/material.dart';
import '../models/User.dart';
import 'package:gotask_partner/core/design/app_colors.dart';

/// Centralized in-memory session and app-wide state.
/// This decouples global variables from `main.dart`.
class AppSession {
  AppSession._();

  static String userId = '';
  static String userFirstName = '';
  static String userLastName = '';
  static String userEmail = '';
  static String userPhone = '';
  static User? user;

  static String deviceName = '';
  static String dtz = '';
  static String globalLocaleString = '';
  static int totalNotificationsCount = 0;
  static String csrfToken = '';
  static String setCookie = '';
  static Map selectedCouponCode = {};

  static bool isLoginSeen = false;

  static bool isShowAddressScreenFromLogin = true;

  static String categoryId = '';
  static String categoryName = '';
  static String subCategoryId = '';
  static String subCategoryName = '';
  static String currentLocation = '';
  static String? postalCode = '';
  static String isGuestUser = '';

  static DateTime selectedDate = DateTime.now();
  static String? selectedSlot = '';

  static bool isNotificationHandled = false;
  static String rzpKey = 'rzp_live_TicOTFFn5T0Oxb';

  static Map<String, dynamic>? pendingNotificationData;

  /// Global navigator key for navigation/overlays where context is not immediately available.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Global context helper from navigatorKey
  static BuildContext? get context => navigatorKey.currentContext;

  /// Brand colors
  /// True when the partner tapped Register on the Welcome screen. Used only to
  /// tell an existing partner they already have an account after OTP.
  static bool registerIntent = false;

  static const Color mainColor = AppColors.primary;
  static const Color bgColor = Color(0xFFFFFFFF);

  /// Synchronize session variables from a loaded User model.
  static void setUser(User? newUser) {
    user = newUser;
    if (newUser != null) {
      userId = newUser.id.toString();
      userFirstName = newUser.FirstName;
      userLastName = newUser.LastName;
      userEmail = newUser.email;
      userPhone = newUser.phone;
      isGuestUser = 'false';
    } else {
      userId = '';
      userFirstName = '';
      userLastName = '';
      userEmail = '';
      userPhone = '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Backward-compatibility getters/variables for existing screens during migration:
// ─────────────────────────────────────────────────────────────────────────────

String get userID => AppSession.userId;
set userID(String val) => AppSession.userId = val;

String get userFirstName => AppSession.userFirstName;
set userFirstName(String val) => AppSession.userFirstName = val;

String get userLastName => AppSession.userLastName;
set userLastName(String val) => AppSession.userLastName = val;

String get userEmail => AppSession.userEmail;
set userEmail(String val) => AppSession.userEmail = val;

String get userPhone => AppSession.userPhone;
set userPhone(String val) => AppSession.userPhone = val;

User? get user => AppSession.user;
set user(User? val) => AppSession.user = val;

String get deviceName => AppSession.deviceName;
set deviceName(String val) => AppSession.deviceName = val;

String get dtz => AppSession.dtz;
set dtz(String val) => AppSession.dtz = val;

String get globalLocaleString => AppSession.globalLocaleString;
set globalLocaleString(String val) => AppSession.globalLocaleString = val;

int get totalNotificationsCount => AppSession.totalNotificationsCount;
set totalNotificationsCount(int val) => AppSession.totalNotificationsCount = val;

String get csrfToken => AppSession.csrfToken;
set csrfToken(String val) => AppSession.csrfToken = val;

String get setCookie => AppSession.setCookie;
set setCookie(String val) => AppSession.setCookie = val;

Map get SelectedCouponCode => AppSession.selectedCouponCode;
set SelectedCouponCode(Map val) => AppSession.selectedCouponCode = val;

bool get isLoginSeen => AppSession.isLoginSeen;
set isLoginSeen(bool val) => AppSession.isLoginSeen = val;

bool get isShowAddressScreenFromLogin => AppSession.isShowAddressScreenFromLogin;
set isShowAddressScreenFromLogin(bool val) => AppSession.isShowAddressScreenFromLogin = val;

String get CategoryID => AppSession.categoryId;
set CategoryID(String val) => AppSession.categoryId = val;

String get CategoryName => AppSession.categoryName;
set CategoryName(String val) => AppSession.categoryName = val;

String get SubCategoryID => AppSession.subCategoryId;
set SubCategoryID(String val) => AppSession.subCategoryId = val;

String get SubCategoryName => AppSession.subCategoryName;
set SubCategoryName(String val) => AppSession.subCategoryName = val;

String get currentLocation => AppSession.currentLocation;
set currentLocation(String val) => AppSession.currentLocation = val;

String? get postalCode => AppSession.postalCode;
set postalCode(String? val) => AppSession.postalCode = val;

String get isGuestUser => AppSession.isGuestUser;
set isGuestUser(String val) => AppSession.isGuestUser = val;

DateTime get selectedDate => AppSession.selectedDate;
set selectedDate(DateTime val) => AppSession.selectedDate = val;

String? get selectedSlot => AppSession.selectedSlot;
set selectedSlot(String? val) => AppSession.selectedSlot = val;

bool get isNotificationHandled => AppSession.isNotificationHandled;
set isNotificationHandled(bool val) => AppSession.isNotificationHandled = val;

String get rzpKey => AppSession.rzpKey;
set rzpKey(String val) => AppSession.rzpKey = val;

Map<String, dynamic>? get pendingNotificationData => AppSession.pendingNotificationData;
set pendingNotificationData(Map<String, dynamic>? val) => AppSession.pendingNotificationData = val;

GlobalKey<NavigatorState> get navigatorKey => AppSession.navigatorKey;

const Color mainColor = AppSession.mainColor;
const Color bgColor = AppSession.bgColor;
