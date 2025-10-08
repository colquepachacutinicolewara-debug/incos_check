import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SoporteScreen extends StatelessWidget {
  const SoporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soporte"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          elevation: 6,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.construction,
                  size: 80,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppSpacing.medium),
                Text(
                  "La pantalla de soporte está en inicio de proceso",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
