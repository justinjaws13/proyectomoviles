import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class PokemonDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> fullPokedex; // Lista completa de Pokémon
  final List<Map<String, dynamic>> filteredPokedex; // Lista filtrada
  final int currentIndex;
  final Set<int> favoritePokemonIds;
  final Function(int) onFavoriteToggle; // Lista de IDs de Pokémon favoritos

  const PokemonDetailScreen({
    super.key,
    required this.fullPokedex,
    required this.filteredPokedex,
    required this.currentIndex,
    required this.favoritePokemonIds,
    required this.onFavoriteToggle,
  });

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late int currentIndex;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    _updateFavoriteStatus();
  }

  void _updateFavoriteStatus() {
    final pokemonId = widget.filteredPokedex[currentIndex]['id'];
    setState(() {
      isFavorite = widget.favoritePokemonIds.contains(pokemonId);
    });
  }

  void _toggleFavorite() async {
    final pokemonId = widget.filteredPokedex[currentIndex]['id'];
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (isFavorite) {
        widget.favoritePokemonIds.remove(pokemonId);
      } else {
        widget.favoritePokemonIds.add(pokemonId);
      }
      isFavorite = !isFavorite;

      // Guardar favoritos actualizados
      prefs.setStringList(
        'favoritePokemonIds',
        widget.favoritePokemonIds.map((id) => id.toString()).toList(),
      );
    });
  }

  Future<void> _sharePokemonDetails() async {
    try {
      final imageBytes = await _capturePokemonCard();

      await Share.shareXFiles(
        [
          XFile.fromData(
            imageBytes,
            name: '${widget.filteredPokedex[currentIndex]['name']}.png',
            mimeType: 'image/png',
          ),
        ],
        text: '¡Mira este increíble Pokémon!',
      );
    } catch (e) {
      print("Error al compartir el Pokémon: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final pokemonDetail = widget.filteredPokedex[currentIndex];

    // Acceder a los sprites
    final spriteData = pokemonDetail['pokemon_v2_pokemonsprites'];
    final imageUrl = (spriteData.isNotEmpty && spriteData[0]['sprites'] != null
        ? spriteData[0]['sprites']['front_default']
        : '')?.toString() ??
        '';

    // Cadena evolutiva completa (usando la lista completa de Pokémon)
    final speciesData = pokemonDetail['pokemon_v2_pokemonspecy'];
    final evolutionChain = speciesData['pokemon_v2_evolutionchain']
    ['pokemon_v2_pokemonspecies'];

    final allEvolutions = evolutionChain.map<Map<String, String>>((evolution) {
      final evolutionName = (evolution['name'] ?? 'Unknown').toString();

      // Buscar en la lista completa
      final matchedPokemon = widget.fullPokedex.firstWhere(
            (pokemon) => pokemon['name'] == evolutionName,
        orElse: () => {}, // Aquí puede estar el problema
      );

      final evolutionImage = (matchedPokemon['pokemon_v2_pokemonsprites']
          ?.isNotEmpty ==
          true)
          ? matchedPokemon['pokemon_v2_pokemonsprites'][0]['sprites']
      ['front_default']
          .toString()
          : '';

      return {
        'name': evolutionName,
        'imageUrl': evolutionImage,
      };
    }).toList();


    // Colores
    final pokemonType = pokemonDetail['pokemon_v2_pokemontypes'][0]
    ['pokemon_v2_type']['name'];
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
    child: SafeArea(
    child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pokemonDetail['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.yellow : Colors.white,
                            size: 28,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: _sharePokemonDetails,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              RepaintBoundary(
                key: _shareKey,
                child: _buildPokemonCardForSharing(pokemonDetail, typeColors),
              ),
              // Animación de la imagen principal
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 200,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
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
                      content:
                      Text("Height: ${pokemonDetail['height']}\nWeight: ${pokemonDetail['weight']}"),
                      icon: Icons.straighten,
                    ),
                    _buildCard(
                      title: "Types",
                      content: Text(
                        pokemonDetail['pokemon_v2_pokemontypes']
                            .map((type) => type['pokemon_v2_type']['name'])
                            .join(', '),
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      icon: Icons.category,
                    ),
                    _buildCard(
                      title: "Abilities",
                      content: Text(pokemonDetail['pokemon_v2_pokemonabilities']
                          .map((ability) =>
                      ability['pokemon_v2_ability']['name'])
                          .join(', '),
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      icon: Icons.flash_on,
                    ),
                    _buildCard(
                      title: "Stats",
                      content: _buildStatsTable(pokemonDetail['pokemon_v2_pokemonstats']),
                      icon: Icons.bar_chart,
                    ),
                    _buildCard(
                      title: "Moves",
                      content: Text(pokemonDetail['pokemon_v2_pokemonmoves']
                          .map((move) => move['pokemon_v2_move']['name'])
                          .join(', '),
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      icon: Icons.sports_martial_arts,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Evolution Chain",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
                                    (pokemon) =>
                                pokemon['name'] == evolution['name'],
                              );

                              if (targetIndex != -1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PokemonDetailScreen(
                                      fullPokedex: widget.fullPokedex,
                                      filteredPokedex: widget.fullPokedex,
                                      currentIndex: targetIndex,
                                      favoritePokemonIds:
                                      widget.favoritePokemonIds,
                                      onFavoriteToggle:
                                      widget.onFavoriteToggle, // Asegúrate de incluir esto
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: evolution['imageUrl'],
                                    height: 100,
                                    fit: BoxFit.fitHeight,
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error,
                                        color: Colors.red),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    evolution['name'],
                                    style:
                                    const TextStyle(color: Colors.white),
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
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.05), // Fondo semitransparente
        ),
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    content, // Aquí pasas directamente el Widget
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatsTable(List stats) {
    return Column(
      children: stats.map<Widget>((stat) {
        final statName = stat['pokemon_v2_stat']['name'].toString().toUpperCase();
        final baseStat = stat['base_stat'];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  statName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 5,
                child: LinearProgressIndicator(
                  value: baseStat / 255.0,
                  backgroundColor: Colors.grey[300],
                  color: baseStat > 100 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                baseStat.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget para generar la tarjeta del Pokémon
  Widget _buildPokemonCardForSharing(
      Map<String, dynamic> pokemonDetail, List<Color> typeColors) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: typeColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre del Pokémon
          Text(
            pokemonDetail['name'].toString().toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1.5, 1.5), // Desplazamiento
                  blurRadius: 2.0, // Desenfoque
                  color: Colors.black, // Color de la sombra
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Imagen del Pokémon
          CachedNetworkImage(
            imageUrl: pokemonDetail['pokemon_v2_pokemonsprites'][0]['sprites']
            ['front_default'] ??
                '',
            height: 150,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) =>
            const Icon(Icons.error, color: Colors.red),
          ),
          const SizedBox(height: 16),
          // Tipos del Pokémon
          Text(
            "Type: ${pokemonDetail['pokemon_v2_pokemontypes'].map((type) => type['pokemon_v2_type']['name']).join(', ')}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Habilidades del Pokémon
          Text(
            "Abilities: ${pokemonDetail['pokemon_v2_pokemonabilities'].map((ability) => ability['pokemon_v2_ability']['name']).join(', ')}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Estadísticas del Pokémon
          Expanded(
            child: ListView(
              children: pokemonDetail['pokemon_v2_pokemonstats']
                  .map<Widget>((stat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "${stat['pokemon_v2_stat']['name'].toString().toUpperCase()}: ${stat['base_stat']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          offset: Offset(0.8, 0.8),
                          blurRadius: 1.5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  final GlobalKey _shareKey = GlobalKey();

  /// Captura el lienzo como imagen
  Future<Uint8List> _capturePokemonCard() async {
    try {
      RenderRepaintBoundary boundary =
      _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print("Error al capturar la tarjeta del Pokémon: $e");
      rethrow;
    }
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
