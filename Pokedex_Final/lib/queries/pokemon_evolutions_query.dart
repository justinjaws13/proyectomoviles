const String getPokemonEvolutionsQuery = """
  query GetPokemonEvolutions(\$chainId: Int!) {
    pokemon_v2_evolutionchain(where: {id: {_eq: \$chainId}}) {
      pokemon_v2_pokemonspecies(order_by: {id: asc}) {
        name
      }
    }
  }
""";
