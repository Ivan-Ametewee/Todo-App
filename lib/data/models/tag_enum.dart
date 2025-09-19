enum Tag {
  business('Business'),
  work('Work'),
  school('School'),
  personal('Personal'),
  other('Other');

  const Tag(this.displayName);
  
  final String displayName;

  static Tag fromString(String value) {
    return Tag.values.firstWhere(
      (tag) => tag.name == value.toLowerCase(),
      orElse: () => Tag.other,
    );
  }

  @override
  String toString() => displayName;
}