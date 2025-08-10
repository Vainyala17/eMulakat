// import 'package:flutter/material.dart';
//
// import '../../models/visitor_model.dart';
// import '../../utils/color_scheme.dart';
//
// class HorizontalVisitCard extends StatelessWidget {
//   final VisitorModel visitor;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const HorizontalVisitCard({
//     Key? key,
//     required this.visitor,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);
//
//   Color statusColor(VisitStatus status) {
//     switch (status) {
//       case VisitStatus.approved:
//         return Color(0xFF4CAF50);
//       case VisitStatus.rejected:
//         return Color(0xFFE53E3E);
//       case VisitStatus.pending:
//         return Color(0xFFFF9800);
//     }
//   }
//
//   Color statusBackgroundColor(VisitStatus status) {
//     switch (status) {
//       case VisitStatus.approved:
//         return Color(0xFF4CAF50).withOpacity(0.1);
//       case VisitStatus.rejected:
//         return Color(0xFFE53E3E).withOpacity(0.1);
//       case VisitStatus.pending:
//         return Color(0xFFFF9800).withOpacity(0.1);
//     }
//   }
//
//   IconData statusIcon(VisitStatus status) {
//     switch (status) {
//       case VisitStatus.approved:
//         return Icons.check_circle;
//       case VisitStatus.rejected:
//         return Icons.cancel;
//       case VisitStatus.pending:
//         return Icons.schedule;
//     }
//   }
//
//   String getStatusText(VisitStatus status) {
//     switch (status) {
//       case VisitStatus.approved:
//         return 'Approved';
//       case VisitStatus.rejected:
//         return 'Rejected';
//       case VisitStatus.pending:
//         return 'Pending';
//     }
//   }
//
//   String getDayOfWeek(DateTime date) {
//     const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
//     return days[date.weekday - 1];
//   }
//
//   String getMonthName(DateTime date) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return months[date.month - 1];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         curve: Curves.easeInOut,
//         width: 170,
//         margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isSelected
//                 ? [Color(0xFF3B6C99), Color(0xFF5A8BBA)] // darker active colors
//                 : [Colors.white, Color(0xFFF8F9FA)],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: isSelected
//                   ? Color(0xFF5A8BBA).withOpacity(0.4)
//                   : Colors.grey.withOpacity(0.2),
//               blurRadius: isSelected ? 12 : 8,
//               offset: Offset(0, isSelected ? 6 : 4),
//               spreadRadius: isSelected ? 2 : 0,
//             )
//           ],
//           border: Border.all(
//             color: Color(0xFF5A8BBA),
//             width: isSelected ? 3 : 2,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Status Badge
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: statusBackgroundColor(visitor.status),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: statusColor(visitor.status),
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       statusIcon(visitor.status),
//                       size: 15,
//                       color: statusColor(visitor.status),
//                     ),
//                     SizedBox(width: 4),
//                     Text(
//                       getStatusText(visitor.status),
//                       style: TextStyle(
//                         color: statusColor(visitor.status),
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Date Information
//               Column(
//                 children: [
//                   Text(
//                     getDayOfWeek(visitor.visitDate),
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: isSelected ? Colors.black : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? Colors.white.withOpacity(0.2)
//                           : Color(0xFF5A8BBA).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       visitor.visitDate.day.toString().padLeft(2, '0'),
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: isSelected ? Colors.white : Color(0xFF5A8BBA),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     getMonthName(visitor.visitDate),
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: isSelected ? Colors.black : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     visitor.visitDate.year.toString(),
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: isSelected ? Colors.black : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 2),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }