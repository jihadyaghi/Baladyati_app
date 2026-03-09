import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/zone_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPagee extends StatefulWidget {
  const RegisterPagee({super.key});

  @override
  State<RegisterPagee> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPagee> with SingleTickerProviderStateMixin {
  final formkey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final dob = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  double passwordStrength = 0.0;
  String passwordStrengthLabel = '';
  Color passwordStrengthColor = Colors.transparent;
  List<ZoneModel> zones = [];
  ZoneModel? selectedZone;
  bool zonesLoading = true;
  DateTime? selectedDob;
  late AnimationController anim;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;
  static const Color background     = Color(0xFF070E09);
  static const Color surface = Color(0xFF111A13);
  static const Color surface2   = Color(0xFF162B1C);
  static const Color green   = Color(0xFF2D9B5A);
  static const Color greenLight  = Color(0xFF3DBD71);
  static const Color gold    = Color(0xFFC9A84C);
  static const Color border  = Color(0xFF1E3A24);
  static const Color text1   = Color(0xFFF0F0F0);
  static const Color text2   = Color(0xFFA8C4AF);
  static const Color text3   = Color(0xFF5A7A62);
  static const Color red     = Color(0xFFE05252);
  @override
  void initState(){
    super.initState();
    anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700)
      );
    fadeAnim = CurvedAnimation(parent: anim, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
    anim.forward();
    loadZones();
    password.addListener(updatePasswordStrength);
  }
  Future<void> loadZones() async {
    final result = await AuthService.fetchZones();
    if (!mounted) return;
    setState(() {
      zonesLoading = false;
      if (result.success) zones = result.zones;
    });
  }
  @override
  void dispose(){
    anim.dispose();
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    dob.dispose();
    password.dispose();
    confirmPassword.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }
   void updatePasswordStrength() {
    final p = password.text;
    double strength = 0;
    if (p.isEmpty) {
      setState(() {
        passwordStrength = 0;
        passwordStrengthLabel = '';
        passwordStrengthColor = Colors.transparent;
      });
      return;
    }
    if (p.length >= 6)  strength += 0.25;
    if (p.length >= 10) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(p)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(p)) strength += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) strength += 0.2;
    String label;
    Color  color;
    if (strength < 0.35) {
      label = 'Weak';     color = red;
    } else if (strength < 0.65) {
      label = 'Fair';     color = gold;
    } else if (strength < 0.85) {
      label = 'Good';     color = Colors.lightGreen;
    } else {
      label = 'Strong '; color = greenLight;
    }

    setState(() {
      passwordStrength =strength.clamp(0.0, 1.0);
      passwordStrengthLabel =label;
      passwordStrengthColor =color;
    });
  }
  Future<void> pickDate() async{
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDob ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      builder: (ctx,child)=>Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: green,
            onPrimary: Colors.white,
            surface: Color(0xFF111A13),
            onSurface: text1
          ),
          
        ),
        child: child!
        )
      );
      if(picked != null){
        setState(() {
          selectedDob = picked;
          dob.text = '${picked.month.toString().padLeft(2,'0')}/${picked.day.toString().padLeft(2,'0')}/${picked.year}';
        });
      }
  }
  String? validateName(String? v, String field){
    if(v == null || v.trim().isEmpty){
      return '$field is required';
    }
    if(v.trim().length <2){
      return '$field is too short';
    }
    return null;
  }
  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty){
      return 'Phone number is required';
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7){
      return 'Enter a valid phone number';
    }
    return null;
  }
  String? validateDob(String? v) {
    if (selectedDob == null){
      return 'Date of birth is required';
    }
    return null;
  }
  String? validateZone(ZoneModel? v) {
    if (v == null){
      return 'Please select your residential zone';
    }
    return null;
  }
  String? validatePassword(String? v) {
    if (v == null || v.isEmpty){
      return 'Password is required';
    }
    if (v.length < 6){
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty){
      return 'Please confirm your password';
    }
    if (v != password.text){
      return 'Passwords do not match';
    }
    return null;
  }
  Future<void> handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!formkey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    // Format date as YYYY-MM-DD for backend
    final dob = selectedDob!;
    final dobFormatted =
        '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';

    final success = await auth.register(
      firstName:       firstName.text.trim(),
      lastName:        lastName.text.trim(),
      phone:           phone.text.trim(),
      dateOfBirth:     dobFormatted,
      zoneId:          selectedZone!.id,
      password:        password.text,
      confirmPassword: confirmPassword.text,
    );

    if (!mounted){
      return;
    } 

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showError(auth.errorMessage ?? 'Registration failed.');
    }
  }
  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13.5)),
            ),
          ],
        ),
        backgroundColor: red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light
      )
    );
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child:FadeTransition(
          opacity:fadeAnim,
          child: SlideTransition(
            position:slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    buildTopBar(),
                    const SizedBox(height: 28),
                    buildPersonalSection(),
                    const SizedBox(height: 20),
                    _buildZoneSection(),
                    const SizedBox(height: 20),
                    buildSecuritySection(),
                    const SizedBox(height: 28),
                    buildRegisterButton(),
                    const SizedBox(height: 20),
                    buildLoginLink(),
                    const SizedBox(height: 36)
                  ],
                )
                ),
            ), 
            ), 
          ) 
        ),
    );
  }
  Widget buildTopBar(){
    return Row(
      children: [
        GestureDetector(
          onTap: ()=>Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border)
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,color: text2,size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text:const TextSpan(
                style: TextStyle(fontSize: 13,fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: 'Baladi',
                    style: TextStyle(color: text2)
                  ),
                  TextSpan(
                    text: 'yati',
                    style: TextStyle(color: gold),
                  )
                ]
              ) 
              ),
              const Text('Create Account', style: TextStyle(color: text1,fontSize: 22, fontWeight: FontWeight.w900),),
              const Text('Register as a Citizen of Btormaz Municipality',style: TextStyle(color: text3,fontSize: 12.5))
          ],
        )
      ],
    );
  }
  Widget section(String title, List<Widget>children){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: TextStyle(color: text3,fontSize: 10.5,fontWeight: FontWeight.w800,letterSpacing: 1.4)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        )
      ],
    );
  }
  Widget buildPersonalSection(){
    return section('Personal Information', [
      Row(
        children: [
          Expanded(
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label('First Name'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: firstName,
                  focusNode: firstNameFocus,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: text1,fontSize: 15),
                  onFieldSubmitted: (_)=>FocusScope.of(context).requestFocus(lastNameFocus),
                  validator: (v)=>validateName(v, 'First Name'),
                  decoration:inputDeco(hint: 'Jihad') ,
                )
              ],
            ) 
            ),
            const SizedBox(width: 12),
            Expanded(
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('Last Name'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: lastName,
                    focusNode: lastNameFocus,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: text1,fontSize: 15),
                    onFieldSubmitted: (_)=>FocusScope.of(context).requestFocus(phoneFocus),
                    validator: (v)=>validateName(v, 'Last Name'),
                    decoration: inputDeco(hint: 'Yaghie'),
                  )
                ],
              ) 
              )
        ],
      ),
      const SizedBox(height: 16),
      label('Phone Number , used to log in'),
      const SizedBox(height: 7),
      Row(
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: border)
            ),
            child: const Row(
              children: [
                Text('LB',style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text('+961',style: TextStyle(color: text2,fontSize: 14,fontWeight: FontWeight.w700))
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:TextFormField(
              controller: phone,
              focusNode: phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: text1, fontSize: 15),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s]'))
              ],
              onFieldSubmitted: (_)=>pickDate(),
              validator: validatePhone,
              decoration: inputDeco(hint: '81 670 212'),
            ) 
            )
        ],
      ),
      const SizedBox(height: 6),
      const Text('You will use this number to sign in every time.',style: TextStyle(color: text3,fontSize: 11.5)),
      const SizedBox(height: 16),
      label('Date Of Birth'),
      const SizedBox(height: 7),
      TextFormField(
        controller: dob,
        readOnly: true,
        onTap: pickDate,
        validator: validateDob,
        style: TextStyle(color: text1,fontSize: 15),
        decoration: inputDeco(hint: 'MM/DD/YYYY',icon: Icons.calendar_today_rounded),
      )
    ]);
  }
  Widget _buildZoneSection() {
    return section('RESIDENTIAL ZONE', [
      label('RESIDENTIAL ZONE'),
      const SizedBox(height: 7),
      zonesLoading
          ? Container(
              height: 52,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: border),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: green),
                ),
              ),
            )
          : DropdownButtonFormField<ZoneModel>(
              value: selectedZone,
              dropdownColor: surface,
              style: const TextStyle(color: text1, fontSize: 14.5),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: text3),
              decoration: inputDeco(hint: 'Select your zone'),
              validator: validateZone,
              items: zones
                  .map((z) => DropdownMenuItem(
                        value: z,
                        child: Text(z.label,
                            style:
                                const TextStyle(color: text1)),
                      ))
                  .toList(),
              onChanged: (z) => setState(() => selectedZone = z),
            ),
      const SizedBox(height: 12),

      // Zone info banner
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child:  Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Expanded(
  child: RichText(
    text: TextSpan(
      style: TextStyle(
        color: text2,
        fontSize: 12.5,
        height: 1.5,
      ),
      children: [
        TextSpan(
          text: 'Why zone? ',
          style: TextStyle(
            color: gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(
          text:
              'Your zone sets your waste collection schedule '
              'and lets the municipality send you relevant '
              'local notifications.',
        ),
      ],
    ),
  ),
),
          ],
        ),
      ),
    ]);
  }
  Widget buildSecuritySection() {
    return section('SECURITY', [
      label('PASSWORD'),
      const SizedBox(height: 7),
      TextFormField(
        controller: password,
        focusNode: passwordFocus,
        obscureText: obscurePassword,
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: text1, fontSize: 15),
        onFieldSubmitted: (_) =>
            FocusScope.of(context).requestFocus(confirmPasswordFocus),
        validator: validatePassword,
        decoration: inputDeco(
          hint: '••••••••••',
          icon: Icons.lock_rounded,
          suffix: GestureDetector(
            onTap: () =>
                setState(() => obscurePassword = !obscurePassword),
            child: Icon(
              obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,   
              color: text3, size: 20,
            ),
          ),
        ),
      ),

      // Password strength bar
      if (passwordStrength > 0) ...[
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: passwordStrength,
            minHeight: 4,
            backgroundColor: border,
            valueColor:
                AlwaysStoppedAnimation<Color>(passwordStrengthColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          passwordStrengthLabel,
          style: TextStyle(
              color: passwordStrengthColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600),
        ),
      ],

      const SizedBox(height: 16),
      label('CONFIRM PASSWORD'),
      const SizedBox(height: 7),
      TextFormField(
        controller: confirmPassword,
        focusNode: confirmPasswordFocus,
        obscureText: obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        style: const TextStyle(color: text1, fontSize: 15),
        onFieldSubmitted: (_) => handleRegister(),
        validator: validateConfirmPassword,
        decoration: inputDeco(
          hint: '••••••••••',
          icon: Icons.lock_outline_rounded,
          suffix: GestureDetector(
            onTap: () => setState(
                () => obscureConfirmPassword = !obscureConfirmPassword),
            child: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: text3, size: 20,
            ),
          ),
        ),
      ),
    ]);
  }
  Widget buildRegisterButton(){
    return Consumer<AuthProvider>(
      builder: (_,auth,__){
        final loading = auth.isLoading;
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed:loading ? null : handleRegister ,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(15)
              )
            ),
            child: loading ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ):const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4
              ),
            )
            ),
        );
      },
    );
  }
  Widget buildLoginLink(){
    return Center(
      child: GestureDetector(
        onTap: ()=>Navigator.pushReplacementNamed(context, '/login'),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14
            ),
            children: [
              TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: text3)
              ),
              TextSpan(
                text: 'Sign In',
                style: TextStyle(color: greenLight,fontWeight: FontWeight.w800)
              )
            ]
          ) 
          ),
      ),
    );
  }
  Widget label(String text) => Text(
        text,
        style: const TextStyle(
          color: green,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      );
   InputDecoration inputDeco({
    required String hint,
    IconData?       icon,
    Widget?         suffix,
  }) {
    return InputDecoration(
      hintText:  hint,
      hintStyle: const TextStyle(color: text3, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: text3, size: 20)
          : null,
      suffixIcon: suffix != null
          ? Padding(
              padding: const EdgeInsets.only(right: 4), child: suffix)
          : null,
      filled:      true,
      fillColor:   surface2,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: green, width: 1.6)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: red, width: 1.6)),
      errorStyle: const TextStyle(color: red, fontSize: 12),
    );
  }
}