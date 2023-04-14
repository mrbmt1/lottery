import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<int> _vietlottResults = [];
  int _drawPeriodCount = 0;
  List<int> _drawPeriods = [];
  List<List<int>> _winningNumbers = [];

  @override
  void initState() {
    super.initState();
    loadNumbers();
  }

  void loadNumbers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();
    final results = snapshot.docs.map((doc) => doc.data()).toList();

    for (var result in results) {
      final numbers = [
        result['number_1'],
        result['number_2'],
        result['number_3'],
        result['number_4'],
        result['number_5'],
        result['number_6'],
        result['special_number']
      ];

      final List<int> winningNumbers = [];
      for (var number in numbers) {
        if (number != null) {
          winningNumbers.add(number);
        }
      }

      if (winningNumbers.length == 7) {
        _winningNumbers.add(winningNumbers);
        _drawPeriods.add(result['draw_period']);
      }
    }

    _drawPeriodCount = _drawPeriods.length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sàn 6/55'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 22, 25, 179),
      ),
      body: Container(
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
        child: InteractiveViewer(
          constrained: true,
          minScale: 1,
          maxScale: 20,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _drawPeriodCount,
            itemBuilder: (context, index) {
              final drawPeriod = _drawPeriods[index];
              final winningNumbers = _winningNumbers[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    child: Center(
                      child: Text(
                        '${drawPeriod.toString().padLeft(4, '0')}',
                        style: TextStyle(
                          fontSize: 3.5,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ...List.generate(
                    55,
                    (index) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: winningNumbers.contains(index + 1)
                            ? Colors.red
                            : Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}'.padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 3.5,
                            color: winningNumbers.contains(index + 1)
                                ? Colors.white
                                : Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
