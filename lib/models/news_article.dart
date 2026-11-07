class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.summary,
    required this.date,
    required this.category,
    required this.iconCode,
  });

  final String title;
  final String summary;
  final DateTime date;
  final String category;
  final int iconCode;
}
