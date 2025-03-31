import 'package:flutter/material.dart';

class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key});

  @override
  _DashboardBodyState createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  String selectedPeriod = 'Last Month';
  List<String> periods = ['Last Month', 'This Year', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            
          Text(
            '         Earning Summary',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
          

            Container(
  decoration: BoxDecoration(
    color: Colors.white, // White background
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.white), // Optional: Border styling
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: DropdownButton<String>(
    value: selectedPeriod,
    dropdownColor: Colors.white, // Ensure dropdown items have a white background
    style: const TextStyle(color: Colors.black), // Set text color
    underline: const SizedBox(), // Removes the underline
    icon: const Icon(Icons.arrow_drop_down, color: Colors.black), // Arrow color
    items: periods.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20), // Apply to all items
        ),
      );
    }).toList(),
    onChanged: (newValue) {
      setState(() {
        selectedPeriod = newValue!;
      });
    },
  ),
),
            ],
          ),
          const SizedBox(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoCard(title: 'Revenue', value: '\$0.00', icon: Icons.money),
              InfoCard(
                  title: 'Total Rents', value: '0', icon: Icons.directions_car),
              InfoCard(
                  title: 'Feedback Rating', value: '5.0', icon: Icons.star),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Sales',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView(
              children: [
                const SaleItem(
                    order: '#00003',
                    date: 'October 1, 2024',
                    status: 'Completed',
                    amount: '\$0.00'),
                const SaleItem(
                    order: '#00002',
                    date: 'October 1, 2024',
                    status: 'Completed',
                    amount: '\$0.00'),
                const SaleItem(
                    order: '#00001',
                    date: 'October 1, 2024',
                    status: 'Completed',
                    amount: '\$0.00'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    
    Color iconColor;
switch (title) {
  case 'Revenue':
    iconColor = Colors.green; // Green for Revenue
    break;
  case 'Total Rents':
    iconColor = Colors.blue; // Blue for Total Rents
    break;
  case 'Feedback Rating':
    iconColor = Colors.yellow; // Yellow for Feedback
    break;
  default:
    iconColor = Colors.grey; // Fallback color
}
     return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: iconColor), // Dynamic color here
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SaleItem extends StatelessWidget {
  final String order;
  final String date;
  final String status;
  final String amount;
  

  const SaleItem(
      {super.key,
      required this.order,
      required this.date,
      required this.status,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order,
                  style: const TextStyle(
                    fontSize: 25,  // Bigger font for order number
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:FontWeight.w500 ,
                    color: Colors.grey.shade700, // Softer color for readability
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      status == "Completed" ? Icons.check_circle : Icons.timelapse,
                      color: status == "Completed" ? Colors.green : Colors.orange,
                      size: 25,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 20, // Bigger status text
                        color: status == "Completed" ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 25,  // Larger font for amount
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
