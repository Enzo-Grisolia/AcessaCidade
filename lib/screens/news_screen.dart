import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/demo_data.dart';
import '../models/news_article.dart';
import '../widgets/ui_parts.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = DemoData.seedNews();
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 790;
      final width = constraints.maxWidth;
      final cols = width >= 1100 ? 3 : width >= 650 ? 2 : 1;
      return ListView(
        padding: EdgeInsets.fromLTRB(desktop ? 32 : 16, 27, desktop ? 32 : 16, 32),
        children: [
          const PageHeading(
            eyebrow: 'Informação e comunidade',
            title: 'O bairro em pauta',
            subtitle: 'Notícias, iniciativas e orientações sobre espaços urbanos inclusivos.',
          ),
          const SizedBox(height: 18),
          const DemoNotice(compact: true),
          const SizedBox(height: 18),
          if (articles.isNotEmpty) _FeaturedNews(article: articles.first),
          const SizedBox(height: 18),
          if (articles.length > 1)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 262,
              ),
              itemCount: articles.length - 1,
              itemBuilder: (_, index) => _NewsCard(article: articles[index + 1], index: index),
            ),
        ],
      );
    });
  }
}

String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

class _FeaturedNews extends StatelessWidget {
  const _FeaturedNews({required this.article});
  final NewsArticle article;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF087E83), Color(0xFF2CA69B)]),
      borderRadius: BorderRadius.circular(22),
    ),
    child: LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 530;
      final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('DESTAQUE DA SEMANA', style: TextStyle(
          color: Colors.white, fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(article.title, style: TextStyle(color: Colors.white,
          fontSize: wide ? 26 : 21, height: 1.13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(article.summary, style: const TextStyle(color: Color(0xFFE2FFFC), height: 1.45)),
        const SizedBox(height: 14),
        Wrap(spacing: 7, runSpacing: 7, children: [
          _Tag(article.category.toUpperCase()), _Tag(_date(article.date)),
          const _Tag('Conteúdo demonstrativo'),
        ]),
      ]);
      final art = Container(height: 155,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18)),
        child: const Center(child: Icon(Icons.accessible_forward_rounded,
          size: 82, color: Colors.white)));
      if (!wide) return Column(children: [text, const SizedBox(height: 18), art]);
      return Row(children: [Expanded(flex: 3, child: text),
        const SizedBox(width: 24), Expanded(flex: 2, child: art)]);
    }),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.17),
      borderRadius: BorderRadius.circular(24)),
    child: Text(label, style: const TextStyle(color: Colors.white,
      fontSize: 10, fontWeight: FontWeight.w800)));
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article, required this.index});
  final NewsArticle article;
  final int index;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(15),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 85, width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(13),
          gradient: LinearGradient(colors: index.isEven
            ? const [Color(0xFFE8F6F3), Color(0xFFB8E7DD)]
            : const [Color(0xFFE9F3F1), Color(0xFFD8EFE8)])),
        child: Icon(index.isEven ? Icons.accessibility_new_rounded : Icons.groups_outlined,
          size: 45, color: AppColors.sea)),
      const SizedBox(height: 13),
      Row(children: [
        Expanded(child: Text(article.category.toUpperCase(),
          style: const TextStyle(color: AppColors.sea, fontSize: 10,
            fontWeight: FontWeight.w900, letterSpacing: 0.8))),
        Text(_date(article.date), style: const TextStyle(fontSize: 10,
          color: Color(0xFF647782))),
      ]),
      const SizedBox(height: 7),
      Text(article.title, style: const TextStyle(fontWeight: FontWeight.w900,
        fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      Expanded(child: Text(article.summary, maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF647782), height: 1.35, fontSize: 12))),
      const Text('Exemplo · não é notícia oficial', style: TextStyle(
        color: AppColors.amber, fontSize: 10)),
    ]),
  ));
}
