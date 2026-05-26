// // ==========================================================
// // SEARCH SCREEN - PREMIUM ADAPTIVE (CHIPS & GRID)
// // ==========================================================

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:eternia_ef/providers/theme_provider.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final _searchController = TextEditingController();
//   String _query = "";
//   int _selectedCategoryIndex = 0;

//   final List<Map<String, dynamic>> _categories = [
//     {"title": "All", "icon": Icons.all_inclusive},
//     {"title": "Counselors", "icon": Icons.psychology_outlined},
//     {"title": "Peer Groups", "icon": Icons.people_outline},
//     {"title": "Meditations", "icon": Icons.spa_outlined},
//     {"title": "Articles", "icon": Icons.article_outlined},
//   ];

//   final List<String> _recent = ["Anxiety management", "Sleep meditation", "Dr. Aria Vance", "Breathing techniques"];

//   final List<Map<String, dynamic>> _trending = [
//     {"title": "Overcoming Social Anxiety", "type": "Article", "image": Icons.menu_book, "color": const Color(0xFF53B29A)},
//     {"title": "Deep Sleep Sounds", "type": "Audio", "image": Icons.headphones, "color": const Color(0xFF42A5F5)},
//     {"title": "Grief Support Group", "type": "Community", "image": Icons.people, "color": const Color(0xFFFFB300)},
//     {"title": "Morning Affirmations", "type": "Meditation", "image": Icons.wb_sunny, "color": const Color(0xFFE53935)},
//   ];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final bool isDark = themeProvider.isDark;

//     final Color primaryColor = isDark ? const Color(0xFF67F5D4) : const Color(0xFF335848);
//     final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4);
//     final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);
//     final Color innerCardColor = isDark ? const Color(0xFF141D1F) : Colors.white;
//     final Color borderColor = isDark ? Colors.white.withValues(alpha:0.08) : const Color(0xFFE7E2D8);

//     final query = _query.trim().toLowerCase();
//     final recent = query.isEmpty
//         ? _recent
//         : _recent.where((term) => term.toLowerCase().contains(query)).toList();

//     return Scaffold(
//       backgroundColor: bg,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                 child: _buildHeader(context, textColor, primaryColor),
//               ),
//               const SizedBox(height: 8),

//               // SEARCH BAR
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: innerCardColor,
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(color: borderColor),
//                     boxShadow: [
//                       if (!isDark) BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 4))
//                     ]
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.search, color: isDark ? Colors.grey[500] : Colors.grey[600], size: 20),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextField(
//                           controller: _searchController,
//                           onChanged: (value) => setState(() => _query = value),
//                           style: GoogleFonts.poppins(color: textColor, fontSize: 14),
//                           decoration: InputDecoration(
//                             hintText: "Search for peace...",
//                             hintStyle: GoogleFonts.poppins(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 14),
//                             border: InputBorder.none,
//                             contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                         ),
//                       ),
//                       if (_query.isNotEmpty)
//                         GestureDetector(
//                           onTap: () {
//                             _searchController.clear();
//                             setState(() => _query = "");
//                           },
//                           child: Icon(Icons.close, color: isDark ? Colors.grey[500] : Colors.grey[600], size: 20),
//                         )
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // CATEGORY CHIPS
//               SizedBox(
//                 height: 48,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   itemCount: _categories.length,
//                   itemBuilder: (context, index) {
//                     final cat = _categories[index];
//                     final isSelected = _selectedCategoryIndex == index;
//                     return GestureDetector(
//                       onTap: () => setState(() => _selectedCategoryIndex = index),
//                       child: Container(
//                         margin: const EdgeInsets.only(right: 12),
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         decoration: BoxDecoration(
//                           color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha:0.05) : Colors.white),
//                           borderRadius: BorderRadius.circular(24),
//                           border: Border.all(color: isSelected ? primaryColor : borderColor),
//                         ),
//                         alignment: Alignment.center,
//                         child: Row(
//                           children: [
//                             Icon(cat["icon"] as IconData, color: isSelected ? (isDark ? const Color(0xFF071011) : Colors.white) : primaryColor, size: 16),
//                             const SizedBox(width: 8),
//                             Text(
//                               cat["title"] as String,
//                               style: GoogleFonts.poppins(
//                                 color: isSelected ? (isDark ? const Color(0xFF071011) : Colors.white) : textColor,
//                                 fontSize: 13,
//                                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // RECENT SEARCHES
//               if (recent.isNotEmpty) ...[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: _buildSectionTitle("RECENT SEARCHES", primaryColor),
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Wrap(
//                     spacing: 10,
//                     runSpacing: 10,
//                     children: recent.map((term) => GestureDetector(
//                       onTap: () {
//                         _searchController.text = term;
//                         _searchController.selection = TextSelection.collapsed(offset: term.length);
//                         setState(() => _query = term);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: innerCardColor,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: borderColor),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.history, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 14),
//                             const SizedBox(width: 8),
//                             Text(term, style: GoogleFonts.poppins(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 11)),
//                           ],
//                         ),
//                       ),
//                     )).toList(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//               ],

//               // TRENDING CARDS
//               if (_query.isEmpty) ...[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: _buildSectionTitle("TRENDING NOW", primaryColor),
//                 ),
//                 const SizedBox(height: 16),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   itemCount: _trending.length,
//                   itemBuilder: (context, index) {
//                     final item = _trending[index];
//                     final Color cardColor = item["color"] as Color;
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: innerCardColor,
//                           borderRadius: BorderRadius.circular(24),
//                           border: Border.all(color: borderColor),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               height: 60, width: 60,
//                               decoration: BoxDecoration(
//                                 color: cardColor.withValues(alpha:0.15),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Icon(item["image"] as IconData, color: cardColor, size: 28),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.grey.withValues(alpha:0.1),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(item["type"] as String, style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 9, fontWeight: FontWeight.bold)),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Text(item["title"] as String, style: GoogleFonts.poppins(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
//                                 ],
//                               ),
//                             ),
//                             Icon(Icons.arrow_forward_ios, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 16),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],

//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, Color textColor, Color primaryColor) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha:0.05),
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
//             ),
//             child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Discover", style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 38, height: 1.1, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text("Find resources, spaces, and guides.", style: GoogleFonts.poppins(color: primaryColor.withValues(alpha:0.7), fontSize: 13, fontWeight: FontWeight.w500)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title, Color color) {
//     return Text(title, style: GoogleFonts.poppins(color: color.withValues(alpha:0.6), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold));
//   }
// }
