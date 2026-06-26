import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController(text: 'Baghdad');
  String _type = 'photographer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملف مزود الخدمة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text('استوديو كامل بجيبك', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('هذه البيانات ستذهب للمراجعة ولا تظهر للعميل قبل الموافقة.', style: TextStyle(color: SawrniBrand.muted)),
            const SizedBox(height: 20),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'اسم الحساب / الاستوديو')),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'نوع الخدمة'),
              items: const [
                DropdownMenuItem(value: 'photographer', child: Text('مصور')),
                DropdownMenuItem(value: 'editor', child: Text('محرر صور')),
                DropdownMenuItem(value: 'model', child: Text('مودل')),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 14),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'المدينة')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('حفظ وإرسال للمراجعة')),
          ],
        ),
      ),
    );
  }
}
