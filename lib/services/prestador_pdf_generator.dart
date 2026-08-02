import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/prestador.dart';

/// Builds a printable PDF listing the given [prestadores], with the search
/// filters used shown at the top for context.
Future<Uint8List> gerarPdfPrestadores({
  required List<Prestador> prestadores,
  required PrestadorFiltro filtro,
}) async {
  final doc = pw.Document();
  final geradoEm = DateTime.now();
  final dataFormatada =
      '${geradoEm.day.toString().padLeft(2, '0')}/'
      '${geradoEm.month.toString().padLeft(2, '0')}/'
      '${geradoEm.year} '
      '${geradoEm.hour.toString().padLeft(2, '0')}:'
      '${geradoEm.minute.toString().padLeft(2, '0')}';

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text(
          'Rede Credenciada — Uniodonto Porto Alegre',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Gerado em $dataFormatada',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        if (filtro.resumo.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(
            'Filtros: ${filtro.resumo.join(' · ')}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
        pw.SizedBox(height: 16),
        pw.Text(
          '${prestadores.length} prestador(es) encontrado(s)',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        ...prestadores.map(
          (p) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  p.nome,
                  style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                ),
                if (p.cro.isNotEmpty)
                  pw.Text('CRO: ${p.cro}', style: const pw.TextStyle(fontSize: 9)),
                if (p.endereco.isNotEmpty)
                  pw.Text(p.endereco, style: const pw.TextStyle(fontSize: 9)),
                if (p.localizacao.isNotEmpty)
                  pw.Text(p.localizacao, style: const pw.TextStyle(fontSize: 9)),
                if (p.telefones.isNotEmpty)
                  pw.Text(p.telefones, style: const pw.TextStyle(fontSize: 9)),
                if (p.areasAtuacao.isNotEmpty)
                  pw.Text(
                    'Áreas de atuação: ${p.areasAtuacao}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  return doc.save();
}
