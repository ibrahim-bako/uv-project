import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    Instructions(),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                              // TODO: Implement onPressed
                            },
                            child: Text('Déclancher une alerte',
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InstructionData {
  final String title;
  final String description;
  final String imageUrl;
  final String content;
  final List<String> tags;

  const InstructionData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
    this.tags = const [],
  });
}

class Instructions extends StatefulWidget {
  const Instructions({super.key});

  @override
  State<Instructions> createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions> {
  // final List<InstructionData> instructions = const [
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité', "Incendie", "Prévention", "Sécurité"],
  //   ),
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité'],
  //   ),
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité'],
  //   ),
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité'],
  //   ),
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité'],
  //   ),
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité'],
  //   ),
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité'],
  //   ),
  //   InstructionData(
  //     title: 'Comment utiliser un extincteur',
  //     description: 'Instructions pour utiliser un extincteur',
  //     imageUrl:
  //         'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff76b839-714c-45a3-860f-42a9159bfe78/d92zgvw-49f8be43-2806-4bce-a4f4-d6e211b4974e.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9mZjc2YjgzOS03MTRjLTQ1YTMtODYwZi00MmE5MTU5YmZlNzgvZDkyemd2dy00OWY4YmU0My0yODA2LTRiY2UtYTRmNC1kNmUyMTFiNDk3NGUucG5nIn1dXX0.09S1VZnN30NsCmro7HFa6-0lvQtHxrj7uz26kd1v1cc',
  //     content: 'Instructions pour utiliser un extincteur',
  //     tags: ['Feu', 'Sécurité'],
  //   ),
  // ];

  final List<InstructionData> instructions = [];

  @override
  void initState() async {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseFirestore.instance
          .collection("emergency_instructions")
          .get()
          .then(
        (QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach(
            (doc) {
              setState(() {
                instructions.add(
                  InstructionData(
                    title: doc['title'],
                    description: doc['description'],
                    imageUrl: doc['imageUrl'],
                    content: doc['content'],
                    tags: List<String>.from(doc['tags']),
                  ),
                );
              });
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              // const TextField(
              //   decoration: InputDecoration(
              //     prefixIcon: Icon(Icons.search),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(99)),
              //     ),
              //     hintText: "Rechercher des instructions",
              //   ),
              // ),
              Expanded(
                child: ListView.separated(
                  itemCount: instructions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final instruction = instructions[index];
                    return GestureDetector(
                      onTap: () {
                        // TODO: Implement onTap
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                InstructionsDetails(instruction: instruction),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Image.network(instruction.imageUrl),
                        title: Text(
                          "${instruction.title} $index",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          children: [
                            Text(
                              instruction.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: instruction.tags
                                    .map(
                                      (String tag) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            child: Text(tag),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstructionsDetails extends StatelessWidget {
  const InstructionsDetails({super.key, required this.instruction});

  final InstructionData instruction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(instruction.title),
        ),
        body: Markdown(
          data: instruction.content,
        ),
      ),
    );
  }
}

class HospitalData {
  final String name;
  final String description;
  final String imageUrl;
  final LatLng location;

  const HospitalData({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
  });
}

class Locations extends StatelessWidget {
  const Locations({super.key});

  final List<HospitalData> hospitals = const [
    HospitalData(
      name: 'CHU Yalgado',
      description: 'Centre Hospitalier Universitaire Yalgado',
      imageUrl: 'https://www.chuyalgado.com/images/logo.png',
      location: LatLng(12.355981, -1.528083),
    ),
    HospitalData(
      name: 'CHU Yalgado',
      description: 'Centre Hospitalier Universitaire Yalgado',
      imageUrl: 'https://www.chuyalgado.com/images/logo.png',
      location: LatLng(12.363481, -1.528083),
    ),
    HospitalData(
      name: 'CHU Yalgado',
      description: 'Centre Hospitalier Universitaire Yalgado',
      imageUrl: 'https://www.chuyalgado.com/images/logo.png',
      location: LatLng(12.303981, -1.548023),
    ),
    HospitalData(
      name: 'CHU Yalgado',
      description: 'Centre Hospitalier Universitaire Yalgado',
      imageUrl: 'https://www.chuyalgado.com/images/logo.png',
      location: LatLng(12.393921, -1.528383),
    ),
  ];

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        tileProvider: CancellableNetworkTileProvider(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emplacements"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: determinePosition(),
                  builder: (context, AsyncSnapshot<Position> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    LatLng location = LatLng(
                      snapshot.data!.latitude,
                      snapshot.data!.longitude,
                    );

                    return FlutterMap(
                      options: const MapOptions(
                        // initialCenter: location,
                        initialCenter: LatLng(12.353981, -1.528083),
                        initialZoom: 12,
                      ),
                      children: [
                        openStreetMapTileLayer,
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: location,
                              width: 20,
                              height: 20,
                              child: const Icon(
                                Icons.my_location_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            ...hospitals.map(
                              (HospitalData hospital) => Marker(
                                point: hospital.location,
                                width: 20,
                                height: 20,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(hospital.name),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(hospital.description),
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
                                  child: const Icon(Icons.location_on),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
