class Scripture {
  int? id;
  String reference;
  String text;
  String translation;
  String listName;

  Scripture({
    this.id,
    required this.reference,
    required this.text,
    required this.translation,
    this.listName = "My List",
  });

  // Convert to JSON for Sembast
  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'text': text,
        'translation': translation,
        'listName': listName,
      };

  // Create from JSON
  factory Scripture.fromJson(Map<String, dynamic> json) => Scripture(
        id: json['id'] as int?,
        reference: json['reference'] as String,
        text: json['text'] as String,
        translation: json['translation'] as String,
        listName: json['listName'] as String? ?? "My List",
      );
}
