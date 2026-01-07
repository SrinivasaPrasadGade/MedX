import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/main.dart';
import 'package:google_fonts/google_fonts.dart'; // Added import

import 'package:patient_app/core/services/medication_service.dart';
import 'package:patient_app/core/services/notification_service.dart';
import 'package:patient_app/core/services/clinical_service.dart'; // Added Import



import 'package:patient_app/features/dashboard/presentation/providers/medication_provider.dart';

// --- UI Components ---

class HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final Function()? onTap;

  const HoverScale({super.key, required this.child, this.scale = 1.02, this.onTap});

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              boxShadow: _isHovered 
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))]
                : [],
            ),
            child: widget.child,
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
  bool _showBanner = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    // Check for welcome message after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final msg = ref.read(welcomeMessageProvider);
      if (msg != null) {
        setState(() {
          _message = msg;
          _showBanner = true;
        });
        
        // Hide after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showBanner = false);
          ref.read(welcomeMessageProvider.notifier).state = null; // Clear message
        });
      }
    });
  }

  void _showAddDialog() {
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("Add Medication", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                   IconButton(
                     onPressed: () => setState(() => isSmartMode = !isSmartMode),
                     icon: Icon(isSmartMode ? Icons.edit_note : Icons.auto_awesome, 
                        color: isSmartMode ? Colors.grey : const Color(0xFF007AFF)),
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
                         decoration: BoxDecoration(color: const Color(0xFF007AFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                         child: Row(children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFF007AFF), size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text("Type naturally, e.g., 'Take Metformin 500mg at 8am'", style: TextStyle(color: const Color(0xFF007AFF), fontSize: 13)))
                         ]),
                       ),
                       const SizedBox(height: 16),
                       TextField(
                         controller: smartController, 
                         maxLines: 3, 
                         decoration: const InputDecoration(
                           border: OutlineInputBorder(), 
                           hintText: "Enter prescription details..."
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
                                
                                // Switch back to manual to review
                                setState(() => isSmartMode = false);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not extract details")));
                              }
                           },
                           icon: isAnalyzing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.analytics),
                           label: const Text("Analyze & Fill"),
                           style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white)
                         ),
                       )
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: "Medication Name")),
                      TextField(controller: dosageController, decoration: const InputDecoration(labelText: "Dosage (e.g., 10mg)")),
                      TextField(controller: timeController, decoration: const InputDecoration(labelText: "Time (e.g., 9:00 AM)")),
                    ],
                  ),
              ),
              actions: [
                if (!isSmartMode) ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey))
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty) {
                        // 1. Get Dependencies
                        final navigator = Navigator.of(context);
                        final clinicalService = ref.read(clinicalServiceProvider);
                        final currentMeds = ref.read(medicationProvider);
                        final newMedName = nameController.text;
                        
                        // 2. Check for Interactions
                        // ... (Existing interaction logic)
                        final interaction = await clinicalService.checkInteractions(
                          newMedName, 
                          currentMeds.map((m) => m.name).toList()
                        );

                        // 3. Handle Result
                        if (interaction != null && interaction.warning != null) {
                          // Show Warning Dialog (Nested)
                          // Note: Nested dialogs in StatefulBuilder context might need root context
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
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white),
                    child: const Text("Add"),
                  ),
                ]
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());
    final medications = ref.watch(medicationProvider);
    
    // Calculate adherence
    final takenCount = medications.where((m) => m.isTaken).length.toDouble();
    final totalCount = medications.length.toDouble();
    final adherence = totalCount == 0 ? 0.0 : (takenCount / totalCount) * 100; // Fixed: 0.0 for double

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // iOS Light Gray
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF007AFF), // Blue to match theme
        tooltip: "Add Medication",
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Summary'),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/documents'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.perm_media_outlined, color: Colors.black, size: 20),
                    ),
                    tooltip: "Scan Documents",
                  ),
                  IconButton(
                    onPressed: () => context.push('/profile'), 
                    icon: Hero(
                      tag: 'profile-pic',
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=John+Doe&background=007AFF&color=fff'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(today.toUpperCase(), 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 16),
                    
                    // Adherence Card
                    HoverScale(child: _AdherenceCard(adherence: adherence)),
                    const SizedBox(height: 24),

                    // Weekly Analysis Chart
                     Text("Weekly Analysis", style: Theme.of(context).textTheme.headlineMedium),
                     const SizedBox(height: 12),
                     const HoverScale(scale: 1.01, child: _WeeklyChart()),
                     const SizedBox(height: 24),
                    
                    // Schedule Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's Schedule", style: Theme.of(context).textTheme.headlineMedium),
                        TextButton(onPressed: () {}, child: const Text("See All")),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Medication List
                    if (medications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text("No medications scheduled.", style: TextStyle(color: Colors.grey))),
                      )
                    else
                      ...medications.map((med) => HoverScale(
                        scale: 1.02,
                        onTap: () => ref.read(medicationProvider.notifier).toggleTaken(med.id),
                        child: _MedicationTile(med: med)
                      )),
                  ]),
                ),
              ),
            ],
          ),
          
          // Welcome Banner Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            top: _showBanner ? 60 : -100, // Slide down
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black, // Intense Black
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _message ?? "Welcome",
                      style: GoogleFonts.inter(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  final double adherence;
  const _AdherenceCard({required this.adherence});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Adherence Score", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: adherence),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Text("${value.toInt()}%", 
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF007AFF)));
                  },
                ),
                const SizedBox(height: 4),
                Text("You're doing better than 80% of patients.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          
          SizedBox(
            width: 100,
            height: 100,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF007AFF), 
                    value: adherence == 0 ? 0.1 : adherence, 
                    radius: 12, 
                    showTitle: false
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF2F2F7), 
                    value: 100 - adherence, 
                    radius: 12, 
                    showTitle: false
                  ),
                ],
                centerSpaceRadius: 35,
                sectionsSpace: 0,
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
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Listen to provider changes to refresh chart when meds are taken
  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch when medication state changes (e.g. user toggles a med)
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
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Adherence Trends (Last 7 Days)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : BarChart(
              BarChartData(
                barGroups: _data.asMap().entries.map((e) {
                  final index = e.key;
                  final day = e.value['day'];
                  final val = (e.value['value'] as num).toDouble();
                  return _makeGroup(index, val, day);
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
                          child: Text(_data[value.toInt()]['day'], style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroup(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y >= 100 ? const Color(0xFF34C759) : (y >= 50 ? const Color(0xFF007AFF) : const Color(0xFFFF3B30)),
          width: 12,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: const Color(0xFFF2F2F7)),
        ),
      ],
    );
  }
}

class _MedicationTile extends StatelessWidget {
  final Medication med;

  const _MedicationTile({required this.med});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: med.isTaken ? Border.all(color: const Color(0xFF34C759).withOpacity(0.3), width: 1.5) : null,
        boxShadow: med.isTaken ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: med.isTaken ? const Color(0xFF34C759).withOpacity(0.1) : const Color(0xFF007AFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              med.isTaken ? Icons.check : (med.type == "Injection" ? Icons.vaccines : Icons.medication), 
              color: med.isTaken ? const Color(0xFF34C759) : const Color(0xFF007AFF)
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
                  color: med.isTaken ? Colors.grey : Colors.black
                )),
                Text("${med.dose} • ${med.time}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
          if (med.isTaken)
            const Text("Taken", style: TextStyle(color: Color(0xFF34C759), fontWeight: FontWeight.w500))
          else 
            Text(med.status, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
