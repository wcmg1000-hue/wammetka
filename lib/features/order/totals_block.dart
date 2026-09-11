import 'package:flutter/material.dart';

import 'money.dart';

class TotalsBlock extends StatelessWidget {
  const TotalsBlock({
    super.key,
    required this.subtotalCentavos,
    required this.domicilioCentavos,
    required this.totalCentavos,
  });

  final int subtotalCentavos;
  final int domicilioCentavos;
  final int totalCentavos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RowMoney(label: 'Subtotal productos', value: subtotalCentavos),
        _RowMoney(label: 'Domicilio', value: domicilioCentavos),
        _RowMoney(label: 'Total a pagar', value: totalCentavos, bold: true),
      ],
    );
  }
}

class _RowMoney extends StatelessWidget {
  const _RowMoney({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final int value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          Text(
            formatCopFromCentavos(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ],
      ),
    );
  }
}
