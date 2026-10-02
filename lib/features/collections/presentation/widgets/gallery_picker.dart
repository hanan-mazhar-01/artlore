import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../domain/collection_models.dart';

/// Ruled list of galleries with a gold check, plus "+ New gallery".
class GalleryPicker extends StatefulWidget {
  const GalleryPicker({
    super.key,
    required this.galleries,
    required this.counts,
    required this.selectedId,
    required this.onSelected,
    required this.onCreate,
  });

  final List<Gallery> galleries;
  final Map<String, int> counts;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onCreate;

  @override
  State<GalleryPicker> createState() => _GalleryPickerState();
}

class _GalleryPickerState extends State<GalleryPicker> {
  bool _naming = false;
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final name = value.trim();
    setState(() => _naming = false);
    _name.clear();
    if (name.isNotEmpty) widget.onCreate(name);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rule = BoxDecoration(
      border: Border(top: BorderSide(color: p.line(.1))),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final g in widget.galleries)
          Tappable(
            onTap: () => widget.onSelected(g.id),
            semanticLabel: g.name,
            pressedScale: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: rule,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name, style: AppTypography.sans(15)),
                        const SizedBox(height: 2),
                        Text(
                          _works(widget.counts[g.id] ?? 0),
                          style: AppTypography.metadata.copyWith(
                            color: p.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Check(on: g.id == widget.selectedId),
                ],
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: rule,
          child: _naming
              ? TextField(
                  controller: _name,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: AppTypography.sans(14),
                  cursorColor: p.accent,
                  onSubmitted: _submit,
                  onTapOutside: (_) => _submit(_name.text),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Name your gallery',
                    hintStyle: AppTypography.sans(14).copyWith(color: p.muted),
                  ),
                )
              : Tappable(
                  onTap: () => setState(() => _naming = true),
                  semanticLabel: 'New gallery',
                  child: Text(
                    '+ New gallery',
                    style: AppTypography.sans(14).copyWith(color: p.accent),
                  ),
                ),
        ),
      ],
    );
  }

  static String _works(int n) => n == 1 ? '1 work' : '$n works';
}

class _Check extends StatelessWidget {
  const _Check({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? p.accent : Colors.transparent,
        border: Border.all(color: on ? p.accent : p.line(.3)),
      ),
      child: on
          ? Center(
              child: ArtIcon(
                ArtIcons.check,
                size: 12,
                color: p.onAccent,
                strokeWidth: 2.4,
              ),
            )
          : null,
    );
  }
}
