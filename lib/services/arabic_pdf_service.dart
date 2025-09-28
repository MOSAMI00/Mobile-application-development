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

      final pdf = pw.Document();
      final logoData = await rootBundle.load(
        'assets/images/accounting blog logo.jpg',
      );
      final logoBytes = logoData.buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(25),

          // الهيدر
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logoImage),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'كشف حساب',
                        style: pw.TextStyle(
                          fontSize: 22,
                          font: arabicFont,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        '${account['name']}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          font: arabicFont,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.2, color: PdfColors.grey600),
            ],
          ),

          // الفوتر
          footer: (context) => pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),

          build: (pw.Context context) {
            final headerStyle = pw.TextStyle(
              fontSize: 14,
              font: arabicFont,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            );
            final cellStyle = pw.TextStyle(
              fontSize: 12,
              font: arabicFont,
              color: PdfColors.black,
            );

            // تحديد نص الرصيد
            String balanceText;
            if (totalBalance > 0) {
              balanceText =
                  "الرصيد الحالي: ${totalBalance.toStringAsFixed(2)} ريال (له)";
            } else if (totalBalance < 0) {
              balanceText =
                  "الرصيد الحالي: ${totalBalance.abs().toStringAsFixed(2)} ريال (عليه)";
            } else {
              balanceText = "الرصيد الحالي: 0 ريال";
            }

            return [
              // جدول العمليات
              if (accountTxs.isNotEmpty) ...[
                pw.SizedBox(height: 15),
                pw.Text(
                  'تفاصيل العمليات',
                  style: pw.TextStyle(
                    fontSize: 16,
                    font: arabicFont,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 8),

                pw.Table.fromTextArray(
                  headers: ['التاريخ', 'التفاصيل', 'نوع العملية', 'المبلغ'],
                  data: accountTxs.map((tx) {
                    return [
                      tx['date']?.toString().split(' ')[0] ?? 'غير محدد',
                      tx['category']?.toString() ?? '-',
                      tx['type']?.toString() ?? 'غير محدد',
                      '${tx['amount'] ?? 0} ريال',
                    ];
                  }).toList(),
                  headerStyle: headerStyle,
                  headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
                  cellStyle: cellStyle,
                  cellAlignment: pw.Alignment.center,
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 0.7,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                ),
              ] else
                pw.Text('لا توجد عمليات مسجلة', style: cellStyle),

              pw.SizedBox(height: 25),

              // ملخص الحساب
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ملخص الحساب',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: arabicFont,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Bullet(text: balanceText, style: cellStyle),
                    pw.Bullet(
                      text:
                          'إجمالي الدخل (له) : ${totalIncome.toStringAsFixed(2)} ريال',
                      style: cellStyle,
                    ),
                    pw.Bullet(
                      text:
                          'إجمالي المصروفات (عليه) :${totalExpense.toStringAsFixed(2)} ريال',
                      style: cellStyle,
                    ),
                    pw.Bullet(
                      text: 'عدد العمليات: ${accountTxs.length}',
                      style: cellStyle,
                    ),
                  ],
                ),
              ),
            ];
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
