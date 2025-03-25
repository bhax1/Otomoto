import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ViewVehicleForm extends StatefulWidget {
  final String vehicleId;

  const ViewVehicleForm({super.key, required this.vehicleId});

  @override
  _ViewVehicleFormState createState() => _ViewVehicleFormState();
}

class _ViewVehicleFormState extends State<ViewVehicleForm> {
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchVehicleDetails();
  }

  Future<void> _fetchVehicleDetails() async {
    try {
      DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (vehicleDoc.exists && vehicleDoc.data() != null) {
        setState(() {
          vehicleData = vehicleDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });

        // Trigger opacity change separately after build
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              opacity = 1.0;
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
          vehicleData = null;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        vehicleData = null;
      });
      _showError('Error loading vehicle details: $error');
    }
  }

  void _showError(String message) {
    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Close the previous screen if needed
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: isLoading
          ? const Center(
              child: SpinKitThreeBounce(
                color: Colors.blueGrey,
                size: 30.0,
              ),
            )
          : AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              opacity: opacity,
              child: vehicleData == null
                  ? const Center(child: Text("No data found."))
                  : Column(
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
                          Icons.directions_car,
                          "Brand: ${vehicleData!['brand']}",
                        ),
                        _buildInfoRow(
                          Icons.directions_car_filled,
                          "Model: ${vehicleData!['model']}",
                        ),
                        _buildInfoRow(
                          Icons.numbers,
                          "Plate Number: ${vehicleData!['plate_num']}",
                        ),
                        _buildInfoRow(
                          Icons.category,
                          "Body Type: ${vehicleData!['body_type']}",
                        ),
                        _buildInfoRow(
                          Icons.color_lens,
                          "Color: ${vehicleData!['color']}",
                        ),
                        _buildInfoRow(
                          Icons.money_rounded,
                          "Rental Rate: ${vehicleData!['rental_rate']}",
                        ),
                        _buildInfoRow(
                          Icons.verified,
                          "Status: ${vehicleData!['status']}",
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close",
                                style: TextStyle(color: Colors.white)),
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
