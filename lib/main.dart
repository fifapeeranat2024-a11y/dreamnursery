import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChildCareApp());
}

// -----------------------------------------------------------------------------
// CONSTANTS & COLOR PALETTE
// -----------------------------------------------------------------------------
class AppColors {
  static const Color primary = Color(0xFF0B3B5C);
  static const Color primaryDark = Color(0xFF072A40);
  static const Color primaryLight = Color(0xFF1A5A7A);
  static const Color secondary = Color(0xFFFF6B00);
  static const Color secondaryLight = Color(0xFFFF8833);
  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color success = Color(0xFF059669);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color background = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0B3B5C);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A000000);
  static const Color devColor = Color(0xFFFF6B00);
}

// -----------------------------------------------------------------------------
// MAIN ENTRY POINT
// -----------------------------------------------------------------------------
class ChildCareApp extends StatelessWidget {
  const ChildCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChildCare Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// SPLASH SCREEN
// -----------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    _initializeApp();
  }

  void _initializeApp() async {
    await AppState.instance.loadAllData();
    print('📂 Data loaded');
    
    final hasUser = AppState.instance.currentUser != null;
    print('👤 Has user: $hasUser');
    
    if (hasUser) {
      print('✅ User already logged in: ${AppState.instance.currentUser?.email}');
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const RootRouter(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3),
                            width: 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.15),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.child_care_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'CHILDCARE PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ระบบรับ-ส่งเด็กอัจฉริยะ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ROOT ROUTER
// -----------------------------------------------------------------------------
class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final user = AppState.instance.currentUser;
        print('🔍 RootRouter: currentUser = ${user?.email ?? 'null'}');
        
        if (user == null) {
          print('➡️ No user, go to LoginScreen');
          return const LoginScreen();
        }

        print('➡️ User role: ${user.role}');
        switch (user.role) {
          case UserRole.parent:
            return const ParentDashboard();
          case UserRole.staff:
            return const StaffDashboard();
          case UserRole.admin:
            return const AdminDashboard();
          case UserRole.developer:
            return const DeveloperDashboard();
        }
      },
    );
  }
}

// -----------------------------------------------------------------------------
// LOGIN SCREEN
// -----------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkSavedAccount();
  }

  void _checkSavedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('current_user_email');
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกรูปแบบอีเมลให้ถูกต้อง')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final success = AppState.instance.login(email, _passwordController.text);
    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง!'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.child_care_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ยินดีต้อนรับ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ลงชื่อเข้าใช้เพื่อดำเนินการต่อ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'อีเมล',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                  ? Icons.visibility_off_rounded 
                                  : Icons.visibility_rounded,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'เข้าสู่ระบบ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยังไม่มีบัญชี? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'สมัครสมาชิก',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REGISTER SCREEN
// -----------------------------------------------------------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserRole _selectedRole = UserRole.parent;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _childNameController = TextEditingController();
  final _secretCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  XFile? _childPhoto;

  double _strengthScore = 0.0;
  String _strengthLabel = '';
  Color _strengthColor = AppColors.textMuted;

  void _checkPasswordStrength(String val) {
    if (val.isEmpty) {
      setState(() {
        _strengthScore = 0.0;
        _strengthLabel = '';
      });
      return;
    }
    bool hasMinLength = val.length >= 8;
    bool hasUpper = val.contains(RegExp(r'[A-Z]'));
    bool hasDigits = val.contains(RegExp(r'[0-9]'));
    bool hasSpecial = val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int scoreCount = 0;
    if (hasMinLength) scoreCount++;
    if (hasUpper) scoreCount++;
    if (hasDigits) scoreCount++;
    if (hasSpecial) scoreCount++;

    setState(() {
      _strengthScore = scoreCount / 4;
      if (scoreCount == 4) {
        _strengthLabel = 'รหัสผ่านปลอดภัยสูงมาก';
        _strengthColor = AppColors.success;
      } else if (scoreCount >= 2) {
        _strengthLabel = 'รหัสผ่านความปลอดภัยปานกลาง';
        _strengthColor = AppColors.warning;
      } else {
        _strengthLabel = 'รหัสผ่านควรเพิ่มความปลอดภัย';
        _strengthColor = AppColors.danger;
      }
    });
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (photo != null) {
        setState(() {
          _childPhoto = photo;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถถ่ายรูปได้: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (photo != null) {
        setState(() {
          _childPhoto = photo;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถเลือกรูปได้: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showPhotoPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'เลือกรูปโปรไฟล์เด็ก',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('ถ่ายรูปใหม่'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('เลือกรูปจากอัลบั้ม'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded, color: AppColors.danger),
              title: const Text('ยกเลิก'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() async {
    final email = _emailController.text.trim();
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกรูปแบบอีเมลให้ถูกต้อง')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านทั้งสองช่องไม่ตรงกัน!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    String? err;
    if (_selectedRole == UserRole.parent) {
      final childName = _childNameController.text.trim();
      if (childName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกชื่อลูกของท่าน')),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (_childPhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาถ่ายรูปโปรไฟล์เด็ก')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final savedPath = await AppState.instance.saveChildPhoto(childName, _childPhoto!);
      if (savedPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถบันทึกรูปได้ กรุณาลองใหม่')),
        );
        setState(() => _isLoading = false);
        return;
      }

      err = AppState.instance.registerParent(
        email: email,
        phone: _phoneController.text.trim(),
        childName: childName,
        password: _passwordController.text,
        childPhotoPath: savedPath,
      );
    } else {
      err = AppState.instance.registerStaff(
        email: email,
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        secretCode: _secretCodeController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      AppState.instance.login(email, _passwordController.text);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 50,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'สมัครสมาชิกสำเร็จ!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ระบบกำลังพาคุณเข้าสู่หน้าหลัก',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('เริ่มใช้งาน'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'สมัครสมาชิก',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = UserRole.parent),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.parent
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ผู้ปกครอง',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedRole == UserRole.parent
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = UserRole.staff),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.staff
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'พนักงาน',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedRole == UserRole.staff
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedRole == UserRole.parent) ...[
              TextField(
                controller: _childNameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อลูก',
                  prefixIcon: Icon(Icons.child_care_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รูปโปรไฟล์เด็ก',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showPhotoPicker,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                              image: _childPhoto != null
                                  ? DecorationImage(
                                      image: FileImage(File(_childPhoto!.path)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _childPhoto == null
                                ? const Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 30,
                                    color: AppColors.textMuted,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _childPhoto == null
                                    ? 'ยังไม่มีรูปโปรไฟล์'
                                    : 'มีรูปโปรไฟล์แล้ว',
                                style: TextStyle(
                                  color: _childPhoto == null
                                      ? AppColors.textMuted
                                      : AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _childPhoto == null
                                    ? 'กดที่รูปเพื่อถ่ายหรือเลือกรูป'
                                    : 'กดที่รูปเพื่อเปลี่ยนรูป',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedRole == UserRole.staff) ...[
              TextField(
                controller: _secretCodeController,
                decoration: const InputDecoration(
                  labelText: 'รหัสลับพนักงาน',
                  prefixIcon: Icon(Icons.key_rounded),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: _checkPasswordStrength,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword 
                      ? Icons.visibility_off_rounded 
                      : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            if (_strengthLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _strengthScore,
                  color: _strengthColor,
                  backgroundColor: AppColors.background,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _strengthLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: _strengthColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword 
                      ? Icons.visibility_off_rounded 
                      : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'สมัครสมาชิก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PARENT DASHBOARD
// -----------------------------------------------------------------------------
class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  void _openScanner(BuildContext context, String expectedType, String childName) async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!context.mounted) return;

    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QRScannerPage(
            expectedType: expectedType,
            childName: childName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาอนุญาตการใช้งานกล้อง'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;
        final user = state.currentUser!;
        final childName = user.childName ?? 'ไม่ระบุ';
        final status = state.childStatuses[childName] ?? 'ยังไม่ส่งเด็ก';
        final isCheckedIn = status == 'ส่งเด็กแล้ว';

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.background, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'ผู้ปกครอง',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => state.logout(),
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isCheckedIn
                                    ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                                    : [AppColors.primary, AppColors.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isCheckedIn ? AppColors.success : AppColors.primary).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: FutureBuilder<String?>(
                                        future: state.getChildPhoto(childName),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(14),
                                              child: Image.file(
                                                File(snapshot.data!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Icon(
                                                  Icons.child_care_rounded,
                                                  size: 28,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }
                                          return Icon(
                                            Icons.child_care_rounded,
                                            size: 28,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            childName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            'รหัส: ${user.email}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCheckedIn ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'สถานะ: $status',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (state.announcements.isNotEmpty) ...[
                            const Text(
                              'ประกาศจากแอดมิน',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...state.announcements.map((announce) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announce.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    announce.content,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${announce.createdAt.toString().substring(0, 16)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                            const SizedBox(height: 16),
                          ],
                          const Text(
                            'ปฏิบัติการ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'เลือกประเภทการดำเนินการที่ต้องการ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () => _openScanner(context, 'drop_off', childName),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.qr_code_scanner_rounded, size: 32),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'ส่งเด็ก',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () => _openScanner(context, 'pick_up', childName),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.qr_code_scanner_rounded, size: 32),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'รับเด็ก',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'ให้พนักงานแสดง QR Code จากนั้นกดสแกนเพื่อทำรายการ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// STAFF DASHBOARD
// -----------------------------------------------------------------------------
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  GeneratedQR? activeQR;
  String? selectedChildName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoGenerateQR();
    });
  }

  void _autoGenerateQR() {
    if (selectedChildName == null && AppState.instance.childStatuses.isNotEmpty) {
      setState(() {
        selectedChildName = AppState.instance.childStatuses.keys.first;
      });
    }

    if (selectedChildName != null) {
      final newQR = AppState.instance.createQRCode(
        'drop_off',
        childName: selectedChildName,
      );
      setState(() {
        activeQR = newQR;
      });
    }
  }

  void _generateQR(String type) {
    if (selectedChildName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกเด็กก่อน'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final newQR = AppState.instance.createQRCode(
      type,
      childName: selectedChildName,
    );
    
    setState(() {
      activeQR = newQR;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('สร้าง QR ${type == 'drop_off' ? 'ส่งเด็ก' : 'รับเด็ก'} สำเร็จ'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _openVerification(BuildContext context, String childName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FaceVerificationPage(childName: childName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final user = state.currentUser!;
    final childrenNames = state.childStatuses.keys.toList();

    return Scaffold(
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.background, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'พนักงาน',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => state.logout(),
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'สร้าง QR Code แล้วให้ผู้ปกครองสแกน เพื่อยืนยันตัวตนด้วยรูป',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (state.announcements.isNotEmpty) ...[
                            const Text(
                              'ประกาศจากแอดมิน',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...state.announcements.map((announce) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announce.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    announce.content,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${announce.createdAt.toString().substring(0, 16)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                            const SizedBox(height: 16),
                          ],
                          if (childrenNames.isNotEmpty) ...[
                            const Text(
                              'เลือกเด็ก',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButton<String>(
                                value: selectedChildName,
                                hint: const Text('เลือกชื่อเด็ก'),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: childrenNames.map((name) {
                                  final status = state.childStatuses[name] ?? 'ไม่ระบุ';
                                  return DropdownMenuItem(
                                    value: name,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: status == 'ส่งเด็กแล้ว' || status == 'รับเด็กกลับบ้านแล้ว'
                                                ? AppColors.success
                                                : AppColors.warning,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('$name ($status)'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedChildName = value;
                                    if (value != null) {
                                      _autoGenerateQR();
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          const Text(
                            'สร้าง QR Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: () => _generateQR('drop_off'),
                                  child: const Text(
                                    'ส่งเด็ก',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: () => _generateQR('pick_up'),
                                  child: const Text(
                                    'รับเด็ก',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (activeQR != null) ...[
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        activeQR!.type == 'drop_off' ? 'QR ส่งเด็ก' : 'QR รับเด็ก',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: activeQR!.isUsed ? AppColors.danger : AppColors.success,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          activeQR!.isUsed ? 'ใช้งานแล้ว' : 'พร้อมใช้งาน',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'เด็ก: ${activeQR!.childName ?? 'ไม่ระบุชื่อ'}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: QrImageView(
                                      data: activeQR!.codeId,
                                      version: QrVersions.auto,
                                      size: 200,
                                      gapless: false,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SelectableText(
                                      activeQR!.codeId,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _autoGenerateQR,
                                          icon: const Icon(Icons.refresh_rounded),
                                          label: const Text('สร้างใหม่'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.secondary,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            if (selectedChildName != null) {
                                              _openVerification(context, selectedChildName!);
                                            }
                                          },
                                          icon: const Icon(Icons.face_rounded),
                                          label: const Text('ยืนยันตัวตน'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (selectedChildName != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: state.childStatuses[selectedChildName]?.contains('แล้ว') == true
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: state.childStatuses[selectedChildName]?.contains('แล้ว') == true
                                        ? AppColors.success
                                        : AppColors.warning,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      state.childStatuses[selectedChildName]?.contains('แล้ว') == true
                                          ? Icons.check_circle_rounded
                                          : Icons.info_rounded,
                                      color: state.childStatuses[selectedChildName]?.contains('แล้ว') == true
                                          ? AppColors.success
                                          : AppColors.warning,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'เด็ก: $selectedChildName\nสถานะ: ${state.childStatuses[selectedChildName] ?? 'ไม่ระบุ'}',
                                        style: TextStyle(
                                          color: state.childStatuses[selectedChildName]?.contains('แล้ว') == true
                                              ? AppColors.success
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.qr_code_rounded,
                                    size: 60,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ยังไม่มี QR Code',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'เลือกเด็กและสร้าง QR ด้านบน',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FACE VERIFICATION PAGE
// -----------------------------------------------------------------------------
class FaceVerificationPage extends StatefulWidget {
  final String childName;

  const FaceVerificationPage({
    super.key,
    required this.childName,
  });

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  XFile? _capturedPhoto;
  bool _isVerifying = false;
  FaceVerificationResult? _result;
  bool _showConfidence = false;

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      
      if (photo != null) {
        setState(() {
          _capturedPhoto = photo;
          _result = null;
          _showConfidence = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถถ่ายรูปได้: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _verifyFace() async {
    if (_capturedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาถ่ายรูปเพื่อยืนยันตัวตน'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _result = null;
      _showConfidence = false;
    });

    final result = await AppState.instance.verifyFace(widget.childName, _capturedPhoto!);
    
    setState(() {
      _isVerifying = false;
      _result = result;
      _showConfidence = true;
    });

    if (result.isMatch) {
      AppState.instance.updateChildStatus(widget.childName, 'ยืนยันตัวตนสำเร็จ');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ยืนยันตัวตนสำเร็จ!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context, true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ ใบหน้าไม่ตรงกับระบบ กรุณาลองใหม่'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ยืนยันตัวตน: ${widget.childName}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: AppColors.accent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'กรุณาถ่ายรูปใบหน้าเด็กให้ชัดเจน เพื่อยืนยันตัวตน',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                image: _capturedPhoto != null
                    ? DecorationImage(
                        image: FileImage(File(_capturedPhoto!.path)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _capturedPhoto == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.face_rounded,
                          size: 60,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ยังไม่มีรูป',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'กดปุ่มถ่ายรูปด้านล่าง',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isVerifying ? null : _takePhoto,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(
                  _capturedPhoto == null ? '📸 ถ่ายรูปยืนยันตัวตน' : '📸 ถ่ายรูปใหม่',
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            FutureBuilder<String?>(
              future: AppState.instance.getChildPhoto(widget.childName),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(snapshot.data!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              size: 30,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'รูปโปรไฟล์ที่บันทึกไว้',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                widget.childName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ระบบมีรูปแล้ว',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isVerifying ? null : _verifyFace,
                child: _isVerifying
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('กำลังตรวจสอบใบหน้า...'),
                        ],
                      )
                    : const Text(
                        '🔍 ตรวจสอบใบหน้า',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.isMatch 
                      ? AppColors.success.withOpacity(0.1) 
                      : AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _result!.isMatch 
                        ? AppColors.success 
                        : AppColors.danger,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _result!.isMatch 
                              ? Icons.check_circle_rounded 
                              : Icons.error_rounded,
                          color: _result!.isMatch 
                              ? AppColors.success 
                              : AppColors.danger,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _result!.message,
                            style: TextStyle(
                              color: _result!.isMatch 
                                  ? AppColors.success 
                                  : AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showConfidence) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'ความแม่นยำ: ${(_result!.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _result!.confidence,
                                color: _result!.confidence > 0.7 
                                    ? AppColors.success 
                                    : AppColors.warning,
                                backgroundColor: AppColors.background,
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 ระบบจะตรวจสอบเฉพาะใบหน้าเท่านั้น ไม่สนใจสภาพแวดล้อมรอบข้าง',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// QR SCANNER PAGE
// -----------------------------------------------------------------------------
class QRScannerPage extends StatefulWidget {
  final String expectedType;
  final String childName;

  const QRScannerPage({
    super.key,
    required this.expectedType,
    required this.childName,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> with WidgetsBindingObserver {
  MobileScannerController? controller;
  bool isScanned = false;
  bool isInitialized = false;
  bool hasError = false;
  double _scanLinePosition = 0.0;
  bool _scanLineGoingDown = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScanner();
      _startScanLineAnimation();
    });
  }

  void _startScanLineAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _scanLinePosition = 0.0;
          _scanLineGoingDown = true;
        });
        _animateScanLine();
      }
    });
  }

  void _animateScanLine() {
    if (!mounted) return;
    
    const double step = 2.0;
    const Duration interval = Duration(milliseconds: 30);
    
    Future.delayed(interval, () {
      if (!mounted) return;
      
      setState(() {
        if (_scanLineGoingDown) {
          _scanLinePosition += step;
          if (_scanLinePosition >= 230) {
            _scanLineGoingDown = false;
          }
        } else {
          _scanLinePosition -= step;
          if (_scanLinePosition <= 0) {
            _scanLineGoingDown = true;
          }
        }
      });
      
      _animateScanLine();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restartScanner();
    }
  }

  Future<void> _initializeScanner() async {
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }

      if (!mounted) return;

      if (status.isGranted) {
        if (controller != null) {
          await controller?.dispose();
          controller = null;
        }

        controller = MobileScannerController();

        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;
        setState(() {
          isInitialized = true;
          hasError = false;
        });
      } else {
        _showPermissionDenied();
      }
    } catch (e) {
      AppState.instance.addErrorLog('Scanner init error: $e');
      if (!mounted) return;
      setState(() {
        hasError = true;
        isInitialized = false;
      });
    }
  }

  Future<void> _restartScanner() async {
    try {
      if (controller != null) {
        await controller?.stop();
        await controller?.dispose();
        controller = null;
      }

      controller = MobileScannerController();

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;
      setState(() {
        isInitialized = true;
        hasError = false;
        isScanned = false;
      });
    } catch (e) {
      AppState.instance.addErrorLog('Restart scanner error: $e');
      await _initializeScanner();
    }
  }

  void _showPermissionDenied() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ต้องการสิทธิ์กล้อง'),
        content: const Text('กรุณาอนุญาตการใช้งานกล้องเพื่อสแกน QR Code'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _initializeScanner();
            },
            child: const Text('ขออนุญาตอีกครั้ง'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanned || !isInitialized) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      if (!mounted) return;
      setState(() => isScanned = true);
      
      controller?.stop();

      final rawValue = barcode!.rawValue!;
      
      final result = AppState.instance.processScan(
        rawValue,
        widget.expectedType,
        widget.childName,
      );

      if (!mounted) return;

      if (result == 'SUCCESS') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สแกนสำเร็จ! อัปเดทสถานะเรียบร้อย'),
            backgroundColor: AppColors.success,
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('แจ้งเตือน'),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  setState(() {
                    isScanned = false;
                  });
                  controller?.start();
                },
                child: const Text('ลองใหม่'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('ยกเลิก'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'สแกน QR (${widget.expectedType == 'drop_off' ? 'มาส่งเด็ก' : 'มารับเด็ก'})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            controller?.stop();
            controller?.dispose();
            controller = null;
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null)
              MobileScanner(
                controller: controller!,
                fit: BoxFit.cover,
                onDetect: _onDetect,
                errorBuilder: (context, error) {
                  AppState.instance.addErrorLog('Scanner display error: $error');
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'เกิดข้อผิดพลาดในการเปิดกล้อง',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              await controller?.dispose();
                              controller = null;
                              await _initializeScanner();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('ลองอีกครั้ง'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),

            if (isInitialized && !hasError)
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -2,
                        left: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 4),
                              left: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 4),
                              right: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        left: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 4),
                              left: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 4),
                              right: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 30),
                          height: 2,
                          margin: EdgeInsets.only(top: _scanLinePosition),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFFF6B00),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF6B00).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (isInitialized && !hasError)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'นำ QR Code มาวางในกรอบ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADMIN DASHBOARD
// -----------------------------------------------------------------------------
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _newCodeController = TextEditingController();
  int _selectedTab = 0;
  int _deleteConfirmStep = 0;
  String? _userToDelete;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.background, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'แอดมิน',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  state.currentUser?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (state.unreadNotificationCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${state.unreadNotificationCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            IconButton(
                              onPressed: () => state.logout(),
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() { _selectedTab = 0; _deleteConfirmStep = 0; }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'แจ้งเตือน ${state.unreadNotificationCount > 0 ? '(${state.unreadNotificationCount})' : ''}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() { _selectedTab = 1; _deleteConfirmStep = 0; }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'จัดการระบบ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() { _selectedTab = 2; _deleteConfirmStep = 0; }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 2 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'ประกาศ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildNotificationsTab(state)
                        : _selectedTab == 1
                            ? _buildManagementTab(state)
                            : _buildAnnouncementTab(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsTab(AppState state) {
    if (state.registrationNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 60,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่มีแจ้งเตือน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'เมื่อมีผู้สมัครสมาชิกจะแจ้งเตือนที่นี่',
              style: TextStyle(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.registrationNotifications.length,
      itemBuilder: (context, index) {
        final notif = state.registrationNotifications[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notif.isRead ? AppColors.border : AppColors.accent.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            onTap: () => state.markNotificationAsRead(index),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.role == 'ผู้ปกครอง'
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notif.role == 'ผู้ปกครอง'
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                color: notif.role == 'ผู้ปกครอง' ? AppColors.success : AppColors.warning,
              ),
            ),
            title: Text(
              'สมัครสมาชิกใหม่',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${notif.role}: ${notif.email}'),
                if (notif.childName.isNotEmpty)
                  Text('เด็ก: ${notif.childName}'),
                Text(
                  _formatTime(notif.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            trailing: notif.isRead
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inHours < 1) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inDays < 1) return '${diff.inHours} ชั่วโมงที่แล้ว';
    return '${diff.inDays} วันที่แล้ว';
  }

  Widget _buildManagementTab(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'จัดการรหัสลับพนักงาน',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCodeController,
                  decoration: const InputDecoration(
                    hintText: 'เพิ่มรหัสลับใหม่',
                    prefixIcon: Icon(Icons.key_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onPressed: () {
                  if (_newCodeController.text.isNotEmpty) {
                    state.addSecretCode(_newCodeController.text);
                    _newCodeController.clear();
                  }
                },
                child: const Text('เพิ่ม'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.adminSecretCodes.map((code) {
              return Chip(
                label: Text(code),
                backgroundColor: AppColors.background,
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                onDeleted: () => state.deleteSecretCode(code),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'จัดการผู้ใช้งาน',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final u = state.users[index];
              final isAdmin = u.role == UserRole.admin || u.role == UserRole.developer;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: u.role == UserRole.developer 
                      ? AppColors.secondary.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: u.role == UserRole.developer 
                        ? AppColors.secondary 
                        : AppColors.border,
                    width: u.role == UserRole.developer ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: u.role == UserRole.developer
                                ? AppColors.secondary.withOpacity(0.1)
                                : u.role == UserRole.admin
                                    ? AppColors.primary.withOpacity(0.1)
                                    : u.role == UserRole.staff
                                        ? AppColors.warning.withOpacity(0.1)
                                        : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            u.role == UserRole.developer
                                ? Icons.code_rounded
                                : u.role == UserRole.admin
                                    ? Icons.admin_panel_settings_rounded
                                    : u.role == UserRole.staff
                                        ? Icons.person_outline_rounded
                                        : Icons.person_rounded,
                            color: u.role == UserRole.developer
                                ? AppColors.secondary
                                : u.role == UserRole.admin
                                    ? AppColors.primary
                                    : u.role == UserRole.staff
                                        ? AppColors.warning
                                        : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${u.role.name} ${u.childName != null ? "(${u.childName})" : ""}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (u.role == UserRole.developer)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'DEV',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                '📱 ${u.phone}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isAdmin)
                          IconButton(
                            onPressed: () => _showDeleteConfirmation(state, u.email),
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: AppColors.danger,
                            ),
                          ),
                      ],
                    ),
                    if (!isAdmin) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.accent.withOpacity(0.1),
                                foregroundColor: AppColors.accent,
                              ),
                              onPressed: () => _showEditEmailDialog(state, u.email),
                              icon: const Icon(Icons.email_rounded, size: 16),
                              label: const Text('แก้ไขอีเมล'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.accent.withOpacity(0.1),
                                foregroundColor: AppColors.accent,
                              ),
                              onPressed: () => _showEditPhoneDialog(state, u.email),
                              icon: const Icon(Icons.phone_rounded, size: 16),
                              label: const Text('แก้ไขเบอร์'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(AppState state, String email) {
    setState(() {
      _userToDelete = email;
      _deleteConfirmStep = 0;
    });
    _showDeleteDialog(state, email);
  }

  void _showDeleteDialog(AppState state, String email) {
    final step = _deleteConfirmStep;
    final totalSteps = 3;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              step < totalSteps - 1 ? Icons.warning_rounded : Icons.dangerous_rounded,
              color: step < totalSteps - 1 ? AppColors.warning : AppColors.danger,
            ),
            const SizedBox(width: 8),
            Text(
              step < totalSteps - 1 ? 'ยืนยันการลบบัญชี' : 'ยืนยันครั้งสุดท้าย',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คุณกำลังจะลบบัญชี: $email',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'ขั้นตอนที่ ${step + 1} จาก $totalSteps',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (step + 1) / totalSteps,
              backgroundColor: AppColors.background,
              color: step < totalSteps - 1 ? AppColors.warning : AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              step == 0 ? 'คุณแน่ใจหรือไม่ว่าต้องการลบบัญชีนี้?'
                  : step == 1 ? 'การดำเนินการนี้ไม่สามารถย้อนกลับได้!'
                  : 'ยืนยันการลบบัญชีนี้? (คลิกยืนยันครั้งสุดท้าย)',
              style: TextStyle(
                color: step == 2 ? AppColors.danger : AppColors.textSecondary,
                fontWeight: step == 2 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _deleteConfirmStep = 0;
                _userToDelete = null;
              });
            },
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: step < totalSteps - 1 ? AppColors.warning : AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (step < totalSteps - 1) {
                setState(() {
                  _deleteConfirmStep = step + 1;
                });
                _showDeleteDialog(state, email);
              } else {
                state.kickUser(email);
                setState(() {
                  _deleteConfirmStep = 0;
                  _userToDelete = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ลบบัญชีสำเร็จ'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(step < totalSteps - 1 ? 'ยืนยัน' : 'ยืนยันครั้งสุดท้าย'),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog(AppState state, String email) {
    final controller = TextEditingController(text: email);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('แก้ไขอีเมล'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'อีเมลใหม่',
            prefixIcon: Icon(Icons.email_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newEmail = controller.text.trim();
              if (isValidEmail(newEmail)) {
                state.updateUserEmail(email, newEmail);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('อัปเดทอีเมลสำเร็จ'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('รูปแบบอีเมลไม่ถูกต้อง'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog(AppState state, String email) {
    final user = state.users.firstWhere((u) => u.email == email);
    final controller = TextEditingController(text: user.phone);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('แก้ไขเบอร์โทรศัพท์'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'เบอร์โทรศัพท์ใหม่',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newPhone = controller.text.trim();
              if (newPhone.isNotEmpty) {
                state.updateUserPhone(email, newPhone);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('อัปเดทเบอร์โทรศัพท์สำเร็จ'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('กรุณากรอกเบอร์โทรศัพท์'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementTab(AppState state) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สร้างประกาศ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'หัวข้อประกาศ',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'เนื้อหาประกาศ',
              prefixIcon: Icon(Icons.description_rounded),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  state.addAnnouncement(titleController.text, contentController.text);
                  titleController.clear();
                  contentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ประกาศถูกเพิ่มแล้ว'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณากรอกหัวข้อและเนื้อหา'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text('เพิ่มประกาศ'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'รายการประกาศ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (state.announcements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'ยังไม่มีประกาศ',
                  style: TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.announcements.length,
              itemBuilder: (context, index) {
                final announce = state.announcements[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              announce.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.danger),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('ลบประกาศ'),
                                  content: const Text('คุณแน่ใจว่าต้องการลบประกาศนี้?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('ยกเลิก'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        state.deleteAnnouncement(announce.id);
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('ลบประกาศสำเร็จ'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      },
                                      child: const Text('ลบ'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announce.content,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${announce.createdAt.toString().substring(0, 16)} โดย ${announce.adminEmail}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DEVELOPER DASHBOARD
// -----------------------------------------------------------------------------
class DeveloperDashboard extends StatefulWidget {
  const DeveloperDashboard({super.key});

  @override
  State<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends State<DeveloperDashboard> {
  int _selectedTab = 0;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.background, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.secondary, AppColors.secondaryLight],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.code_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'นักพัฒนา',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  state.currentUser?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.secondary, AppColors.secondaryLight],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'DEV',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => state.logout(),
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? AppColors.secondary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'สถิติระบบ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? AppColors.secondary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'ประกาศ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 2),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 2 ? AppColors.secondary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Error Logs',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildStatsTab(state)
                        : _selectedTab == 1
                            ? _buildAnnouncementTab(state)
                            : _buildErrorLogsTab(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('ผู้ใช้งาน', state.users.length, Icons.people_rounded, AppColors.primary),
              _buildStatCard('ผู้ปกครอง', state.users.where((u) => u.role == UserRole.parent).length, Icons.person_rounded, AppColors.success),
              _buildStatCard('พนักงาน', state.users.where((u) => u.role == UserRole.staff).length, Icons.person_outline_rounded, AppColors.warning),
              _buildStatCard('QR ทั้งหมด', state.generatedQRs.length, Icons.qr_code_rounded, AppColors.secondary),
              _buildStatCard('QR ที่ใช้งานได้', state.getActiveQRs().length, Icons.qr_code_rounded, AppColors.accent),
              _buildStatCard('เด็กทั้งหมด', state.childStatuses.length, Icons.child_care_rounded, AppColors.primaryLight),
              _buildStatCard('ประกาศ', state.announcements.length, Icons.announcement_rounded, AppColors.secondary),
              _buildStatCard('Error Logs', state.errorLogs.length, Icons.error_rounded, AppColors.danger),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ข้อมูลระบบ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('จำนวนผู้ใช้ทั้งหมด', state.users.length),
                _buildInfoRow('Admin', state.users.where((u) => u.role == UserRole.admin).length),
                _buildInfoRow('Developer', state.users.where((u) => u.role == UserRole.developer).length),
                _buildInfoRow('QR Code ที่สร้าง', state.generatedQRs.length),
                _buildInfoRow('QR ที่ยังใช้งานได้', state.getActiveQRs().length),
                _buildInfoRow('จำนวนเด็ก', state.childStatuses.length),
                _buildInfoRow('ประกาศทั้งหมด', state.announcements.length),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementTab(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สร้างประกาศ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'หัวข้อประกาศ',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'เนื้อหาประกาศ',
              prefixIcon: Icon(Icons.description_rounded),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                  state.addAnnouncement(_titleController.text, _contentController.text);
                  _titleController.clear();
                  _contentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ประกาศถูกเพิ่มแล้ว'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณากรอกหัวข้อและเนื้อหา'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text('เพิ่มประกาศ'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'รายการประกาศ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (state.announcements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'ยังไม่มีประกาศ',
                  style: TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.announcements.length,
              itemBuilder: (context, index) {
                final announce = state.announcements[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              announce.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.danger),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('ลบประกาศ'),
                                  content: const Text('คุณแน่ใจว่าต้องการลบประกาศนี้?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('ยกเลิก'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        state.deleteAnnouncement(announce.id);
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('ลบประกาศสำเร็จ'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      },
                                      child: const Text('ลบ'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announce.content,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${announce.createdAt.toString().substring(0, 16)} โดย ${announce.adminEmail}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildErrorLogsTab(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Error Logs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (state.errorLogs.isNotEmpty)
                TextButton(
                  onPressed: () {
                    state.clearErrorLogs();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ล้าง Error Logs สำเร็จ'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text(
                    'ล้างทั้งหมด',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${state.errorLogs.length} รายการ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: state.errorLogs.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'ไม่มี Error Logs',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.errorLogs.length,
                    itemBuilder: (context, index) {
                      final log = state.errorLogs[state.errorLogs.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          log,
                          style: const TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}