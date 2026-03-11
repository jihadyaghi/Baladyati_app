import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/home_modal.dart';
import 'package:frontend/services/home_service.dart';

class HomePagee extends StatefulWidget {
  const HomePagee({super.key});

  @override
  State<HomePagee> createState() => _HomePageState();
}

class _HomePageState extends State<HomePagee> {
  HomeData? data;
  bool loading = true;
  String? error;
  int navIndex = 0;
  static const Color background = Color(0xFF070E09);
  static const Color surface = Color(0xFF111A13);
  static const Color surface2 = Color(0xFF162B1C);
  static const Color green = Color(0xFF2D9B5A);
  static const Color greenLight = Color(0xFF3DBD71);
  static const Color gold = Color(0xFFC9A84C);
  static const Color red = Color(0xFFE05252);
  static const Color border = Color(0xFF1E3A24);
  static const Color text1 = Color(0xFFF0F0F0);
  static const Color text2 = Color(0xFFA8C4AF);
  static const Color text3 = Color(0xFF5A7A62);
  @override
  void initState(){
    super.initState();
    load();
  }
  Future<void> load() async{
    setState(() {
      loading = true;
      error = null;
    });
    final result = await HomeService.fetchHomeData();
    if(!mounted){
      return;
    }
    setState(() {
      loading = false;
      if(result.success){
        data = result.data;
      }
      else{
        error = result.errorMessage;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light
      )
    );
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: loading ? buildLoding()
        ),
    );
  }
  Widget buildLoding() => const Center(
    child: CircularProgressIndicator(
      color: Color(0xFF2D9B5A),
      strokeWidth: 2.5,
    ),
  );
  Widget buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded , color: Color(0xFF5A7A62),size: 52),
          const SizedBox(height: 16),
          Text(error ?? 'Something went wrong',textAlign: TextAlign.center,style: TextStyle(color: Color(0xFFA8C4AF), fontSize: 15)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:load,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12)
              )
            ),
            child: const Text('Retry',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),

             )
        ],
      ), 
      ),
  );
Widget buildContent(){
  final d = data!;
  return RefreshIndicator(
    color: green,
    backgroundColor: surface,
    onRefresh: load,
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
      children: [
        const SizedBox(height: 8),
        buildHeader(d),
        const SizedBox(height: 24),
        sectionlabel('MUNICIPALITY')
      ],
    ),
     );
}
Widget buildHeader(HomeData d){
  final hour = DateTime.now().hour;
  final greeting = hour < 12
  ? 'Good morning' : hour<17 ? 'Good afternoon' : 'Good Evening';
  final now = DateTime.now();
  const wdays = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  const months =['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final dateStr = '${wdays[now.weekday % 7]}, ${months[now.month]} ${now.day}, ${now.year}';
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$greeting, ${d.firstName}', style: TextStyle(color: text1,fontSize: 20,fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Betormaz · ${d.zone} · $dateStr',style: TextStyle(color: text3,fontSize: 12.5),)
          ],
        ) 
        ),
        GestureDetector(
          onTap: ()=>Navigator.pushNamed(context, ''),
          child: Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: border)
                ),
                child: const Icon(Icons.notifications_rounded, color: text2,size: 22),
              ),
              if((data?.unreadNotifications ?? 0)>0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: gold, shape: BoxShape.circle
                    ),
                  ),
                )
            ],
          ),
        )
    ],
  );
}
Widget sectionlabel(String text) => Text(
  text,
  style: TextStyle(
    color: text3,
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4
  ),
);
Widget buildMunicipalityCard(MunicipalityInfo m){
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: border)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(14)
              ),
            )
          ],
        )
      ],
    ),
  );
}
}