import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottery/edit.dart';

class Vietlott655Form extends StatefulWidget {
  @override
  _Vietlott655FormState createState() => _Vietlott655FormState();
}

class _Vietlott655FormState extends State<Vietlott655Form> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _regularNumber1Controller =
      TextEditingController();
  final TextEditingController _regularNumber2Controller =
      TextEditingController();
  final TextEditingController _regularNumber3Controller =
      TextEditingController();
  final TextEditingController _regularNumber4Controller =
      TextEditingController();
  final TextEditingController _regularNumber5Controller =
      TextEditingController();
  final TextEditingController _regularNumber6Controller =
      TextEditingController();
  final TextEditingController _specialNumberController =
      TextEditingController();
  final TextEditingController _prize1ValueController = TextEditingController();
  final TextEditingController _prize2ValueController = TextEditingController();

  final TextEditingController _jackpot1Controller = TextEditingController();
  final TextEditingController _jackpot1prizeController =
      TextEditingController();

  final TextEditingController _jackpot2Controller = TextEditingController();
  final TextEditingController _jackpot2prizeController =
      TextEditingController();

  final TextEditingController _drawPeriodController = TextEditingController();
  final TextEditingController _drawDateController = TextEditingController();
  final prizeValueFormat = NumberFormat.decimalPattern();

  void _selectDate(BuildContext context) async {
    await initializeDateFormatting('vi_VN', null);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2017),
      lastDate: DateTime(2100),
      locale: Locale('vi', 'VN'),
    );

    if (picked != null) {
      final DateFormat formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
      final String formattedDate = formatter.format(picked);
      setState(() {
        _drawDateController.text = formattedDate;
      });
    }
  }

  String? _validateNumber(String? value, TextEditingController controller) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số';
    }

    final number = int.tryParse(value);
    if (number == null || number < 1 || number > 55) {
      return 'Số phải là số tự nhiên từ 1 đến 55';
    }

    final duplicateControllers = [
      _regularNumber1Controller,
      _regularNumber2Controller,
      _regularNumber3Controller,
      _regularNumber4Controller,
      _regularNumber5Controller,
      _regularNumber6Controller,
      _specialNumberController,
    ].where((c) => c != controller);

    if (duplicateControllers.any((c) => c.text == value)) {
      return 'Số không được trùng nhau';
    }

    return null;
  }

  Future<bool> _checkDrawPeriodExistence(int drawPeriod) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .where('draw_period', isEqualTo: drawPeriod)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // A document with the given draw period already exists
      return true;
    } else {
      // No document with the given draw period exists
      return false;
    }
  }

  @override
  void dispose() {
    _regularNumber1Controller.dispose();
    _regularNumber2Controller.dispose();
    _regularNumber3Controller.dispose();
    _regularNumber4Controller.dispose();
    _regularNumber5Controller.dispose();
    _regularNumber6Controller.dispose();
    _specialNumberController.dispose();
    _prize1ValueController.dispose();
    _prize2ValueController.dispose();

    _jackpot1Controller.dispose();
    _jackpot1prizeController.dispose();

    _jackpot2Controller.dispose();
    _jackpot2prizeController.dispose();

    _drawPeriodController.dispose();
    _drawDateController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      // Check if the draw period already exists
      final drawPeriod = int.tryParse(_drawPeriodController.text.trim()) ?? 0;
      final drawPeriodExists = await _checkDrawPeriodExistence(drawPeriod);

      if (drawPeriodExists) {
        // A document with the given draw period already exists
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Thông báo'),
              content: Text(
                  'Kỳ đã tồn tại, vui lòng chỉnh sửa hoặc xóa kết quả kỳ cũ trước khi import thông tin kỳ mới.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Đóng'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        int jackpot1Winner = int.tryParse(_jackpot1Controller.text.trim()) ?? 0;
        int jackpot2Winner = int.tryParse(_jackpot2Controller.text.trim()) ?? 0;
        int prize1Value = int.tryParse(_prize1ValueController.text.trim()) ?? 0;
        int prize2Value = int.tryParse(_prize2ValueController.text.trim()) ?? 0;

        int jackpot1Prize =
            jackpot1Winner > 0 ? (prize1Value ~/ jackpot1Winner) : 0;
        int jackpot2Prize =
            jackpot2Winner > 0 ? (prize2Value ~/ jackpot2Winner) : 0;

        await FirebaseFirestore.instance
            .collection('vietlott_655_results')
            .add({
          'number_1': _regularNumber1Controller.text.trim().isEmpty
              ? null
              : int.tryParse(_regularNumber1Controller.text.trim()),
          'number_2': _regularNumber2Controller.text.trim().isEmpty
              ? null
              : int.tryParse(_regularNumber2Controller.text.trim()),
          'number_3': _regularNumber3Controller.text.trim().isEmpty
              ? null
              : int.tryParse(_regularNumber3Controller.text.trim()),
          'number_4': _regularNumber4Controller.text.trim().isEmpty
              ? null
              : int.tryParse(_regularNumber4Controller.text.trim()),
          'number_5': _regularNumber5Controller.text.trim().isEmpty
              ? null
              : int.tryParse(_regularNumber5Controller.text.trim()),
          'number_6': _regularNumber6Controller.text.trim().isEmpty
              ? null
              : int.tryParse(_regularNumber6Controller.text.trim()),
          'special_number': int.tryParse(_specialNumberController.text.trim()),
          'prize1_value': prize1Value,
          'prize2_value': prize2Value,
          'jackpot1_winner': jackpot1Winner,
          'jackpot1_prize': jackpot1Prize,
          'jackpot2_winner': jackpot2Winner,
          'jackpot2_prize': jackpot2Prize,
          'draw_period': int.tryParse(_drawPeriodController.text.trim()),
          'draw_date': _drawDateController.text.trim(),
          'created_at': FieldValue.serverTimestamp(),
        });
        // Show a notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thông tin vé số đã được lưu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhập thông tin kỳ xổ'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 22, 25, 179),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditVietlott655Form(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Sửa thông tin kỳ'),
              ),
            ],
          ),
        ],
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
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _drawPeriodController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kỳ xổ',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập kỳ xổ';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final intDrawPeriod = int.tryParse(newValue.text);
                    if (intDrawPeriod == null || intDrawPeriod < 0) {
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
              ),
              TextFormField(
                controller: _drawDateController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Thời gian mở giải',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập thời gian mở giải';
                  }
                  return null;
                },
                onTap: () {
                  _selectDate(context);
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'cặp 1',
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _regularNumber1Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, _regularNumber1Controller),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'cặp 2',
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _regularNumber2Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, _regularNumber2Controller),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'cặp 3',
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _regularNumber3Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, _regularNumber3Controller),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'cặp 4',
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _regularNumber4Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, _regularNumber4Controller),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'cặp 5',
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _regularNumber5Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, _regularNumber5Controller),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'cặp 6',
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _regularNumber6Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          _validateNumber(value, _regularNumber6Controller),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _specialNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cặp số đặc biệt',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    _validateNumber(value, _specialNumberController),
              ),
              TextFormField(
                controller: _prize1ValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá trị Jackpot 1',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập giá trị giải thưởng';
                  }
                  final prizeValue = int.tryParse(value);
                  if (prizeValue == null || prizeValue <= 30000000000) {
                    return 'Giá trị giải thưởng phải lớn hơn 30 tỷ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prize2ValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá trị Jackpot 2',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập giá trị giải thưởng';
                  }
                  final prize2Value = int.tryParse(value);
                  if (prize2Value == null || prize2Value <= 120000000) {
                    return 'Giá trị giải thưởng phải lớn hơn 120 triệu';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jackpot1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số người trúng Jackpot 1',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập số người trúng Jackpot 1';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jackpot1prizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Số tiền trúng(tự động chia dựa theo số người trúng)',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jackpot2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số người trúng Jackpot 2',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập số người trúng Jackpot 2';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jackpot2prizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền trúng',
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Lưu thông tin'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  side: BorderSide(
                    width: 2,
                    color: Colors.blue,
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
