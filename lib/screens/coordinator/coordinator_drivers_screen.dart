import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/driver_model.dart';
import '../../services/coordinator_service.dart';

class CoordinatorDriversScreen extends StatefulWidget {
  const CoordinatorDriversScreen({super.key});

  @override
  State<CoordinatorDriversScreen> createState() =>
      _CoordinatorDriversScreenState();
}

class _CoordinatorDriversScreenState extends State<CoordinatorDriversScreen> {
  List<DriverModel> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() => _isLoading = true);
    final list = await CoordinatorService.instance.getDrivers();
    setState(() {
      _drivers = list;
      _isLoading = false;
    });
  }

  void _openDriverForm([DriverModel? driver]) {
    final nameController = TextEditingController(text: driver?.name ?? '');
    final phoneController = TextEditingController(text: driver?.phone ?? '');
    final licenseController = TextEditingController(text: driver?.licenseNumber ?? '');
    final cityController = TextEditingController(text: driver?.baseCity ?? 'Ooty / Coimbatore');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(driver == null ? 'Add Network Driver' : 'Edit Driver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Driver Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: licenseController,
                decoration: const InputDecoration(labelText: 'Driving License No.'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'Base City / Hill Route'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(dialogCtx);

              final newDriver = DriverModel(
                driverId: driver?.driverId ?? 'drv-${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                licenseNumber: licenseController.text.trim(),
                baseCity: cityController.text.trim(),
                rating: driver?.rating ?? 4.9,
                totalTrips: driver?.totalTrips ?? 0,
              );

              await CoordinatorService.instance.saveDriver(newDriver);
              _loadDrivers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save Driver', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Driver Fleet'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDriverForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Driver'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _drivers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = _drivers[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        d.name.isNotEmpty ? d.name[0] : 'D',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      d.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${d.phone} • ${d.baseCity}\nDL: ${d.licenseNumber} • Rating: ⭐${d.rating} (${d.totalTrips} Trips)',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                      onPressed: () => _openDriverForm(d),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
