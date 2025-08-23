import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [IconButton(icon: Icon(Icons.menu), onPressed: () {})],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  foregroundImage: AssetImage(
                    'images/صورة واتساب بتاريخ 2024-10-04 في 22.16.17_14975f39.jpg',
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mohammed Sami",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Software Engineering",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),

            // Wallet and Card Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Wallet Balance:"),
                        Text(
                          "\$5046.57",
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        SizedBox(height: 5),
                        Text("Total Service"),
                        Text("24", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Master Card",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "74888-XXXX",
                          style: TextStyle(color: Colors.white),
                        ),

                        Text(
                          "Taha Ali K.",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Houses Section
            Text("Houses", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.pink[50]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.5, 0.5],
                ),
                //borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      buildHouseCard(
                        Icons.add,
                        "Add Workers",
                        color: Colors.red,
                      ),
                      buildHouseCard(null, "Tobi Lateef"),
                      SizedBox(width: 12),
                      buildHouseCard(null, "Queen Needle"),
                      buildHouseCard(null, "Joan Blessing"),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Services",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("All", style: TextStyle(color: Colors.red)),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Services Section
                  SizedBox(height: 10),
                  buildServiceCard(Icons.electrical_services, "Electrical"),
                  SizedBox(height: 10),
                  buildServiceCard(Icons.build, "Others"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHouseCard(
    IconData? icon,
    String title, {
    Color color = Colors.white,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Column(
          children: [
            icon != null
                ? Icon(icon, color: color)
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.red,
                    backgroundImage: AssetImage(
                      'images/صورة واتساب بتاريخ 2024-10-04 في 22.16.17_14975f39.jpg',
                    ),
                  ),
            SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget buildServiceCard(IconData icon, String title) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.red),
          SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
