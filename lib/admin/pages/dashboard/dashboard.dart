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
              const Text(
                'Earning Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedPeriod,
                items: periods.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedPeriod = newValue!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
      child: ListTile(
        title: Text(order),
        subtitle: Text(date),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status, style: const TextStyle(color: Colors.green)),
            const SizedBox(width: 10),
            Text(amount),
          ],
        ),
      ),
    );
  }
}
