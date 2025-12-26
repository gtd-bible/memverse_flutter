class Scripture {
  Scripture({
    this.id,
    required this.reference,
    required this.text,
    required this.translation,
    this.listName = "My List",
  });

  // Simulating an ID for now
  int? id;
  String reference;
  String text;
  String translation;
  String listName;
}
