import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PokemonDetailScreen extends StatefulWidget {
  final pokemonDetail;
  final Color color;
  final int heroTag;

  const PokemonDetailScreen({
    Key? key,
    required this.pokemonDetail,
    required this.color,
    required this.heroTag,
  }) : super(key: key);

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: widget.color,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40,
            left: 1,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 90,
            left: 20,
            child: Text(
              widget.pokemonDetail['name'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(60)),
                color: Colors.black26,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.pokemonDetail['type'] != null
                    ? widget.pokemonDetail['type'].join(', ')
                    : "Unknown Type", // Texto alternativo si 'type' es null
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),
          ),
          Positioned(
            top: height * 0.25,
            right: -7,
            child: Image.asset(
              'images/pokeball2-remove.png',
              height: 200,
              fit: BoxFit.fitHeight,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: Text(
                            "Name",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.pokemonDetail['name'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: Text(
                            "Height",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.pokemonDetail['height'].toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: Text(
                            "Weight",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.pokemonDetail['weight'].toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: Text(
                            "Spawn Time",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.pokemonDetail['spawn_time'].toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: Text(
                            "Weaknesses",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.pokemonDetail['weaknesses'].join(", "),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: Text(
                            "Previous Evolution",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.pokemonDetail['prev_evolution'] != null
                                ? widget.pokemonDetail['prev_evolution'][0]['name'] // Muestra el nombre de la primera evolución anterior
                                : "None", // Texto alternativo si no hay evolución anterior
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // Espacio entre las filas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: Text(
                            "Next Evolution",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.pokemonDetail['next_evolution'] != null
                                ? widget.pokemonDetail['next_evolution'][0]['name'] // Muestra el nombre de la primera evolución siguiente
                                : "None", // Texto alternativo si no hay próxima evolución
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.18,
            left: (width / 2) - 200,
            child: CachedNetworkImage(
              imageUrl: widget.pokemonDetail['img'],
              height: 235,
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }
}
