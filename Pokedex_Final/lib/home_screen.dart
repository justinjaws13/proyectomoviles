import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pokedex_final/queries/FilterSection.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importamos shared_preferences
import 'pokemon_details_screen.dart';
import 'queries/graphql_queries.dart'; // Importamos la consulta GraphQL

const Map<String, IconData> _typeIcons = {
  'grass': Icons.grass,
  'fire': Icons.local_fire_department,
  'water': Icons.water_drop,
  'electric': Icons.flash_on,
  'rock': Icons.terrain_outlined,
  'ground': Icons.landscape,
  'psychic': Icons.psychology,
  'fighting': Icons.sports_mma,
  'bug': Icons.bug_report,
  'ghost': FontAwesomeIcons.ghost,
  'normal': Icons.circle,
  'poison': Icons.science,
  'ice': Icons.ac_unit,
  'dark': FontAwesomeIcons.moon,
  'steel': FontAwesomeIcons.screwdriver,
  'dragon': FontAwesomeIcons.dragon,
  'fairy': FontAwesomeIcons.wandMagic,
  'flying': FontAwesomeIcons.feather,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? selectedType;
  int? selectedGeneration;
  String? selectedAbility;
  String? selectedSortOrder;
  String searchQuery = "";
  Set<int> favoritePokemonIds = {}; // IDs de Pokémon favoritos
  bool showFavoritesOnly = false; // Mostrar solo favoritos
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Rango de poder
  int? minPower = 0; // Poder mínimo
  int? maxPower = 800; // Poder máximo
  RangeValues powerRange = const RangeValues(0, 800);

  final List<String> types = [
    'All', 'Grass', 'Fire', 'Water', 'Electric', 'Rock', 'Ground', 'Psychic',
    'Fighting', 'Bug', 'Ghost', 'Normal', 'Poison', 'Ice', 'Dragon', 'Dark',
    'Fairy', 'Steel', 'Flying'
  ];
  final List<int?> generations = [null, 1, 2, 3, 4, 5, 6, 7, 8];

  final List<String> abilities = [
    'All', 'Overgrow', 'Blaze', 'Torrent', 'Static', 'Poison Point', 'Swift Swim',
    'Intimidate', 'Levitate', 'Chlorophyll', 'Guts', 'Keen Eye', 'Sturdy', 'Inner Focus',
    'Compound Eyes', 'Sand Stream', 'Pressure', 'Synchronize', 'Thick Fat', 'Immunity',
    'Flash Fire', 'Flame Body', 'Water Absorb', 'Volt Absorb', 'Cute Charm', 'Shell Armor',
    'Natural Cure', 'Run Away', 'Pickup', 'Early Bird', 'Truant', 'Hustle', 'Marvel Scale',
    'Battle Armor', 'Hyper Cutter', 'Soundproof', 'Effect Spore', 'Arena Trap',
    'Vital Spirit', 'Rain Dish', 'Speed Boost', 'Magic Guard', 'Filter', 'Iron Barbs',
    'Adaptability', 'Sheer Force', 'Mold Breaker', 'Prankster', 'Rough Skin', 'Lightning Rod',
    'Unburden', 'Technician', 'Mega Launcher', 'Contrary', 'Bulletproof', 'Strong Jaw',
    'Protean', 'Drought', 'Defiant', 'Victory Star', 'Snow Warning', 'Solar Power', 'Steadfast',
    'No Guard', 'Reckless', 'Multiscale', 'Magic Bounce', 'Pixilate', 'Parental Bond',
    'Dark Aura', 'Fairy Aura', 'Aura Break', 'Shadow Shield',
  ];

  final List<String> sortOptions = [
    'Number', 'Name', 'Power', 'Type', 'Abilities'
  ];


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _loadFavorites(); // cargo los favoritos al iniciar
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favoritePokemonIds') ?? [];
      setState(() {
        favoritePokemonIds = favoriteIds.map((id) => int.parse(id)).toSet();
      });
    } catch (e) {
      print("Error al cargar favoritos: $e");
    }
  }

  void _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = favoritePokemonIds.map((id) => id.toString()).toList();
    prefs.setStringList('favoritePokemonIds', favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Text(
            "Pokédex",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFavoritesOnly = !showFavoritesOnly;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: FiltersSection(
              types: types,
              typeIcons: _typeIcons,
              generations: generations,
              abilities: abilities,
              sortOptions: sortOptions,
              selectedType: selectedType,
              onTypeChanged: (value) {
                setState(() {
                  selectedType = value == 'all' ? null : value;
                });
              },
              selectedGeneration: selectedGeneration,
              onGenerationChanged: (value) {
                setState(() {
                  selectedGeneration = value;
                });
              },
              selectedAbility: selectedAbility,
              onAbilityChanged: (value) {
                setState(() {
                  selectedAbility = value;
                });
              },
              powerRange: powerRange,
              onPowerRangeChanged: (range) {
                setState(() {
                  powerRange = range;
                  minPower = range.start.toInt();
                  maxPower = range.end.toInt();
                });
              },
              selectedSortOrder: selectedSortOrder,
              onSortOrderChanged: (value) {
                setState(() {
                  selectedSortOrder = value;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(getPokemonListQuery),
              ),
              builder: (QueryResult result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (result.hasException) {
                  return Center(child: Text('Error al cargar datos: ${result.exception.toString()}'));
                }

                final pokedex = (result.data?['pokemon_v2_pokemon'] as List?)
                    ?.cast<Map<String, dynamic>>() ??
                    [];

                final displayedPokedex = showFavoritesOnly
                    ? pokedex.where((pokemon) => favoritePokemonIds.contains(pokemon['id'])).toList()
                    : pokedex;

                final filteredPokedex = displayedPokedex.where((pokemon) {
                  final types = (pokemon['pokemon_v2_pokemontypes'] as List?)
                      ?.map((typeData) =>
                      (typeData['pokemon_v2_type']['name'] as String).toLowerCase())
                      .toList() ??
                      [];
                  final generation = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];

                  final abilities = (pokemon['pokemon_v2_pokemonabilities'] as List?)
                      ?.map((abilityData) =>
                  abilityData['pokemon_v2_ability']['name'] as String)
                      .toList() ??
                      [];

                  final power = ((pokemon['pokemon_v2_pokemonstats'] as List?) ?? [])
                      .fold<int>(0, (sum, stat) => sum + ((stat['base_stat'] ?? 0) as int));

                  final name = (pokemon['name'] as String).toLowerCase();

                  final matchesType = selectedType == null || types.contains(selectedType);
                  final matchesGeneration =
                      selectedGeneration == null || generation == selectedGeneration;
                  final matchesAbility =
                      selectedAbility == null || abilities.contains(selectedAbility);
                  final matchesSearch = searchQuery.isEmpty ||
                      name.contains(searchQuery) ||
                      pokemon['id'].toString() == searchQuery;

                  // Nueva condición: verificar si el poder está dentro del rango seleccionado
                  final matchesPower = (minPower == null || power >= minPower!) &&
                      (maxPower == null || power <= maxPower!);

                  return matchesType && matchesGeneration && matchesAbility && matchesPower && matchesSearch;
                }).toList();

                // Aplicar ordenación
                if (selectedSortOrder != null) {
                  if (selectedSortOrder == 'name') {
                    filteredPokedex.sort((a, b) =>
                        (a['name'] as String).compareTo(b['name'] as String));
                  } else if (selectedSortOrder == 'number') {
                    filteredPokedex.sort((a, b) =>
                        (a['id'] as int).compareTo(b['id'] as int));
                  } else if (selectedSortOrder == 'power') {
                    filteredPokedex.sort((a, b) {
                      final powerA = ((a['pokemon_v2_pokemonstats'] as List?) ?? [])
                          .fold<int>(0, (sum, stat) => sum + ((stat['base_stat'] ?? 0) as int));
                      final powerB = ((b['pokemon_v2_pokemonstats'] as List?) ?? [])
                          .fold<int>(0, (sum, stat) => sum + ((stat['base_stat'] ?? 0) as int));
                      return powerB.compareTo(powerA);
                    });
                  } else if (selectedSortOrder == 'type') {
                    filteredPokedex.sort((a, b) {
                      final typesA = (a['pokemon_v2_pokemontypes'] as List?)
                          ?.map((typeData) => typeData['pokemon_v2_type']['name'] as String)
                          .toList() ??
                          [];
                      final typesB = (b['pokemon_v2_pokemontypes'] as List?)
                          ?.map((typeData) => typeData['pokemon_v2_type']['name'] as String)
                          .toList() ??
                          [];
                      final firstTypeA = typesA.isNotEmpty ? typesA.first : '';
                      final firstTypeB = typesB.isNotEmpty ? typesB.first : '';
                      return firstTypeA.compareTo(firstTypeB);
                    });
                  } else if (selectedSortOrder == 'ability') {
                    filteredPokedex.sort((a, b) {
                      final abilitiesA = (a['pokemon_v2_pokemonabilities'] as List?)
                          ?.map((abilityData) =>
                      abilityData['pokemon_v2_ability']['name'] as String)
                          .toList() ??
                          [];
                      final abilitiesB = (b['pokemon_v2_pokemonabilities'] as List?)
                          ?.map((abilityData) =>
                      abilityData['pokemon_v2_ability']['name'] as String)
                          .toList() ??
                          [];
                      final firstAbilityA = abilitiesA.isNotEmpty ? abilitiesA.first : '';
                      final firstAbilityB = abilitiesB.isNotEmpty ? abilitiesB.first : '';
                      return firstAbilityA.compareTo(firstAbilityB);
                    });
                  }
                }



                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: filteredPokedex.length,
                  itemBuilder: (context, index) {
                    final pokemon = filteredPokedex[index];
                    final pokemonId = pokemon['id'];
                    final isFavorite = favoritePokemonIds.contains(pokemonId);

                    final types = (pokemon['pokemon_v2_pokemontypes'] as List?)
                        ?.map((typeData) => typeData['pokemon_v2_type']['name'] as String)
                        .toList() ??
                        ['Unknown'];

                    final spriteData = pokemon['pokemon_v2_pokemonsprites']?.first['sprites'];
                    final imageUrl = spriteData != null ? spriteData['front_default'] : null;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PokemonDetailScreen(
                              fullPokedex: pokedex,
                              filteredPokedex: filteredPokedex,
                              currentIndex: index,
                              favoritePokemonIds: favoritePokemonIds,
                              onFavoriteToggle: (pokemonId) { // callback
                                setState(() {
                                  if (favoritePokemonIds.contains(pokemonId)) {
                                    favoritePokemonIds.remove(pokemonId);
                                  } else {
                                    favoritePokemonIds.add(pokemonId);
                                  }
                                });
                                _saveFavorites(); // guardar los favoritos actualizados
                              },
                            ),
                          ),
                        );

                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getTypeColor(types.first).withOpacity(0.8),
                              _getTypeColor(types.first).withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 10),
                                  child: Text(
                                    pokemon['name'].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                                  child: Row(
                                    children: types.map((type) {
                                      return Icon(
                                        _typeIcons[type.toLowerCase()] ?? Icons.help,
                                        color: Colors.white,
                                        size: 18,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: imageUrl != null
                                        ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      height: 170,
                                      fit: BoxFit.contain,
                                    )
                                        : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white,
                                      size: 100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isFavorite) {
                                      favoritePokemonIds.remove(pokemonId);
                                    } else {
                                      favoritePokemonIds.add(pokemonId);
                                    }
                                  });
                                  _saveFavorites();
                                },
                                child: Icon(
                                  isFavorite ? Icons.star : Icons.star_border,
                                  color: isFavorite ? Colors.yellow : Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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
}
