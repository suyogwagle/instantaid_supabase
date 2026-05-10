import 'package:supabase_flutter/supabase_flutter.dart';

class FirstAidService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch available subcategories for a specific age group
  Future<List<String>> getSubcategories({
    required int id,
    required String ageGroup,
  }) async {
    try {
      print('🔍 Fetching subcategories for id: $id, ageGroup: $ageGroup');

      // First get the category name from the id
      final categoryResponse = await _supabase
          .from('first_aid_categoryy')
          .select('category')
          .eq('id', id)
          .limit(1)
          .single();

      final categoryName = categoryResponse['category'];
      print('📋 Category name: $categoryName');

      // Get categories with subcategory details
      final response = await _supabase
          .from('first_aid_categoryy')
          .select('first_aid_sub_categories(sub_category)')
          .eq('category', categoryName)
          .eq('age_group', ageGroup)
          .not('sub_category', 'is', null);

      if (response == null || response.isEmpty) {
        print('ℹ️ No subcategories found');
        return [];
      }

      // Extract unique subcategory names
      final subcategoryNames = <String>{};
      for (var item in response) {
        if (item['first_aid_sub_categories'] != null) {
          final subcat = item['first_aid_sub_categories']['sub_category'];
          if (subcat != null && subcat.toString().isNotEmpty) {
            subcategoryNames.add(subcat.toString());
          }
        }
      }

      final result = subcategoryNames.toList();
      print('✅ Subcategories: $result');
      return result;
    } catch (e) {
      print('❌ Error fetching subcategories: $e');
      return [];
    }
  }

  // Fetch available category types for a specific category
  Future<List<String>> getCategoryTypes({
    required int id,
    required String ageGroup,
  }) async {
    try {
      print('🔍 Fetching category types for id: $id, ageGroup: $ageGroup');

      // First get the category name from the id
      final categoryResponse = await _supabase
          .from('first_aid_categoryy')
          .select('category')
          .eq('id', id)
          .limit(1)
          .single();

      final categoryName = categoryResponse['category'];

      // Get categories with category type details
      final response = await _supabase
          .from('first_aid_categoryy')
          .select('first_aid_category_type(type)')
          .eq('category', categoryName)
          .eq('age_group', ageGroup)
          .not('type', 'is', null);

      if (response == null || response.isEmpty) {
        print('ℹ️ No category types found');
        return [];
      }

      // Extract unique category type names
      final categoryTypeNames = <String>{};
      for (var item in response) {
        if (item['first_aid_category_type'] != null) {
          final typeValue = item['first_aid_category_type']['type'];
          if (typeValue != null && typeValue.toString().isNotEmpty) {
            categoryTypeNames.add(typeValue.toString());
          }
        }
      }

      final result = categoryTypeNames.toList();
      print('✅ Category Types: $result');
      return result;
    } catch (e) {
      print('❌ Error fetching category types: $e');
      return [];
    }
  }

  // Fetch complete lesson data with optional subcategory and categoryType filters
  Future<Map<String, dynamic>> getLessonData({
    required int id,
    required String ageGroup,
    String? subcategory,
    String? categoryType,
    required String category,
  }) async {
    try {
      print('\n🔍 === FETCHING LESSON DATA ===');
      print('  Initial ID: $id');
      print('  Age Group: $ageGroup');
      print('  Subcategory: ${subcategory ?? 'none'}');
      print('  Category Type: ${categoryType ?? 'none'}');
      print('================================\n');

      // Use the passed category name directly
      final categoryName = category;
      print('📋 Category name: $categoryName');

      // Build query by category name, age group, and optional filters
      var query = _supabase
          .from('first_aid_categoryy')
          .select('''
            id,
            category,
            sub_category,
            type,
            age_group,
            first_aid_sub_categories(id, sub_category, description),
            first_aid_category_type(type)
          ''')
          .eq('category', categoryName)
          .eq('age_group', ageGroup);

      int? subcategoryId;
      int? categoryTypeId;

      // Get subcategory ID if provided
      if (subcategory != null && subcategory.isNotEmpty) {
        print('🔎 Looking for subcategory: "$subcategory"');

        final subcategoryResponse = await _supabase
            .from('first_aid_sub_categories')
            .select('id, sub_category')
            .eq('sub_category', subcategory)
            .maybeSingle();

        if (subcategoryResponse != null) {
          subcategoryId = subcategoryResponse['id'] as int;
          print('✅ Found subcategory ID: $subcategoryId');
        } else {
          print('⚠️ Subcategory "$subcategory" not found');
        }
      }

      // Get category type ID if provided
      if (categoryType != null && categoryType.isNotEmpty) {
        print('🔎 Looking for category type: "$categoryType"');

        final categoryTypeResponse = await _supabase
            .from('first_aid_category_type')
            .select('id, type')
            .eq('type', categoryType)
            .maybeSingle();

        if (categoryTypeResponse != null) {
          categoryTypeId = categoryTypeResponse['id'] as int;
          print('✅ Found category type ID: $categoryTypeId');
        } else {
          print('⚠️ Category type "$categoryType" not found');
        }
      }

      // Apply filters
      if (subcategoryId != null) {
        query = query.eq('sub_category', subcategoryId);
        print('🔧 Applied subcategory filter: $subcategoryId');
      }

      if (categoryTypeId != null) {
        query = query.eq('type', categoryTypeId);
        print('🔧 Applied category type filter: $categoryTypeId');
      }

      // Execute query
      print('🔍 Executing query...');

      dynamic categoryResponse;

      try {
        // Try to get a single result
        categoryResponse = await query.maybeSingle();
      } catch (e) {
        // If multiple rows are returned (406 error), get the first one
        if (e.toString().contains('406') || e.toString().contains('multiple')) {
          print('⚠️ Multiple rows found, getting first match...');
          final results = await query.limit(1);
          categoryResponse = results.isNotEmpty ? results.first : null;
        } else {
          rethrow;
        }
      }

      if (categoryResponse == null) {
        print('❌ No match found');
        throw Exception(
            'No lesson found for:\n'
                '  - Category: "$categoryName"\n'
                '  - Age Group: "$ageGroup"\n'
                '  - Subcategory: "${subcategory ?? 'none'}"\n'
                '  - Type: "${categoryType ?? 'none'}"\n\n'
                'Please check your selections.');
      }

      print('✅ Found matching category with ID: ${categoryResponse['id']}');

      // Use the actual category ID from the response
      final actualCategoryId = categoryResponse['id'];

      // Fetch all content for this category
      final contentResponse = await _supabase
          .from('first_aid_content')
          .select('''
            id,
            category_id,
            section_id,
            description,
            first_aid_content_sections(id, section)
          ''')
          .eq('category_id', actualCategoryId);

      print('📝 Content response count: ${contentResponse.length}');

      // Organize content by sections
      Map<String, dynamic> organizedData = {
        'title': categoryResponse['category'] ?? 'Unknown',
        'subCategory': categoryResponse['first_aid_sub_categories']?['sub_category'] ?? '',
        'subCategoryDescription': categoryResponse['first_aid_sub_categories']?['description'] ?? '',
        'type': categoryResponse['first_aid_category_type']?['type'] ?? '',
        'ageGroup': categoryResponse['age_group'] ?? '',
        'completedSections': 0,
        'totalSections': 0,
      };

      // Initialize section containers
      Map<String, dynamic> sections = {
        'overview': null,
        'preventive methods': [],
        'precautions': [],
        'symptoms': [],
        'first aid steps': [],
        'do': [],
        'dont': [],
        'warning': [],
        'when to seek help': [],
      };

      // Process each content item
      for (var content in contentResponse) {
        if (content['first_aid_content_sections'] == null) {
          print('⚠️ Content ID ${content['id']} has no section data');
          continue;
        }

        String sectionName =
        content['first_aid_content_sections']['section'].toString().toLowerCase();
        String description = content['description'] ?? '';

        print('📌 Processing section: $sectionName');

        switch (sectionName) {
          case 'overview':
            sections['overview'] = description;
            break;
          case 'preventive methods':
            sections['preventive methods'] = _parseListContent(description);
            break;
          case 'precautions':
            sections['precautions'] = _parseListContent(description);
            break;
          case 'symptoms':
            sections['symptoms'] = _parseListContent(description);
            break;
          case 'first aid steps':
            sections['first aid steps'] = _parseStepsContent(description);
            break;
          case 'do':
            sections['do'] = _parseListContent(description);
            break;
          case 'dont':
            sections['dont'] = _parseListContent(description);
            break;
          case 'warning':
            sections['warning'] = _parsewarningsContent(description);
            break;
          case 'when to seek help':
            sections['when to seek help'] = _parseListContent(description);
            break;
          default:
            print('⚠️ Unknown section: $sectionName');
        }
      }

      // Add all sections to organized data
      organizedData['overview'] = sections['overview'] ?? 'No overview available.';
      organizedData['preventive methods'] = sections['preventive methods'];
      organizedData['precautions'] = sections['precautions'];
      organizedData['symptoms'] = sections['symptoms'];
      organizedData['first aid steps'] = sections['first aid steps'];
      organizedData['do'] = sections['do'];
      organizedData['dont'] = sections['dont'];
      organizedData['warning'] = sections['warning'];
      organizedData['when to seek help'] = sections['when to seek help'];

      // Calculate total sections
      int totalSections = 0;
      if (sections['overview'] != null) totalSections++;
      if ((sections['preventive methods'] as List).isNotEmpty) totalSections++;
      if ((sections['precautions'] as List).isNotEmpty) totalSections++;
      if ((sections['symptoms'] as List).isNotEmpty) totalSections++;
      if ((sections['first aid steps'] as List).isNotEmpty) totalSections++;
      if ((sections['do'] as List).isNotEmpty) totalSections++;
      if ((sections['dont'] as List).isNotEmpty) totalSections++;
      if ((sections['warning'] as List).isNotEmpty) totalSections++;
      if ((sections['when to seek help'] as List).isNotEmpty) totalSections++;

      organizedData['totalSections'] = totalSections > 0 ? totalSections : 1;

      print('✅ Successfully organized data with $totalSections sections\n');

      return organizedData;
    } catch (e, stackTrace) {
      print('❌ Error fetching lesson data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Fetch all categories with their sub-categories and types
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await _supabase
          .from('first_aid_categoryy')
          .select('''
            id,
            category,
            sub_category,
            type,
            age_group,
            first_aid_sub_categories(sub_category),
            first_aid_category_type(type)
          ''')
          .order('category');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  // Fetch categories by age group
  Future<List<Map<String, dynamic>>> getCategoriesByAgeGroup(String ageGroup) async {
    try {
      final response = await _supabase
          .from('first_aid_categoryy')
          .select('''
            id,
            category,
            sub_category,
            type,
            age_group,
            first_aid_sub_categories(sub_category),
            first_aid_category_type(type)
          ''')
          .eq('age_group', ageGroup)
          .order('category');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching categories by age group: $e');
      rethrow;
    }
  }

  // Parse list content (bullet points or newlines)
  List<String> _parseListContent(String content) {
    if (content.isEmpty) return [];

    return content
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.replaceFirst(RegExp(r'^[-•*]\s*'), ''))
        .map((e) => e.replaceFirst(RegExp(r'^\d+\.\s*'), ''))
        .toList();
  }

  // Parse steps with title and description
  List<Map<String, dynamic>> _parseStepsContent(String content) {
    if (content.isEmpty) return [];

    final lines = content.split('\n').where((e) => e.trim().isNotEmpty).toList();
    final steps = <Map<String, dynamic>>[];
    int stepNumber = 1;

    for (String line in lines) {
      String cleanLine = line.trim();
      cleanLine = cleanLine.replaceFirst(RegExp(r'^[-•*]\s*'), '');
      cleanLine = cleanLine.replaceFirst(RegExp(r'^\d+\.\s*'), '');

      final parts = cleanLine.split(RegExp(r'[:\-]', multiLine: false));
      String title;
      String description;

      if (parts.length > 1) {
        title = parts[0].trim();
        description = parts.sublist(1).join(':').trim();
      } else {
        title = 'Step $stepNumber';
        description = cleanLine;
      }

      steps.add({
        'number': stepNumber,
        'title': title,
        'description': description,
        'completed': false,
      });

      stepNumber++;
    }

    return steps;
  }

  // Parse warnings with severity detection
  List<Map<String, dynamic>> _parsewarningsContent(String content) {
    if (content.isEmpty) return [];

    final lines = content.split('\n').where((e) => e.trim().isNotEmpty).toList();
    final warnings = <Map<String, dynamic>>[];

    for (String line in lines) {
      String message = line.trim();
      String severity = 'medium';

      final lowerLine = message.toLowerCase();
      if (lowerLine.contains('critical') ||
          lowerLine.contains('emergency') ||
          lowerLine.contains('911') ||
          lowerLine.contains('immediately')) {
        severity = 'critical';
      } else if (lowerLine.contains('important') ||
          lowerLine.contains('serious') ||
          lowerLine.contains('danger') ||
          lowerLine.contains('do not')) {
        severity = 'high';
      }

      message = message.replaceFirst(RegExp(r'^[-•*]\s*'), '');
      message = message.replaceFirst(
          RegExp(r'^(critical|high|medium):\s*', caseSensitive: false), '');

      warnings.add({'severity': severity, 'message': message});
    }

    return warnings;
  }

  Future<void> debugSpecificCategory(int id) async {
    try {
      print('\n🔍 === DEBUGGING CATEGORY ID: $id ===');

      final allWithId =
      await _supabase.from('first_aid_categoryy').select('*').eq('id', id);
      print('Records with ID $id: $allWithId');

      final allAgeGroups = await _supabase
          .from('first_aid_categoryy')
          .select('id, category, age_group')
          .order('id');
      print('All available categories and age groups: $allAgeGroups');

      print('=== END DEBUG ===\n');
    } catch (e) {
      print('❌ Debug failed: $e');
    }
  }
}