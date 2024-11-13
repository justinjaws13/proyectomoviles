# pokedex_final

Una aplicación de Pokédex desarrollada en Flutter, que permite a los usuarios explorar 
y obtener información detallada sobre diferentes especies de Pokémon. 
Esta aplicación utiliza la API de GraphQL de PokeAPI para obtener datos en tiempo real.

# Índice
1. Descripción General
2. Características
3. Requisitos Técnicos
4. Instalación
5. Estructura de la Aplicación
6. Detalles de la Implementación
7. Decisiones de Diseño
8. Documentación Técnica

### Descripción General

Este proyecto Pokédex permite:

Visualizar una lista de Pokémon con sus nombres, imágenes y tipos.
Acceder a una pantalla de detalles que muestra información extendida sobre cada Pokémon, 
como sus estadísticas, habilidades, evoluciones y movimientos.
Filtrar Pokémon por tipo y generación.
Disfrutar de una navegación fluida entre la lista de Pokémon y los detalles.

### Características

Interfaz Intuitiva: Diseño simple y atractivo que incluye una lista de Pokémon con sus imágenes y nombres.
API en Tiempo Real: La aplicación utiliza la API de GraphQL de PokeAPI para obtener datos de Pokémon de manera eficiente.
Navegación Intuitiva: Facilita la navegación entre la lista de Pokémon y la vista de detalles de cada uno.
Filtros Personalizables: Permite filtrar Pokémon por tipo y generación.
Animaciones Suaves: Incluye animaciones y transiciones para mejorar la experiencia de usuario.

### Requisitos Técnicos

Flutter SDK: >=2.17.0 <4.0.0
Dart: Compatible con las versiones especificadas de Flutter
GraphQL API: PokeAPI (https://pokeapi.co) graphql_flutter v5.0.0
Paquetes de Flutter:
graphql_flutter: Para la integración con la API de GraphQL.
cached_network_image: Para gestionar la carga de imágenes.
flutter/material.dart: Widgets y diseño en Flutter.

### Instalación

Clonar el repositorio:
`git clone https://github.com/justinjaws13/proyectomoviles/tree/main/Pokedex_Final
cd pokedex_final`

Instalar dependencias:
`flutter pub get
`
Ejecutar la aplicación:
`flutter run
`

### Estructura de la Aplicación

lib/
├── main.dart              # Punto de entrada de la aplicación
├── home_screen.dart       # Pantalla principal con la lista de Pokémon y filtros
└── pokemon_details_screen.dart # Pantalla de detalles del Pokémon

### Detalles de la Implementación
1. Interfaz de Usuario
   Lista de Pokémon: Presenta una lista en GridView con nombres, tipos e imágenes.
   Detalles del Pokémon: Pantalla que muestra información detallada como 
   estadísticas, habilidades, evoluciones, y movimientos.
2. Uso de GraphQL
   Consulta de la Lista de Pokémon: Utilizamos una consulta de GraphQL para obtener los datos básicos de cada Pokémon.
   Consulta de Detalles: Cada vez que el usuario selecciona un Pokémon, 
   se envía una consulta de GraphQL para obtener datos adicionales, como estadísticas y habilidades.
3. Navegación
   Se utiliza Navigator para la transición entre la lista y los detalles del Pokémon. 
   También se implementa Hero Animation para una transición visual suave de las imágenes.
4. Sistema de Filtrado y Ordenación
   Filtro por Tipo: Dropdown para seleccionar el tipo de Pokémon.
   Filtro por Generación: Dropdown para filtrar por generación.
5. Animaciones y Transiciones
   La lista de Pokémon se muestra con una transición de opacidad (FadeTransition), 
   mientras que la navegación a la pantalla de detalles utiliza una animación Hero para la imagen del Pokémon.

### Decisiones de Diseño

**Uso de GraphQL**
Para implementar la obtención de datos de Pokémon en tiempo real, 
integramos la API de PokeAPI usando graphql_flutter, una librería de Flutter que facilita el acceso 
y manejo de datos de GraphQL en la aplicación. Esta librería se utiliza para:

* Consulta de la Lista de Pokémon:
  Una primera consulta de GraphQL permite obtener información básica de los Pokémon, 
  como su nombre, tipo y sprites (imágenes). Estos datos se muestran en la vista principal de la lista.
* Consulta de Detalles de Pokémon:
  Al seleccionar un Pokémon, se envía una segunda consulta de GraphQL para obtener detalles adicionales, 
  como estadísticas, habilidades, evoluciones y movimientos. Esto garantiza que solo los datos necesarios 
  se obtengan cuando son requeridos, optimizando el rendimiento de la aplicación.

Cada consulta se implementa mediante widgets de Query proporcionados por graphql_flutter, 
lo cual simplifica la administración de estados y evita la recarga innecesaria de datos, 
al integrar el manejo de resultados y errores de manera directa.

**Filtros Personalizables**
Para una experiencia de usuario flexible y personalizada, los filtros permiten a los usuarios clasificar
y buscar Pokémon por tipo y generación. La implementación de estos filtros se realiza mediante 
**DropdownButton** en la barra superior, manteniéndolos siempre visibles y accesibles. 
Los filtros aplican lógica de búsqueda en los datos ya obtenidos, permitiendo:

**Filtrado por Tipo:** Los tipos de Pokémon (como Agua, Fuego, Planta, etc.) se muestran en un menú desplegable. 
El usuario puede seleccionar un tipo y ver únicamente Pokémon de esa categoría.

**Filtrado por Generación:** Similar al filtro de tipo, el filtro de generación permite a los usuarios buscar 
Pokémon específicos de una generación en particular, o bien ver todos en la opción "Todas".

**Gestión de Imágenes con cached_network_image:** 
Se utilizó esta librería para mejorar la eficiencia y reducir el tiempo de carga de imágenes.

### Documentación Técnica
La aplicación realiza consultas específicas para obtener tanto la lista de Pokémon como sus detalles.
Descriremos cada consulta y su propósito:

**1. Consulta de la Lista y Detalles del Pokémon**
`const String getPokemonListQuery = """
query {
pokemon_v2_pokemon{
name
height
weight
pokemon_v2_pokemonspecy {
generation_id
evolution_chain_id
evolves_from_species_id
pokemon_v2_evolutionchain {
pokemon_v2_pokemonspecies {
name
}
}
}
pokemon_v2_pokemontypes {
pokemon_v2_type {
name
}
}
pokemon_v2_pokemonabilities {
pokemon_v2_ability {
name
}
}
pokemon_v2_pokemonstats {
base_stat
pokemon_v2_stat {
name
}
}
pokemon_v2_pokemonmoves(limit: 5) {  
pokemon_v2_move {
name
}
}
pokemon_v2_pokemonsprites {
sprites
}
}
}
""";
`
**2. Manejo de Estados y Animaciones**
   Las animaciones entre pantallas se manejan principalmente con Hero y FadeTransition, 
   mientras que los estados de filtros y datos se gestionan usando setState y GraphQL Query.


