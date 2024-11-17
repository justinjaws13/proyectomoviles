import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> pokemonList; // Lista completa de Pokémon
  final int currentIndex; // Índice del Pokémon actual

  const PokemonDetailScreen({
    super.key,
    required this.pokemonList,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pokemonDetail = pokemonList[currentIndex];

    // Acceder a los sprites
    final spriteData = pokemonDetail['pokemon_v2_pokemonsprites'];
    final imageUrl = (spriteData.isNotEmpty && spriteData[0]['sprites'] != null
        ? spriteData[0]['sprites']['front_default']
        : '')?.toString() ?? '';

    // Cadena evolutiva completa
    final speciesData = pokemonDetail['pokemon_v2_pokemonspecy'];
    final evolutionChain = speciesData['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'];

    final allEvolutions = evolutionChain.map<Map<String, String>>((evolution) {
      final evolutionName = (evolution['name'] ?? 'Unknown').toString();

      // Find the corresponding Pokémon safely
      final matchedPokemon = pokemonList.firstWhere(
            (pokemon) => pokemon['name'] == evolutionName,
        orElse: () => {},
      );

      // Get the sprite URL, ensuring it's a string
      final evolutionImage = matchedPokemon.isNotEmpty &&
          matchedPokemon['pokemon_v2_pokemonsprites'] != null &&
          matchedPokemon['pokemon_v2_pokemonsprites'][0]['sprites'] != null
          ? (matchedPokemon['pokemon_v2_pokemonsprites'][0]['sprites']['front_default'] ?? '').toString()
          : '';

      return {'name': evolutionName, 'imageUrl': evolutionImage};
    }).toList();

    // Obtener el color basado en el tipo del Pokémon actual
    final pokemonType = pokemonDetail['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name'];
    final color = _getTypeColor(pokemonType);


    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          pokemonDetail['name'],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal del Pokémon
            Center(
              child: Hero(
                tag: currentIndex,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  fit: BoxFit.fitHeight,
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSection(
                    "Height & Weight",
                    "Height: ${pokemonDetail['height']} \nWeight: ${pokemonDetail['weight']}",
                  ),
                  buildSection(
                    "Types",
                    pokemonDetail['pokemon_v2_pokemontypes']
                        .map((type) => type['pokemon_v2_type']['name'])
                        .join(', '),
                  ),
                  buildSection(
                    "Abilities",
                    pokemonDetail['pokemon_v2_pokemonabilities']
                        .map((ability) => ability['pokemon_v2_ability']['name'])
                        .join(', '),
                  ),
                  buildSection(
                    "Stats",
                    pokemonDetail['pokemon_v2_pokemonstats']
                        .map((stat) =>
                    "${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}")
                        .join('\n'),
                  ),
                  buildSection(
                    "Moves",
                    pokemonDetail['pokemon_v2_pokemonmoves']
                        .map((move) => move['pokemon_v2_move']['name'])
                        .join(', '),
                  ),

                  // Sección de todas las evoluciones
                  const SizedBox(height: 20),
                  const Text(
                    "Evolution Chain",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: allEvolutions.length,
                      itemBuilder: (context, index) {
                        final evolution = allEvolutions[index];

                        return GestureDetector(
                          onTap: () {
                            // Navegar al detalle del Pokémon seleccionado
                            final targetIndex = pokemonList.indexWhere(
                                    (pokemon) => pokemon['name'] == evolution['name']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PokemonDetailScreen(
                                  pokemonList: pokemonList,
                                  currentIndex: targetIndex,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: evolution['imageUrl'],
                                  height: 100,
                                  fit: BoxFit.fitHeight,
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.red),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  evolution['name'],
                                  style: const TextStyle(color: Colors.white),
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

            // Lista de Pokémon (barra horizontal)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "All Pokémon",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pokemonList.length,
                itemBuilder: (context, index) {
                  final otherPokemon = pokemonList[index];
                  final otherImageUrl = otherPokemon['pokemon_v2_pokemonsprites'][0]['sprites']['front_default'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PokemonDetailScreen(
                            pokemonList: pokemonList,
                            currentIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: otherImageUrl,
                            height: 80, // Incrementar el tamaño para visibilidad
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.red),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            otherPokemon['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
Color _getTypeColor(String type) {
  switch (type) {
    case 'grass':
      return Colors.greenAccent;
    case 'fire':
      return Colors.redAccent;
    case 'water':
      return Colors.blue;
    case 'electric':
      return Colors.yellowAccent;
    case 'rock':
      return Colors.grey;
    case 'ground':
      return Colors.brown;
    case 'psychic':
      return Colors.indigo;
    case 'fighting':
      return Colors.orangeAccent;
    case 'bug':
      return Colors.lightGreenAccent;
    case 'ghost':
      return Colors.deepPurple;
    case 'normal':
      return Colors.black26;
    case 'poison':
      return Colors.deepPurpleAccent;
    case 'ice':
      return Colors.lightBlueAccent;
    case 'dark':
      return Colors.black87;
    case 'steel':
      return Colors.blueGrey;
    default:
      return Colors.pinkAccent;
  }
}
