import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class LibraryManagementPage extends StatefulWidget {
  const LibraryManagementPage({super.key});
  @override
  State<LibraryManagementPage> createState() => _LibraryManagementPageState();
}

class _LibraryManagementPageState extends State<LibraryManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _books = [];
  List<dynamic> _issued = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); _fetchBooks(); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _fetchBooks() async {
    setState(() => _isLoading = true);
    try {
      final books = await ApiService.get('/library/books');
      final issued = await ApiService.get('/library/issued');
      setState(() { _books = books; _issued = issued; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  void _showSnack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
    backgroundColor: isError ? Colors.redAccent : AppColors.primary,
    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  void _showAddBookDialog() {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final isbnCtrl = TextEditingController();
    final stockCtrl = TextEditingController();

    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Book', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(titleCtrl, 'Book Title', Icons.book_rounded),
        const SizedBox(height: 12),
        _field(authorCtrl, 'Author', Icons.person_outline),
        const SizedBox(height: 12),
        _field(isbnCtrl, 'ISBN', Icons.numbers_rounded),
        const SizedBox(height: 12),
        _field(stockCtrl, 'Stock', Icons.inventory_rounded, type: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            Navigator.pop(context);
            try {
              await ApiService.post('/library/books', {
                'title': titleCtrl.text.trim(),
                'author': authorCtrl.text.trim(),
                'isbn': isbnCtrl.text.trim(),
                'stock': int.tryParse(stockCtrl.text) ?? 1,
              });
              _fetchBooks(); _showSnack('Book added');
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
        title: const Text('Library', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Books'), Tab(text: 'Issued'), Tab(text: 'Fines')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(controller: _tabController, children: [
              _books.isEmpty
                  ? Center(child: Text('No books', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
                  : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _books.length, itemBuilder: (_, i) => _bookCard(_books[i])),
              _issued.isEmpty
                  ? Center(child: Text('No issued books', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
                  : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _issued.length, itemBuilder: (_, i) => _issuedCard(_issued[i])),
              Center(child: Text('No fines pending', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4)))),
            ]),
    );
  }

  Widget _bookCard(dynamic book) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.book_rounded, color: AppColors.primary, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(book['title'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        Text('${book['author'] ?? ''} · ISBN: ${book['isbn'] ?? ''}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${book['stock'] ?? 0}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
        Text('in stock', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.text.withOpacity(0.4))),
      ]),
    ]),
  );

  Widget _issuedCard(dynamic issue) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.book_online_rounded, color: Colors.orange, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(issue['bookTitle'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        Text('Student: ${issue['studentId'] ?? ''} · Due: ${issue['dueDate'] ?? ''}',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
      ])),
    ]),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) =>
    TextField(controller: ctrl, keyboardType: type,
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