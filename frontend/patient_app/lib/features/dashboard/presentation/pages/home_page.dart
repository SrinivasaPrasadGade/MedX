import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/theme/app_theme.dart';

import 'package:patient_app/core/services/medication_service.dart';
import 'package:patient_app/core/services/notification_service.dart';
import 'package:patient_app/core/services/clinical_service.dart';

import 'package:patient_app/features/dashboard/presentation/providers/medication_provider.dart';

// --- UI Components ---

class AppleGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppleGlassCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
             BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

// --- Main Page ---

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // ... (Keep existing state logic for banner and dialogs)
    bool _showBanner = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final msg = ref.read(welcomeMessageProvider);
      if (msg != null) {
        setState(() {
          _message = msg;
          _showBanner = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showBanner = false);
          ref.read(welcomeMessageProvider.notifier).state = null;
        });
      }
    });
  }

  void _showAddDialog() {
    // ... (Keep existing add dialog logic, maybe style it later if needed, but priority is main UI)
    // For brevity, I'll keep the logic implementation identical but wrap it to save space in this rewrite if allowed.
    // Actually, I should keep the full logic to ensure it works. 
    // I will copy the _showAddDialog logic from previous file but ensuring correct imports.
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final timeController = TextEditingController();
    final smartController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        bool isSmartMode = false;
        bool isAnalyzing = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("Add Medication", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                   IconButton(
                     onPressed: () => setState(() => isSmartMode = !isSmartMode),
                     icon: Icon(isSmartMode ? Icons.edit_note : Icons.auto_awesome, 
                        color: isSmartMode ? AppTheme.textSecondary : AppTheme.primary),
                     tooltip: isSmartMode ? "Switch to Manual" : "Switch to Smart Add",
                   )
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: isSmartMode 
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                         child: Row(children: [
                            const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(child: Text("Type naturally, e.g., 'Take Metformin 500mg at 8am'", style: TextStyle(color: AppTheme.primary, fontSize: 13)))
                         ]),
                       ),
                       const SizedBox(height: 16),
                       TextField(
                         controller: smartController, 
                         maxLines: 3, 
                         decoration: InputDecoration(
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
                           hintText: "Enter prescription details...",
                           filled: true,
                           fillColor: AppTheme.background,
                         )
                       ),
                       const SizedBox(height: 16),
                       SizedBox(
                         width: double.infinity,
                         child: ElevatedButton.icon(
                           onPressed: isAnalyzing ? null : () async {
                              setState(() => isAnalyzing = true);
                              final service = ref.read(clinicalServiceProvider);
                              final result = await service.extractMedication(smartController.text);
                              setState(() => isAnalyzing = false);
                              
                              if (result != null) {
                                if (result.name != null) nameController.text = result.name!;
                                if (result.dosage != null) dosageController.text = result.dosage!;
                                if (result.time != null) timeController.text = result.time!;
                                setState(() => isSmartMode = false);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not extract details")));
                              }
                           },
                           icon: isAnalyzing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.analytics),
                           label: const Text("Analyze & Fill"),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppTheme.textPrimary,
                             foregroundColor: Colors.white,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             padding: const EdgeInsets.symmetric(vertical: 16)
                           )
                         ),
                       )
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInput(nameController, "Medication Name"),
                      const SizedBox(height: 12),
                      _buildInput(dosageController, "Dosage (e.g., 10mg)"),
                      const SizedBox(height: 12),
                      _buildInput(timeController, "Time (e.g., 9:00 AM)"),
                    ],
                  ),
              ),
              actions: [
                if (!isSmartMode) ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: Text("Cancel", style: TextStyle(color: AppTheme.textSecondary))
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty) {
                        final navigator = Navigator.of(context);
                        final clinicalService = ref.read(clinicalServiceProvider);
                        final currentMeds = ref.read(medicationProvider);
                        final newMedName = nameController.text;
                        
                        final interaction = await clinicalService.checkInteractions(
                          newMedName, 
                          currentMeds.map((m) => m.name).toList()
                        );

                        if (interaction != null && interaction.warning != null) {
                           if (context.mounted) {
                               showDialog(
                                context: context, 
                                builder: (ctx) => AlertDialog(
                                  title: const Row(children: [Icon(Icons.warning, color: Colors.amber), SizedBox(width: 8), Text("Interaction Detected")]),
                                  content: Text("${interaction.warning}\n\nSeverity: ${interaction.severity}"),
                                  actions: [
                                    TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Cancel")),
                                    TextButton(onPressed: () { 
                                      Navigator.pop(ctx); 
                                      navigator.pop();
                                      ref.read(medicationProvider.notifier).addMedication(newMedName, dosageController.text, timeController.text);
                                    }, child: const Text("Proceed", style: TextStyle(color: Colors.red)))
                                  ]
                                )
                              );
                           }
                        } else {
                          ref.read(medicationProvider.notifier).addMedication(
                            newMedName, 
                            dosageController.text, 
                            timeController.text
                          );
                          navigator.pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: const StadiumBorder()),
                    child: const Text("Add"),
                  ),
                ]
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            );
          }
        );
      }
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());
    final medications = ref.watch(medicationProvider);
    final user = ref.watch(currentUserProvider);
    final name = user?['full_name'] ?? 'Guest';
    
    final takenCount = medications.where((m) => m.isTaken).length.toDouble();
    final totalCount = medications.length.toDouble();
    final adherence = totalCount == 0 ? 0.0 : (takenCount / totalCount) * 100;

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.textPrimary, // Black pill
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
          ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => context.push('/chat'),
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
              tooltip: "AI Assistant",
            ),
            Container(height: 24, width: 1, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 8)),
            IconButton(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              tooltip: "Add Medication",
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Glass App Bar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: AppTheme.background.withOpacity(0.7),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      centerTitle: false,
                      title: Text(
                        'Good Morning,\n$name', 
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, 
                          color: AppTheme.textPrimary,
                          fontSize: 20, // Collapsed size
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0071E3&color=fff&size=128'),
                      ),
                    ),
                  )
                ],
              ),
              
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // Dashboard Grid (Bento)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Adherence (Large)
                        Expanded(
                          flex: 3,
                          child: AppleGlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.pie_chart_outline, color: AppTheme.primary),
                                    Text("${adherence.toInt()}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text("Adherence", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text("Excellent", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Quick Actions / Stats (Small)
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              AppleGlassCard(
                                padding: const EdgeInsets.all(16),
                                onTap: () => context.push('/documents'),
                                child: const Center(child: Icon(Icons.document_scanner_outlined, size: 28, color: AppTheme.textPrimary)),
                              ),
                              const SizedBox(height: 16),
                              AppleGlassCard(
                                padding: const EdgeInsets.all(16),
                                child: const Center(child: Icon(Icons.favorite_border, size: 28, color: AppTheme.destructive)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Weekly Chart
                    AppleGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Weekly Progress", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                          const SizedBox(height: 20),
                          const _WeeklyChart(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Text("Today's Plan", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),
                    
                    if (medications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text("All clear for today!", style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                        ),
                      )
                    else
                      ...medications.map((med) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _MedicationGlassTile(med: med),
                      )),
                      
                    const SizedBox(height: 80), // Space for FAB
                  ]),
                ),
              ),
            ],
          ),
          
           // Banner
           AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            top: _showBanner ? 100 : -100, 
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _message ?? "Welcome",
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600, 
                            fontSize: 15
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends ConsumerStatefulWidget {
  const _WeeklyChart();
  @override
  ConsumerState<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends ConsumerState<_WeeklyChart> {
  // ... (Keep existing chart logic, just update colors)
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.watch(medicationProvider); 
    _loadData();
  }

  Future<void> _loadData() async {
    final service = ref.read(medicationServiceProvider);
    final data = await service.getWeeklyAnalytics();
    if (mounted) {
      setState(() {
         _data = data;
         _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Compact
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
        : BarChart(
        BarChartData(
          barGroups: _data.asMap().entries.map((e) {
            final index = e.key;
            final val = (e.value['value'] as num).toDouble();
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: val,
                  color: val >= 100 ? AppTheme.success : (val >= 50 ? AppTheme.primary : AppTheme.destructive),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: AppTheme.background),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= _data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_data[value.toInt()]['day'].substring(0,1), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _MedicationGlassTile extends ConsumerWidget {
  final Medication med;
  const _MedicationGlassTile({required this.med});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(medicationProvider.notifier).toggleTaken(med.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: med.isTaken ? AppTheme.success.withOpacity(0.2) : Colors.transparent, 
            width: 2
          ),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(med.isTaken ? 0.01 : 0.03), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: med.isTaken ? AppTheme.success.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                med.isTaken ? Icons.check : (med.type == "Injection" ? Icons.vaccines : Icons.medication), 
                color: med.isTaken ? AppTheme.success : AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name, style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 16,
                    decoration: med.isTaken ? TextDecoration.lineThrough : null,
                    color: med.isTaken ? AppTheme.textSecondary : AppTheme.textPrimary
                  )),
                  const SizedBox(height: 2),
                  Text("${med.dose} • ${med.time}", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, 
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: med.isTaken ? AppTheme.success : Colors.transparent,
                border: Border.all(color: med.isTaken ? AppTheme.success : AppTheme.textSecondary.withOpacity(0.3), width: 2)
              ),
              child: med.isTaken ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            )
          ],
        ),
      ),
    );
  }
}
