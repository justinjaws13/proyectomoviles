import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> pokemonList; // Lista completa de Pokémon
  final int currentIndex; // Índice del Pokémon actual
  final Color color;

  const PokemonDetailScreen({
    super.key,
    required this.pokemonList,
    required this.currentIndex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pokemonDetail = pokemonList[currentIndex];

    // Acceder a los sprites
    final spriteData = pokemonDetail['pokemon_v2_pokemonsprites'];
    final imageUrl = spriteData.isNotEmpty
        ? spriteData[0]['sprites']['front_default']
        : '';

    // Índices de navegación
    final previousIndex = currentIndex > 0 ? currentIndex - 1 : null;
    final nextIndex = currentIndex < pokemonList.length - 1 ? currentIndex + 1 : null;

    // Datos de evolución
    final speciesData = pokemonDetail['pokemon_v2_pokemonspecy'];
    final evolutionChain = speciesData['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'];
    final currentPokemonName = pokemonDetail['name'];

    final evolutionNames = evolutionChain.map((evolution) => evolution['name']).toList();
    final currentEvolutionIndex = evolutionNames.indexOf(currentPokemonName);
    final previousEvolution = currentEvolutionIndex > 0 ? evolutionNames[currentEvolutionIndex - 1] : 'None';
    final nextEvolution = currentEvolutionIndex < evolutionNames.length - 1 ? evolutionNames[currentEvolutionIndex + 1] : 'None';

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
              tag: currentIndex,
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
                  // Nombre del Pokémon
                  Text(
                    pokemonDetail['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Altura y peso
                  Text(
                    "Height: ${pokemonDetail['height']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    "Weight: ${pokemonDetail['weight']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Tipos
                  buildSection(
                    "Types",
                    pokemonDetail['pokemon_v2_pokemontypes']
                        .map((type) => type['pokemon_v2_type']['name'])
                        .join(', '),
                  ),

                  // Habilidades
                  buildSection(
                    "Abilities",
                    pokemonDetail['pokemon_v2_pokemonabilities']
                        .map((ability) => ability['pokemon_v2_ability']['name'])
                        .join(', '),
                  ),

                  // Estadísticas
                  buildSection(
                    "Stats",
                    pokemonDetail['pokemon_v2_pokemonstats']
                        .map((stat) =>
                    "${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}")
                        .join(', '),
                  ),

                  // Movimientos
                  buildSection(
                    "Moves",
                    pokemonDetail['pokemon_v2_pokemonmoves']
                        .map((move) => move['pokemon_v2_move']['name'])
                        .join(', '),
                  ),

                  // Evoluciones
                  buildSection("Previous Evolution", previousEvolution),
                  buildSection("Next Evolution", nextEvolution),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (previousIndex != null)
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PokemonDetailScreen(
                      pokemonList: pokemonList,
                      currentIndex: previousIndex,
                      color: color,
                    ),
                  ),
                );
              },
              child: const Text(
                "Previous",
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (nextIndex != null)
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PokemonDetailScreen(
                      pokemonList: pokemonList,
                      currentIndex: nextIndex,
                      color: color,
                    ),
                  ),
                );
              },
              child: const Text(
                "Next",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
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
