import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pokemonDetail;
  final Color color;
  final int heroTag;

  const PokemonDetailScreen({
    Key? key,
    required this.pokemonDetail,
    required this.color,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the 'sprites' field directly as a Map
    final spriteData = pokemonDetail['pokemon_v2_pokemonsprites'];
    final imageUrl = spriteData.isNotEmpty
        ? spriteData[0]['sprites']['front_default'] // Access front_default directly
        : '';

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: heroTag,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                fit: BoxFit.fitHeight,
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pokemonDetail['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Height: ${pokemonDetail['height']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    "Weight: ${pokemonDetail['weight']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  buildSection("Types", pokemonDetail['pokemon_v2_pokemontypes']
                      .map((type) => type['pokemon_v2_type']['name'])
                      .join(', ')),
                  buildSection("Abilities", pokemonDetail['pokemon_v2_pokemonabilities']
                      .map((ability) => ability['pokemon_v2_ability']['name'])
                      .join(', ')),
                  buildSection("Stats", pokemonDetail['pokemon_v2_pokemonstats']
                      .map((stat) => "${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}")
                      .join(', ')),
                  buildSection("Moves", pokemonDetail['pokemon_v2_pokemonmoves']
                      .map((move) => move['pokemon_v2_move']['name'])
                      .join(', ')),
                  // Temporarily removing evolutions section
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
