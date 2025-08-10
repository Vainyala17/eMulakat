// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
//
// import '../../models/visitor_model.dart';
// import 'horizontal_visit_card.dart';
//
// class VisitCardCarousel extends StatefulWidget {
//   final List<VisitorModel> visitors;
//   final ValueChanged<int> onTapCard;
//
//   const VisitCardCarousel({
//     Key? key,
//     required this.visitors,
//     required this.onTapCard,
//   }) : super(key: key);
//
//   @override
//   State<VisitCardCarousel> createState() => _VisitCardCarouselState();
// }
//
// class _VisitCardCarouselState extends State<VisitCardCarousel> with TickerProviderStateMixin {
//   late PageController _pageController;
//   int _currentPage = 0;
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(viewportFraction: 0.75, initialPage: 0);
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.visitors.isEmpty) {
//       return Container(
//         height: 300,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.event_busy,
//                 size: 64,
//                 color: Colors.grey[400],
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'No visits found',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 280,
//           child: PageView.builder(
//             controller: _pageController,
//             itemCount: widget.visitors.length,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentPage = index;
//               });
//               _animationController.forward().then((_) {
//                 _animationController.reverse();
//               });
//             },
//             itemBuilder: (context, index) {
//               final visitor = widget.visitors[index];
//               final isCenter = index == _currentPage;
//
//               return AnimatedBuilder(
//                 animation: _pageController,
//                 builder: (context, child) {
//                   double value = 1.0;
//                   if (_pageController.position.haveDimensions) {
//                     value = _pageController.page! - index;
//                     value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
//                   }
//
//                   return Center(
//                     child: SizedBox(
//                       height: Curves.easeOut.transform(value) * 260,
//                       width: Curves.easeOut.transform(value) * 200,
//                       child: child,
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//                   child: HorizontalVisitCard(
//                     visitor: visitor,
//                     isSelected: isCenter,
//                     onTap: () {
//                       if (!isCenter) {
//                         _pageController.animateToPage(
//                           index,
//                           duration: Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         );
//                       } else {
//                         widget.onTapCard(index);
//                       }
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 20),
//         if (widget.visitors.length > 1)
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: SmoothPageIndicator(
//               controller: _pageController,
//               count: widget.visitors.length,
//               effect: WormEffect(
//                 activeDotColor: Color(0xFF5A8BBA),
//                 dotColor: Colors.grey.shade300,
//                 dotHeight: 8,
//                 dotWidth: 8,
//                 spacing: 12,
//               ),
//             ),
//           ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }