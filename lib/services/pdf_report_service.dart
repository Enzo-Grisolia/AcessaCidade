import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/demo_data.dart';
import '../models/incident.dart';
import 'priority_service.dart';

/// PDF exemplificativo do painel; não constitui relatório validado.
class PdfReportService {
  static Future<void> export(List<Incident> incidents) async {
    final ranked = PriorityService.ranked(incidents, DemoData.places);
    final pdf = pw.Document();
    final date = DateTime.now();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        pw.Text('ACESSACIDADE', style: pw.TextStyle(
          fontSize: 23, fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#007F80'))),
        pw.SizedBox(height: 9),
        pw.Text('RELATORIO DEMONSTRATIVO - GESTAO URBANA',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.Text('Bairro: ${DemoData.district}'),
        pw.Text('Gerado em: ${date.day}/${date.month}/${date.year}'),
        pw.SizedBox(height: 11),
        pw.Container(padding: const pw.EdgeInsets.all(9),
          color: PdfColor.fromHex('#FFF3DF'),
          child: pw.Text('ATENCAO: os relatos e locais desta versao '
              'sao ficticios e nao foram validados em campo.')),
        pw.SizedBox(height: 16),
        pw.Text('Resumo', style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Text('Total de relatos: ${incidents.length}'),
        pw.Text('Ativos: ${incidents.where((i) => i.status != IncidentStatus.resolved).length}'),
        pw.Text('Resolvidos: ${incidents.where((i) => i.status == IncidentStatus.resolved).length}'),
        pw.SizedBox(height: 20),
        pw.Text('Ranking de intervencoes', style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headers: ['#', 'Barreira / categoria', 'Confirm.', 'Pontos'],
          data: [
            for (int index = 0; index < ranked.length; index++)
              [
                '${index + 1}',
                '${ranked[index].title}\n${ranked[index].category}',
                '${ranked[index].existsVotes}',
                PriorityService.score(ranked[index], DemoData.places).toStringAsFixed(2),
              ],
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Text('Formula demonstrativa: P = S x (1 + ln(1 + C)) x (1 + E) x R'),
        pw.Text('S: severidade; C: confirmacoes; E: proximidade de equipamentos; '
            'R: recencia. Pesos sao hipoteses do grupo.'),
        pw.SizedBox(height: 9),
        pw.Text('Fonte: dados criados para o prototipo da GS FIAP 2026.2.'),
      ],
    ));
    await Printing.layoutPdf(
      name: 'AcessaCidade_Relatorio_Demo',
      onLayout: (_) => pdf.save(),
    );
  }
}
