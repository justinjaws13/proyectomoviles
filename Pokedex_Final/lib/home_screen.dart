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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                return Card(
                  child: Column(
                    children: [
                      Text(pokedex[index]['name']),
                      CachedNetworkImage(imageUrl: pokedex[index]['img']),
                    ],
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
    );
  }

  //llamada a la api para conseguir la informacion de los pokemons
  void conseguirPokemonData() async {
    var url = Uri.https("raw.githubusercontent.com", "/Biuni/PokemonGO-Pokedex/master/pokedex.json");
    var client = http.Client();
    try {
      //para esperar por el servidor porque hay imagenes que no cargaban y daban error
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
      print('Network error: $error');
    } finally {
      client.close();
    }
  }
}
