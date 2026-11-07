# Fluxo de telas e roteiro de demonstração — AcessaCidade

## Fluxo de navegação

Splash → [Onboarding: 3 páginas / opção "Não mostrar novamente"] → Home

Home possui cinco áreas (NavigationBar):

1. **Mapa** — mapa real OSM com pontos e incidentes fictícios, filtros por perfil/categoria, botão "Ver lista". Os marcadores levam à ficha do local ou ao detalhe do relato.
2. **Locais** — pesquisa e filtro por tipo, ficha de acessibilidade (sim/não/não sei), resumo por perfil e relatos num raio de 150m.
3. **Relatar** — categoria, descrição, perfis afetados, toque no mapa para coordenada, geocodificação REST, endereço manual, foto opcional com texto alternativo e publicação local.
4. **Notícias** — blog de leitura com dados de demonstração.
5. **Gestor** — indicadores, ranking de prioridade com explicação e exportação PDF.

Ícone de **perfil** na barra superior: nome de demonstração e preferências de mobilidade opcionais. Necessário para votar/publicar (não equivale a autenticação segura).

## Passo a passo para uma apresentação de 3 a 5 minutos

1. Abra com o mapa real e marque a distinção entre **ruas reais** e **relatos fictícios**. Mostre 2 marcadores.
2. Toque em **Ver lista**. Demonstre a experiência alternativa ao mapa, incluindo endereço e distância da referência.
3. Ajuste o perfil para **Deficiência visual** e abra a ficha de uma parada/UBS; mostre itens do checklist que não atendem.
4. Abra um relato confirmado e clique **Ainda existe**. O protótipo exigirá configurar um nome local.
5. Na aba **Relatar**, toque no mapa e em **Consultar endereço (API REST)**. Mostre carregamento/sucesso (ou erro + tentativa novamente e endereço manual), escolha uma categoria e publique.
6. Abra **Gestor**, explique o cálculo e exporte o relatório PDF.
7. Termine citando o que é necessário para produção: autenticação, fotos em storage, banco/API, validação em campo, acessibilidade com usuários reais e eventual classificação por IA.

## Como validar estados obrigatórios de API

- **Inicial:** logo ao abrir a tela Relatar, antes de consultar.
- **Carregando:** entre o toque no botão e a resposta.
- **Sucesso:** endereço preenchido usando JSON recebido da API Nominatim.
- **Erro:** com conexão indisponível, aguarde a resposta e veja mensagem; botão passa a "Tentar consulta novamente".
- **Fallback:** endereço continua editável manualmente.

## Acessibilidade

Há rótulos semânticos nos marcadores e cartões e uma **lista equivalente** no Mapa. Testar com TalkBack/VoiceOver/NVDA antes da entrega. Este protótipo NÃO foi auditado em conformidade WCAG 2.2 AA nem testado com usuários PcD; é obrigatório fazer esses testes.
