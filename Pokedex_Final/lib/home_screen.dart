import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var pokemonApi = "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json";
  List pokedex = [];

  @override
  void initState() {
    super.initState();
    if (mounted) {
      conseguirPokemonData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo (pokeball)
          Positioned(
            top: -50,
            right: -50,
            child: Image.asset('images/pokeball2.png', width: 200, fit: BoxFit.fitWidth),
          ),
          // Contenido desplazable
          Positioned(
            top: 80,
              left: 20,
              child:Text("Pokedex",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black ),)
          ),
          Positioned(
            top: 150,
            bottom: 0,
            width: width,
            child: SingleChildScrollView(  // Añadimos SingleChildScrollView para evitar desbordamiento
              child: Column(
                children: [
                  // Si hay datos del pokédex, mostramos el GridView
                  pokedex.isNotEmpty
                      ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: pokedex.length,
                    itemBuilder: (context, index) {
                      var type = pokedex[index]['type'][0];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 30,
                                left: 10,
                                child: Text(
                                  pokedex[index]['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 52,
                                left: 10,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Colors.black26,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 4),
                                    child: Text(
                                      type.toString(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: CachedNetworkImage(
                                  imageUrl: pokedex[index]['img'],
                                  height: 100,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Llamada a la API para obtener los datos de Pokémon
  void conseguirPokemonData() async {
    var url = Uri.https("raw.githubusercontent.com", "/Biuni/PokemonGO-Pokedex/master/pokedex.json");
    var client = http.Client();
    try {
      // Esperamos la respuesta del servidor (en caso de que las imágenes no se carguen rápidamente)
      var response = await client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var decodedJsonData = jsonDecode(response.body);
        setState(() {
          pokedex = decodedJsonData['pokemon'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red: $error');
    } finally {
      client.close();
    }
  }
}
