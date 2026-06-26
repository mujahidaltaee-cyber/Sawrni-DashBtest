import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SawrniScaffold extends StatelessWidget {
  const SawrniScaffold({super.key, required this.child, this.title, this.actions});

  final Widget child;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: title == null
            ? null
            : AppBar(
                title: Text(title!, style: const TextStyle(fontWeight: FontWeight.w900)),
                actions: actions,
              ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF7F8FC), Color(0xFFEFF3F9)],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SawrniHero extends StatelessWidget {
  const SawrniHero({super.key, required this.title, required this.subtitle, this.badge});

  final String title;
  final String subtitle;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: SawrniTheme.navy,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null)
            Text(badge!, style: const TextStyle(color: SawrniTheme.gold, fontWeight: FontWeight.w900, letterSpacing: .4)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 34, height: 1.1)),
          const SizedBox(height: 14),
          Text(subtitle, style: const TextStyle(color: Color(0xFFD6DEEA), fontWeight: FontWeight.w600, fontSize: 15, height: 1.7)),
        ],
      ),
    );
  }
}

class SawrniCard extends StatelessWidget {
  const SawrniCard({super.key, required this.child, this.padding = const EdgeInsets.all(22)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}
