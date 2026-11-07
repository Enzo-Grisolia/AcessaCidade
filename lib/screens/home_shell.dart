import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/profile_sheet.dart';
import 'manager_screen.dart';
import 'map_screen.dart';
import 'news_screen.dart';
import 'places_screen.dart';
import 'report_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});
  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const titles = [
    'Mapa colaborativo', 'Locais públicos', 'Novo relato',
    'Notícias do bairro', 'Painel do gestor',
  ];
  static const navLabels = ['Mapa', 'Locais', 'Relatar', 'Notícias', 'Gestor'];
  static const navIcons = [
    Icons.map_outlined, Icons.location_city_outlined,
    Icons.add_circle_outline, Icons.article_outlined, Icons.bar_chart_outlined,
  ];
  static const selectedIcons = [
    Icons.map, Icons.location_city, Icons.add_circle,
    Icons.article, Icons.bar_chart,
  ];

  Widget _sideNav() => Container(
    width: 246,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: AppColors.outline)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 12, 25),
        child: Row(children: [
          Image.asset('assets/images/acessacidade_logo.png', width: 45, height: 45),
          const SizedBox(width: 11),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AcessaCidade', style: TextStyle(
                color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 18,
                letterSpacing: -0.7)),
              SizedBox(height: 2),
              Text('MAPA COLABORATIVO', style: TextStyle(
                color: AppColors.sea, fontSize: 9, letterSpacing: 1,
                fontWeight: FontWeight.w800)),
            ],
          )),
        ]),
      ),
      const Divider(color: AppColors.outline, height: 1, indent: 18, endIndent: 18),
      const Padding(
        padding: EdgeInsets.fromLTRB(27, 25, 0, 12),
        child: Text('EXPLORAR', style: TextStyle(
          color: Color(0xFF728890), letterSpacing: 1.6,
          fontWeight: FontWeight.w900, fontSize: 10)),
      ),
      for (var i = 0; i < titles.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Material(
            color: i == _index ? AppColors.seaLight : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => setState(() => _index = i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(children: [
                  Icon(i == _index ? selectedIcons[i] : navIcons[i],
                    color: i == _index ? AppColors.sea : const Color(0xFF627883), size: 23),
                  const SizedBox(width: 14),
                  Text(navLabels[i], style: TextStyle(
                    color: i == _index ? AppColors.sea : const Color(0xFF536D79),
                    fontSize: 14, fontWeight: i == _index ? FontWeight.w900 : FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      const Spacer(),
      Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 15),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppColors.background,
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(12)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('●  Prévia da Global Solution', style: TextStyle(
            color: AppColors.sea, fontWeight: FontWeight.w800, fontSize: 11)),
          SizedBox(height: 5),
          Text('Dados fictícios • Bela Vista, SP',
            style: TextStyle(color: Color(0xFF637B85), fontSize: 10)),
        ]),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final screens = [
      MapScreen(state: widget.state),
      PlacesScreen(state: widget.state),
      ReportScreen(state: widget.state),
      const NewsScreen(),
      ManagerScreen(state: widget.state),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 1000;
      final content = Scaffold(
        appBar: AppBar(
          toolbarHeight: desktop ? 70 : 62,
          titleSpacing: 21,
          title: desktop
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ACESSACIDADE / GLOBAL SOLUTION 2026.2',
                  style: TextStyle(color: AppColors.sea, fontSize: 10,
                    letterSpacing: 1.4, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(titles[_index], style: const TextStyle(
                  fontSize: 21, fontWeight: FontWeight.w900)),
              ])
            : Row(children: [
                Image.asset('assets/images/acessacidade_logo.png', width: 34, height: 34),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ACESSACIDADE', style: TextStyle(color: AppColors.sea,
                    fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
                  Text(titles[_index], style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
                ])),
              ]),
          actions: [
            IconButton(
              tooltip: 'Editar perfil de mobilidade',
              onPressed: () => showProfileSheet(context, widget.state),
              icon: const Icon(Icons.account_circle_outlined, size: 26),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(child: screens[_index]),
        bottomNavigationBar: desktop ? null : NavigationBar(
          height: 72,
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: [for (var i = 0; i < navLabels.length; i++)
            NavigationDestination(icon: Icon(navIcons[i]),
              selectedIcon: Icon(selectedIcons[i]), label: navLabels[i]),
          ],
        ),
      );
      if (!desktop) return content;
      return Scaffold(body: Row(children: [
        _sideNav(),
        Expanded(child: content),
      ]));
    });
  }
}
