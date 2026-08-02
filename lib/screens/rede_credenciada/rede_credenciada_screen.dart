import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../../data/cities_by_state.dart';
import '../../data/neighborhoods_by_city.dart';
import '../../data/state_capitals.dart';
import '../../models/prestador.dart';
import '../../services/prestador_pdf_generator.dart';
import '../../services/rede_credenciada_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

const _estados = <String, String>{
  'AC': 'Acre',
  'AL': 'Alagoas',
  'AP': 'Amapá',
  'AM': 'Amazonas',
  'BA': 'Bahia',
  'CE': 'Ceará',
  'DF': 'Distrito Federal',
  'ES': 'Espírito Santo',
  'GO': 'Goiás',
  'MA': 'Maranhão',
  'MT': 'Mato Grosso',
  'MS': 'Mato Grosso do Sul',
  'MG': 'Minas Gerais',
  'PA': 'Pará',
  'PB': 'Paraíba',
  'PR': 'Paraná',
  'PE': 'Pernambuco',
  'PI': 'Piauí',
  'RJ': 'Rio de Janeiro',
  'RN': 'Rio Grande do Norte',
  'RS': 'Rio Grande do Sul',
  'RO': 'Rondônia',
  'RR': 'Roraima',
  'SC': 'Santa Catarina',
  'SP': 'São Paulo',
  'SE': 'Sergipe',
  'TO': 'Tocantins',
};

/// Lets the beneficiário search the Uniodonto Porto Alegre accredited
/// network (dentistas/clínicas) by estado, cidade, bairro, área de atuação,
/// CRO or nome, and export the results as a PDF.
class RedeCredenciadaScreen extends StatefulWidget {
  const RedeCredenciadaScreen({super.key});

  @override
  State<RedeCredenciadaScreen> createState() => _RedeCredenciadaScreenState();
}

class _RedeCredenciadaScreenState extends State<RedeCredenciadaScreen> {
  final _bairroController = TextEditingController();
  final _areaController = TextEditingController();
  final _croController = TextEditingController();
  final _nomeController = TextEditingController();

  String? _estado;
  String? _cidade;
  String? _bairro;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _isGeneratingPdf = false;
  bool _searched = false;
  String? _errorMessage;

  List<Prestador> _resultados = const [];
  int _page = 1;
  int _totalPages = 1;

  bool get _temMaisPaginas => _page < _totalPages;

  /// Cities available for [_estado], with the state capital pinned first
  /// and the rest alphabetical.
  List<String> get _cidadesDisponiveis {
    if (_estado == null) return const [];
    final cidades = List<String>.of(citiesByState[_estado] ?? const []);
    final capital = stateCapitals[_estado];
    if (capital != null && cidades.remove(capital)) {
      cidades.sort();
      return [capital, ...cidades];
    }
    cidades.sort();
    return cidades;
  }

  /// Bairros on record for [_estado]/[_cidade], alphabetical. Empty when
  /// there's no bairro data for that city — the field then falls back to
  /// free text.
  List<String> get _bairrosDisponiveis {
    if (_estado == null || _cidade == null) return const [];
    final bairros =
        List<String>.of(neighborhoodsByCity[_estado]?[_cidade] ?? const []);
    bairros.sort();
    return bairros;
  }

  @override
  void dispose() {
    _bairroController.dispose();
    _areaController.dispose();
    _croController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  PrestadorFiltro get _filtroAtual => PrestadorFiltro(
        estado: _estado,
        cidade: _cidade,
        bairro: _cidade == null
            ? null
            : (_bairrosDisponiveis.isNotEmpty
                ? _bairro
                : _bairroController.text),
        areaAtuacao: _areaController.text,
        cro: _croController.text,
        nome: _nomeController.text,
      );

  void _onEstadoChanged(String? value) {
    setState(() {
      _estado = value;
      _cidade = null;
      _bairro = null;
      _bairroController.clear();
    });
  }

  void _onCidadeChanged(String? value) {
    setState(() {
      _cidade = value;
      _bairro = null;
      _bairroController.clear();
    });
  }

  void _onBairroChanged(String? value) {
    setState(() => _bairro = value);
  }

  Future<void> _buscar() async {
    FocusScope.of(context).unfocus();
    final filtro = _filtroAtual;
    if (filtro.isEmpty) {
      setState(
        () => _errorMessage = 'Informe ao menos um filtro para buscar.',
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searched = true;
    });

    try {
      final pagina = await RedeCredenciadaService.instance.buscar(filtro);
      if (!mounted) return;
      setState(() {
        _resultados = pagina.prestadores;
        _page = pagina.page;
        _totalPages = pagina.totalPages;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _resultados = const [];
        _errorMessage =
            'Não foi possível buscar a rede credenciada agora. Verifique '
            'sua conexão e tente novamente.';
      });
    }
  }

  Future<void> _carregarMais() async {
    if (_isLoadingMore || !_temMaisPaginas) return;
    setState(() => _isLoadingMore = true);

    try {
      final pagina = await RedeCredenciadaService.instance.buscar(
        _filtroAtual,
        page: _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _resultados = [..._resultados, ...pagina.prestadores];
        _page = pagina.page;
        _totalPages = pagina.totalPages;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar mais resultados.'),
        ),
      );
    }
  }

  Future<void> _baixarPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final bytes = await gerarPdfPrestadores(
        prestadores: _resultados,
        filtro: _filtroAtual,
      );
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'rede_credenciada.pdf',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível gerar o PDF agora.')),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rede Credenciada')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              'Encontre dentistas e clínicas parceiras',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Preencha um ou mais filtros abaixo.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: [
                const DropdownMenuItem<String>(child: Text('Todos')),
                ..._estados.entries.map(
                  (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  ),
                ),
              ],
              onChanged: _onEstadoChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('cidade-$_estado'),
              initialValue: _cidade,
              decoration: InputDecoration(
                labelText: 'Cidade',
                enabled: _estado != null,
                helperText: _estado == null
                    ? 'Selecione um estado primeiro'
                    : null,
              ),
              items: _cidadesDisponiveis
                  .map(
                    (cidade) => DropdownMenuItem<String>(
                      value: cidade,
                      child: Text(
                        cidade == stateCapitals[_estado]
                            ? '$cidade (Capital)'
                            : cidade,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _estado == null ? null : _onCidadeChanged,
            ),
            const SizedBox(height: 16),
            if (_bairrosDisponiveis.isNotEmpty)
              DropdownButtonFormField<String>(
                key: ValueKey('bairro-$_estado-$_cidade'),
                initialValue: _bairro,
                decoration: const InputDecoration(labelText: 'Bairro'),
                items: _bairrosDisponiveis
                    .map(
                      (bairro) => DropdownMenuItem<String>(
                        value: bairro,
                        child: Text(bairro),
                      ),
                    )
                    .toList(),
                onChanged: _onBairroChanged,
              )
            else
              AppTextField(
                label: 'Bairro',
                controller: _bairroController,
                enabled: _cidade != null,
                prefixIcon: Icons.map_outlined,
                textInputAction: TextInputAction.next,
              ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Área de atuação',
              hint: 'Ex.: Ortodontia',
              controller: _areaController,
              prefixIcon: Icons.medical_services_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'CRO',
              controller: _croController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.badge_outlined,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Nome',
              controller: _nomeController,
              prefixIcon: Icons.person_search_outlined,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Semantics(
                liveRegion: true,
                child: ErrorBanner(message: _errorMessage!),
              ),
              const SizedBox(height: 16),
            ],
            PrimaryButton(
              label: 'Buscar',
              icon: Icons.search,
              isLoading: _isSearching,
              onPressed: _buscar,
            ),
            if (_searched && !_isSearching) ...[
              const SizedBox(height: 28),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_resultados.length} resultado(s)',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (_resultados.isNotEmpty)
                    Flexible(
                      child: OutlinedButton.icon(
                        onPressed: _isGeneratingPdf ? null : _baixarPdf,
                        icon: _isGeneratingPdf
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Baixar PDF'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_resultados.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Nenhum prestador encontrado para esses filtros.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ..._resultados.map((p) => _PrestadorCard(prestador: p)),
              if (_temMaisPaginas) ...[
                const SizedBox(height: 8),
                Center(
                  child: _isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        )
                      : TextButton(
                          onPressed: _carregarMais,
                          child: const Text('Carregar mais resultados'),
                        ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PrestadorCard extends StatelessWidget {
  const _PrestadorCard({required this.prestador});

  final Prestador prestador;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prestador.nome,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (prestador.cro.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'CRO ${prestador.cro}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
            if (prestador.endereco.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(prestador.endereco, style: theme.textTheme.bodyMedium),
            ],
            if (prestador.localizacao.isNotEmpty)
              Text(prestador.localizacao, style: theme.textTheme.bodyMedium),
            if (prestador.telefones.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      prestador.telefones,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (prestador.areasAtuacao.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                prestador.areasAtuacao,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
