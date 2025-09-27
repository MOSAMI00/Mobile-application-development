import 'package:flutter/material.dart';
import '../services/exchange_api.dart';

class UsdToAny extends StatefulWidget {
  final Map<String, dynamic> rates;
  final Map<String, String> currencies;
  const UsdToAny({super.key, required this.rates, required this.currencies});

  @override
  // ignore: library_private_types_in_public_api
  _UsdToAnyState createState() => _UsdToAnyState();
}

class _UsdToAnyState extends State<UsdToAny> {
  TextEditingController usdController = TextEditingController();
  String dropdownValue = 'USD';
  String answer = 'سيظهر هنا نتيجة التحويل';

  @override
  void initState() {
    super.initState();
    // تعيين قيمة افتراضية للعملة
    if (widget.currencies.isNotEmpty) {
      dropdownValue = widget.currencies.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تحويل من USD إلى أي عملة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: usdController,
              decoration: InputDecoration(
                hintText: 'أدخل المبلغ بالدولار',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    isExpanded: true,
                    underline: Container(height: 2, color: Colors.grey.shade400),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: widget.currencies.keys.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('$value - ${widget.currencies[value]}'),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (usdController.text.isEmpty) {
                        setState(() {
                          answer = 'يرجى إدخال المبلغ';
                        });
                        return;
                      }
                      
                      setState(() {
                        answer = '${usdController.text} USD = ${ExchangeApi.convertUsd(widget.rates, usdController.text, dropdownValue)} $dropdownValue';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('تحويل'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                answer,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
            )
          ],
        ),
      ),
    );
  }
}