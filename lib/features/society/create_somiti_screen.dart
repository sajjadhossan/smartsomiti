import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/somiti_model.dart';
import '../../services/somiti_service.dart';
import '../dashboard/somiti_main_dashboard.dart';

class CreateSomitiScreen extends StatefulWidget {
  final User user;
  const CreateSomitiScreen({super.key, required this.user});

  @override
  State<CreateSomitiScreen> createState() => _CreateSomitiScreenState();
}

class _CreateSomitiScreenState extends State<CreateSomitiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _padHeaderCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _bkashCtrl = TextEditingController();
  final _presidentCtrl = TextEditingController();
  final _secretaryCtrl = TextEditingController();
  final _cashierCtrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final somiti = await SomitiService().createSomiti(
        name: _nameCtrl.text.trim(),
        padHeader: _padHeaderCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        bankAccount: _bankCtrl.text.trim(),
        bkashNumber: _bkashCtrl.text.trim(),
        presidentName: _presidentCtrl.text.trim(),
        secretaryName: _secretaryCtrl.text.trim(),
        cashierName: _cashierCtrl.text.trim(),
        creatorId: widget.user.uid,
        creatorEmail: widget.user.email ?? '',
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SomitiMainDashboard(somiti: somiti, user: widget.user),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন সমিতি সেটআপ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('সমিতির মূল পরিচিতি ও অফিসিয়াল প্যাড', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'সমিতির নাম *',
                  hintText: 'যেমন: প্রগতি ক্ষুদ্র সঞ্চয় সমবায় সমিতি',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'সমিতির নাম আবশ্যক' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _padHeaderCtrl,
                decoration: const InputDecoration(
                  labelText: 'অফিসিয়াল প্যাডের স্লোগান / হেডার',
                  hintText: 'যেমন: সঞ্চয়ে সমৃদ্ধি, একতায় শক্তি',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'কার্যালয়ের পূর্ণ ঠিকানা',
                  hintText: 'যেমন: মিরপুর-১০, ঢাকা',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const Text('আর্থিক একাউন্ট তথ্য', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankCtrl,
                decoration: const InputDecoration(
                  labelText: 'ব্যাংক হিসাব নম্বর ও ব্যাংকের নাম',
                  hintText: 'যেমন: সোনালী ব্যাংক - ১২৩৪৫৬৭৮',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bkashCtrl,
                decoration: const InputDecoration(
                  labelText: 'বিকাশ / নগদ নম্বর',
                  hintText: 'যেমন: ০১৭১২-৩৪৫৬৭৮ (পার্সোনাল)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android_rounded),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text('কমিটির প্রধান দায়িত্বশীলগণ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _presidentCtrl,
                decoration: const InputDecoration(
                  labelText: 'সভাপতির নাম',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _secretaryCtrl,
                decoration: const InputDecoration(
                  labelText: 'সাধারণ সম্পাদকের নাম',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cashierCtrl,
                decoration: InputDecoration(
                  labelText: 'কোষাধ্যক্ষের নাম',
                  hintText: widget.user.displayName ?? 'সাজ্জাদ হোসেন (আপনি)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.price_check_rounded),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('সমিতি সম্পন্ন ও চালু করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
