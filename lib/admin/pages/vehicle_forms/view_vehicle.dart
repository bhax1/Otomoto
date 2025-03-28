import 'package:flutter/material.dart';

class ViewVehicleForm extends StatefulWidget {
  final String vehicleId;
  final String brand, model, plateNumber, bodyType, color, status;
  final double rentalRate;

  const ViewVehicleForm({
    super.key,
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.bodyType,
    required this.color,
    required this.status,
    required this.rentalRate,
  });

  @override
  _ViewVehicleFormState createState() => _ViewVehicleFormState();
}

class _ViewVehicleFormState extends State<ViewVehicleForm> {
  bool isLoading = true;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        isLoading = false;
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Vehicle Details",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.numbers_rounded, "Vehicle ID: ${widget.vehicleId}"),
            _buildInfoRow(Icons.directions_car, "Brand: ${widget.brand}"),
            _buildInfoRow(
                Icons.directions_car_filled, "Model: ${widget.model}"),
            _buildInfoRow(Icons.numbers, "Plate Number: ${widget.plateNumber}"),
            _buildInfoRow(Icons.category, "Body Type: ${widget.bodyType}"),
            _buildInfoRow(Icons.color_lens, "Color: ${widget.color}"),
            _buildInfoRow(Icons.money_rounded,
                "Rental Rate: ₱${widget.rentalRate.toStringAsFixed(2)}"),
            _buildInfoRow(Icons.verified, "Status: ${widget.status}"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
