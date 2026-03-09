import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
final formkey = GlobalKey<FormState>();
final phone = TextEditingController();
final password = TextEditingController();
final phoneFocus = FocusNode();
final passwordFocus = FocusNode();
bool obscurePassword = true;
late AnimationController animCtrl;
late Animation<double> fadeAnim;
late Animation<Offset> slideAnim;
static const Color background = Color(0xFF070E09);
static const Color surface = Color(0xFF111A13);
static const Color surface2 = Color(0xFF162B1C);
static const Color green = Color(0xFF2D9B5A);
static const Color greenLight = Color(0xFF3DBD71);
static const Color border = Color(0xFF1E3A24);
static const Color text1 = Color(0xFFF0F0F0);
static const Color text2 = Color(0xFFA8C4AF);
static const Color text3 = Color(0xFF5A7A62);
static const Color red = Color(0xFFE05252);
@override
  void initState() {
    super.initState();
    animCtrl = AnimationController(
      vsync:this,
      duration: const Duration(milliseconds: 750) 
      );
    fadeAnim = CurvedAnimation(parent: animCtrl, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero
    ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeOut));
    animCtrl.forward();
  }
  @override
  void dispose() {
    animCtrl.dispose();
    phone.dispose();
    password.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }
  String? validatePhone(String? v){
    if(v==null || v.trim().isEmpty){
      return 'Phone number is required';
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if(digits.length < 7){
      return 'Enter a valid phone number';
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
  Future<void> handleLogin() async {
    FocusScope.of(context).unfocus();
    if(!formkey.currentState!.validate()){
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      phone: phone.text.trim(),
      password: password.text
      );
      if(!mounted){
        return;
      }
      if (success){
        Navigator.pushReplacementNamed(context, '/home');
      }
      else{
        showErrorSnackBar(auth.errorMessage ?? 'Login failed. Try again');
      }
  }
  void showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5)),
            ),
          ],
        ),
        backgroundColor: red,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light
    ));
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child:FadeTransition(
          opacity:fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  buildLogo(),
                  const SizedBox(height: 44),
                  buildCard(),
                  const SizedBox(height: 28),
                  buildRegister(),
                  const SizedBox(height: 32)
                ],
              ),
            ),
            ), 
          ) 
        ),
    );
  }
  Widget buildLogo(){
  return Column(
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: green,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: green,
              blurRadius: 28,
              offset: const Offset(0, 10)
            )
          ]
        ),
        child: const Icon(
          Icons.account_balance_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
      const SizedBox(height: 20),
      RichText(
        text:const TextSpan(
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4
          ),
          children: [
            TextSpan(text: 'Baladi', style: TextStyle(color: text1)),
            TextSpan(text: 'yati', style: TextStyle(color: Color(0xFFC9A84C)))
          ],
        ) 
        ),
        const SizedBox(height: 8),
        const Text('Municipal digital services',textAlign: TextAlign.center,style: TextStyle(color: text2,fontSize: 13.5,height: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 900),
                builder: (_,v,__)=>Opacity(
                  opacity: v,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: greenLight,shape: BoxShape.circle
                    ),
                  ),
                  )
                  ),
                  const SizedBox(width: 8),
                  const Text('Betormaz Municipality', style: TextStyle(color: text2,fontSize: 11.5, fontWeight: FontWeight.w600))
            ],
          ),
        )
    ],
  );
}
Widget buildCard(){
  return Container(
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 24,
          offset: const Offset(0, 8),
        )
      ]
    ),
    child: Form(
      key: formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label('Phone Number'),
          const SizedBox(height: 8),
          buildPhone(),
          const SizedBox(height: 20),
          label('Password'),
          const SizedBox(height: 8),
          buildPassword(),
          const SizedBox(height: 10),
          buildForgetPassword(),
          const SizedBox(height: 24),
          buildSignInButton()
        ],
      )
      ),
  );
}
Widget label(String text) => Text(
        text,
        style: const TextStyle(
          color: green,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      );
Widget buildPhone(){
  return TextFormField(
    controller: phone,
    focusNode: phoneFocus,
    keyboardType: TextInputType.phone,
    textInputAction: TextInputAction.next,
    style: TextStyle(color: text1,fontSize: 15),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-]'))
    ],
    onFieldSubmitted: (_)=>FocusScope.of(context).requestFocus(passwordFocus),
    validator: validatePhone,
    decoration: inputDeco(
      hint: '+961 81 670 212',
       icon: Icons.phone_iphone_rounded
       ),
  );
}
InputDecoration inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: text3, fontSize: 14),
      prefixIcon: Icon(icon, color: text3, size: 20),
      suffixIcon: suffix != null
          ? Padding(
              padding: const EdgeInsets.only(right: 4), child: suffix)
          : null,
      filled: true,
      fillColor: surface2,
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
  Widget buildPassword(){
    return TextFormField(
      controller: password,
      focusNode: passwordFocus,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: text1,fontSize: 15),
      onFieldSubmitted: (_)=> handleLogin(),
      validator: validatePassword,
      decoration: inputDeco(
        hint: '••••••••••',
        icon: Icons.lock_rounded,
        suffix: GestureDetector(
          onTap: ()=>setState(()=> 
            obscurePassword = !obscurePassword
          ),
          child: Icon(
            obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: text3,
            size: 20,
          ),
        )
         ),
    );
  }
  Widget buildForgetPassword(){
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: ()=>Navigator.pushNamed(context, 'routeName'),
        child: RichText(
          text:const TextSpan(
            style: TextStyle(fontSize: 13),
            children: [
              TextSpan(text: 'Forget Password?',style: TextStyle(color: Color(0xFFC9A84C))),
            ]
          ) 
          ),
      ),
    );
  }
  Widget buildSignInButton(){
    return Consumer<AuthProvider>(
      builder: (_,auth,__){
        final loading = auth.isLoading;
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:loading ? null : handleLogin ,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              disabledBackgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)
              ),
            ),
            child: loading ?
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ): const Text(
              'Sign In',
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800,letterSpacing: 0.4),
            )
            ),
        );
      },
    );
  }
  Widget buildRegister(){
    return GestureDetector(
      onTap: ()=>Navigator.pushNamed(context, '/register'),
      child: RichText(
        text:const TextSpan(
          style: TextStyle(fontSize: 14),
          children: [
            TextSpan(
              text: "Don't have an account?",
              style: TextStyle(color: text3)
            ),
            TextSpan(
              text: "Register",
              style: TextStyle(color: greenLight,fontWeight: FontWeight.w800)
            )
          ]
        ) 
        ),
    );
  }
}
