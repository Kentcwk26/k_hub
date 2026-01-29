import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../models/eventsActivities.dart';
import '../repositories/announcement_repository.dart';
import '../utils/date_formatter.dart';
import '../viewmodels/announcement_viewmodel.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationViewModel()..loadNotifications()),
        ChangeNotifierProvider(create: (_) => AnnouncementViewModel(AnnouncementRepository())),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const NotificationsAndAnnouncementsContent(),
      ),
    );
  }
}

class NotificationsAndAnnouncementsContent extends StatelessWidget {
  const NotificationsAndAnnouncementsContent({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<NotificationViewModel>(context);
    final announcementVm = Provider.of<AnnouncementViewModel>(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StreamBuilder<List<Announcement>>(
            stream: announcementVm.getAnnouncementsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _SectionHeader(
                  title: 'Announcements',
                  icon: Icons.announcement,
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _SectionHeader(
                  title: 'Announcements',
                  icon: Icons.announcement,
                );
              }

              final announcements = snapshot.data ?? [];

              if (announcements.isEmpty) {
                return const _SectionHeader(
                  title: 'Announcements',
                  icon: Icons.announcement,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    title: 'Announcements',
                    icon: Icons.announcement,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return _AnnouncementListItem(
                        announcement: announcement,
                        onTap: () => _showAnnouncementDetails(context, announcement),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),

        SliverToBoxAdapter(
          child: Consumer<NotificationViewModel>(
            builder: (context, vm, _) {
              final notifications = vm.notifications;

              if (notifications.isEmpty) {
                return const _SectionHeader(
                  title: 'Notifications',
                  icon: Icons.notifications,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    title: 'Notifications',
                    icon: Icons.notifications,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _NotificationListItem(
                        notification: n,
                        onDismiss: () => vm.deleteNotification(n.notificationId),
                        onStatusToggle: () {
                          if (n.status == "Unread") {
                            vm.markAsUnread(n.notificationId);
                          } else {
                            vm.markAsRead(n.notificationId);
                          }
                        },
                        onDelete: () => vm.deleteNotification(n.notificationId),
                        onTap: () => _showNotificationDetails(context, n),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),

        SliverToBoxAdapter(
          child: Consumer<NotificationViewModel>(
            builder: (context, notificationVm, _) {
              return StreamBuilder<List<Announcement>>(
                stream: announcementVm.getAnnouncementsStream(),
                builder: (context, snapshot) {
                  final announcements = snapshot.data ?? [];
                  final notifications = notificationVm.notifications;

                  if (announcements.isEmpty && notifications.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No notifications or announcements',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNotificationDetails(BuildContext context, Notifications notification) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementDetails(BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.announcementTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (announcement.announcementImage.isNotEmpty)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          announcement.announcementImage,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Image not available'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                Text(
                  announcement.announcementContent,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                
                if (announcement.announcementLink.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Related Link:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse(announcement.announcementLink));
                        },
                        child: Text(
                          announcement.announcementLink,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementListItem extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementListItem({
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.announcementTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (announcement.announcementImage.isNotEmpty)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          announcement.announcementImage,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Image not available'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                Text(
                  announcement.announcementContent.length > 150
                      ? '${announcement.announcementContent.substring(0, 150)}...'
                      : announcement.announcementContent,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.fullDateTime(announcement.createdTime),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationListItem extends StatelessWidget {
  final Notifications notification;
  final VoidCallback onDismiss;
  final VoidCallback onStatusToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _NotificationListItem({
    required this.notification,
    required this.onDismiss,
    required this.onStatusToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Dismissible(
        key: Key(notification.notificationId),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => onDismiss(),
        child: Card(
          elevation: 1,
          child: ListTile(
            leading: Icon(
              Icons.notifications,
              color: notification.status == "Read" ? Colors.grey : Colors.red,
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: notification.status == "Unread" 
                    ? FontWeight.bold 
                    : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              notification.dateformat,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    notification.status == "Read"
                        ? Icons.mark_email_unread
                        : Icons.mark_email_read,
                    color: notification.status == "Read"
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  onPressed: onStatusToggle,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AnnouncementViewModel(AnnouncementRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Announcements')),
        body: const _AnnouncementContent(),
      ),
    );
  }
}

class _AnnouncementContent extends StatelessWidget {
  const _AnnouncementContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AnnouncementViewModel>(context);

    return StreamBuilder<List<Announcement>>(
      stream: viewModel.getAnnouncementsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final announcements = snapshot.data ?? [];

        if (announcements.isEmpty) {
          return const Center(
            child: Text(
              'No announcements yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return AnnouncementCard(announcement: announcement);
          },
        );
      },
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final bool showMenu;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.showMenu = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    announcement.announcementTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                if (showMenu)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (announcement.announcementImage.isNotEmpty)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      announcement.announcementImage,
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            Text(
              announcement.announcementContent,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              "Announcement created on ${DateFormatter.shortDateTime(announcement.createdTime)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}