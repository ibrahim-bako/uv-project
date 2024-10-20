import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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

class EmergencyInstructions extends StatefulWidget {
  const EmergencyInstructions({super.key});

  @override
  State<EmergencyInstructions> createState() => _EmergencyInstructionsState();
}

class _EmergencyInstructionsState extends State<EmergencyInstructions> {
  List<InstructionData> emergencyInstructions = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FirebaseFirestore.instance
          .collection("emergency_instructions")
          .get()
          .then(
        (QuerySnapshot querySnapshot) {
          setState(() {
            emergencyInstructions = querySnapshot.docs.map(
              (doc) {
                return InstructionData(
                  title: doc['title'],
                  description: doc['description'],
                  imageUrl: doc['imageUrl'],
                  content: doc['content'],
                  tags: List<String>.from(doc['tags']),
                );
              },
            ).toList();
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions d\'urgence'),
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
              //     hintText: "Rechercher des emergencyInstructions",
              //   ),
              // ),
              if (emergencyInstructions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: emergencyInstructions.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 3,
                    ),
                    itemBuilder: (context, index) {
                      final instruction = emergencyInstructions[index];
                      return GestureDetector(
                        onTap: () {
                          // TODO: Implement onTap
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EmergencyInstructionsDetails(
                                      instruction: instruction),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            minLeadingWidth: 50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            minVerticalPadding: 5,
                            leading: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image(
                                fit: BoxFit.fill,
                                image: NetworkImage(instruction.imageUrl),
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            title: Text(
                              "${instruction.title} $index",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  instruction.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: instruction.tags
                                        .map(
                                          (String tag) => Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            child: Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
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
                        ),
                      );
                    },
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyInstructionsDetails extends StatelessWidget {
  const EmergencyInstructionsDetails({super.key, required this.instruction});

  final InstructionData instruction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(instruction.title, maxLines: 2,),
      ),
      body: Markdown(
        data: instruction.content,
        softLineBreak: true,
        
      ),
    );
  }
}
