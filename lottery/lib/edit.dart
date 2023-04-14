import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottery/import.dart';

class EditVietlott655Form extends StatefulWidget {
  @override
  _EditVietlott655FormState createState() => _EditVietlott655FormState();
}

class _EditVietlott655FormState extends State<EditVietlott655Form> {
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
  List<String> _drawPeriods = [];

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

  @override
  void initState() {
    super.initState();
    _getDrawPeriods();
  }

  Future<void> _getDrawPeriods() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('vietlott_655_results')
          .orderBy('draw_period', descending: true)
          .get();
      _drawPeriods =
          result.docs.map((doc) => doc.get('draw_period').toString()).toList();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadDrawResult(String drawPeriod) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('vietlott_655_results')
          .where('draw_period', isEqualTo: int.parse(drawPeriod))
          .get();
      final data = result.docs.first.data();

      _drawDateController.text = (data['draw_date']);
      _regularNumber1Controller.text = data['number_1'].toString();
      _regularNumber2Controller.text = data['number_2'].toString();
      _regularNumber3Controller.text = data['number_3'].toString();
      _regularNumber4Controller.text = data['number_4'].toString();
      _regularNumber5Controller.text = data['number_5'].toString();
      _regularNumber6Controller.text = data['number_6'].toString();
      _specialNumberController.text = data['special_number'].toString();
      _prize1ValueController.text = data['prize1_value'].toString();
      _prize2ValueController.text = data['prize2_value'].toString();
      _jackpot1Controller.text = data['jackpot1_winner'].toString();
      _jackpot1prizeController.text = data['jackpot1_prize'].toString();
      _jackpot2Controller.text = data['jackpot2_winner'].toString();
      _jackpot2prizeController.text = data['jackpot2_prize'].toString();
    } catch (e) {
      print(e);
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

  void _updateForm() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      int jackpot1Winner = int.tryParse(_jackpot1Controller.text.trim()) ?? 0;
      int jackpot2Winner = int.tryParse(_jackpot2Controller.text.trim()) ?? 0;
      int prize1Value = int.tryParse(_prize1ValueController.text.trim()) ?? 0;
      int prize2Value = int.tryParse(_prize2ValueController.text.trim()) ?? 0;

      int jackpot1Prize =
          jackpot1Winner > 0 ? (prize1Value ~/ jackpot1Winner) : 0;
      int jackpot2Prize =
          jackpot2Winner > 0 ? (prize2Value ~/ jackpot2Winner) : 0;

      final drawPeriod = int.tryParse(_drawPeriodController.text.trim());

      try {
        final result = await FirebaseFirestore.instance
            .collection('vietlott_655_results')
            .where('draw_period', isEqualTo: drawPeriod)
            .get();
        final documentId = result.docs.first.id;
        await FirebaseFirestore.instance
            .collection('vietlott_655_results')
            .doc(documentId)
            .update({
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
          'draw_period': drawPeriod,
          'draw_date': _drawDateController.text.trim(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        // Show a notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thông tin vé số đã được cập nhật.')),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  void _deleteForm() async {
    final drawPeriod = int.tryParse(_drawPeriodController.text.trim());
    try {
      final result = await FirebaseFirestore.instance
          .collection('vietlott_655_results')
          .where('draw_period', isEqualTo: drawPeriod)
          .get();
      final documentId = result.docs.first.id;

      // Hiển thị hộp thoại xác nhận trước khi xóa
      final confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Xác nhận xóa'),
            content:
                Text('Bạn có chắc chắn muốn xóa thông tin vé số này không?'),
            actions: [
              TextButton(
                child: Text('Hủy'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Xóa'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => EditVietlott655Form(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );

      // Nếu người dùng đã xác nhận muốn xóa, thực hiện xóa
      if (confirmed == true) {
        await FirebaseFirestore.instance
            .collection('vietlott_655_results')
            .doc(documentId)
            .delete();
        // Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thông tin vé số đã được xóa.')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa thông tin kỳ xổ'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 22, 25, 179),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Vietlott655Form(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'add',
                child: Text('Thêm mới'),
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
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _drawPeriodController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Chọn kỳ cần sửa',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return _drawPeriods.where((period) =>
                      period.toLowerCase().startsWith(pattern.toLowerCase()));
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  _drawPeriodController.text = suggestion;
                  _loadDrawResult(suggestion);
                },
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
                onPressed: _updateForm,
                child: Text('Cập nhật'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
              ElevatedButton(
                onPressed: _deleteForm,
                child: Text('Xóa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
