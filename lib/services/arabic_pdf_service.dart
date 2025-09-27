// محسّن للحجم - استيراد مكتبات أساسية فقط
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data.dart';
import '../services/database_service.dart';
import 'theme_provider.dart';

class ArabicPDFService {
  static pw.Font? _cachedArabicFont;

  static Future<pw.Font> _loadArabicFont() async {
    if (_cachedArabicFont != null) {
      return _cachedArabicFont!;
    }

    try {
      print('جاري تحميل الخط العربي المحلي...');

      // تحميل الخط من ملف assets
      final ByteData fontData = await rootBundle.load(
        'assets/fonts/Cairo-Medium.ttf',
      );
      final Uint8List fontBytes = fontData.buffer.asUint8List();

      // إنشاء كائن الخط
      final pw.Font arabicFont = pw.Font.ttf(fontBytes.buffer.asByteData());

      // تخزين الخط في الذاكرة المؤقتة
      _cachedArabicFont = arabicFont;

      print('تم تحميل الخط العربي المحلي بنجاح');
      return arabicFont;
    } catch (e) {
      print('فشل في تحميل الخط العربي المحلي: $e');
      throw Exception('تعذر تحميل الخط العربي: $e');
    }
  }

  static Future<void> generateArabicReport(
    int accountId,
    ThemeProvider themeProvider, {
    String? accountName,
  }) async {
    try {
      print('بدء إنشاء تقرير PDF جديد للحساب: $accountId');

      // تحميل الخط العربي المحلي
      pw.Font arabicFont;
      arabicFont = await _loadArabicFont();

      try {
        print('تم تحميل الخط العربي بنجاح');
      } catch (e) {
        print('فشل في تحميل الخط العربي: $e');
        // استخدام الخط الافتراضي كبديل
        arabicFont = pw.Font.helvetica();
      }

      // البحث عن الحساب أو استخدام الاسم المُمرر
      Map<String, dynamic> account;
      if (accountName != null) {
        account = {'id': accountId, 'name': accountName, 'balance': 0.0};
      } else {
        account = accounts.firstWhere(
          (acc) => acc['id'] == accountId,
          orElse: () => {
            'id': accountId,
            'name': 'حساب غير محدد',
            'balance': 0.0,
          },
        );
      }

      // الحصول على العمليات
      final accountTxs = transactions
          .where((tx) => tx['accountId'] == accountId)
          .toList();
      print('عدد العمليات: ${accountTxs.length}');

      // حساب الإحصائيات
      double totalIncome = 0;
      double totalExpense = 0;

      for (var tx in accountTxs) {
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        if (tx['type'] == themeProvider.incomeLabel) {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      final totalBalance = totalIncome - totalExpense;
      print(
        'الإحصائيات: الرصيد=$totalBalance، الدخل=$totalIncome، المصروفات=$totalExpense',
      );

      // إنشاء مستند PDF جديد بسيط
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            // أنماط النص البسيطة والواضحة
            final titleStyle = pw.TextStyle(
              fontSize: 24,
              color: PdfColors.blue800,
              font: arabicFont,
              fontWeight: pw.FontWeight.bold,
            );
            final headerStyle = pw.TextStyle(
              fontSize: 18,
              color: PdfColors.black,
              font: arabicFont,
              fontWeight: pw.FontWeight.bold,
            );
            final textStyle = pw.TextStyle(
              fontSize: 14,
              color: PdfColors.black,
              font: arabicFont,
            );

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // عنوان التقرير بسيط وجميل
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue300, width: 2),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'تقرير الحساب المالي',
                        style: titleStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'اسم الحساب: ${account['name']}',
                        style: headerStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'تاريخ التقرير: ${DateTime.now().toString().split(' ')[0]}',
                        style: textStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // ملخص الحساب بسيط وواضح
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green300, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ملخص الحساب:', style: headerStyle),
                      pw.SizedBox(height: 10),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('الرصيد الحالي:', style: textStyle),
                          pw.Text(
                            '${totalBalance.toStringAsFixed(2)} ريال',
                            style: textStyle.copyWith(
                              color: totalBalance >= 0
                                  ? PdfColors.green700
                                  : PdfColors.red700,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'إجمالي ${themeProvider.incomeLabel}:',
                            style: textStyle,
                          ),
                          pw.Text(
                            '${totalIncome.toStringAsFixed(2)} ريال',
                            style: textStyle.copyWith(
                              color: PdfColors.green600,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'إجمالي ${themeProvider.expenseLabel}:',
                            style: textStyle,
                          ),
                          pw.Text(
                            '${totalExpense.toStringAsFixed(2)} ريال',
                            style: textStyle.copyWith(
                              color: PdfColors.red600,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('عدد العمليات:', style: textStyle),
                          pw.Text(
                            '${accountTxs.length}',
                            style: textStyle.copyWith(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // جدول العمليات بسيط وواضح
                if (accountTxs.isNotEmpty) ...[
                  pw.Text('تفاصيل العمليات:', style: headerStyle),
                  pw.SizedBox(height: 10),

                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                      width: 1,
                    ),
                    children: [
                      // رأس الجدول
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'نوع العملية',
                              style: headerStyle,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'المبلغ',
                              style: headerStyle,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'التاريخ',
                              style: headerStyle,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      // صفوف البيانات
                      ...accountTxs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tx = entry.value;
                        final isEven = index % 2 == 0;

                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: isEven ? PdfColors.grey50 : PdfColors.white,
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                tx['type']?.toString() ?? 'غير محدد',
                                style: textStyle,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '${tx['amount']?.toString() ?? '0'} ريال',
                                style: textStyle.copyWith(
                                  color: tx['type'] == themeProvider.incomeLabel
                                      ? PdfColors.green600
                                      : PdfColors.red600,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                tx['date']?.toString().split(' ')[0] ??
                                    'غير محدد',
                                style: textStyle,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ] else ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.yellow50,
                      border: pw.Border.all(
                        color: PdfColors.orange300,
                        width: 1,
                      ),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'لا توجد عمليات مسجلة لهذا الحساب',
                      style: textStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],

                pw.Spacer(),

                // تذييل بسيط وجميل
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'تطبيق إدارة الحسابات المالية',
                        style: headerStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'تم إنشاء التقرير في: ${DateTime.now().toString().substring(0, 19)}',
                        style: textStyle.copyWith(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // عرض PDF مع خيارات المستعرض
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'تقرير_${account['name']}_${DateTime.now().toString().split(' ')[0]}.pdf',
      );
    } catch (e) {
      throw Exception('فشل في إنشاء التقرير: ${e.toString()}');
    }
  }
}
