// Enhanced tag-based sub-category mapping
// Maps consolidated categories to their original sub-categories via tags

class SubCategoryMapper {
  static const Map<String, List<SubCategory>> categoryToSubCategories = {
    'Work & Career': [
      SubCategory(id: 'academic-stress', name: 'Academic Pressure', icon: '📚'),
      SubCategory(id: 'job-security', name: 'Job Security', icon: '🔒'),
      SubCategory(id: 'career-growth', name: 'Career Growth', icon: '📈'),
      SubCategory(id: 'business', name: 'Business', icon: '💼'),
      SubCategory(id: 'side-hustle', name: 'Side Hustles', icon: '⚡'),
      SubCategory(id: 'work-balance', name: 'Work-Life Balance', icon: '⚖️'),
    ],
    'Relationships': [
      SubCategory(id: 'dating', name: 'Dating & Apps', icon: '💕'),
      SubCategory(id: 'marriage', name: 'Marriage', icon: '💍'),
      SubCategory(id: 'romantic', name: 'Romance', icon: '❤️'),
      SubCategory(id: 'friendship', name: 'Friendship', icon: '👥'),
      SubCategory(id: 'family-relations', name: 'Family Dynamics', icon: '👨‍👩‍👧‍👦'),
    ],
    'Parenting & Family': [
      SubCategory(id: 'new-parent', name: 'New Parents', icon: '🍼'),
      SubCategory(id: 'pregnancy', name: 'Pregnancy', icon: '🤰'),
      SubCategory(id: 'child-care', name: 'Child Care', icon: '👶'),
      SubCategory(id: 'family-dynamics', name: 'Family Life', icon: '🏠'),
      SubCategory(id: 'elder-care', name: 'Elder Care', icon: '👴'),
    ],
    'Personal Growth': [
      SubCategory(id: 'self-discovery', name: 'Identity & Purpose', icon: '🔍'),
      SubCategory(id: 'habits', name: 'Habits & Discipline', icon: '🎯'),
      SubCategory(id: 'mental-wellness', name: 'Mental Health', icon: '🧘'),
      SubCategory(id: 'personal-development', name: 'Self-Improvement', icon: '🌱'),
      SubCategory(id: 'mindfulness', name: 'Mindfulness', icon: '🧘‍♀️'),
    ],
    'Life Transitions': [
      SubCategory(id: 'milestones', name: 'Life Milestones', icon: '🎯'),
      SubCategory(id: 'major-decisions', name: 'Big Decisions', icon: '🤔'),
      SubCategory(id: 'separation', name: 'Divorce & Separation', icon: '💔'),
      SubCategory(id: 'life-planning', name: 'Life Planning', icon: '📅'),
    ],
    'Social & Community': [
      SubCategory(id: 'isolation', name: 'Loneliness', icon: '😔'),
      SubCategory(id: 'social-expectations', name: 'Social Pressure', icon: '👥'),
      SubCategory(id: 'neurodivergent', name: 'Neurodiversity', icon: '🧠'),
      SubCategory(id: 'spirituality', name: 'Spiritual Life', icon: '🕉️'),
      SubCategory(id: 'community', name: 'Community Building', icon: '🏘️'),
    ],
    'Health & Wellness': [
      SubCategory(id: 'body-image', name: 'Body Confidence', icon: '💪'),
      SubCategory(id: 'digital-balance', name: 'Digital Wellness', icon: '📱'),
      SubCategory(id: 'eco-anxiety', name: 'Climate Anxiety', icon: '🌍'),
      SubCategory(id: 'physical-health', name: 'Physical Health', icon: '🏃'),
      SubCategory(id: 'mental-wellbeing', name: 'Mental Wellbeing', icon: '😌'),
    ],
    'Financial': [
      SubCategory(id: 'budgeting', name: 'Budgeting', icon: '💰'),
      SubCategory(id: 'financial-planning', name: 'Financial Planning', icon: '📊'),
      SubCategory(id: 'economic-stress', name: 'Economic Stress', icon: '😰'),
      SubCategory(id: 'wealth-building', name: 'Wealth Building', icon: '🏦'),
    ],
    'Education & Learning': [
      SubCategory(id: 'academic', name: 'Academic Success', icon: '🎓'),
      SubCategory(id: 'learning', name: 'Learning Goals', icon: '📖'),
      SubCategory(id: 'skill-development', name: 'Skill Development', icon: '🛠️'),
      SubCategory(id: 'education-planning', name: 'Education Planning', icon: '📚'),
    ],
    'Modern Living': [
      SubCategory(id: 'technology', name: 'Technology', icon: '💻'),
      SubCategory(id: 'lifestyle', name: 'Lifestyle', icon: '🌟'),
      SubCategory(id: 'modern-challenges', name: 'Modern Challenges', icon: '🏙️'),
      SubCategory(id: 'contemporary-issues', name: 'Contemporary Issues', icon: '📰'),
    ],
  };

  /// Get sub-categories for a main category
  static List<SubCategory> getSubCategories(String mainCategory) {
    return categoryToSubCategories[mainCategory] ?? [];
  }

  /// Check if a scenario matches a sub-category based on tags
  static bool scenarioMatchesSubCategory(dynamic scenario, String subCategoryId) {
    if (scenario.tags == null || scenario.tags.isEmpty) return false;
    
    // Check if any of the scenario's tags contain the sub-category identifier
    return scenario.tags.any((tag) => 
      tag.toLowerCase().contains(subCategoryId.toLowerCase()) ||
      tag.toLowerCase().contains(subCategoryId.replaceAll('-', '_').toLowerCase()) ||
      tag.toLowerCase().contains(subCategoryId.replaceAll('-', ' ').toLowerCase())
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final String icon;

  const SubCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}