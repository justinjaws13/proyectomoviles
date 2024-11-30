import 'package:flutter/material.dart';

class FiltersSection extends StatelessWidget {
  final List<String> types;
  final Map<String, IconData> typeIcons;
  final List<int?> generations;
  final List<String> abilities;
  final List<String> sortOptions;

  final String? selectedType;
  final void Function(String?) onTypeChanged;
  final int? selectedGeneration;
  final void Function(int?) onGenerationChanged;
  final String? selectedAbility;
  final void Function(String?) onAbilityChanged;
  final RangeValues powerRange;
  final void Function(RangeValues) onPowerRangeChanged;
  final String? selectedSortOrder;
  final void Function(String?) onSortOrderChanged;

  const FiltersSection({
    super.key,
    required this.types,
    required this.typeIcons,
    required this.generations,
    required this.abilities,
    required this.sortOptions,
    required this.selectedType,
    required this.onTypeChanged,
    required this.selectedGeneration,
    required this.onGenerationChanged,
    required this.selectedAbility,
    required this.onAbilityChanged,
    required this.powerRange,
    required this.onPowerRangeChanged,
    required this.selectedSortOrder,
    required this.onSortOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Buscar Pokémon por nombre o número",
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => onTypeChanged(value.isEmpty ? null : value),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Filtro por tipo
            _buildDropdownButton<String>(
              context: context, // Pass the context explicitly
              value: selectedType,
              hint: "Tipo",
              items: types.map((type) {
                final typeKey = type.toLowerCase();
                return DropdownMenuItem<String>(
                  value: type.toLowerCase(),
                  child: Row(
                    children: [
                      Icon(
                        typeIcons[typeKey] ?? Icons.help,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(type, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onTypeChanged,
            ),
            // Filtro por generación
            _buildDropdownButton<int?>(
              context: context, // Pass the context explicitly
              value: selectedGeneration,
              hint: "Generación",
              items: generations.map((gen) {
                return DropdownMenuItem<int?>(
                  value: gen,
                  child: Text(
                    gen == null ? 'Todas' : "Gen $gen",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onGenerationChanged,
            ),
            // Filtro por habilidad
            _buildDropdownButton<String>(
              context: context, // Pass the context explicitly
              value: selectedAbility,
              hint: "Habilidad",
              items: abilities.map((ability) {
                return DropdownMenuItem<String>(
                  value: ability == 'All' ? null : ability.toLowerCase(),
                  child: Text(
                    ability,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onAbilityChanged,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Poder:", style: TextStyle(color: Colors.white)),
            Expanded(
              child: RangeSlider(
                values: powerRange,
                min: 0,
                max: 800,
                divisions: 20,
                labels: RangeLabels(
                  powerRange.start.round().toString(),
                  powerRange.end.round().toString(),
                ),
                activeColor: Colors.blueAccent,
                inactiveColor: Colors.white38,
                onChanged: onPowerRangeChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDropdownButton<String>(
          context: context, // Pass the context explicitly
          value: selectedSortOrder,
          hint: "Ordenar",
          items: sortOptions.map((sortOption) {
            return DropdownMenuItem<String>(
              value: sortOption.toLowerCase(),
              child: Text(
                sortOption,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onSortOrderChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownButton<T>({
    required BuildContext context,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white38),
      ),
      child: DropdownButton<T>(
        value: value,
        dropdownColor: Colors.black87,
        hint: Text(hint, style: const TextStyle(color: Colors.white70)),
        items: items,
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        underline: Container(), // Eliminar la línea inferior predeterminada
      ),
    );
  }
}
