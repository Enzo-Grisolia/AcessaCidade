# Correspondência com os critérios da avaliação Flutter

| Critério do PDF do professor | Onde está implementado no protótipo | Situação |
| --- | --- | --- |
| Splash e logo / transição automática / SharedPreferences | `screens/splash_screen.dart`; `services/local_store.dart` | Feito em código |
| Onboarding de 3 páginas + avançar/voltar + não mostrar novamente | `screens/onboarding_screen.dart` | Feito em código |
| Pelo menos 4 telas principais, passagem de parâmetros e retorno | `screens/home_shell.dart`, 5 abas; rotas para detalhes | Feito em código |
| WebService REST com `http`, JSON→model e 4 estados | `services/geocoding_service.dart`, `models/geocoded_address.dart`, `screens/report_screen.dart` | Feito em código; depende de internet |
| Widgets Column, Row, Card, ListView, Scaffold, AppBar, buttons, Icon, Image | Vários arquivos de tela; logo via `Image.asset` na Splash, foto via `Image.memory` no relato | Feito em código |
| 3 interações, uma lista→detalhe | Filtro, lista→detalhes, voto, registro, seleção mapa | Feito em código |
| Stateful/Stateless e setState, separação de camadas | `models`, `services`, `widgets`, `screens`; `setState` e `ChangeNotifier` | Feito em código |
| ZIP, GitHub, README, screenshots, vídeo pitch | README e ZIP presentes | GitHub, screenshots e vídeo pendentes |

**Observação:** o enunciado exige `Image.asset` ou `Image.network`; o logo da Splash usa `Image.asset`.

**Muito importante:** nenhum teste de build foi executado no ambiente de geração. Rodar `flutter pub get`, `flutter analyze`, `flutter test` e `flutter run -d chrome` localmente antes de considerar a implementação pronta.
