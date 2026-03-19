  import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:frontend/services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  List<AppNotification> all = [];
  bool loading = true;
  String? error;
  int unreadCount = 0;
  String filter = 'all';
  late AnimationController animCtrl;
  late Animation<double> fadeAnim;
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
    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      );
      fadeAnim = CurvedAnimation(
        parent: animCtrl, 
        curve: Curves.easeOut
        );
        load();
  }
  @override
  void dispose(){
    animCtrl.dispose();
    super.dispose();
  }
  Future<void> load() async{
    setState(() {
      loading = true;
      error = null;
    });
    final result = await NotificationService.getNotification();
    if (!mounted) return;
    setState(() {
      loading = false;
      if(result.success){
        all = result.notifications;
        unreadCount = result.unreadCount;
        animCtrl.forward(from: 0);
      }
      else{
        error = result.errorMessage;
      }
    });
  }
  List<AppNotification> get filtered{
    if(filter == 'unread'){
      return all.where((n)=> !n.isRead).toList();
    }
    return all;
  }
  Future<void> markOneRead(AppNotification n) async{
    if (n.isRead) return;
    setState(() {
      final idx = all.indexWhere((x) => x.id == n.id);
      if (idx != -1){
        all[idx] = n.copyWith(isRead: true);
        unreadCount = (unreadCount - 1).clamp(0, 9999);
      }
    });
    await NotificationService.markOneRead(n.id);
  }
  Future<void> markAllRead() async{
    setState(() {
      all = all.map((n)=> n.copyWith(isRead: true)).toList();
      unreadCount = 0;
    });
    await NotificationService.markAllRead();
  }
  Future<void> deleteOne(AppNotification n) async{
    setState(() {
      if (!n.isRead && unreadCount>0){
        unreadCount --;
      }
      all.removeWhere((x)=>x.id == n.id);
    });
    await NotificationService.deleteOne(n.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted.',style: TextStyle(color: Colors.white)),
        backgroundColor: text3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        )
    );
  }
  Future<void> clearAll() async{
    final confirm = await showDialog<bool>(
      context: context, 
      builder: (_)=> AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18)
        ),
        title: const Text(
          'Clear All',
          style: TextStyle(
            color: text1,
            fontWeight: FontWeight.w800
          ),
        ),
        content: const Text(
          'Delete all notifications? this cannot be undone.',
          style: TextStyle(
            color: text2,
            height: 1.5
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()=> Navigator.pop(context,false), 
            child: const Text('Cancel', style: TextStyle(color: greenLight,fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: ()=> Navigator.pop(context,true), 
              child: const Text('Clear All',style: TextStyle(color: red,fontWeight: FontWeight.w700))
              ),
        ],
      )
      );
      if (confirm != true) return;
      setState(() {
        all = [];
        unreadCount = 0;
      });
      await NotificationService.deleteAll();
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
        child: Column(
          children: [
            buildHeader(),
            if (!loading && error == null) buildFilterRow(),
            Expanded(child: buildBody())
          ],
        )
        ),
    );
  }
  Widget buildHeader(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border)
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: text2,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                const Text('Notifications',style: TextStyle(color: text1,fontSize: 20,fontWeight: FontWeight.w900)),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9,vertical: 3),
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gold)
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: TextStyle(color: gold,fontSize: 11.5,fontWeight: FontWeight.w700),
                    ),
                  )
                ]
              ],
            )
            ),
            if (!loading && all.isNotEmpty) PopupMenuButton<String>(
              color: surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: border)
              ),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border)
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: text2,
                  size: 20,
                ),
              ),
              onSelected: (v){
                if (v == 'read_all') markAllRead();
                if (v == 'clear_all') clearAll();
              },
              itemBuilder: (_)=>[
                if (unreadCount > 0) PopupMenuItem(
                  value: 'read_all',
                  child: Row(
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        color: Color(0xFF3DBD71),
                        size: 18,
                      ),
                      const SizedBox(width: 18),
                      Text(
                        'Mark all as read',
                        style: TextStyle(color: text1),
                      )
                    ],
                  )
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_sweep_rounded,
                          color: Color(0xFFE05252),
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text('Clear All',style: TextStyle(color: text1),)
                      ],
                    )
                    )
              ]
              )
        ],
      ),
      );
  }
  Widget buildFilterRow(){
    final unreadCnt = all.where((n)=> !n.isRead).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          filterChip('all', 'All (${all.length})'),
          const SizedBox(width: 10),
          filterChip('unread', 'Unread ($unreadCnt)')
        ],
      ),
      );
  }
  Widget filterChip(String value, String label){
    final active = filter == value;
    return GestureDetector(
      onTap: ()=> setState(()=> filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
        decoration: BoxDecoration(
          color: active ? green : surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? green : border)
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : text3,
            fontSize: 12.5,
            fontWeight: active ?  FontWeight.w700 : FontWeight.w500
          ),
        ),
        ),
    );
  }
  Widget buildBody(){
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D9B5A),
          strokeWidth: 2.5,
        ),
      );
    }
    if (error != null){
      return buildError();
    }
    final items = filtered;
    if (items.isEmpty){
      return buildEmpty();
    }
    return FadeTransition(
      opacity: fadeAnim,
      child: RefreshIndicator(
        color: green,
        backgroundColor: surface,
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          itemCount: items.length,
          itemBuilder: (_, i){
            final n = items[i];
            final showDate = i == 0 || !sameDay(items[i -1], n);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDate) buildDateHeader(n),
                buildCard(n)
              ],
            );
          }
          ) , 
        
        ),
      );
  }
  Widget buildError(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: text3,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text2,
                fontSize: 14,
                height: 1.5
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: load,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ), 
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700
                ),
              )
              )
          ],
        ),
        ),
    );
  }
  Widget buildEmpty(){
    final isUnreadFilter = filter == 'unread';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_rounded,
              color: text3,
              size: 56,
            ),
            const SizedBox(height: 18),
            Text(
              isUnreadFilter ? 'All caught up!' : 'No notifications yet',
              style: TextStyle(
                color: text1,
                fontSize: 17,
                fontWeight: FontWeight.w800
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUnreadFilter ? 'You have read all your notifications.' : 'we \'ll notify you about your requests, \n appointments and announcements.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text3,
                fontSize: 13.5,
                height: 1.5
              ),
            ),
            if (isUnreadFilter) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(()=> filter = 'all'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  decoration: BoxDecoration(
                    color: surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: const Text(
                    'View all notifications',
                    style: TextStyle(
                      color: greenLight,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                ),
              )
            ]
          ],
        ),
        ),
    );
  }
  bool sameDay(AppNotification a, AppNotification b){
    try {
      final da = DateTime.parse(a.createdAt);
      final db = DateTime.parse(b.createdAt);
      return da.year == db.year && da.month == db.month && da.day == db.day;
    }
    catch (_){
      return false;
    }
  }
  Widget buildDateHeader(AppNotification n){
    String label;
    try{
      final dt = DateTime.parse(n.createdAt).toLocal();
      final now = DateTime.now();
      final diff = DateTime(now.year, now.month, now.day).difference(DateTime(dt.year,dt.month,dt.day)).inDays;
      if (diff == 0){
        label = 'Today';
      }
      else if (diff == 1){
        label = 'Yesterday';
      }
      else {
        const months = [
          '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
        ];
        label = '${months[dt.month]} ${dt.day}, ${dt.year}';
      }
    }
    catch (_){
      label = '';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10,top: 6),
      child: Text(
        label,
        style: TextStyle(
          color: text3,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5
        ),
      ),
      );
  }
  Widget buildCard(AppNotification n) {
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: red,
          ),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: red,
          size: 24,
        ),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => deleteOne(n),
      child: GestureDetector(
        onTap: () => markOneRead(n),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n.isRead ? surface : surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: n.isRead ? border : n.type.color,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: n.type.bgColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Icon(
                    n.type.icon,
                    color: n.type.color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title.isNotEmpty ? n.title : n.type.label,
                            style: TextStyle(
                              color: n.type.color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          n.timeAgo,
                          style: const TextStyle(
                            color: text3,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      n.message,
                      style: TextStyle(
                        color: n.isRead ? text2 : text1,
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight:
                            n.isRead ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!n.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
}
}