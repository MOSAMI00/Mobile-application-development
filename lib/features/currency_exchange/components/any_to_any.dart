// lib/features/currency_exchange/components/any_to_any.dart
import 'package:flutter/material.dart';
import '../services/exchange_api.dart';

class AnyToAny extends StatefulWidget {
  final Map<String, dynamic> rates;
  final Map<String, String> currencies;
  const AnyToAny({Key? key, required this.rates, required this.currencies})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AnyToAnyState createState() => _AnyToAnyState();
}

class _AnyToAnyState extends State<AnyToAny> {
  TextEditingController amountController = TextEditingController();
  String dropdownValue1 = 'USD';
  String dropdownValue2 = 'EUR';
  String answer = 'سيظهر هنا نتيجة التحويل';

  @override
  void initState() {
    super.initState();
    // تعيين قيم افتراضية للعملات
    if (widget.currencies.isNotEmpty) {
      final currenciesList = widget.currencies.keys.toList();
      dropdownValue1 = currenciesList[0];
      dropdownValue2 = currenciesList.length > 1 ? currenciesList[1] : currenciesList[0];
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
              'تحويل بين أي عملتين',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: 'أدخل المبلغ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue1,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    isExpanded: true,
                    underline: Container(height: 2, color: Colors.grey.shade400),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue1 = newValue!;
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
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue2,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    isExpanded: true,
                    underline: Container(height: 2, color: Colors.grey.shade400),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue2 = newValue!;
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
              ],
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (amountController.text.isEmpty) {
                  setState(() {
                    answer = 'يرجى إدخال المبلغ';
                  });
                  return;
                }
                
                setState(() {
                  answer = '${amountController.text} $dropdownValue1 = ${ExchangeApi.convertAny(
                        widget.rates, 
                        amountController.text, 
                        dropdownValue1, 
                        dropdownValue2
                      )} $dropdownValue2';
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('تحويل'),
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