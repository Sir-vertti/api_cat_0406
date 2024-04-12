import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BreedsList(),
    );
  }
}

class BreedsList extends StatefulWidget {
  const BreedsList({super.key});

  @override
  _BreedsListState createState() => _BreedsListState();
}

class _BreedsListState extends State<BreedsList> {
  late List<Breed> breeds;

  @override
  void initState() {
    super.initState();
    fetchBreeds();
  }

  Future<void> fetchBreeds() async {
    final response = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/breeds'),
      headers: {
        'x-api-key':
            'live_GgDeQj6he8Apxjm0BKlsOvV0Ura02FiclqbCTjhYFTpbvyYxPLYN7mDJIAy4efKL'
      },
    );
    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      setState(() {
        breeds = (parsed as List).map((json) => Breed.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load breeds');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Breeds'),
      ),
      body: breeds == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: breeds.length,
                    itemBuilder: (context, index) {
                      final breed = breeds[index];
                      return ListTile(
                        title: Text(breed.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BreedDetail(breed: breed)),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class BreedDetail extends StatelessWidget {
  final Breed breed;

  const BreedDetail({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(breed.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (breed.image != null)
              Image.network(
                breed.image!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: 200,
                height: 200,
                color: Colors
                    .grey, // Otra forma de mostrar un placeholder si la imagen no está disponible
              ),
            const SizedBox(height: 20),
            Text('Description: ${breed.description ?? "Not available"}'),
            Text('Origin: ${breed.origin ?? "Not available"}'),
            Text('Life span: ${breed.lifeSpan ?? "Not available"}'),
          ],
        ),
      ),
    );
  }
}

class Breed {
  final String id;
  final String name;
  final String? description;
  final String? origin;
  final String? lifeSpan;
  final String? image;

  Breed({
    required this.id,
    required this.name,
    this.description,
    this.origin,
    this.lifeSpan,
    this.image,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      origin: json['origin'],
      lifeSpan: json['life_span'],
      image: json['image'] != null ? json['image']['url'] : null,
    );
  }
}
