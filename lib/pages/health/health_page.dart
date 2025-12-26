import 'package:flutter/material.dart';
import '../../service/health_supabase_service.dart';
import 'medical_history_page.dart';
import 'vaccine_history_page.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final _svc = HealthSupabaseService();

  late Future<_Counts> _countsFuture;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    _countsFuture = _fetchCounts();
  }

  Future<_Counts> _fetchCounts() async {
    final medical = await _svc.countMedicalEntries();
    final vaccine = await _svc.countVaccineEntries();
    return _Counts(medical: medical, vaccine: vaccine);
  }

  Future<void> _openMedical() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicalHistoryPage()),
    );
    setState(_loadCounts); // refresh counts when coming back
  }

  Future<void> _openVaccine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VaccineHistoryPage()),
    );
    setState(_loadCounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2430),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8B6D6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Health",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<_Counts>(
          future: _countsFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Center(
                child: Text(
                  "Failed to load data\n${snap.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            final data = snap.data!;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SectionCard(
                    title: "Medical",
                    titleBg: const Color(0xFF7FB069),
                    bodyLeftText: "${data.medical} records stored",
                    rightTextButton: "View",
                    onRightTextTap: _openMedical,
                    onPlusTap: _openMedical,
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: "Vaccine",
                    titleBg: const Color(0xFFB8B6D6),
                    bodyLeftText: "${data.vaccine} records stored",
                    rightTextButton: "View",
                    onRightTextTap: _openVaccine,
                    onPlusTap: _openVaccine,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Counts {
  final int medical;
  final int vaccine;
  _Counts({required this.medical, required this.vaccine});
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color titleBg;
  final String bodyLeftText;
  final String rightTextButton;
  final VoidCallback onRightTextTap;
  final VoidCallback onPlusTap;

  const _SectionCard({
    required this.title,
    required this.titleBg,
    required this.bodyLeftText,
    required this.rightTextButton,
    required this.onRightTextTap,
    required this.onPlusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F3D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: titleBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF101317),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
                InkWell(
                  onTap: onPlusTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E8B57),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    bodyLeftText,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                InkWell(
                  onTap: onRightTextTap,
                  child: Text(
                    rightTextButton,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
