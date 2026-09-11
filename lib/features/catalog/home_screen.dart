import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/wammetka_colors.dart';
import '../../widgets/accent_card.dart';
import '../auth/auth_providers.dart';
import '../order/money.dart';
import 'catalog_models.dart';
import 'catalog_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();
  bool _soloAbiertos = true;
  bool _loading = true;
  String? _error;
  List<Comercio> _comercios = <Comercio>[];
  List<Municipio> _municipios = <Municipio>[];
  String? _municipioId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final muns = await repo.listMunicipiosHabilitados();
      final profile = ref.read(sessionProvider);
      var mid = profile?.municipioId;
      if (mid == null || !muns.any((m) => m.id == mid)) {
        mid = muns
            .where((m) => m.nombre == 'Fonseca')
            .map((m) => m.id)
            .firstOrNull;
        mid ??= muns.isEmpty ? null : muns.first.id;
      }
      final shops = mid == null
          ? <Comercio>[]
          : await repo.listComercios(municipioId: mid);
      if (!mounted) {
        return;
      }
      setState(() {
        _municipios = muns;
        _municipioId = mid;
        _comercios = shops;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickMunicipio() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text(
                  'Municipio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ..._municipios.map(
                (m) => ListTile(
                  title: Text(
                    m.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: m.id == _municipioId,
                  onTap: () => Navigator.of(ctx).pop(m.id),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == _municipioId) {
      return;
    }
    try {
      await ref.read(catalogRepositoryProvider).updateOwnMunicipio(selected);
      await ref.read(sessionProvider.notifier).restore();
      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(sessionProvider);
    final q = _search.text.trim().toLowerCase();
    final filtered = _comercios.where((c) {
      if (_soloAbiertos && !c.abierto) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      return c.nombre.toLowerCase().contains(q) ||
          c.zonaNombre.toLowerCase().contains(q);
    }).toList();
    final munName = _municipios
        .where((m) => m.id == _municipioId)
        .map((m) => m.nombre)
        .firstOrNull;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hola, ${profile?.nombre ?? ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                label: Text(
                  munName ?? 'Municipio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _municipios.isEmpty ? null : _pickMunicipio,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Buscar tienda o producto',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Abiertos ahora'),
                  selected: _soloAbiertos,
                  onSelected: (v) => setState(() => _soloAbiertos = v),
                ),
                FilterChip(
                  label: const Text('Todas'),
                  selected: !_soloAbiertos,
                  onSelected: (v) => setState(() => _soloAbiertos = !v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _ErrorBanner(message: _error!, onRetry: _load)
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Text(
                  'Aún no hay comercios en tu zona',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
              )
            else
              ...filtered.map(
                (shop) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AccentCard(
                    accent: shop.abierto
                        ? WammetkaColors.primary
                        : WammetkaColors.text.withValues(alpha: 0.35),
                    onTap: () => context.push('/comercio/${shop.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shop.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _Badge(
                              text: shop.abierto ? 'Abierto' : 'Cerrado',
                              ok: shop.abierto,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shop.zonaNombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '30–50 min · ${formatCopFromCentavos(shop.domicilioCentavos)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (ok ? WammetkaColors.success : WammetkaColors.text).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: ok ? WammetkaColors.success : WammetkaColors.text,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.cloud_off_outlined, size: 40),
        const SizedBox(height: 8),
        const Text(
          'Sin conexión',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
