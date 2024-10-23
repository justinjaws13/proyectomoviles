import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strawberry Pavlova',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Strawberry Pavlova'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Columna izquierda con el texto y los detalles de la receta
                Expanded(
                  flex: 2, // Da más espacio a la columna que a la imagen
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de la receta
                      const Text(
                        'Strawberry Pavlova',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8), // Espacio entre los elementos
                      // Descripción de la receta
                      const Text(
                        'Pavlova is a meringue-based dessert named after the Russian ballerina Anna Pavlova. Pavlova features a crisp crust and soft, light inside, topped with fruit and whipped cream.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      // Fila con estrellas y número de reseñas
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.green[500]),
                          Icon(Icons.star, color: Colors.green[500]),
                          Icon(Icons.star, color: Colors.green[500]),
                          Icon(Icons.star, color: Colors.green[500]),
                          Icon(Icons.star_half, color: Colors.green[500]),
                          const SizedBox(width: 8),
                          const Text('170 Reviews', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Fila con detalles de preparación, cocción y porciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailColumn(Icons.timer, 'PREP:', '25 min'),
                          _buildDetailColumn(Icons.restaurant, 'COOK:', '1 hr'),
                          _buildDetailColumn(Icons.people, 'FEEDS:', '4-6'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // Espacio entre la columna y la imagen
                // Imagen a la derecha
                Expanded(
                  flex: 1, // Menos espacio para la imagen
                  child: Image.asset(
                    'assets/strawberry_pavlova.jpg', // Ruta de la imagen
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para crear las columnas con iconos y texto
  Widget _buildDetailColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[500]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
