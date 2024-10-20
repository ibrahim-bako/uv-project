import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HospitalData {
  final String name;
  final String description;
  final LatLng location;

  const HospitalData({
    required this.name,
    required this.description,
    required this.location,
  });
}

class Locations extends StatefulWidget {
  const Locations({super.key});

  @override
  State<Locations> createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  List<HospitalData> hospitals = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseFirestore.instance.collection("hospitals").get().then(
        (QuerySnapshot querySnapshot) {
          setState(() {
            hospitals = querySnapshot.docs.map(
              (doc) {
                return HospitalData(
                  name: doc['name'],
                  description: doc['description'],
                  location: LatLng(
                      doc['location'].latitude, doc['location'].longitude),
                );
              },
            ).toList();
          });
          debugPrint(hospitals.toString());
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lieux de santé"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: const MapOptions(
                    // initialCenter: location,
                    initialCenter: LatLng(12.353981, -1.528083),
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    // CurrentLocationLayer(
                    //   followOnLocationUpdate: AlignOnUpdate.once,
                    //   style: const LocationMarkerStyle(
                    //     marker: DefaultLocationMarker(
                    //       child: Icon(
                    //         Icons.navigation,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //     markerSize: Size(40, 40),
                    //     markerDirection: MarkerDirection.heading,
                    //   ),
                    // ),
                    MarkerLayer(
                      markers: [
                        ...hospitals.map(
                          (HospitalData hospital) => Marker(
                            point: hospital.location,
                            width: 100,
                            height: 50,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                debugPrint(hospitals.toString());

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(hospital.name),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(hospital.description),
                                          const Chip(
                                            label: Text("Ouvert"),
                                            backgroundColor: Colors.green,
                                          )
                                        ],
                                      ),
                                      actions: [
                                        OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Fermer'),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            // ignore: deprecated_member_use
                                            launch(
                                              'https://www.google.com/maps/search/?api=1&query=${hospital.location.latitude},${hospital.location.longitude}',
                                            );
                                          },
                                          child: const Text(
                                            'Ouvrir dans Google Maps',
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
