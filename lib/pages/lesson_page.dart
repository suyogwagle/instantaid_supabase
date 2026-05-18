// import 'package:flutter/material.dart';
// import 'package:instant_aid/pages/quiz_page.dart';
// import 'package:provider/provider.dart';
// import 'package:instant_aid/services/first_aid_content_service.dart';
// import '../services/progress_service.dart';
// import '../widget/lesson_requirements.dart';
//
// class LessonPage extends StatefulWidget {
//   final int id;
//   final String initialage_group;
//   final String imageUrl;
//
//   const LessonPage({
//     super.key,
//     required this.id,
//     required this.imageUrl,
//     this.initialage_group = 'adult',
//   });
//
//   @override
//   State<LessonPage> createState() => _LessonPageState();
// }
//
// class _LessonPageState extends State<LessonPage> {
//   late String _selectedOption;
//   String? _selectedSubcategory;
//   String? _selectedType;
//   bool _isBookmarked = false;
//   bool _isLoading = true;
//   bool _isLoadingSubcategories = false;
//   bool _isLoadingTypes = false;
//   bool _isCompleting = false;        // true while markComplete() is in flight
//   bool _isCurrentLessonComplete = false; // tracks if this combo is already done
//   String? _errorMessage;
//
//
//   List<String> get _ageGroups {
//     switch (widget.id) {
//       case 2:  // Choking Response
//         return ["adult", "infant"];
//       default: // Burns and all others
//         return ["adult", "child"];
//     }
//   }
//
//   List<String> _subcategories = [];
//   List<String> _types = [];
//
//   final Map<String, bool> _expandedSections = {
//     'description': false,
//     'preventive_methods': false,
//     'precautions': false,
//     'symptoms': false,
//     'first_aid_steps': false,
//     'do': false,
//     'dont': false,
//     'when_to_seek_help': false,
//   };
//
//   final Map<String, bool> _viewedSections = {
//     'description': false,
//     'preventive_methods': false,
//     'precautions': false,
//     'symptoms': false,
//     'first_aid_steps': false,
//     'do': false,
//     'dont': false,
//     'when_to_seek_help': false,
//   };
//
//   final FirstAidService _firstAidService = FirstAidService();
//
//   Map<String, dynamic> lessonData = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedOption = widget.initialage_group;
//     _loadInitialData();
//   }
//
//   Future<void> _loadInitialData() async {
//     setState(() {
//       _isLoading = true;
//       _isLoadingSubcategories = true;
//     });
//
//     try {
//       // set subcategories statically
//       final subcategories = _subcategoriesForLesson();
//
//       // set types statically (must happen BEFORE _loadLessonData so _selectedType is non-null when the first query runs)
//       final types = _typesForLesson();
//
//       setState(() {
//         _subcategories   = subcategories;
//         _selectedSubcategory = subcategories.isNotEmpty ? subcategories.first : null;
//         _isLoadingSubcategories = false;
//
//         if (_hasTypeSelector()) {
//           _types       = types;
//           _selectedType = types.isNotEmpty ? types.first : null;
//         }
//       });
//
//       // load lesson data — subcategory AND type are both set
//       await _loadLessonData();
//     } catch (e) {
//       print('Error loading initial data: $e');
//       setState(() {
//         _errorMessage = 'Failed to load data: $e';
//         _isLoading = false;
//         _isLoadingSubcategories = false;
//         _isLoadingTypes = false;
//       });
//     }
//   }
//
//   // Burns uses degree names; Choking uses cause names.
//   List<String> _typesForLesson() {
//     switch (widget.id) {
//       case 1: // Burn Treatment
//         return ['first_degree', 'second_degree', 'third_degree', 'fourth_degree'];
//       case 2: // Choking Response
//         return ['food', 'foreign_object', 'liquid', 'other_circumstances'];
//       default:
//         return [];
//     }
//   }
//
//   // Maps lessonId to the category_name stored in first_aid_category table.
//   String _categoryName() {
//     switch (widget.id) {
//       case 1: return 'Burn';
//       case 2: return 'Choking';
//       case 3: return 'CPR Procedure';
//       case 4: return 'Fracture Treatment';
//       case 5: return 'Minor Injuries';
//       default: return '';
//     }
//   }
//
//   Future<void> _loadTypes() async {
//     setState(() {
//       _isLoadingTypes = true;
//       _types = _typesForLesson();
//       _isLoadingTypes = false;
//     });
//   }
//
//   List<String> _subcategoriesForLesson() {
//     switch (widget.id) {
//       case 1: // Burn Treatment
//         return ['Thermal Burn', 'Chemical Burn', 'Electrical Burn', 'SunBurn', 'Friction Burn'];
//       case 2: // Choking Response
//         return ['Mild Choking', 'Severe Choking', 'Unconscious Choking'];
//       default:
//         return [];
//     }
//   }
//
//   Future<void> _loadSubcategories() async {
//     final subs = _subcategoriesForLesson();
//     setState(() {
//       _subcategories = subs;
//       _selectedSubcategory = subs.isNotEmpty ? subs.first : null;
//     });
//     print('✅ Subcategories for lesson \${widget.id}: \$_subcategories');
//   }
//
//   Future<void> _loadLessonData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       print('\n📊 === LOADING LESSON DATA ===');
//       print('  ID: ${widget.id}');
//       print('  Age Group: $_selectedOption');
//       print('  Subcategory: $_selectedSubcategory');
//       print('  Type: $_selectedType');
//       print('===============================\n');
//
//       final data = await _firstAidService.getLessonData(
//         id: widget.id,
//         category: _categoryName(),       // explicit category name
//         ageGroup: _selectedOption,
//         subcategory: _selectedSubcategory,
//         categoryType: _selectedType,
//       );
//
//       print('Loaded data: $data');
//
//       setState(() {
//         lessonData = data;
//         _isLoading = false;
//       });
//
//       // Check if this exact combo is already saved in lesson_progress
//       await _checkIfAlreadyComplete();
//     } catch (e) {
//       print('Error loading data: $e');
//       setState(() {
//         _errorMessage = 'Failed to load lesson data: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   // ── Check if current subcategory/degree/ageGroup is already complete ─────
//   Future<void> _checkIfAlreadyComplete() async {
//     final key = LessonRequirements.buildKey(
//       subcategory: _selectedSubcategory,
//       degree:      _selectedType,
//       ageGroup:    _selectedOption,
//     );
//     try {
//       final progressService = context.read<ProgressService>();
//       final completed = await progressService.getCompletedLessons(lessonId: widget.id);
//       // Normalise fetched keys so they match the normalised key from buildKey()
//       final completedKeys = completed.map((c) => c.subcategory.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_')).toSet();
//       final isComplete = completedKeys.contains(key);
//       setState(() {
//         _isCurrentLessonComplete = isComplete;
//         // If already completed, mark every section as viewed so they all
//         // render with the blue border + check tick
//         if (isComplete) {
//           _viewedSections.updateAll((_, __) => true);
//         }
//       });
//     } catch (_) {
//       setState(() => _isCurrentLessonComplete = false);
//     }
//   }
//
//   // ── Called when user taps the ✓ button ─────────────────────────────────
//   Future<void> _markCurrentLessonComplete() async {
//     // Guard 1: burn lessons require subcategory + degree to be selected
//     if (_hasTypeSelector() &&
//         (_selectedSubcategory == null || _selectedType == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please select a subcategory and ${_typeLabel().toLowerCase()} first.'),
//           backgroundColor: Colors.orange,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//
//     // all sections must be opened at least once before marking done
//     final total   = _getAvailableSectionsCount();
//     final viewed  = _getViewedSectionsCount();
//     if (viewed < total) {
//       final remaining = total - viewed;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.info_outline, color: Colors.white, size: 18),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'Please open all sections first. '
//                       '$remaining section${remaining == 1 ? '' : 's'} remaining.',
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.orange.shade700,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isCompleting = true);
//
//     final key = LessonRequirements.buildKey(
//       subcategory: _selectedSubcategory,
//       degree:      _selectedType,
//       ageGroup:    _selectedOption,
//     );
//
//     try {
//       await context.read<ProgressService>().markComplete(
//         lessonId:    widget.id,
//         subcategory: key,
//       );
//
//       setState(() {
//         _isCurrentLessonComplete = true;
//         _isCompleting = false;
//       });
//
//       if (context.mounted) {
//         final label = key
//             .replaceAll('_', ' ')
//             .replaceAll('/', ' — ')
//             .split(' ')
//             .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
//             .join(' ');
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white, size: 18),
//                 const SizedBox(width: 8),
//                 Expanded(child: Text('$label marked complete')),
//               ],
//             ),
//             backgroundColor: Colors.green.shade600,
//             behavior: SnackBarBehavior.floating,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => _isCompleting = false);
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Could not save progress: $e'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
//
//   void _toggleSection(String section) {
//     setState(() {
//       _expandedSections[section] = !_expandedSections[section]!;
//       if (_expandedSections[section]!) {
//         _viewedSections[section] = true;
//       }
//     });
//   }
//
//
//   // ── Per-lesson labels and icons for the type dropdown ───────────────────
//   String _typeLabel() {
//     switch (widget.id) {
//       case 1:  return 'Burn Degree';
//       case 2:  return 'Choking Cause';
//       default: return 'Type';
//     }
//   }
//
//   IconData _typeIcon() {
//     switch (widget.id) {
//       case 1:  return Icons.local_fire_department;
//       case 2:  return Icons.air;
//       default: return Icons.category;
//     }
//   }
//
//   String _typeRequiredHint() {
//     switch (widget.id) {
//       case 1:  return 'REQUIRED — SELECT BURN DEGREE';
//       case 2:  return 'REQUIRED — SELECT CHOKING CAUSE';
//       default: return 'REQUIRED — SELECT TYPE';
//     }
//   }
//
//   // Returns true for any lesson that has a type/degree selector.
//   // Add new lesson ids here as more content is added.
//   bool _hasTypeSelector() {
//     return widget.id == 1 || widget.id == 2;
//   }
//
//   int _getAvailableSectionsCount() {
//     int count = 0;
//     if (lessonData['overview'] != null && lessonData['overview'].toString().isNotEmpty) count++;
//     if (lessonData['preventive methods'] != null &&
//         lessonData['preventive methods'] is List &&
//         (lessonData['preventive methods'] as List).isNotEmpty) count++;
//     if (lessonData['precautions'] != null &&
//         lessonData['precautions'] is List &&
//         (lessonData['precautions'] as List).isNotEmpty) count++;
//     if (lessonData['symptoms'] != null &&
//         lessonData['symptoms'] is List &&
//         (lessonData['symptoms'] as List).isNotEmpty) count++;
//     if (lessonData['first aid steps'] != null &&
//         lessonData['first aid steps'] is List &&
//         (lessonData['first aid steps'] as List).isNotEmpty) count++;
//     if (lessonData['do'] != null &&
//         lessonData['do'] is List &&
//         (lessonData['do'] as List).isNotEmpty) count++;
//     if (lessonData['dont'] != null &&
//         lessonData['dont'] is List &&
//         (lessonData['dont'] as List).isNotEmpty) count++;
//     if (lessonData['when to seek help'] != null &&
//         lessonData['when to seek help'] is List &&
//         (lessonData['when to seek help'] as List).isNotEmpty) count++;
//     return count;
//   }
//
//   int _getViewedSectionsCount() {
//     int count = 0;
//     if (lessonData['overview'] != null &&
//         lessonData['overview'].toString().isNotEmpty &&
//         (_viewedSections['description'] ?? false)) count++;
//     if (lessonData['preventive methods'] != null &&
//         lessonData['preventive methods'] is List &&
//         (lessonData['preventive methods'] as List).isNotEmpty &&
//         (_viewedSections['preventive_methods'] ?? false)) count++;
//     if (lessonData['precautions'] != null &&
//         lessonData['precautions'] is List &&
//         (lessonData['precautions'] as List).isNotEmpty &&
//         (_viewedSections['precautions'] ?? false)) count++;
//     if (lessonData['symptoms'] != null &&
//         lessonData['symptoms'] is List &&
//         (lessonData['symptoms'] as List).isNotEmpty &&
//         (_viewedSections['symptoms'] ?? false)) count++;
//     if (lessonData['first aid steps'] != null &&
//         lessonData['first aid steps'] is List &&
//         (lessonData['first aid steps'] as List).isNotEmpty &&
//         (_viewedSections['first_aid_steps'] ?? false)) count++;
//     if (lessonData['do'] != null &&
//         lessonData['do'] is List &&
//         (lessonData['do'] as List).isNotEmpty &&
//         (_viewedSections['do'] ?? false)) count++;
//     if (lessonData['dont'] != null &&
//         lessonData['dont'] is List &&
//         (lessonData['dont'] as List).isNotEmpty &&
//         (_viewedSections['dont'] ?? false)) count++;
//     if (lessonData['when to seek help'] != null &&
//         lessonData['when to seek help'] is List &&
//         (lessonData['when to seek help'] as List).isNotEmpty &&
//         (_viewedSections['when_to_seek_help'] ?? false)) count++;
//     return count;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: _buildAppBar(),
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.grey[50],
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//           ? _buildErrorWidget()
//           : Column(
//         children: [
//           _buildTopImage(screenHeight),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: _buildMainContent(screenWidth, screenHeight),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _isLoading || _errorMessage != null
//           ? null
//           : _buildBottomBar(),
//     );
//   }
//
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             Text(
//               'Error Loading Data',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage ?? 'Unknown error occurred',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _loadLessonData,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[700],
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   AppBar _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: Padding(
//         padding: const EdgeInsets.only(left: 10),
//         child: _circleButton(
//           icon: Icons.arrow_back_ios_new,
//           onTap: () => Navigator.pop(context),
//         ),
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 10),
//           child: _circleButton(
//             icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//             onTap: () {
//               setState(() {
//                 _isBookmarked = !_isBookmarked;
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(_isBookmarked ? 'Lesson bookmarked' : 'Bookmark removed'),
//                   duration: const Duration(seconds: 1),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTopImage(double screenHeight) {
//     return SizedBox(
//       height: screenHeight * 0.30,
//       width: double.infinity,
//       child: Stack(
//         children: [
//           Image.network(
//             widget.imageUrl,
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//             errorBuilder: (_, __, ___) => Container(
//               color: Colors.grey[300],
//               child: const Center(
//                 child: Icon(Icons.medical_services, size: 80, color: Colors.grey),
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withValues(alpha: 0.7),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainContent(double screenWidth, double screenHeight) {
//     final totalSections = _getAvailableSectionsCount();
//     // If this combo is already saved in Supabase, treat all sections as viewed
//     // so the bar shows 100% instead of resetting to 0% on revisit.
//     final completedSections = _isCurrentLessonComplete
//         ? totalSections
//         : _getViewedSectionsCount();
//     final completionPercentage = totalSections > 0
//         ? (completedSections / totalSections * 100).round()
//         : 0;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           lessonData['title'] ?? 'First Aid Lesson',
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         if (totalSections > 0) ...[
//           Row(
//             children: [
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: completedSections / totalSections,
//                     minHeight: 8,
//                     backgroundColor: Colors.grey[300],
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       completedSections == totalSections ? Colors.green : Colors.blue[700]!,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 '$completionPercentage%',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: completedSections == totalSections ? Colors.green : Colors.blue[700],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '$completedSections/$totalSections sections complete',
//             style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 32),
//         ],
//
//         _buildSectionHeader('Select Age Group', Icons.people),
//         const SizedBox(height: 12),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[300]!),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: _selectedOption,
//               isExpanded: true,
//               icon: const Icon(Icons.keyboard_arrow_down),
//               onChanged: (val) async {
//                 setState(() {
//                   _selectedOption = val!;
//                   _expandedSections.updateAll((key, value) => false);
//                   _viewedSections.updateAll((key, value) => false);
//                   _selectedSubcategory = null;
//                   _selectedType = null;
//                   _subcategories = [];
//                   _types = [];
//                   _isLoading = true;
//                 });
//
//                 await _loadSubcategories();
//                 await _loadLessonData();
//
//                 if (_hasTypeSelector()) {
//                   await _loadTypes();
//                 }
//               },
//               items: _ageGroups.map((value) {
//                 return DropdownMenuItem(
//                   value: value,
//                   child: Text(
//                     value.toUpperCase(),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 16),
//
//         if (_subcategories.isNotEmpty) ...[
//           _buildSectionHeader('Select Subcategory', Icons.category),
//           const SizedBox(height: 12),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[300]!),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: _isLoadingSubcategories
//                 ? const Padding(
//               padding: EdgeInsets.symmetric(vertical: 12),
//               child: Center(
//                 child: SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             )
//                 : DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: _selectedSubcategory,
//                 isExpanded: true,
//                 icon: const Icon(Icons.keyboard_arrow_down),
//                 onChanged: (val) async {
//                   setState(() {
//                     _selectedSubcategory = val;
//                     _expandedSections.updateAll((key, value) => false);
//                     _viewedSections.updateAll((key, value) => false);
//                     _selectedType = null;
//                     _isLoading = true;
//                   });
//                   await _loadLessonData();
//                 },
//                 items: _subcategories.map((value) {
//                   return DropdownMenuItem(
//                     value: value,
//                     child: Text(
//                       value.toUpperCase(),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//
//         if (_hasTypeSelector() && !_isLoading) ...[
//           _buildSectionHeader(_typeLabel(), _typeIcon()),
//           const SizedBox(height: 12),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: _selectedType == null ? Colors.orange[300]! : Colors.grey[300]!,
//                 width: _selectedType == null ? 2 : 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: _isLoadingTypes
//                 ? const Padding(
//               padding: EdgeInsets.symmetric(vertical: 12),
//               child: Center(
//                 child: SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             )
//                 : DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: _selectedType,
//                 isExpanded: true,
//                 hint: Row(
//                   children: [
//                     Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       _typeRequiredHint(),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//                 icon: const Icon(Icons.keyboard_arrow_down),
//                 onChanged: (val) async {
//                   setState(() {
//                     _selectedType = val;
//                     _expandedSections.updateAll((key, value) => false);
//                     _viewedSections.updateAll((key, value) => false);
//                     _isLoading = true;
//                   });
//                   await _loadLessonData();
//                 },
//                 items: _types.map((value) {
//                   return DropdownMenuItem(
//                     value: value,
//                     child: Text(
//                       value.replaceAll('_', ' ').toUpperCase(),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//
//           if (_selectedType == null) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.orange[200]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Please select a ${_typeLabel().toLowerCase()} to view the lesson content',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.orange[900],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//
//           const SizedBox(height: 32),
//         ] else if (!_isLoadingSubcategories && _subcategories.isEmpty) ...[
//           const SizedBox(height: 16),
//         ],
//
//         if (!_hasTypeSelector() || (_hasTypeSelector() && _selectedType != null)) ...[
//           if (lessonData['overview'] != null && lessonData['overview'].toString().isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'description',
//               title: 'Description',
//               icon: Icons.info_outline,
//               child: Text(
//                 lessonData['overview'],
//                 style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[800]),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//
//           if (lessonData['preventive methods'] != null &&
//               lessonData['preventive methods'] is List &&
//               (lessonData['preventive methods'] as List).isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'preventive_methods',
//               title: 'Preventive Methods',
//               icon: Icons.security_sharp,
//               color: Colors.green,
//               child: Column(
//                 children: (lessonData['preventive methods'] as List)
//                     .map<Widget>((item) => _buildListItem(item.toString(), Icons.security, Colors.green))
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//
//           if (lessonData['precautions'] != null &&
//               lessonData['precautions'] is List &&
//               (lessonData['precautions'] as List).isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'precautions',
//               title: 'Precautions',
//               icon: Icons.error_outline,
//               color: Colors.orange,
//               child: Column(
//                 children: (lessonData['precautions'] as List)
//                     .map<Widget>((item) => _buildListItem(item.toString(), Icons.error, Colors.orange))
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//
//           if (lessonData['symptoms'] != null &&
//               lessonData['symptoms'] is List &&
//               (lessonData['symptoms'] as List).isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'symptoms',
//               title: 'Symptoms',
//               icon: Icons.sick_outlined,
//               color: Colors.purple,
//               child: Column(
//                 children: (lessonData['symptoms'] as List)
//                     .map<Widget>((item) => _buildListItem(item.toString(), Icons.circle, Colors.purple))
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//
//           if (lessonData['first aid steps'] != null &&
//               lessonData['first aid steps'] is List &&
//               (lessonData['first aid steps'] as List).isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'first_aid_steps',
//               title: 'First Aid Steps',
//               icon: Icons.medical_services_outlined,
//               child: Column(
//                 children: (lessonData['first aid steps'] as List)
//                     .asMap()
//                     .entries
//                     .map<Widget>((entry) {
//                   if (entry.value is Map) {
//                     return _buildStepCard(entry.value as Map<String, dynamic>);
//                   } else {
//                     return _buildStepCard({
//                       'number': entry.key + 1,
//                       'title': 'Step ${entry.key + 1}',
//                       'description': entry.value.toString(),
//                       'completed': false,
//                     });
//                   }
//                 })
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//
//           if (lessonData['do'] != null &&
//               lessonData['do'] is List &&
//               (lessonData['do'] as List).isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'do',
//               title: 'Do',
//               icon: Icons.check_circle_outline,
//               color: Colors.green,
//               child: Column(
//                 children: (lessonData['do'] as List)
//                     .map<Widget>((item) => _buildListItem(item.toString(), Icons.check, Colors.green))
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//
//           if (lessonData['dont'] != null &&
//               lessonData['dont'] is List &&
//               (lessonData['dont'] as List).isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'dont',
//               title: 'Don\'t',
//               icon: Icons.cancel_outlined,
//               color: Colors.red,
//               child: Column(
//                 children: (lessonData['dont'] as List)
//                     .map<Widget>((item) => _buildListItem(item.toString(), Icons.close, Colors.red))
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//
//           if (lessonData['when to seek help'] != null &&
//               lessonData['when to seek help'] is List &&
//               (lessonData['when to seek help'] as List).isNotEmpty) ...[
//             _buildCollapsibleSection(
//               sectionKey: 'when_to_seek_help',
//               title: 'When to Seek Help',
//               icon: Icons.local_hospital_outlined,
//               color: Colors.red,
//               child: Column(
//                 children: (lessonData['when to seek help'] as List)
//                     .map<Widget>((item) => _buildListItem(item.toString(), Icons.local_hospital, Colors.red))
//                     .toList(),
//               ),
//             ),
//           ],
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             color: Colors.green.shade50,
//             margin: EdgeInsets.all(12),
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: Colors.green,
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Note",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green.shade800,
//                           ),
//                         ),
//                         SizedBox(height: 6),
//                         Text(
//                           "Click the arrow on the green box to confirm completion!",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade800,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ],
//     );
//   }
//
//   Widget _buildCollapsibleSection({
//     required String sectionKey,
//     required String title,
//     required IconData icon,
//     Color? color,
//     required Widget child,
//   }) {
//     final isExpanded = _expandedSections[sectionKey] ?? false;
//     final isViewed = _viewedSections[sectionKey] ?? false;
//
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isViewed ? (color ?? Colors.blue[700]!) : Colors.grey[200]!,
//           width: isViewed ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           InkWell(
//             onTap: () => _toggleSection(sectionKey),
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(icon, color: color ?? Colors.blue[700], size: 24),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: color ?? Colors.black87,
//                       ),
//                     ),
//                   ),
//                   if (isViewed)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: (color ?? Colors.blue[700])!.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         Icons.check_circle,
//                         size: 18,
//                         color: color ?? Colors.blue[700],
//                       ),
//                     ),
//                   const SizedBox(width: 8),
//                   Icon(
//                     isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                     color: Colors.grey[600],
//                     size: 28,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isExpanded) ...[
//             const Divider(height: 1),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: child,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
//     return Row(
//       children: [
//         Icon(icon, color: color ?? Colors.blue[700], size: 24),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: color ?? Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStepCard(Map<String, dynamic> step) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: (step['completed'] ?? false) ? Colors.green : Colors.grey[300]!,
//             width: 2,
//           ),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: (step['completed'] ?? false) ? Colors.green : Colors.blue[700],
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: (step['completed'] ?? false)
//                     ? const Icon(Icons.check, color: Colors.white, size: 24)
//                     : Text(
//                   '${step['number'] ?? ''}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     step['title'] ?? '',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     step['description'] ?? '',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                       height: 1.4,
//                     ),
//                   ),
//                   if (step['completed'] ?? false)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8),
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Completed',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.green[700],
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildListItem(String text, IconData icon, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             // ── Take Quiz button ───────────────────────────────────────────
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => QuizPage(
//                         lessonId:    widget.id,
//                         lessonTitle: lessonData['title'] ?? 'Quiz',
//                         // QuizPage checks eligibility automatically.
//                         // If not all lessons are done it shows the gate screen.
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[700],
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.quiz_outlined, color: Colors.white),
//                     SizedBox(width: 8),
//                     Text(
//                       'Take Quiz',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//
//             // ── Mark complete button ──
//             // Shows a spinner while saving, a filled check when already done.
//             ElevatedButton(
//               onPressed: _isCompleting || _isCurrentLessonComplete
//                   ? null
//                   : _markCurrentLessonComplete,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _isCurrentLessonComplete
//                     ? Colors.green.shade300   // dimmed = already done
//                     : Colors.green,
//                 disabledBackgroundColor: _isCurrentLessonComplete
//                     ? Colors.green.shade300
//                     : Colors.grey.shade300,
//                 padding: const EdgeInsets.all(16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: _isCompleting
//                   ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2.5,
//                 ),
//               )
//                   : Icon(
//                 _isCurrentLessonComplete
//                     ? Icons.check_circle   // already saved
//                     : Icons.check,          // not yet saved
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(alpha: 0.9),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(icon, size: 20, color: Colors.black87),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:instant_aid/pages/quiz_page.dart';
import 'package:provider/provider.dart';
import 'package:instant_aid/services/first_aid_content_service.dart';
import '../services/progress_service.dart';
import '../widget/lesson_requirements.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  // Primary palette
  static const teal       = Color(0xFF00897B);
  static const tealLight  = Color(0xFFB2DFDB);
  static const tealDark   = Color(0xFF00695C);
  static const tealFaint  = Color(0xFFE0F2F1);

  // Neutrals
  static const bg         = Color(0xFFF7F8FA);
  static const card       = Colors.white;
  static const textPri    = Color(0xFF1A2535);
  static const textSec    = Color(0xFF64748B);
  static const divider    = Color(0xFFECEFF4);

  // Semantics
  static const green      = Color(0xFF2E7D32);
  static const greenFaint = Color(0xFFE8F5E9);
  static const orange     = Color(0xFFE65100);
  static const orangeFaint= Color(0xFFFFF3E0);
  static const purple     = Color(0xFF6A1B9A);
  static const purpleFaint= Color(0xFFF3E5F5);
  static const red        = Color(0xFFC62828);
  static const redFaint   = Color(0xFFFFEBEE);
  static const blue       = Color(0xFF1565C0);
  static const blueFaint  = Color(0xFFE3F2FD);

  // Radius
  static const r8  = BorderRadius.all(Radius.circular(8));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const r20 = BorderRadius.all(Radius.circular(20));

  // Shadows
  static List<BoxShadow> shadow1 = [
    const BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> shadow2 = [
    const BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

class LessonPage extends StatefulWidget {
  final int id;
  final String initialage_group;
  final String imageUrl;

  const LessonPage({
    super.key,
    required this.id,
    required this.imageUrl,
    this.initialage_group = 'adult',
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> with SingleTickerProviderStateMixin {
  late String _selectedOption;
  String? _selectedSubcategory;
  String? _selectedType;
  bool _isBookmarked     = false;
  bool _isLoading        = true;
  bool _isLoadingSubcategories = false;
  bool _isLoadingTypes   = false;
  bool _isCompleting     = false;
  bool _isCurrentLessonComplete = false;
  String? _errorMessage;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  List<String> get _ageGroups {
    switch (widget.id) {
      case 2:  return ["adult", "infant"];
      default: return ["adult", "child"];
    }
  }

  List<String> _subcategories = [];
  List<String> _types         = [];

  final Map<String, bool> _expandedSections = {
    'description': false, 'preventive_methods': false,
    'precautions': false,  'symptoms': false,
    'first_aid_steps': false, 'do': false,
    'dont': false,         'when_to_seek_help': false,
  };

  final Map<String, bool> _viewedSections = {
    'description': false, 'preventive_methods': false,
    'precautions': false,  'symptoms': false,
    'first_aid_steps': false, 'do': false,
    'dont': false,         'when_to_seek_help': false,
  };

  final FirstAidService _firstAidService = FirstAidService();
  Map<String, dynamic> lessonData = {};

  // ── lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialage_group;
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadInitialData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── data loading (unchanged logic) ────────────────────────────────────────
  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; _isLoadingSubcategories = true; });
    try {
      final subcategories = _subcategoriesForLesson();
      final types         = _typesForLesson();
      setState(() {
        _subcategories       = subcategories;
        _selectedSubcategory = subcategories.isNotEmpty ? subcategories.first : null;
        _isLoadingSubcategories = false;
        if (_hasTypeSelector()) {
          _types        = types;
          _selectedType = types.isNotEmpty ? types.first : null;
        }
      });
      await _loadLessonData();
    } catch (e) {
      setState(() { _errorMessage = 'Failed to load data: $e'; _isLoading = false; _isLoadingSubcategories = false; _isLoadingTypes = false; });
    }
  }

  List<String> _typesForLesson() {
    switch (widget.id) {
      case 1: return ['first_degree', 'second_degree', 'third_degree', 'fourth_degree'];
      case 2: return ['food', 'foreign_object', 'liquid', 'other_circumstances'];
      default: return [];
    }
  }

  String _categoryName() {
    switch (widget.id) {
      case 1: return 'Burn';    case 2: return 'Choking';
      case 3: return 'CPR Procedure'; case 4: return 'Fracture Treatment';
      case 5: return 'Minor Injuries'; default: return '';
    }
  }

  Future<void> _loadTypes() async {
    setState(() { _isLoadingTypes = true; _types = _typesForLesson(); _isLoadingTypes = false; });
  }

  List<String> _subcategoriesForLesson() {
    switch (widget.id) {
      case 1: return ['Thermal Burn', 'Chemical Burn', 'Electrical Burn', 'SunBurn', 'Friction Burn'];
      case 2: return ['Mild Choking', 'Severe Choking', 'Unconscious Choking'];
      default: return [];
    }
  }

  Future<void> _loadSubcategories() async {
    final subs = _subcategoriesForLesson();
    setState(() { _subcategories = subs; _selectedSubcategory = subs.isNotEmpty ? subs.first : null; });
  }

  Future<void> _loadLessonData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = await _firstAidService.getLessonData(
        id: widget.id, category: _categoryName(),
        ageGroup: _selectedOption, subcategory: _selectedSubcategory,
        categoryType: _selectedType,
      );
      setState(() { lessonData = data; _isLoading = false; });
      _fadeCtrl.forward(from: 0);
      await _checkIfAlreadyComplete();
    } catch (e) {
      setState(() { _errorMessage = 'Failed to load lesson data: $e'; _isLoading = false; });
    }
  }

  Future<void> _checkIfAlreadyComplete() async {
    final key = LessonRequirements.buildKey(subcategory: _selectedSubcategory, degree: _selectedType, ageGroup: _selectedOption);
    try {
      final progressService = context.read<ProgressService>();
      final completed = await progressService.getCompletedLessons(lessonId: widget.id);
      final completedKeys = completed.map((c) => c.subcategory.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_')).toSet();
      final isComplete = completedKeys.contains(key);
      setState(() {
        _isCurrentLessonComplete = isComplete;
        if (isComplete) _viewedSections.updateAll((_, __) => true);
      });
    } catch (_) { setState(() => _isCurrentLessonComplete = false); }
  }

  Future<void> _markCurrentLessonComplete() async {
    if (_hasTypeSelector() && (_selectedSubcategory == null || _selectedType == null)) {
      _showSnack('Please select a subcategory and ${_typeLabel().toLowerCase()} first.', Colors.orange);
      return;
    }
    final total = _getAvailableSectionsCount();
    final viewed = _getViewedSectionsCount();
    if (viewed < total) {
      final remaining = total - viewed;
      _showSnack('Open all sections first. $remaining section${remaining == 1 ? '' : 's'} remaining.', Colors.orange.shade700);
      return;
    }
    setState(() => _isCompleting = true);
    final key = LessonRequirements.buildKey(subcategory: _selectedSubcategory, degree: _selectedType, ageGroup: _selectedOption);
    try {
      await context.read<ProgressService>().markComplete(lessonId: widget.id, subcategory: key);
      setState(() { _isCurrentLessonComplete = true; _isCompleting = false; });
      if (context.mounted) {
        final label = key.replaceAll('_', ' ').replaceAll('/', ' — ').split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');
        _showSnack('$label marked complete ✓', Colors.green.shade600);
      }
    } catch (e) {
      setState(() => _isCompleting = false);
      if (context.mounted) _showSnack('Could not save progress: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
      if (_expandedSections[section]!) _viewedSections[section] = true;
    });
  }

  String _typeLabel() { switch (widget.id) { case 1: return 'Burn Degree'; case 2: return 'Choking Cause'; default: return 'Type'; } }
  IconData _typeIcon() { switch (widget.id) { case 1: return Icons.local_fire_department; case 2: return Icons.air; default: return Icons.category; } }
  String _typeRequiredHint() { switch (widget.id) { case 1: return 'Select Burn Degree'; case 2: return 'Select Choking Cause'; default: return 'Select Type'; } }
  bool _hasTypeSelector() => widget.id == 1 || widget.id == 2;

  int _getAvailableSectionsCount() {
    int c = 0;
    bool hasList(String k) => lessonData[k] is List && (lessonData[k] as List).isNotEmpty;
    if ((lessonData['overview'] ?? '').toString().isNotEmpty) c++;
    if (hasList('preventive methods')) c++;
    if (hasList('precautions')) c++;
    if (hasList('symptoms')) c++;
    if (hasList('first aid steps')) c++;
    if (hasList('do')) c++;
    if (hasList('dont')) c++;
    if (hasList('when to seek help')) c++;
    return c;
  }

  int _getViewedSectionsCount() {
    int c = 0;
    bool hasList(String k) => lessonData[k] is List && (lessonData[k] as List).isNotEmpty;
    if ((lessonData['overview'] ?? '').toString().isNotEmpty && (_viewedSections['description'] ?? false)) c++;
    if (hasList('preventive methods') && (_viewedSections['preventive_methods'] ?? false)) c++;
    if (hasList('precautions') && (_viewedSections['precautions'] ?? false)) c++;
    if (hasList('symptoms') && (_viewedSections['symptoms'] ?? false)) c++;
    if (hasList('first aid steps') && (_viewedSections['first_aid_steps'] ?? false)) c++;
    if (hasList('do') && (_viewedSections['do'] ?? false)) c++;
    if (hasList('dont') && (_viewedSections['dont'] ?? false)) c++;
    if (hasList('when to seek help') && (_viewedSections['when_to_seek_help'] ?? false)) c++;
    return c;
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight   = screenHeight * 0.30;

    return Scaffold(
      backgroundColor: _T.bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _T.teal))
          : _errorMessage != null
          ? _buildErrorWidget()
          : FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Sticky hero that gets covered by the sheet ──────
            SliverAppBar(
              expandedHeight: heroHeight,
              collapsedHeight: 0,
              toolbarHeight: 0,
              pinned: false,
              floating: false,
              stretch: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _T.tealFaint,
                        child: const Center(child: Icon(Icons.medical_services, size: 80, color: _T.teal)),
                      ),
                    ),
                    // gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, _T.tealDark.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Floating back + bookmark over the hero
              leading: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: _glassButton(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 8),
                  child: _glassButton(
                    _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        () {
                      setState(() => _isBookmarked = !_isBookmarked);
                      _showSnack(_isBookmarked ? 'Lesson bookmarked' : 'Bookmark removed', _T.teal);
                    },
                  ),
                ),
              ],
            ),

            // ── White content sheet that slides over the hero ───
            SliverToBoxAdapter(
              child: Container(
                // Pull the sheet up 24 px so it overlaps the hero bottom
                margin: const EdgeInsets.only(top: 0),
                decoration: const BoxDecoration(
                  color: _T.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, -4)),
                  ],
                ),
                // The drag-handle pill
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDD5E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading || _errorMessage != null ? null : _buildBottomBar(),
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 19, color: _T.textPri),
      ),
    );
  }

  // ── error ──────────────────────────────────────────────────────────────────
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _T.redFaint, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, size: 52, color: _T.red),
            ),
            const SizedBox(height: 20),
            const Text('Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _T.textPri)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'Unknown error', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: _T.textSec)),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _loadLessonData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: _T.teal,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── main content ───────────────────────────────────────────────────────────
  Widget _buildMainContent() {
    final totalSections     = _getAvailableSectionsCount();
    final completedSections = _isCurrentLessonComplete ? totalSections : _getViewedSectionsCount();
    final pct               = totalSections > 0 ? (completedSections / totalSections * 100).round() : 0;
    final isDone            = completedSections == totalSections && totalSections > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          lessonData['title'] ?? 'First Aid Lesson',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _T.textPri, height: 1.2),
        ),
        const SizedBox(height: 20),

        // Progress card
        if (totalSections > 0) ...[
          _buildProgressCard(completedSections, totalSections, pct, isDone),
          const SizedBox(height: 24),
        ],

        // ── Selectors ─────────────────────────────────────────────────────
        _buildSelectorLabel('Age Group', Icons.people_alt_rounded),
        const SizedBox(height: 8),
        _buildDropdown<String>(
          value: _selectedOption,
          items: _ageGroups,
          labelBuilder: (v) => v.toUpperCase(),
          onChanged: (val) async {
            setState(() {
              _selectedOption = val!;
              _expandedSections.updateAll((_, __) => false);
              _viewedSections.updateAll((_, __) => false);
              _selectedSubcategory = null; _selectedType = null;
              _subcategories = []; _types = []; _isLoading = true;
            });
            await _loadSubcategories();
            await _loadLessonData();
            if (_hasTypeSelector()) await _loadTypes();
          },
        ),

        if (_subcategories.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSelectorLabel('Subcategory', Icons.category_rounded),
          const SizedBox(height: 8),
          _isLoadingSubcategories
              ? _buildDropdownLoader()
              : _buildDropdown<String>(
            value: _selectedSubcategory,
            items: _subcategories,
            labelBuilder: (v) => v,
            onChanged: (val) async {
              setState(() { _selectedSubcategory = val; _expandedSections.updateAll((_, __) => false); _viewedSections.updateAll((_, __) => false); _selectedType = null; _isLoading = true; });
              await _loadLessonData();
            },
          ),
        ],

        if (_hasTypeSelector() && !_isLoading) ...[
          const SizedBox(height: 16),
          _buildSelectorLabel(_typeLabel(), _typeIcon(), required: _selectedType == null),
          const SizedBox(height: 8),
          _isLoadingTypes
              ? _buildDropdownLoader()
              : _buildDropdown<String>(
            value: _selectedType,
            items: _types,
            labelBuilder: (v) => v.replaceAll('_', ' ').toUpperCase(),
            hint: _typeRequiredHint(),
            isRequired: _selectedType == null,
            onChanged: (val) async {
              setState(() { _selectedType = val; _expandedSections.updateAll((_, __) => false); _viewedSections.updateAll((_, __) => false); _isLoading = true; });
              await _loadLessonData();
            },
          ),
          if (_selectedType == null) ...[
            const SizedBox(height: 10),
            _buildInfoBanner('Select a ${_typeLabel().toLowerCase()} to view lesson content.', Icons.info_outline_rounded, _T.orange, _T.orangeFaint),
          ],
          const SizedBox(height: 24),
        ] else const SizedBox(height: 8),

        // ── Lesson sections ────────────────────────────────────────────────
        if (!_hasTypeSelector() || (_hasTypeSelector() && _selectedType != null)) ...[
          _buildLessonSections(),
          const SizedBox(height: 16),
          _buildCompletionNote(),
        ],
      ],
    );
  }

  // ── progress card ──────────────────────────────────────────────────────────
  Widget _buildProgressCard(int done, int total, int pct, bool isDone) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDone ? _T.tealFaint : Colors.white,
        borderRadius: _T.r16,
        border: Border.all(color: isDone ? _T.teal : _T.divider),
        boxShadow: _T.shadow1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(isDone ? Icons.verified_rounded : Icons.auto_stories_rounded,
                  color: isDone ? _T.teal : _T.textSec, size: 20),
              const SizedBox(width: 8),
              Text(isDone ? 'Lesson Complete!' : 'Reading Progress',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: isDone ? _T.teal : _T.textSec)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? _T.teal : _T.blueFaint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$pct%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: isDone ? Colors.white : _T.blue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 7,
              backgroundColor: isDone ? _T.tealLight.withOpacity(0.4) : _T.divider,
              valueColor: AlwaysStoppedAnimation<Color>(isDone ? _T.teal : _T.blue),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$done of $total sections viewed',
                  style: const TextStyle(fontSize: 13, color: _T.textSec)),
            ],
          ),
        ],
      ),
    );
  }

  // ── selector label ─────────────────────────────────────────────────────────
  Widget _buildSelectorLabel(String label, IconData icon, {bool required = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: required ? _T.orange : _T.teal),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: required ? _T.orange : _T.textPri,
              letterSpacing: 0.3,
            )),
        if (required) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: _T.orangeFaint, borderRadius: BorderRadius.circular(6)),
            child: const Text('REQUIRED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _T.orange)),
          ),
        ],
      ],
    );
  }

  // ── dropdown ───────────────────────────────────────────────────────────────
  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
    String? hint,
    bool isRequired = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _T.r12,
        border: Border.all(
          color: isRequired ? _T.orange.withOpacity(0.5) : _T.divider,
          width: isRequired ? 1.5 : 1,
        ),
        boxShadow: _T.shadow1,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _T.textSec),
          hint: hint != null
              ? Text(hint, style: const TextStyle(fontSize: 15, color: _T.textSec))
              : null,
          onChanged: onChanged,
          items: items.map((v) => DropdownMenuItem(
            value: v,
            child: Text(labelBuilder(v),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _T.textPri)),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildDropdownLoader() {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: Colors.white, borderRadius: _T.r12, boxShadow: _T.shadow1),
      child: const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _T.teal))),
    );
  }

  // ── info banner ────────────────────────────────────────────────────────────
  Widget _buildInfoBanner(String msg, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: _T.r12,
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: TextStyle(fontSize: 13, color: color))),
        ],
      ),
    );
  }

  // ── all lesson sections ────────────────────────────────────────────────────
  Widget _buildLessonSections() {
    bool hasList(String k) => lessonData[k] is List && (lessonData[k] as List).isNotEmpty;
    return Column(
      children: [
        if ((lessonData['overview'] ?? '').toString().isNotEmpty) ...[
          _buildSection(
            key: 'description', title: 'Description', icon: Icons.menu_book_rounded,
            accentColor: _T.blue, accentFaint: _T.blueFaint,
            child: Text(lessonData['overview'], style: const TextStyle(fontSize: 15, height: 1.6, color: _T.textSec)),
          ),
          const SizedBox(height: 12),
        ],
        if (hasList('preventive methods')) ...[
          _buildSection(
            key: 'preventive_methods', title: 'Preventive Methods', icon: Icons.shield_outlined,
            accentColor: _T.green, accentFaint: _T.greenFaint,
            child: _buildBulletList(lessonData['preventive methods'], Icons.check_circle_outline_rounded, _T.green),
          ),
          const SizedBox(height: 12),
        ],
        if (hasList('precautions')) ...[
          _buildSection(
            key: 'precautions', title: 'Precautions', icon: Icons.warning_amber_rounded,
            accentColor: _T.orange, accentFaint: _T.orangeFaint,
            child: _buildBulletList(lessonData['precautions'], Icons.error_outline_rounded, _T.orange),
          ),
          const SizedBox(height: 12),
        ],
        if (hasList('symptoms')) ...[
          _buildSection(
            key: 'symptoms', title: 'Symptoms', icon: Icons.sick_outlined,
            accentColor: _T.purple, accentFaint: _T.purpleFaint,
            child: _buildBulletList(lessonData['symptoms'], Icons.fiber_manual_record, _T.purple),
          ),
          const SizedBox(height: 12),
        ],
        if (hasList('first aid steps')) ...[
          _buildSection(
            key: 'first_aid_steps', title: 'First Aid Steps', icon: Icons.medical_services_outlined,
            accentColor: _T.teal, accentFaint: _T.tealFaint,
            child: _buildStepsList(lessonData['first aid steps']),
          ),
          const SizedBox(height: 12),
        ],
        if (hasList('do')) ...[
          _buildSection(
            key: 'do', title: 'Do', icon: Icons.thumb_up_alt_outlined,
            accentColor: _T.green, accentFaint: _T.greenFaint,
            child: _buildBulletList(lessonData['do'], Icons.check_rounded, _T.green),
          ),
          const SizedBox(height: 12),
        ],
        if (hasList('dont')) ...[
          _buildSection(
            key: 'dont', title: "Don't", icon: Icons.thumb_down_alt_outlined,
            accentColor: _T.red, accentFaint: _T.redFaint,
            child: _buildBulletList(lessonData['dont'], Icons.close_rounded, _T.red),
          ),
          const SizedBox(height: 12),
        ],
        if (hasList('when to seek help')) ...[
          _buildSection(
            key: 'when_to_seek_help', title: 'When to Seek Help', icon: Icons.local_hospital_outlined,
            accentColor: _T.red, accentFaint: _T.redFaint,
            child: _buildBulletList(lessonData['when to seek help'], Icons.local_hospital_rounded, _T.red),
          ),
        ],
      ],
    );
  }

  // ── collapsible section ────────────────────────────────────────────────────
  Widget _buildSection({
    required String key,
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color accentFaint,
    required Widget child,
  }) {
    final isExpanded = _expandedSections[key] ?? false;
    final isViewed   = _viewedSections[key]   ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _T.r16,
        border: Border.all(
          color: isViewed ? accentColor.withOpacity(0.4) : _T.divider,
          width: isViewed ? 1.5 : 1,
        ),
        boxShadow: _T.shadow1,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleSection(key),
            borderRadius: _T.r16,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // icon pill
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: accentFaint, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: isViewed ? accentColor : _T.textPri)),
                  ),
                  if (isViewed)
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: accentColor.withOpacity(0.12), shape: BoxShape.circle),
                      child: Icon(Icons.check_rounded, size: 14, color: accentColor),
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: _T.textSec, size: 24),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: _T.divider),
                Padding(padding: const EdgeInsets.all(16), child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── bullet list ────────────────────────────────────────────────────────────
  Widget _buildBulletList(List items, IconData icon, Color color) {
    return Column(
      children: items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 24, height: 24,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(item.toString(),
                  style: const TextStyle(fontSize: 14, color: _T.textSec, height: 1.55))),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── steps list ─────────────────────────────────────────────────────────────
  Widget _buildStepsList(List steps) {
    return Column(
      children: steps.asMap().entries.map<Widget>((entry) {
        final step = entry.value is Map
            ? entry.value as Map<String, dynamic>
            : {'number': entry.key + 1, 'title': 'Step ${entry.key + 1}', 'description': entry.value.toString(), 'completed': false};
        return _buildStepCard(step);
      }).toList(),
    );
  }

  Widget _buildStepCard(Map<String, dynamic> step) {
    final isDone = step['completed'] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone ? _T.greenFaint : _T.bg,
          borderRadius: _T.r12,
          border: Border.all(color: isDone ? _T.green.withOpacity(0.3) : _T.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDone ? _T.green : _T.teal,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : Text('${step['number'] ?? ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step['title'] ?? '',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _T.textPri)),
                  const SizedBox(height: 4),
                  Text(step['description'] ?? '',
                      style: const TextStyle(fontSize: 13, color: _T.textSec, height: 1.5)),
                  if (isDone) ...[
                    const SizedBox(height: 6),
                    Row(children: const [
                      Icon(Icons.check_circle_rounded, size: 14, color: _T.green),
                      SizedBox(width: 4),
                      Text('Completed', style: TextStyle(fontSize: 12, color: _T.green, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── completion note ────────────────────────────────────────────────────────
  Widget _buildCompletionNote() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _T.tealFaint,
        borderRadius: _T.r12,
        border: Border.all(color: _T.tealLight),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline_rounded, color: _T.teal, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tap the green ✓ button below once you\'ve read all sections to mark this lesson complete.',
              style: TextStyle(fontSize: 13, color: _T.tealDark, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  // ── bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.green.shade300, blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button — same size/shape as the tick button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),

            // Take Quiz
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizPage(lessonId: widget.id, lessonTitle: lessonData['title'] ?? 'Quiz')),
                ),
                icon: const Icon(Icons.quiz_outlined, size: 20),
                label: const Text('Take Quiz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _T.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Mark complete
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: ElevatedButton(
                onPressed: _isCompleting || _isCurrentLessonComplete ? null : _markCurrentLessonComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCurrentLessonComplete ? Colors.green.shade300 : Colors.green,
                  disabledBackgroundColor: _isCurrentLessonComplete ? Colors.green.shade300 : Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isCompleting
                    ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Icon(
                    _isCurrentLessonComplete ? Icons.check_circle_rounded : Icons.check_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}