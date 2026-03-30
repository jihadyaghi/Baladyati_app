import 'package:flutter/material.dart';
import 'package:frontend/pages/appointments/appointments_page.dart';
import 'package:frontend/pages/auth/login_page.dart';
import 'package:frontend/pages/auth/register_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/notification_page.dart';
import 'package:frontend/pages/proposals/proposals_page.dart';
import 'package:frontend/pages/report_issue_page.dart';
import 'package:frontend/pages/request/requests_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
Widget build(BuildContext context){
  final citizen = context.watch<AuthProvider>().citizen;
  return Scaffold(
    backgroundColor: const Color(0xFF070E09),
    appBar: AppBar(
      backgroundColor: const Color(0xFF111A13),
      title: Text("Welcome, ${citizen?.firstname ?? 'Citizen'}!",style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if(context.mounted){
              Navigator.pushReplacementNamed(context, '/login');
            }
          } ,
          icon: const Icon(Icons.logout_rounded, color: Colors.white) 
          )
      ],
    ),
    body: Center(
      child: Text('${citizen?.fullName}\n ${citizen?.zone}',textAlign: TextAlign.center,style: const TextStyle(color: Colors.white,fontSize: 18)),
    ),
  );
}
}
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text('Register Page',
              style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color(0xFF070E09),
      );
}
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_)=>AuthProvider(),
      child: const MyApp(),
      )
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baladiyati',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF070E09),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2D9B5A),
          secondary: Color(0xFF3DBD71)
        )
      ),
       home: _SplashRouter(),
       routes: {
        '/login': (_)=> const LoginPage(),
        '/home': (_)=>const HomePagee(),
        '/register': (_)=>const RegisterPagee(),
        '/requests': (_)=>const RequestsPage(),
        '/notifications': (_)=> const NotificationPage(),
        '/appointments': (_)=> const AppointmentsPage(),
        '/proposals': (_)=> const ProposalsPage(),
        '/issues': (_)=> const ReportIssuePage()
       },
    );
  }
}
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => __SplashRouterState();
}

class __SplashRouterState extends State<_SplashRouter> {
  @override
  void initState(){
    super.initState();
    _checkAuth();
  }
  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      loggedIn ? '/home' : '/login',
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF070E09),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_rounded, color: Color(0xFF2D9B5A),size: 60),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Color(0xFF2D9B5A),
              strokeWidth: 2.5,
            )
          ],
        ),
      ),
    );
  }
}
