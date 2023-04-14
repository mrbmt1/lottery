import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottery/chart.dart';
import 'package:lottery/checking.dart';
import 'package:lottery/edit.dart';
import 'package:lottery/history.dart';
import 'package:lottery/import.dart';
import 'package:lottery/login.dart';
import 'package:lottery/scan.dart';
import 'package:lottery/support.dart';

//log out function
void logout(BuildContext context) async {
  bool confirm = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Đăng xuất"),
      content: Text("Bạn muốn đăng xuất khỏi tài khoản?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text("Không"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text("Có"),
        ),
      ],
    ),
  );
  if (confirm == true) {
    // Đăng xuất khỏi Firebase Authentication
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

class LotteryScreen extends StatefulWidget {
  @override
  _LotteryScreenState createState() => _LotteryScreenState();
}

class _LotteryScreenState extends State<LotteryScreen> {
  String _drawDate = "";
  String _drawCode = "";
  int _regularNumber1Controller = 0;
  int _regularNumber2Controller = 0;
  int _regularNumber3Controller = 0;
  int _regularNumber4Controller = 0;
  int _regularNumber5Controller = 0;
  int _regularNumber6Controller = 0;
  int _specialNumberController = 0;
  int _prize1Value = 0;
  int _prize2Value = 0;
  int _jackpot1Winner = 0;
  int _jackpot1Prize = 0;
  int _jackpot2Winner = 0;
  int _jackpot2Prize = 0;
  List<String> _drawCodes = [];
  List<String> _drawDates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadDraws() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final List<String> drawCodes = snapshot.docs
          .map((doc) => doc.data()['draw_period'].toString())
          .toList();

      setState(() {
        _drawCodes = drawCodes;
      });
    }
  }

  Future<void> _loadDrawDates() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_date', descending: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final List<String> drawDates = snapshot.docs
          .map((doc) => doc.data()['draw_date'].toString())
          .toList();

      setState(() {
        _drawDates = drawDates;
      });
    }
  }

  void showDrawDates() async {
    await _loadDrawDates();
    List<String> filteredDrawDates = List<String>.from(_drawDates);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController searchController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 22, 25, 179),
                      Color.fromARGB(255, 172, 40, 16),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            "Chọn ngày",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          filteredDrawDates = _drawDates
                              .where((drawDate) => drawDate.contains(value))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo ngày',
                        hintStyle: TextStyle(color: Colors.white),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredDrawDates.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              filteredDrawDates[index],
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await _loadDataForDrawDate(
                                  filteredDrawDates[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showDrawCodes() async {
    await _loadDraws();
    List<String> filteredDrawCodes = List<String>.from(_drawCodes);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController searchController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 22, 25, 179),
                      Color.fromARGB(255, 172, 40, 16),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            "Chọn kỳ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          filteredDrawCodes = _drawCodes
                              .where((drawCode) => drawCode.contains(value))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo kỳ',
                        hintStyle: TextStyle(color: Colors.white),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredDrawCodes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              filteredDrawCodes[index],
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await _loadDataForDraw(filteredDrawCodes[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadDataForDrawDate(String drawDate) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .where('draw_date', isEqualTo: drawDate)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _drawDate = data['draw_date'];
        _drawCode = data['draw_period'].toString();
        _regularNumber1Controller = data['number_1'];
        _regularNumber2Controller = data['number_2'];
        _regularNumber3Controller = data['number_3'];
        _regularNumber4Controller = data['number_4'];
        _regularNumber5Controller = data['number_5'];
        _regularNumber6Controller = data['number_6'];
        _specialNumberController = data['special_number'];
        _prize1Value = data['prize1_value'];
        _prize2Value = data['prize2_value'];
        _jackpot1Winner = data['jackpot1_winner'];
        _jackpot1Prize = data['jackpot1_prize'];
        _jackpot2Winner = data['jackpot2_winner'];
        _jackpot2Prize = data['jackpot2_prize'];
      });
    }
  }

  Future<void> _loadDataForDraw(String drawCode) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .where('draw_period', isEqualTo: int.parse(drawCode))
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _drawDate = data['draw_date'];
        _drawCode = data['draw_period'].toString();
        _regularNumber1Controller = data['number_1'];
        _regularNumber2Controller = data['number_2'];
        _regularNumber3Controller = data['number_3'];
        _regularNumber4Controller = data['number_4'];
        _regularNumber5Controller = data['number_5'];
        _regularNumber6Controller = data['number_6'];
        _specialNumberController = data['special_number'];
        _prize1Value = data['prize1_value'];
        _prize2Value = data['prize2_value'];
        _jackpot1Winner = data['jackpot1_winner'];
        _jackpot1Prize = data['jackpot1_prize'];
        _jackpot2Winner = data['jackpot2_winner'];
        _jackpot2Prize = data['jackpot2_prize'];
      });
    }
  }

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _drawDate = data['draw_date'];
        _drawCode = data['draw_period'].toString();
        _regularNumber1Controller = data['number_1'];
        _regularNumber2Controller = data['number_2'];
        _regularNumber3Controller = data['number_3'];
        _regularNumber4Controller = data['number_4'];
        _regularNumber5Controller = data['number_5'];
        _regularNumber6Controller = data['number_6'];
        _specialNumberController = data['special_number'];
        _prize1Value = data['prize1_value'];
        _prize2Value = data['prize2_value'];
        _jackpot1Winner = data['jackpot1_winner'];
        _jackpot1Prize = data['jackpot1_prize'];
        _jackpot2Winner = data['jackpot2_winner'];
        _jackpot2Prize = data['jackpot2_prize'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Kết quả Vietlott 6/55"),
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 22, 25, 179),
        ),
        drawer: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 22, 25, 179),
                  Color.fromARGB(255, 172, 40, 16),
                ],
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Text('Menu',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: Icon(Icons.insert_chart_outlined_outlined,
                      color: Colors.white),
                  title: Text(
                    'Import kết quả',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Vietlott655Form()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_outlined, color: Colors.white),
                  title: Text(
                    'Dò số bằng camera',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ScanningScreen()),
                    );
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.find_in_page_rounded, color: Colors.white),
                  title: Text(
                    'Dò số nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CheckingScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart, color: Colors.white),
                  title: Text(
                    'Thống kê',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChartScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.dashboard, color: Colors.white),
                  title: Text(
                    'Sàn 655',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DashBoard()),
                    );
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.support_agent_rounded, color: Colors.white),
                  title: Text(
                    'Liên hệ và hỗ trợ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SupportScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text(
                    'Thoát',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    logout(context);
                  },
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 22, 25, 179),
                      Color.fromARGB(255, 172, 40, 16),
                    ],
                  ),
                ),
                child: Stack(children: [
                  if (_jackpot1Winner > 0 || _jackpot2Winner > 0)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/jackpotwin.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        GestureDetector(
                          onTap: () {
                            showDrawCodes();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Kỳ số: ",
                                style: TextStyle(
                                  fontSize: 23,
                                  // fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 238, 232, 232),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3.0, 3.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDrawCodes();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Color.fromARGB(255, 238, 232, 232),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 7, 13, 92)
                                            .withOpacity(0.5),
                                        offset: Offset(5, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Text(
                                    "$_drawCode",
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 238, 232, 232),
                                      shadows: [
                                        Shadow(
                                          offset: Offset(3.0, 3.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0)
                                              .withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDrawDates();
                          },
                          child: Column(
                            children: [
                              Text(
                                "Ngày mở thưởng:",
                                style: TextStyle(
                                  fontSize: 23,
                                  // fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 238, 232, 232),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3.0, 3.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 7),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 238, 232, 232),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 7, 13, 92)
                                          .withOpacity(0.5),
                                      offset: Offset(6, 5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  " $_drawDate",
                                  style: TextStyle(
                                    fontSize: 22,
                                    // fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 238, 232, 232),
                                    shadows: [
                                      Shadow(
                                        offset: Offset(3.0, 3.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0)
                                            .withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Kết quả xổ số",
                          style: TextStyle(
                            fontSize: 28,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(3.0, 3.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "$_regularNumber1Controller"
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "$_regularNumber2Controller"
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "$_regularNumber3Controller"
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "$_regularNumber4Controller"
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "$_regularNumber5Controller"
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "$_regularNumber6Controller"
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.red,
                                    Color.fromARGB(255, 33, 65, 243)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "$_specialNumberController"
                                    .toString()
                                    .padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            color: _jackpot1Winner > 0
                                ? Colors.transparent
                                : null, // thay đổi màu sắc nếu jackpot1Winner > 0
                            boxShadow: _jackpot1Winner > 0
                                ? [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      spreadRadius: 15,
                                      blurRadius: 35,
                                      offset: Offset(0,
                                          3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Trị giá Jackpot 1: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 238, 232, 232),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3.0, 3.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 9),
                              Text(
                                "${(_prize1Value).toStringAsFixed(0).replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (match) => '${match[1]}.',
                                    ).toString()} VNĐ",
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 238, 232, 232),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3.0, 3.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(255, 238, 232, 232),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            color:
                                _jackpot2Winner > 0 ? Colors.transparent : null,
                            boxShadow: _jackpot2Winner > 0
                                ? [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      spreadRadius: 15,
                                      blurRadius: 35,
                                      offset: Offset(0,
                                          3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Trị giá Jackpot 2: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 238, 232, 232),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3.0, 3.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 9),
                              Text(
                                "${(_prize2Value).toStringAsFixed(0).replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (match) => '${match[1]}.',
                                    ).toString()} VNĐ",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 238, 232, 232),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3.0, 3.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),
                        Container(
                          child: Text(
                            "Jackpot 1:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _jackpot1Winner > 0
                                  ? Colors.yellow // Đổi màu nếu có người trúng
                                  : Color.fromARGB(255, 238, 232, 232),
                              shadows: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  spreadRadius: 15,
                                  blurRadius: 35,
                                  offset: Offset(0,
                                      3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          child: Text(
                            "Số người trúng: $_jackpot1Winner",
                            style: TextStyle(
                              fontSize: 20,
                              color: _jackpot1Winner > 0
                                  ? Colors.yellow // Đổi màu nếu có người trúng
                                  : Color.fromARGB(255, 238, 232, 232),
                              shadows: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  spreadRadius: 15,
                                  blurRadius: 35,
                                  offset: Offset(0,
                                      3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            "${(_jackpot1Prize).toStringAsFixed(0).replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (match) => '${match[1]}.',
                                ).toString()} VNĐ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _jackpot1Winner > 0
                                  ? Colors.yellow // Đổi màu nếu có người trúng
                                  : Color.fromARGB(255, 238, 232, 232),
                              shadows: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  spreadRadius: 15,
                                  blurRadius: 35,
                                  offset: Offset(0,
                                      3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                )
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        Container(
                          child: Text(
                            "Jackpot 2:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _jackpot2Winner > 0
                                  ? Colors.yellow // Đổi màu nếu có người trúng
                                  : Color.fromARGB(255, 238, 232, 232),
                              shadows: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  spreadRadius: 15,
                                  blurRadius: 35,
                                  offset: Offset(0,
                                      3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          child: Text(
                            "Số người trúng: $_jackpot2Winner",
                            style: TextStyle(
                              fontSize: 20,
                              color: _jackpot2Winner > 0
                                  ? Colors.yellow // Đổi màu nếu có người trúng
                                  : Color.fromARGB(255, 238, 232, 232),
                              shadows: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  spreadRadius: 15,
                                  blurRadius: 35,
                                  offset: Offset(0,
                                      3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            "${(_jackpot2Prize).toStringAsFixed(0).replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (match) => '${match[1]}.',
                                ).toString()} VNĐ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _jackpot2Winner > 0
                                  ? Colors.yellow // Đổi màu nếu có người trúng
                                  : Color.fromARGB(255, 238, 232, 232),
                              shadows: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  spreadRadius: 15,
                                  blurRadius: 35,
                                  offset: Offset(0,
                                      3), // thêm hiệu ứng chói sáng nếu jackpot1Winner > 0
                                )
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(height: 80),
                      ],
                    ),
                  ),
                ])),
          ),
        ));
  }
}
