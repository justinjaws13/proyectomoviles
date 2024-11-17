import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> fullPokedex; // Lista completa de Pokémon
  final List<Map<String, dynamic>> filteredPokedex; // Lista filtrada
  final int currentIndex;

  const PokemonDetailScreen({
    super.key,
    required this.fullPokedex,
    required this.filteredPokedex,
    required this.currentIndex,
  });

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pokemonDetail = widget.filteredPokedex[currentIndex];

    // Acceder a los sprites
    final spriteData = pokemonDetail['pokemon_v2_pokemonsprites'];
    final imageUrl = (spriteData.isNotEmpty && spriteData[0]['sprites'] != null
        ? spriteData[0]['sprites']['front_default']
        : '')?.toString() ?? '';

    // Cadena evolutiva completa (usando la lista completa de Pokémon)
    final speciesData = pokemonDetail['pokemon_v2_pokemonspecy'];
    final evolutionChain = speciesData['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'];
    final allEvolutions = evolutionChain.map<Map<String, String>>((evolution) {
      final evolutionName = (evolution['name'] ?? 'Unknown').toString();

      // Buscar en la lista completa (fullPokedex)
      final matchedPokemon = widget.fullPokedex.firstWhere(
            (pokemon) => pokemon['name'] == evolutionName,
        orElse: () => {},
      );

      // Obtener la imagen de la evolución
      final evolutionImage = matchedPokemon.isNotEmpty &&
          matchedPokemon['pokemon_v2_pokemonsprites'] != null &&
          matchedPokemon['pokemon_v2_pokemonsprites'][0]['sprites'] != null
          ? (matchedPokemon['pokemon_v2_pokemonsprites'][0]['sprites']['front_default'] ?? '').toString()
          : '';

      return {'name': evolutionName, 'imageUrl': evolutionImage};
    }).toList();

    // Colores
    final pokemonType = pokemonDetail['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name'];
    final typeColors = _getTypeGradient(pokemonType);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: typeColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  pokemonDetail['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Animación de la imagen principal
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 200,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              // Información del Pokémon
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildCard(
                      title: "Height & Weight",
                      content: "Height: ${pokemonDetail['height']}\nWeight: ${pokemonDetail['weight']}",
                      icon: Icons.straighten,
                    ),
                    _buildCard(
                      title: "Types",
                      content: pokemonDetail['pokemon_v2_pokemontypes']
                          .map((type) => type['pokemon_v2_type']['name'])
                          .join(', '),
                      icon: Icons.category,
                    ),
                    _buildCard(
                      title: "Abilities",
                      content: pokemonDetail['pokemon_v2_pokemonabilities']
                          .map((ability) => ability['pokemon_v2_ability']['name'])
                          .join(', '),
                      icon: Icons.flash_on,
                    ),
                    _buildCard(
                      title: "Stats",
                      content: pokemonDetail['pokemon_v2_pokemonstats']
                          .map((stat) =>
                      "${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}")
                          .join('\n'),
                      icon: Icons.bar_chart,
                    ),
                    _buildCard(
                      title: "Moves",
                      content: pokemonDetail['pokemon_v2_pokemonmoves']
                          .map((move) => move['pokemon_v2_move']['name'])
                          .join(', '),
                      icon: Icons.sports_martial_arts,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Evolution Chain",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allEvolutions.length,
                        itemBuilder: (context, index) {
                          final evolution = allEvolutions[index];
                          return GestureDetector(
                            onTap: () {
                              final targetIndex = widget.fullPokedex.indexWhere(
                                    (pokemon) => pokemon['name'] == evolution['name'],
                              );

                              if (targetIndex != -1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PokemonDetailScreen(
                                      fullPokedex: widget.fullPokedex,
                                      filteredPokedex: widget.fullPokedex,
                                      currentIndex: targetIndex,
                                    ),
                                  ),
                                );
                              }
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.filteredPokedex.length,
                  itemBuilder: (context, index) {
                    final otherPokemon = widget.filteredPokedex[index];
                    final otherImageUrl = otherPokemon['pokemon_v2_pokemonsprites'][0]['sprites']['front_default'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              imageUrl: otherImageUrl,
                              height: 80,
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
      ),
    );
  }

  Widget _buildCard({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueGrey, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getTypeGradient(String type) {
    switch (type) {
      case 'grass':
        return [Colors.greenAccent, Colors.lightGreen];
      case 'fire':
        return [Colors.redAccent, Colors.orange];
      case 'water':
        return [Colors.blue, Colors.lightBlueAccent];
      case 'electric':
        return [Colors.yellowAccent, Colors.amber];
      case 'rock':
        return [Colors.brown, Colors.grey];
      case 'ground':
        return [Colors.brown, Colors.orangeAccent];
      case 'psychic':
        return [Colors.indigo, Colors.deepPurple];
      case 'fighting':
        return [Colors.orangeAccent, Colors.red];
      case 'bug':
        return [Colors.lightGreenAccent, Colors.green];
      case 'ghost':
        return [Colors.deepPurple, Colors.purple];
      case 'normal':
        return [Colors.grey, Colors.black26];
      case 'poison':
        return [Colors.deepPurpleAccent, Colors.purpleAccent];
      case 'ice':
        return [Colors.lightBlueAccent, Colors.cyan];
      case 'dark':
        return [Colors.black87, Colors.grey];
      case 'steel':
        return [Colors.blueGrey, Colors.grey];
      default:
        return [Colors.pinkAccent, Colors.pink];
    }
  }
}
