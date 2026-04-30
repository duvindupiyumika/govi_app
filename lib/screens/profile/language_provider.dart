import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _selectedLang = "en"; 

  String get selectedLang => _selectedLang;

  void changeLanguage(String langCode) {
    print("------ Language is changing to: $langCode ------");
    _selectedLang = langCode;
    notifyListeners(); 
  }

  Map<String, String> get texts => localizedText[_selectedLang]!;

  static const Map<String, Map<String, String>> localizedText = {
    'en': {
      'profile_title': 'Profile',
      'account': 'Account',
      'manage_profile': 'Manage Profile',
      'notifications': 'Notifications',
      'language': 'Language',
      'lang_name': 'English',
      'preferences': 'Preferences',
      'about_us': 'About Us',
      'dark_mode': 'Dark Mode',
      'support': 'Support',
      'help_center': 'Help Center',
      'no_data': 'No Farmer Data Found',
      'personal_info': 'Personal Information',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'phone': 'Phone Number',
      'district': 'District (Region)',
      'save_changes': 'SAVE CHANGES',
      'update_success': 'Profile Updated Successfully! ✅',
      'update_failed': 'Update Failed:',
    },
    'si': {
      'profile_title': 'පැතිකඩ',
      'account': 'ගිණුම',
      'manage_profile': 'පැතිකඩ කළමනාකරණය',
      'notifications': 'දැනුම්දීම්',
      'language': 'භාෂාව',
      'lang_name': 'සිංහල',
      'preferences': 'මනාප',
      'about_us': 'අපි ගැන',
      'dark_mode': 'අඳුරු මාදිලිය',
      'support': 'සහාය',
      'help_center': 'උදවු මධ්‍යස්ථානය',
      'no_data': 'ගොවි දත්ත කිසිවක් හමුවූයේ නැත',
      'personal_info': 'පුද්ගලික තොරතුරු',
      'full_name': 'සම්පූර්ණ නම',
      'email': 'ඊමේල් ලිපිනය',
      'phone': 'දුරකථන අංකය',
      'district': 'දිස්ත්‍රික්කය (කලාපය)',
      'save_changes': 'වෙනස්කම් සුරකින්න',
      'update_success': 'පැතිකඩ සාර්ථකව යාවත්කාලීන කරන ලදී! ✅',
      'update_failed': 'යාවත්කාලීන කිරීම අසාර්ථකයි:',
    },
    'ta': {
      'profile_title': 'சுயவிவரம்',
      'account': 'கணக்கு',
      'manage_profile': 'சுயவிவரத்தை நிர்வகி',
      'notifications': 'அறிவிப்புகள்',
      'language': 'மொழி',
      'lang_name': 'தமிழ்',
      'preferences': 'விருப்பத்தேர்வுகள்',
      'about_us': 'எங்களைப் பற்றி',
      'dark_mode': 'இருண்ட பயன்முறை',
      'support': 'ஆதரவு',
      'help_center': 'உதவி மையம்',
      'no_data': 'விவசாயி தரவு எதுவும் கிடைக்கவில்லை',
      'personal_info': 'தனிப்பட்ட தகவல்',
      'full_name': 'முழு பெயர்',
      'email': 'மின்னஞ்சல் முகவரி',
      'phone': 'தொலைபேசி எண்',
      'district': 'மாவட்டம் (பகுதி)',
      'save_changes': 'மாற்றங்களைச் சேமிக்கவும்',
      'update_success': 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது! ✅',
      'update_failed': 'புதுப்பிப்பு தோல்வியடைந்தது:',
    },
  };
}