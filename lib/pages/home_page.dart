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
        child: loading ? buildLoding() : error != null ? buildError() : buildContent()
        ),
        bottomNavigationBar: buildBottomNav(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: green,
          elevation: 3,
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white,),
          onPressed: (){
            Navigator.pushNamed(context, '/chat');
          }
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
        sectionlabel('MUNICIPALITY'),
        const SizedBox(height: 10),
        buildMunicipalityCard(d.municipality),
        const SizedBox(height: 22),
        sectionlabel('QUICK ACTIONS'),
        const SizedBox(height: 10),
        buildQuickActions(),
        const SizedBox(height: 24),
        sectionlabel('NEXT WASTE COLLECTION'),
        const SizedBox(height: 10),
        buildWasteCard(d.wasteSchedule),
        const SizedBox(height: 22),
        sectionlabel('MUNICIPALITY STATISTICS'),
        const SizedBox(height: 10),
        buildStatsRow(d.stats),
        const SizedBox(height: 22),
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
        Row(
          children: [
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, '/info');
              },
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: border)
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: text2,
                  size: 22,
                ),
              ),
            ),
            GestureDetector(
          onTap: ()=>Navigator.pushNamed(context, '/notifications'),
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
              child: const Icon(Icons.account_balance_rounded,color: Colors.white,size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name,style: TextStyle(color: text1,fontSize: 16,fontWeight: FontWeight.w800)),
                  Text(m.nameArabic,style: TextStyle(color: text2,fontSize: 12.5)),
                  Text(m.district,style: TextStyle(color: text3,fontSize: 11.5)),
                ],
              ) 
              )
          ],
        ),
        const SizedBox(height: 14),
        const Divider(
          color: Color(0xFF1E3A24),
          height: 1,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: m.isOpenNow ? greenLight : red,
                      shape: BoxShape.circle
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    m.isOpenNow ? 'Open Now': 'Closed',
                    style: TextStyle(
                      color: m.isOpenNow ? greenLight : red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(m.workingHours , style: TextStyle(color: text3,fontSize: 11.5))
                ],
              )
              ),
              GestureDetector(
                onTap: ()=>{

                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone_rounded,color: Colors.white,size: 15),
                      SizedBox(width: 6),
                      Text('Call',style: TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.w700),)
                    ],
                  ),
                ),
              )
          ],
        )
      ],
    ),
  );
}
Widget buildWasteCard(WasteScheduleModal ws){
  final next = ws.nextPickup;
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
            const Text('Waste Schedule',style: TextStyle(color: text1,fontSize: 15,fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border)
              ),
              child: Text(ws.zone,style: TextStyle(color: greenLight,fontSize: 12,fontWeight: FontWeight.w700)),
            )
          ],
        ),
        const SizedBox(height: 14),
        const Divider(color: Color(0xFF1E3A24),height: 1,),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NEXT PICKUP',style: TextStyle(color: text3,fontSize: 9.5,fontWeight: FontWeight.w800,letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text(next?.formattedDate ?? 'No pickup scheduled',style: TextStyle(color: text1,fontSize: 15,fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(next != null ? next.pickupTime.substring(0,5) : 'No schedule set',style: TextStyle(color: text2,fontSize: 12)),
                ],
              )
              ),
              Expanded(
                flex: 5,
                child: buildWeeklyGrid(ws)
                )
          ],
        )
      ],
    ),
  );
}
Widget buildWeeklyGrid(WasteScheduleModal ws){
  if(ws.schedule.isEmpty){
    return const Text('No schedule',style: TextStyle(color: Color(0xFF5A7A62),fontSize: 12));
  }
  final byDay = ws.byDay;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Weekly',style: TextStyle(color: text3,fontSize: 9.5,fontWeight: FontWeight.w800,letterSpacing: 1.2)),
      const SizedBox(height: 6),
      ...byDay.entries.map((entry){
        final dayLabel = entry.key;
        final entries = entry.value;
        final times = entries.map((e)=>e.pickupTime.substring(0, 5)).join(',');
        return Padding(
          padding:const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(dayLabel,style: TextStyle(color: greenLight,fontSize: 12,fontWeight: FontWeight.w700)),
                ),
                Text(times,style: TextStyle(color: text2,fontSize: 12))
            ],
          ), 
          );
      }),
    ],
  );
}
Widget buildStatsRow(MunicipalityStats s){
  return Row(
    children: [
      statCard(s.totalRequests.toString(), 'Total Requests', text1),
      const SizedBox(width: 10),
      statCard(s.openIssues.toString(), 'Open Issues', red),
      const SizedBox(width: 10),
      statCard(s.resolved.toString(), 'Resolved', greenLight)
    ],
  );
}
Widget statCard(String value,String label,Color valueColor){
  return Expanded(
    child:Container(
      padding: const EdgeInsets.symmetric(vertical: 18,horizontal: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border)
      ),
      child: Column(
        children: [
          Text(value,style: TextStyle(color: valueColor,fontSize: 28,fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(label,textAlign: TextAlign.center,style: TextStyle(color: text3,fontSize: 11,height: 1.3)),
        ],
      ),
    ) 
    );
}
Widget buildQuickActions(){
  final actions = [
    {'label': 'Request Doc','icon':Icons.description_rounded,'route': '/requests'},
    {'label': 'Report Issue','icon':Icons.report_problem_rounded, 'route': '/issues'},
    {'label': 'Appointment','icon':Icons.calendar_month_rounded,    'route': '/appointments'},
    {'label': 'Proposals', 'icon':Icons.how_to_vote_rounded,     'route': '/proposals'},//proposals
  ];
   return Row(
      children: actions.map((a) {
        return Expanded(  
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, a['route'] as String),
            child: Container(
              margin: EdgeInsets.only(
                  right: a == actions.last ? 0 : 10),
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 6),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: greenLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: text2,
                      fontSize: 11,
                      fontWeight: FontWeight.w600
                    ),
                  )
                ],
              )
            ),
          ),
        );
      }).toList(),
    );
}
Widget buildBottomNav(){
  const items = [
    {'label': 'Home', 'icon':Icons.home_rounded},
    {'label': 'Requests', 'icon':Icons.description_rounded},
    {'label': 'Profile', 'icon':Icons.person_rounded},
  ];
   return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1710),
        border: Border(top: BorderSide(color: Color(0xFF1E3A24))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == navIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => navIndex = i);
                    const routes = [
                      '/home',  '/requests', '/profile'
                    ];
                    if (i != 0) {
                      Navigator.pushNamed(context, routes[i]);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: active ? greenLight : text3,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          color: active ? greenLight : text3,
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ),
              );
            }),
          ),
        ),
      ),
    );
}
}