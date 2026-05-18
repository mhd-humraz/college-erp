import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});
  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _fetchEvents(); }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/events');
      setState(() { _events = data; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  void _showSnack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
    backgroundColor: isError ? Colors.redAccent : AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final venueCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Event', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(titleCtrl, 'Event Title', Icons.event_rounded),
        const SizedBox(height: 12),
        _field(dateCtrl, 'Date (YYYY-MM-DD)', Icons.calendar_today_rounded),
        const SizedBox(height: 12),
        _field(venueCtrl, 'Venue', Icons.location_on_rounded),
        const SizedBox(height: 12),
        _field(descCtrl, 'Description', Icons.description_outlined),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            Navigator.pop(context);
            try {
              await ApiService.post('/events', {
                'title': titleCtrl.text.trim(),
                'date': dateCtrl.text.trim(),
                'venue': venueCtrl.text.trim(),
                'description': descCtrl.text.trim(),
              });
              _fetchEvents(); _showSnack('Event added');
            } catch (e) { _showSnack('Failed', isError: true); }
          },
          child: const Text('Add', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Events', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchEvents)],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _events.isEmpty
              ? Center(child: Text('No events yet', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (_, i) => _eventCard(_events[i]),
                ),
    );
  }

  Widget _eventCard(dynamic event) => Container(
    margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(event['title'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
      const SizedBox(height: 6),
      Row(children: [
        const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(event['date'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary)),
        const SizedBox(width: 14),
        const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
        const SizedBox(width: 4),
        Expanded(child: Text(event['venue'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary))),
      ]),
      if (event['description'] != null && event['description'].toString().isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(event['description'], style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.text.withOpacity(0.5))),
      ],
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
          onPressed: () async {
            try {
              await ApiService.delete('/events/${event['_id'] ?? event['id']}');
              _fetchEvents(); _showSnack('Event deleted');
            } catch (e) { _showSnack('Failed', isError: true); }
          },
          child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.redAccent, fontSize: 12)),
        ),
      ]),
    ]),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon) =>
    TextField(controller: ctrl,
      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ));
}