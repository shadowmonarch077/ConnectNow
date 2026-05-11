import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  // Sample contacts list — in a real app you'd load from Firestore
  final List<Map<String, String>> _contacts = [
    {'name': 'Alice Johnson', 'email': 'alice@example.com', 'status': 'online'},
    {'name': 'Bob Smith', 'email': 'bob@example.com', 'status': 'offline'},
    {'name': 'Carol White', 'email': 'carol@example.com', 'status': 'online'},
    {'name': 'David Lee', 'email': 'david@example.com', 'status': 'offline'},
    {'name': 'Emma Wilson', 'email': 'emma@example.com', 'status': 'online'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _contacts
        .where((c) =>
            c['name']!.toLowerCase().contains(_search.toLowerCase()) ||
            c['email']!.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: dividerColor),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(color: textHint),
                prefixIcon:
                    Icon(Icons.search_rounded, color: textSecondary, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              ),
            ),
          ),
        ),

        // Contact count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Text(
                '${filtered.length} contact${filtered.length != 1 ? 's' : ''}',
                style:
                    const TextStyle(color: textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No contacts found',
                      style: TextStyle(color: textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final isOnline = c['status'] == 'online';
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: brandGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    c['name']![0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? greenOnline
                                        : textSecondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: surfaceColor, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['name']!,
                                    style: const TextStyle(
                                        color: textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(c['email']!,
                                    style: const TextStyle(
                                        color: textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          // Call button
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Calling ${c['name']}... (they need to share their Room ID)'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: brandGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.video_call_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
