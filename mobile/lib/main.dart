import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/pages/emergency_instructions.dart';
import 'package:mobile/pages/locations.dart';
import 'package:mobile/utils.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScafold(),
    );
  }
}

class HomeScafold extends StatefulWidget {
  const HomeScafold({super.key});

  @override
  State<HomeScafold> createState() => _HomeScafoldState();
}

class _HomeScafoldState extends State<HomeScafold> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    EmergencyInstructions(),
    Locations(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Instructions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Emplacements',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> emergencyContacts = [
    {"name": "Police", "number": "17"},
    {"name": "Pompiers", "number": "18"},
    {"name": "SAMU", "number": "15"},
    {"name": "Gendarmerie", "number": "112"},
    {"name": "Urgences médicales", "number": "141"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alerte d'urgence",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Informez instantanément les services d'urgence locaux de votre position.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.red),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Sélectionnez le type d\'urgence'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          ...[
                                            "Accident de la route",
                                            "Grave chute",
                                            "Incendie ou brullure grave",
                                            "Autres"
                                          ].map(
                                            (emergencyType) {
                                              return ListTile(
                                                title: Text(emergencyType),
                                                onTap: () async {
                                                  // Handle emergencyType

                                                  Position currentPosition =
                                                      await determinePosition();
                                                  FirebaseFirestore.instance
                                                      .collection("hospitals")
                                                      .get()
                                                      .then(
                                                    (QuerySnapshot
                                                        querySnapshot) {
                                                      List<HospitalData>
                                                          hospitals =
                                                          querySnapshot.docs
                                                              .map(
                                                        (doc) {
                                                          return HospitalData(
                                                            name: doc['name'],
                                                            description: doc[
                                                                'description'],
                                                            location: LatLng(
                                                                doc['location']
                                                                    .latitude,
                                                                doc['location']
                                                                    .longitude),
                                                          );
                                                        },
                                                      ).toList();

                                                      double currentDistance = double.infinity;
                                                      late HospitalData nearestHospital;

                                                      for (var hospital in hospitals) {
                                                        double distance = calculateDistance(
                                                            hospital.location
                                                                .latitude,
                                                            hospital.location
                                                                .longitude,
                                                            currentPosition
                                                                .latitude,
                                                            currentPosition
                                                                .longitude);
                                                                if(distance < currentDistance){
                                                                  currentDistance = distance;
                                                                  nearestHospital = hospital;
                                                                }
                                                      }

                                                      // TODO: Send alert to nearest hospital
                                                      debugPrint(nearestHospital.name);
                                                    },
                                                  );

                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Alerte envoyée avec succès'),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Déclancher une alerte',
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Contacts d'urgence",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  emergencyContacts.length,
                  (index) {
                    return Card(
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${emergencyContacts[index]['name']} :",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                emergencyContacts[index]['number'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
