// Create this as a separate file: notification_screen.dart
import 'package:flutter/material.dart';
import '../../models/visitor_model.dart';
import '../../utils/color_scheme.dart';

class NotificationScreen extends StatefulWidget {
  final List<NotificationModel> notifications;
  final Function(String) onNotificationRead;

  const NotificationScreen({
    Key? key,
    required this.notifications,
    required this.onNotificationRead,
  }) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int selectedIndex = 0;

  final List<String> filterOptions = ['All', 'Unread', 'Visit', 'Grievance', 'System'];
  final List<IconData> filterIcons = [
    Icons.all_inclusive,
    Icons.mark_email_unread,
    Icons.event_available,
    Icons.report_problem_outlined,
    Icons.settings_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: filterOptions.length, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationModel> getFilteredNotifications(int index) {
    switch (index) {
      case 1: // Unread
        return widget.notifications.where((n) => !n.isRead).toList();
      case 2: // Visit
        return widget.notifications.where((n) => n.type == 'visit').toList();
      case 3: // Grievance
        return widget.notifications.where((n) => n.type == 'grievance').toList();
      case 4: // System
        return widget.notifications.where((n) => n.type == 'system').toList();
      default: // All
        return widget.notifications;
    }
  }

  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'visit':
        return Icons.event;
      case 'grievance':
        return Icons.report_problem;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color getNotificationColor(String type) {
    switch (type) {
      case 'visit':
        return Color(0xFF6366F1); // Indigo
      case 'grievance':
        return Color(0xFFF59E0B); // Amber
      case 'system':
        return Color(0xFF10B981); // Emerald
      default:
        return AppColors.primary;
    }
  }

  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      widget.notifications.removeWhere((n) => n.id == notificationId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Notification deleted'),
          ],
        ),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light grey background
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with glassmorphism effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.notifications.where((n) => !n.isRead).length} unread messages',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.done_all, color: Colors.black, size: 20),
                        onPressed: () {
                          setState(() {
                            for (var notification in widget.notifications) {
                              if (!notification.isRead) {
                                widget.onNotificationRead(notification.id);
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modern Tab Bar
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                tabs: filterOptions.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  return Tab(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(filterIcons[index], size: 16),
                          SizedBox(width: 8),
                          Text(option),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // PageView for swipeable content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                    _tabController.animateTo(index);
                  });
                },
                itemCount: filterOptions.length,
                itemBuilder: (context, pageIndex) {
                  final notifications = getFilteredNotifications(pageIndex);

                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              Icons.notifications_none_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'No ${filterOptions[pageIndex].toLowerCase()} notifications',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: notification.isRead
                                ? Colors.grey.shade200
                                : getNotificationColor(notification.type).withOpacity(0.3),
                            width: notification.isRead ? 1 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: notification.isRead
                                  ? Colors.black.withOpacity(0.03)
                                  : getNotificationColor(notification.type).withOpacity(0.1),
                              blurRadius: notification.isRead ? 8 : 15,
                              offset: Offset(0, notification.isRead ? 2 : 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (!notification.isRead) {
                                widget.onNotificationRead(notification.id);
                              }
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: getNotificationColor(notification.type).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                getNotificationIcon(notification.type),
                                                color: getNotificationColor(notification.type),
                                                size: 24,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          notification.message,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                            height: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: TextButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            ),
                                            child: Text(
                                              'Close',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Notification Icon with modern styling
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          getNotificationColor(notification.type),
                                          getNotificationColor(notification.type).withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: getNotificationColor(notification.type).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      getNotificationIcon(notification.type),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),

                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: notification.isRead
                                                      ? FontWeight.w600
                                                      : FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            if (!notification.isRead)
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0xFF3B82F6).withOpacity(0.5),
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          notification.message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: getNotificationColor(notification.type).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: getNotificationColor(notification.type).withOpacity(0.2),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    filterIcons[filterOptions.indexOf(notification.type.toLowerCase() == 'visit' ? 'Visit' :
                                                    notification.type.toLowerCase() == 'grievance' ? 'Grievance' :
                                                    notification.type.toLowerCase() == 'system' ? 'System' : 'All')],
                                                    size: 12,
                                                    color: getNotificationColor(notification.type),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    notification.type.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: getNotificationColor(notification.type),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              formatTimestamp(notification.timestamp),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Delete button with modern styling
                                  SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFFEF2F2),
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    child: Icon(
                                                      Icons.delete_outline_rounded,
                                                      color: Color(0xFFDC2626),
                                                      size: 30,
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    'Delete Notification',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Are you sure you want to delete this notification? This action cannot be undone.',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 24),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: Colors.grey.shade100,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            padding: EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              color: Colors.grey.shade700,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            _deleteNotification(notification.id);
                                                          },
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: Color(0xFFDC2626),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            padding: EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          child: Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}