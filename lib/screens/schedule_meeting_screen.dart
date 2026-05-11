import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../resources/agora_methods.dart';
import '../utils/colors.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  String? _generatedRoomId;
  bool _saved = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _generateRoomId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now % 90000000 + 10000000).toString();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: primaryPurple,
            surface: surfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: primaryPurple,
            surface: surfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _scheduleMeeting() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meeting title')),
      );
      return;
    }
    final roomId = _generateRoomId();
    setState(() {
      _generatedRoomId = roomId;
      _saved = true;
    });
  }

  void _startNow() {
    if (_generatedRoomId == null) return;
    AgoraMethods().createMeeting(
      context: context,
      channelName: _generatedRoomId!,
      isAudioMuted: false,
      isVideoMuted: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule Meeting',
          style: TextStyle(
              color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _saved && _generatedRoomId != null
            ? _buildConfirmation()
            : _buildForm(dateStr, timeStr),
      ),
    );
  }

  Widget _buildForm(String dateStr, String timeStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text('Meeting Title',
            style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: dividerColor),
          ),
          child: TextField(
            controller: _titleController,
            style: const TextStyle(color: textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'e.g. Team Standup',
              hintStyle: TextStyle(color: textHint),
              prefixIcon:
                  Icon(Icons.title_rounded, color: textSecondary, size: 20),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Date & Time row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: _PickerTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: dateStr,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _pickTime,
                child: _PickerTile(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: timeStr,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        GestureDetector(
          onTap: _scheduleMeeting,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6B21A8), Color(0xFFA855F7)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B21A8).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Schedule Meeting',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [Color(0xFF6B21A8), Color(0xFFA855F7)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        const Text(
          'Meeting Scheduled!',
          style: TextStyle(
              color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          _titleController.text.trim(),
          style: const TextStyle(color: textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 24),

        // Room ID card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            children: [
              const Text('Room ID',
                  style: TextStyle(color: textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                _generatedRoomId!,
                style: const TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _generatedRoomId!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Room ID copied!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: primaryPurple.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          color: primaryPurple, size: 16),
                      SizedBox(width: 6),
                      Text('Copy Room ID',
                          style: TextStyle(
                              color: primaryPurple,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Start now button
        GestureDetector(
          onTap: _startNow,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: brandGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('Start Now',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: dividerColor),
            ),
            child: const Center(
              child: Text('Done',
                  style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PickerTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, color: primaryPurple, size: 16),
              const SizedBox(width: 6),
              Text(value,
                  style: const TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
