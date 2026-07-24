import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

// -----------------------------------------------------------------------------
// USER ROLE ENUM
// -----------------------------------------------------------------------------
enum UserRole { parent, staff, admin, developer }

// -----------------------------------------------------------------------------
// USER MODEL
// -----------------------------------------------------------------------------
class UserModel {
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final String? childName;
  final String? childPhotoPath;
  final DateTime registeredAt;

  UserModel({
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.childName,
    this.childPhotoPath,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.index,
        'childName': childName,
        'childPhotoPath': childPhotoPath,
        'registeredAt': registeredAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'],
        phone: json['phone'],
        password: json['password'],
        role: UserRole.values[json['role']],
        childName: json['childName'],
        childPhotoPath: json['childPhotoPath'],
        registeredAt: DateTime.parse(json['registeredAt']),
      );
}

// -----------------------------------------------------------------------------
// GENERATED QR MODEL
// -----------------------------------------------------------------------------
class GeneratedQR {
  final String codeId;
  final String type;
  bool isUsed;
  final DateTime createdAt;
  String? childName;

  GeneratedQR({
    required this.codeId,
    required this.type,
    this.isUsed = false,
    required this.createdAt,
    this.childName,
  });

  Map<String, dynamic> toJson() => {
        'codeId': codeId,
        'type': type,
        'isUsed': isUsed,
        'createdAt': createdAt.toIso8601String(),
        'childName': childName,
      };

  factory GeneratedQR.fromJson(Map<String, dynamic> json) => GeneratedQR(
        codeId: json['codeId'],
        type: json['type'],
        isUsed: json['isUsed'],
        createdAt: DateTime.parse(json['createdAt']),
        childName: json['childName'],
      );
}

// -----------------------------------------------------------------------------
// REGISTRATION NOTIFICATION MODEL
// -----------------------------------------------------------------------------
class RegistrationNotification {
  final String email;
  final String role;
  final String childName;
  final DateTime timestamp;
  bool isRead;

  RegistrationNotification({
    required this.email,
    required this.role,
    this.childName = '',
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role,
        'childName': childName,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory RegistrationNotification.fromJson(Map<String, dynamic> json) =>
      RegistrationNotification(
        email: json['email'],
        role: json['role'],
        childName: json['childName'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'] ?? false,
      );
}

// -----------------------------------------------------------------------------
// ANNOUNCEMENT MODEL
// -----------------------------------------------------------------------------
class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String adminEmail;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.adminEmail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'adminEmail': adminEmail,
      };

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        adminEmail: json['adminEmail'],
      );
}

// -----------------------------------------------------------------------------
// FACE VERIFICATION RESULT MODEL
// -----------------------------------------------------------------------------
class FaceVerificationResult {
  final bool isMatch;
  final double confidence;
  final String message;

  FaceVerificationResult({
    required this.isMatch,
    required this.confidence,
    required this.message,
  });
}

// -----------------------------------------------------------------------------
// VALIDATION HELPERS
// -----------------------------------------------------------------------------
bool isValidEmail(String email) {
  final emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  return emailRegex.hasMatch(email);
}

// -----------------------------------------------------------------------------
// APP STATE - MAIN DATA MANAGER
// -----------------------------------------------------------------------------
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal() {
    _initDefaultData();
    loadAllData();
  }

  // ==================== DATA FIELDS ====================
  UserModel? currentUser;
  List<UserModel> users = [];
  List<String> adminSecretCodes = [];
  List<GeneratedQR> generatedQRs = [];
  Map<String, String> childStatuses = {};
  Map<String, String> childPhotos = {};
  List<RegistrationNotification> registrationNotifications = [];
  List<Announcement> announcements = [];
  List<String> errorLogs = [];
  bool isVerifyingFace = false;

  final List<String> defaultSecretCodes = ['ADMIN123', 'STAFF2026', '123456'];

  // ==================== INITIALIZATION ====================
  void _initDefaultData() {
    users.add(UserModel(
      email: 'developer@dreamnursery.com',
      phone: '0899999999',
      password: 'Dev@123456',
      role: UserRole.developer,
      registeredAt: DateTime.now(),
    ));

    users.add(UserModel(
      email: 'admin@dreamnursery.com',
      phone: '0800000000',
      password: 'Admin@123',
      role: UserRole.admin,
      registeredAt: DateTime.now(),
    ));

    adminSecretCodes = List<String>.from(defaultSecretCodes);
    

    announcements.add(Announcement(
      id: '1',
      title: 'ยินดีต้อนรับสู่ Dreamnursery',
      content: 'ระบบรับ-ส่งเด็กอัจฉริยะ พร้อมให้บริการแล้ว',
      createdAt: DateTime.now(),
      adminEmail: 'admin@dreamnursery.com',
    ));
  }

  // ==================== DATA LOADING & SAVING ====================
  Future<void> loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Load users
      final usersJson = prefs.getStringList('users');
      if (usersJson != null && usersJson.isNotEmpty) {
        users =
            usersJson.map((e) => UserModel.fromJson(jsonDecode(e))).toList();
      }

      // Load secret codes
      final savedCodes = prefs.getStringList('admin_secret_codes');
      if (savedCodes != null && savedCodes.isNotEmpty) {
        adminSecretCodes =
            [...defaultSecretCodes, ...savedCodes].toSet().toList();
      }

      // Load child statuses
      final statusesStr = prefs.getString('child_statuses');
      if (statusesStr != null) {
        childStatuses = Map<String, String>.from(jsonDecode(statusesStr));
      }

      // Load child photos
      final photosStr = prefs.getString('child_photos');
      if (photosStr != null) {
        childPhotos = Map<String, String>.from(jsonDecode(photosStr));
      }

      // Load QR codes
      final qrsJson = prefs.getStringList('generated_qrs');
      if (qrsJson != null && qrsJson.isNotEmpty) {
        generatedQRs =
            qrsJson.map((e) => GeneratedQR.fromJson(jsonDecode(e))).toList();
      }

      // Load notifications
      final notifJson = prefs.getStringList('registration_notifications');
      if (notifJson != null && notifJson.isNotEmpty) {
        registrationNotifications = notifJson
            .map((e) => RegistrationNotification.fromJson(jsonDecode(e)))
            .toList();
      }

      // Load announcements
      final announceJson = prefs.getStringList('announcements');
      if (announceJson != null && announceJson.isNotEmpty) {
        announcements = announceJson
            .map((e) => Announcement.fromJson(jsonDecode(e)))
            .toList();
      }

      // Load error logs
      final logsJson = prefs.getStringList('error_logs');
      if (logsJson != null && logsJson.isNotEmpty) {
        errorLogs = logsJson;
      }

      // Load saved email and auto login
      final savedEmail = prefs.getString('current_user_email');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        try {
          final user = users.firstWhere((u) => u.email == savedEmail);
          currentUser = user;
          print('✅ Auto login success: $savedEmail');
        } catch (e) {
          print('❌ Auto login failed: $e');
          currentUser = null;
        }
      }
    } catch (e) {
      print('Load data error: $e');
    }
    notifyListeners();
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await prefs.setStringList(
        'users',
        users.map((e) => jsonEncode(e.toJson())).toList(),
      );

      await prefs.setStringList(
        'admin_secret_codes',
        adminSecretCodes,
      );

      await prefs.setString(
        'child_statuses',
        jsonEncode(childStatuses),
      );

      await prefs.setString(
        'child_photos',
        jsonEncode(childPhotos),
      );

      await prefs.setStringList(
        'generated_qrs',
        generatedQRs.map((e) => jsonEncode(e.toJson())).toList(),
      );

      await prefs.setStringList(
        'registration_notifications',
        registrationNotifications
            .map((e) => jsonEncode(e.toJson()))
            .toList(),
      );

      await prefs.setStringList(
        'announcements',
        announcements.map((e) => jsonEncode(e.toJson())).toList(),
      );

      await prefs.setStringList(
        'error_logs',
        errorLogs,
      );

      if (currentUser != null) {
        await prefs.setString(
          'current_user_email',
          currentUser!.email,
        );
        print('💾 Saved current_user_email: ${currentUser!.email}');
      }
    } catch (e) {
      print('Save data error: $e');
    }
  }

  // ==================== USER MANAGEMENT ====================
  String? registerParent({
    required String email,
    required String phone,
    required String childName,
    required String password,
    String? childPhotoPath,
  }) {
    final cleanEmail = email.trim();
    if (!isValidEmail(cleanEmail)) return 'รูปแบบอีเมลไม่ถูกต้อง';
    if (users.any((u) => u.email == cleanEmail)) return 'อีเมลนี้ถูกใช้งานในระบบแล้ว';

    final newUser = UserModel(
      email: cleanEmail,
      phone: phone.trim(),
      password: password,
      role: UserRole.parent,
      childName: childName.trim(),
      childPhotoPath: childPhotoPath,
      registeredAt: DateTime.now(),
    );
    users.add(newUser);
    childStatuses[childName.trim()] = 'ยังไม่ส่งเด็ก';
    if (childPhotoPath != null) {
      childPhotos[childName.trim()] = childPhotoPath;
    }

    registrationNotifications.add(RegistrationNotification(
      email: cleanEmail,
      role: 'ผู้ปกครอง',
      childName: childName.trim(),
      timestamp: DateTime.now(),
    ));

    _saveAllData();
    notifyListeners();
    return null;
  }

  String? registerStaff({
    required String email,
    required String phone,
    required String password,
    required String secretCode,
  }) {
    final cleanEmail = email.trim();
    final cleanSecret = secretCode.trim();

    if (!isValidEmail(cleanEmail)) return 'รูปแบบอีเมลไม่ถูกต้อง';

    if (!adminSecretCodes.contains(cleanSecret)) {
      return 'รหัสลับพนักงานไม่ถูกต้อง!';
    }

    if (users.any((u) => u.email == cleanEmail)) return 'อีเมลนี้ถูกใช้งานในระบบแล้ว';

    final newUser = UserModel(
      email: cleanEmail,
      phone: phone.trim(),
      password: password,
      role: UserRole.staff,
      registeredAt: DateTime.now(),
    );
    users.add(newUser);

    registrationNotifications.add(RegistrationNotification(
      email: cleanEmail,
      role: 'พนักงาน',
      childName: '',
      timestamp: DateTime.now(),
    ));

    _saveAllData();
    notifyListeners();
    return null;
  }

  bool login(String email, String password) {
    try {
      final cleanEmail = email.trim();
      final user = users.firstWhere(
        (u) => u.email == cleanEmail && u.password == password,
      );
      currentUser = user;
      _saveCurrentUser(cleanEmail);
      _saveAllData();
      print('✅ Login success: $cleanEmail');
      notifyListeners();
      return true;
    } catch (_) {
      print('❌ Login failed');
      return false;
    }
  }

  void logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    print('🚪 Logout: removed current_user_email');
    notifyListeners();
  }

  void _saveCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);
    print('💾 Saved current_user_email: $email');
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('current_user_email');

    print('🔍 AutoLogin: savedEmail = $savedEmail');
    print('🔍 AutoLogin: users count = ${users.length}');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      try {
        final user = users.firstWhere((u) => u.email == savedEmail);
        currentUser = user;
        print('✅ AutoLogin success: ${user.email}');
        notifyListeners();
        return true;
      } catch (e) {
        print('❌ AutoLogin failed: $e');
        currentUser = null;
        return false;
      }
    }
    print('❌ No saved email found');
    return false;
  }

  void kickUser(String email) {
    users.removeWhere((u) => u.email == email);
    _saveAllData();
    notifyListeners();
  }

  void updateUserEmail(String oldEmail, String newEmail) {
    final userIndex = users.indexWhere((u) => u.email == oldEmail);
    if (userIndex != -1) {
      final updatedUser = UserModel(
        email: newEmail,
        phone: users[userIndex].phone,
        password: users[userIndex].password,
        role: users[userIndex].role,
        childName: users[userIndex].childName,
        childPhotoPath: users[userIndex].childPhotoPath,
        registeredAt: users[userIndex].registeredAt,
      );
      users[userIndex] = updatedUser;
      _saveAllData();
      notifyListeners();
    }
  }

  void updateUserPhone(String email, String newPhone) {
    final userIndex = users.indexWhere((u) => u.email == email);
    if (userIndex != -1) {
      final updatedUser = UserModel(
        email: users[userIndex].email,
        phone: newPhone,
        password: users[userIndex].password,
        role: users[userIndex].role,
        childName: users[userIndex].childName,
        childPhotoPath: users[userIndex].childPhotoPath,
        registeredAt: users[userIndex].registeredAt,
      );
      users[userIndex] = updatedUser;
      _saveAllData();
      notifyListeners();
    }
  }

  // ==================== CHILD PHOTO MANAGEMENT ====================
  Future<String?> saveChildPhoto(String childName, XFile photo) async {
    try {
      final bytes = await photo.readAsBytes();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/child_${childName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      childPhotos[childName] = filePath;

      final userIndex = users.indexWhere((u) => u.childName == childName);
      if (userIndex != -1) {
        final updatedUser = UserModel(
          email: users[userIndex].email,
          phone: users[userIndex].phone,
          password: users[userIndex].password,
          role: users[userIndex].role,
          childName: users[userIndex].childName,
          childPhotoPath: filePath,
          registeredAt: users[userIndex].registeredAt,
        );
        users[userIndex] = updatedUser;
      }

      await _saveAllData();
      notifyListeners();
      return filePath;
    } catch (e) {
      print('Save photo error: $e');
      return null;
    }
  }

  Future<String?> getChildPhoto(String childName) async {
    if (childPhotos.containsKey(childName)) {
      final path = childPhotos[childName];
      if (path != null && await File(path).exists()) {
        return path;
      }
    }

    try {
      final user = users.firstWhere((u) => u.childName == childName);
      if (user.childPhotoPath != null && await File(user.childPhotoPath!).exists()) {
        return user.childPhotoPath;
      }
    } catch (_) {
      // User not found
    }
    return null;
  }

  // ==================== QR CODE MANAGEMENT ====================
  GeneratedQR createQRCode(String type, {String? childName}) {
    final now = DateTime.now();
    final randomId =
        'QR${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}_${now.millisecond.toString().padLeft(3, '0')}';

    final newQR = GeneratedQR(
      codeId: randomId,
      type: type,
      isUsed: false,
      createdAt: now,
      childName: childName,
    );
    generatedQRs.add(newQR);
    _saveAllData();
    notifyListeners();
    return newQR;
  }

  String processScan(String qrPayload, String expectedType, String childName) {
    try {
      final qr = generatedQRs.firstWhere((q) => q.codeId == qrPayload);

      if (qr.isUsed) return 'QR Code นี้ถูกใช้งานไปแล้ว!';

      if (qr.type != expectedType) {
        return 'ประเภท QR Code ไม่ถูกต้อง';
      }

      qr.isUsed = true;
      childStatuses[childName] = (expectedType == 'drop_off')
          ? 'ส่งเด็กแล้ว'
          : 'รับเด็กกลับบ้านแล้ว';
      _saveAllData();
      notifyListeners();
      return 'SUCCESS';
    } catch (_) {
      if (qrPayload.startsWith('QR')) {
        final now = DateTime.now();
        final newQR = GeneratedQR(
          codeId: qrPayload,
          type: expectedType,
          isUsed: true,
          createdAt: now,
          childName: childName,
        );
        generatedQRs.add(newQR);

        childStatuses[childName] = (expectedType == 'drop_off')
            ? 'ส่งเด็กแล้ว'
            : 'รับเด็กกลับบ้านแล้ว';
        _saveAllData();
        notifyListeners();
        return 'SUCCESS';
      }

      return 'QR Code ไม่ถูกต้อง!';
    }
  }

  List<GeneratedQR> getActiveQRs() {
    return generatedQRs.where((q) => !q.isUsed).toList();
  }

  int get todayQRCount {
    final now = DateTime.now();
    return generatedQRs
        .where((q) =>
            q.createdAt.year == now.year &&
            q.createdAt.month == now.month &&
            q.createdAt.day == now.day)
        .length;
  }

  // ==================== CHILD STATUS MANAGEMENT ====================
  void updateChildStatus(String childName, String status) {
    childStatuses[childName] = status;
    _saveAllData();
    notifyListeners();
  }

  // ==================== NOTIFICATION MANAGEMENT ====================
  void markNotificationAsRead(int index) {
    if (index < registrationNotifications.length) {
      registrationNotifications[index].isRead = true;
      _saveAllData();
      notifyListeners();
    }
  }

  void clearNotifications() {
    registrationNotifications.clear();
    _saveAllData();
    notifyListeners();
  }

  int get unreadNotificationCount {
    return registrationNotifications.where((n) => !n.isRead).length;
  }

  // ==================== ANNOUNCEMENT MANAGEMENT ====================
  void addAnnouncement(String title, String content) {
    final newAnnouncement = Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      adminEmail: currentUser?.email ?? 'admin@Dreamnursery.com',
    );
    announcements.insert(0, newAnnouncement);
    _saveAllData();
    notifyListeners();
  }

  void deleteAnnouncement(String id) {
    announcements.removeWhere((a) => a.id == id);
    _saveAllData();
    notifyListeners();
  }

  // ==================== SECRET CODE MANAGEMENT ====================
  void addSecretCode(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.isNotEmpty && !adminSecretCodes.contains(trimmedCode)) {
      adminSecretCodes.add(trimmedCode);
      await _saveAllData();
      notifyListeners();
    }
  }

  void deleteSecretCode(String code) async {
    if (adminSecretCodes.contains(code)) {
      adminSecretCodes.remove(code);
      await _saveAllData();
      notifyListeners();
    }
  }

  // ==================== ERROR LOG MANAGEMENT ====================
  void addErrorLog(String error) {
    errorLogs.add('${DateTime.now().toIso8601String()}: $error');
    _saveAllData();
    notifyListeners();
  }

  void clearErrorLogs() {
    errorLogs.clear();
    _saveAllData();
    notifyListeners();
  }

  // ==================== FACE VERIFICATION ====================
  void setVerifying(bool value) {
    isVerifyingFace = value;
    notifyListeners();
  }

  Future<FaceVerificationResult> verifyFace(
      String childName, XFile capturedPhoto) async {
    setVerifying(true);
    await Future.delayed(const Duration(seconds: 3));

    final random = DateTime.now().millisecond % 10;
    final isMatch = random > 2;

    setVerifying(false);

    return FaceVerificationResult(
      isMatch: isMatch,
      confidence: isMatch ? 0.85 + (random / 100) : 0.3 + (random / 100),
      message: isMatch
          ? '✅ ใบหน้าตรงกับระบบ ยืนยันตัวตนสำเร็จ'
          : '❌ ใบหน้าไม่ตรงกับระบบ กรุณาลองใหม่',
    );
  }

  // ==================== UTILITY ====================
  bool get isDeveloper => currentUser?.role == UserRole.developer;
  bool get isAdmin => currentUser?.role == UserRole.admin || isDeveloper;
}
