/// Rich Geological Model representing classification output, physical properties,
/// and African mining locality records.
class MineralSpecimen {
  final String id;
  final String name;
  final String chemicalFormula;
  final String group;
  final String color;
  final String mohsHardness;
  final String crystalSystem;
  final String luster;
  final String streak;
  final String cleavage;
  final String specificGravity;
  final String rawOreEstimate;
  final String specimenEstimate;
  final List<String> africanRegions;
  final String rarityTier;
  final String economicValue;
  final String toxicity;
  final String description;
  final String identificationTips;

  const MineralSpecimen({
    required this.id,
    required this.name,
    required this.chemicalFormula,
    required this.group,
    required this.color,
    required this.mohsHardness,
    required this.crystalSystem,
    required this.luster,
    required this.streak,
    required this.cleavage,
    required this.specificGravity,
    required this.rawOreEstimate,
    required this.specimenEstimate,
    required this.africanRegions,
    required this.rarityTier,
    required this.economicValue,
    required this.toxicity,
    required this.description,
    required this.identificationTips,
  });

  factory MineralSpecimen.fromJson(Map<String, dynamic> json) {
    return MineralSpecimen(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Specimen',
      chemicalFormula: json['chemical_formula'] ?? 'N/A',
      group: json['group'] ?? 'GENERAL MINERAL',
      color: json['color'] ?? 'Variable',
      mohsHardness: json['mohs_hardness'] ?? 'N/A',
      crystalSystem: json['crystal_system'] ?? 'N/A',
      luster: json['luster'] ?? 'N/A',
      streak: json['streak'] ?? 'N/A',
      cleavage: json['cleavage'] ?? 'N/A',
      specificGravity: json['specific_gravity'] ?? 'N/A',
      rawOreEstimate: json['raw_ore_estimate'] ?? 'Market Dependent',
      specimenEstimate: json['specimen_estimate'] ?? 'Grade Dependent',
      africanRegions: List<String>.from(json['african_regions'] ?? []),
      rarityTier: json['rarity_tier'] ?? 'Common',
      economicValue: json['economic_value'] ?? 'Standard Industrial',
      toxicity: json['toxicity'] ?? 'Non-toxic',
      description: json['description'] ?? '',
      identificationTips: json['identification_tips'] ?? '',
    );
  }

  /// Create a dynamic fallback specimen when a predicted label is not yet in DB
  factory MineralSpecimen.fromFallbackLabel(String label) {
    final formattedName = label
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '')
        .join(' ');

    return MineralSpecimen(
      id: label.toLowerCase(),
      name: formattedName,
      chemicalFormula: 'Geological Specimen',
      group: 'FIELD CLASSIFICATION',
      color: 'Natural Texture',
      mohsHardness: '3.0 – 6.0 (Field Test Required)',
      crystalSystem: 'Crystalline Aggregate',
      luster: 'Sub-Vitreous to Earthy',
      streak: 'Pale Gray',
      cleavage: 'Conchoidal / Indistinct',
      specificGravity: '2.6 – 3.8',
      rawOreEstimate: 'Market Index Tracked',
      specimenEstimate: 'Assay Required',
      africanRegions: ['Pan-African Orogenic Belt'],
      rarityTier: 'Geological Specimen',
      economicValue: 'Industrial & Specimen Value',
      toxicity: 'Standard geological handling advised',
      description: '$formattedName specimen classified by on-device geological CNN model.',
      identificationTips: 'Perform streak plate and acid scratch field test for physical verification.',
    );
  }

  Map<String, String> toPropertiesMap() {
    return {
      'MOHS HARDNESS': mohsHardness,
      'LUSTER': luster,
      'STREAK': streak,
      'CRYSTAL SYSTEM': crystalSystem,
      'CLEAVAGE': cleavage,
      'SPECIFIC GRAVITY': specificGravity,
    };
  }
}
