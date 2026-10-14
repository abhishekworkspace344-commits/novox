import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/geofence_model.dart';
import '../../services/admin_service.dart';
import '../../widgets/status_badge.dart';
import 'geofence_map_picker.dart';

class AdminGeofenceScreen extends StatefulWidget {
  const AdminGeofenceScreen({
    super.key,
  });

  @override
  State<AdminGeofenceScreen> createState() => _AdminGeofenceScreenState();
}

class _AdminGeofenceScreenState extends State<AdminGeofenceScreen> {
  late final AdminService adminService;

  GeofenceModel? geofence;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    adminService = AdminService(ApiClient());
    loadGeofence();
  }

  Future<void> loadGeofence() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });

    try {
      final data = await adminService.getGeofence();
      if (!mounted) return;
      setState(() {
        geofence = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load geofence: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> showGeofenceDialog() async {
    final latitudeController = TextEditingController(
      text: geofence?.latitude.toString() ?? "",
    );

    final longitudeController = TextEditingController(
      text: geofence?.longitude.toString() ?? "",
    );

    final radiusController = TextEditingController(
      text: geofence?.radiusMeters.toString() ?? "100",
    );
    final southController = TextEditingController(text: geofence?.south?.toString() ?? '');
    final northController = TextEditingController(text: geofence?.north?.toString() ?? '');
    final westController = TextEditingController(text: geofence?.west?.toString() ?? '');
    final eastController = TextEditingController(text: geofence?.east?.toString() ?? '');

    bool active = geofence?.active ?? true;

    await showDialog(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                geofence == null ? "Create Campus Geofence" : "Configure Geofence",
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      inputField(
                        latitudeController,
                        "Latitude",
                        Icons.my_location_rounded,
                        signed: true,
                      ),
                      inputField(
                        longitudeController,
                        "Longitude",
                        Icons.location_searching_rounded,
                        signed: true,
                      ),
                      Align(alignment: Alignment.centerLeft, child: TextButton.icon(
                        icon: const Icon(Icons.map_outlined), label: const Text('Choose center on map'),
                        onPressed: () async {
                          final lat = double.tryParse(latitudeController.text) ?? 20.5937;
                          final lon = double.tryParse(longitudeController.text) ?? 78.9629;
                          final point = await showDialog<LatLng>(context: context, builder: (_) => GeofenceMapPicker(initialPoint: LatLng(lat, lon)));
                          if (point != null) {
                            latitudeController.text = point.latitude.toStringAsFixed(6);
                            longitudeController.text = point.longitude.toStringAsFixed(6);
                            setDialogState(() {});
                          }
                        },
                      )),
                      const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Optional rectangular campus boundary', style: TextStyle(fontWeight: FontWeight.w600)))),
                      inputField(southController, 'South latitude', Icons.south, signed: true),
                      inputField(northController, 'North latitude', Icons.north, signed: true),
                      inputField(westController, 'West longitude', Icons.west, signed: true),
                      inputField(eastController, 'East longitude', Icons.east, signed: true),
                      inputField(
                        radiusController,
                        "Radius (meters)",
                        Icons.radar_rounded,
                        signed: false,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: AppColors.primary,
                        title: const Text(
                          "Geofence Active",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Enforce attendance inside the campus boundary",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: active,
                        onChanged: saving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  active = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          await saveGeofence(
                            dialogContext,
                            latitudeController.text,
                            longitudeController.text,
                            radiusController.text,
                            southController.text, northController.text, westController.text, eastController.text,
                            active,
                            setDialogState,
                          );
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Settings"),
                ),
              ],
            );
          },
        );
      },
    );

    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    southController.dispose(); northController.dispose(); westController.dispose(); eastController.dispose();
  }

  Future<void> saveGeofence(
    BuildContext dialogContext,
    String latitudeText,
    String longitudeText,
    String radiusText,
    String southText, String northText, String westText, String eastText,
    bool active,
    void Function(void Function()) setDialogState,
  ) async {
    final latitude = double.tryParse(latitudeText.trim());
    final longitude = double.tryParse(longitudeText.trim());
    final radius = double.tryParse(radiusText.trim());

    if (latitude == null || longitude == null || radius == null) {
      showMessage("Please enter valid numerical coordinates and radius");
      return;
    }

    if (latitude < -90 || latitude > 90) {
      showMessage("Latitude must be between -90 and 90");
      return;
    }

    if (longitude < -180 || longitude > 180) {
      showMessage("Longitude must be between -180 and 180");
      return;
    }

    if (radius <= 0) {
      showMessage("Radius must be greater than zero");
      return;
    }

    final boundsText = [southText, northText, westText, eastText];
    final bounds = boundsText.map((value) => value.trim().isEmpty ? null : double.tryParse(value.trim())).toList();
    if (bounds.any((value) => value == null) && boundsText.any((value) => value.trim().isNotEmpty)) {
      showMessage('Enter all four boundary coordinates, or leave them all blank'); return;
    }
    if (bounds.every((value) => value != null)) {
      if (bounds[0]! < -90 || bounds[1]! > 90 || bounds[0]! >= bounds[1]!) { showMessage('South/north must be valid latitudes, with south below north'); return; }
      if (bounds[2]! < -180 || bounds[3]! > 180 || bounds[2]! >= bounds[3]!) { showMessage('West/east must be valid longitudes, with west below east'); return; }
    }

    setDialogState(() {
      saving = true;
    });

    final data = {
      "latitude": latitude,
      "longitude": longitude,
      "radius_meters": radius,
      "active": active,
      "south": bounds[0], "north": bounds[1], "west": bounds[2], "east": bounds[3],
    };

    try {
      if (geofence == null) {
        await adminService.createGeofence(data);
      } else {
        await adminService.updateGeofence(geofence!.id, data);
      }

      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);

      if (!mounted) return;
      setState(() {
        saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Geofence settings saved successfully"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadGeofence();
    } catch (e) {
      setDialogState(() {
        saving = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save geofence: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool signed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: signed,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "No Geofence Configured",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Configure a GPS perimeter to enforce attendance within verified campus grounds.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: showGeofenceDialog,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text("Set Up Campus Geofence"),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGeofence() {
    final geo = geofence!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Hero Status Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Campus Perimeter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      geo.active
                          ? "Perimeter enforcement is active"
                          : "Perimeter enforcement is inactive",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: geo.active ? "ACTIVE" : "INACTIVE"),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Main Configuration Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Configuration",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 6),
              infoRow("Latitude", geo.latitude.toStringAsFixed(6), Icons.my_location_rounded),
              infoRow("Longitude", geo.longitude.toStringAsFixed(6), Icons.location_searching_rounded),
              infoRow("Radius", "${geo.radiusMeters.toStringAsFixed(0)} meters", Icons.radar_rounded),
              if (geo.south != null) ...[
                infoRow("South", geo.south!.toStringAsFixed(6), Icons.south),
                infoRow("North", geo.north!.toStringAsFixed(6), Icons.north),
                infoRow("West", geo.west!.toStringAsFixed(6), Icons.west),
                infoRow("East", geo.east!.toStringAsFixed(6), Icons.east),
              ],
              infoRow("Perimeter State", geo.active ? "Enforced" : "Disabled", geo.active ? Icons.check_circle_outline_rounded : Icons.cancel_outlined),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: showGeofenceDialog,
                  icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                  label: const Text("UPDATE GEOFENCE PERIMETER"),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Help info tile
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Students can check in and conclude attendance only when their GPS location falls inside this radius. The backend verifies coordinates on each check-in.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Campus Geofence"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: loading ? null : loadGeofence,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : geofence == null
              ? buildEmpty()
              : RefreshIndicator(
                  onRefresh: loadGeofence,
                  color: AppColors.primary,
                  child: buildGeofence(),
                ),
    );
  }
}
