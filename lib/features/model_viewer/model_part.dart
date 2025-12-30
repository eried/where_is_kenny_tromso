/// Represents a 3D model part with metadata
class ModelPart {
  final String id;
  final String name;
  final String filename;
  final String? description;
  final int order; // Order in the exploded view
  final Map<String, dynamic>? metadata;

  ModelPart({
    required this.id,
    required this.name,
    required this.filename,
    this.description,
    required this.order,
    this.metadata,
  });

  factory ModelPart.fromJson(Map<String, dynamic> json) {
    return ModelPart(
      id: json['id'] as String,
      name: json['name'] as String,
      filename: json['filename'] as String,
      description: json['description'] as String?,
      order: json['order'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filename': filename,
      'description': description,
      'order': order,
      'metadata': metadata,
    };
  }
}

/// Represents the complete 3D model configuration
class Model3DConfig {
  final String mainModel;
  final String name;
  final List<ModelPart> parts;

  Model3DConfig({
    required this.mainModel,
    required this.name,
    required this.parts,
  });

  factory Model3DConfig.fromJson(Map<String, dynamic> json) {
    return Model3DConfig(
      mainModel: json['mainModel'] as String,
      name: json['name'] as String,
      parts: (json['parts'] as List)
          .map((p) => ModelPart.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  static Model3DConfig placeholder() {
    return Model3DConfig(
      mainModel: 'placeholder.glb',
      name: 'Placeholder Model',
      parts: [
        ModelPart(
          id: 'part_top',
          name: 'Top Section',
          filename: 'placeholder.glb',
          description: 'The upper half of the cube',
          order: 0,
        ),
        ModelPart(
          id: 'part_bottom',
          name: 'Bottom Section',
          filename: 'placeholder.glb',
          description: 'The lower half of the cube',
          order: 1,
        ),
      ],
    );
  }
}
