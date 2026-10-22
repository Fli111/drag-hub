import 'package:flutter/material.dart';
import 'login_page.dart';
import 'event_detail_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final UserModel? currentUser;
  const HomePage({super.key, this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const EventContent(),
      const HistoryContent(),
      ProfileContent(currentUser: widget.currentUser),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0
              ? 'Event'
              : (currentIndex == 1 ? 'Riwayat Event' : 'Profil'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: pages[currentIndex],
      floatingActionButton: (currentIndex == 0 && widget.currentUser?.role == 'panitia')
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Akses Panitia: Formulir Buat Event Baru'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Event'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class EventContent extends StatefulWidget {
  const EventContent({super.key});

  @override
  State<EventContent> createState() => _EventContentState();
}

class _EventContentState extends State<EventContent> {
  int selectedFilterIndex = 0; // 0 for Ongoing, 1 for Upcoming

  final List<Map<String, String>> ongoingEvents = const [
    {
      'title': 'Drag Race Cup #3',
      'location': 'Sirkuit BSD',
      //'image': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=600&q=80',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwMQEF1v8MBLn4dBlLhmXhILbGRLIBeDgdirZY6DZWGaz6d-5mamSEKw&s=10',

    },
    {
      'title': 'Matic Open Class',
      'location': 'Sentul',
      //'image': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
      'image': 'https://balapmotor.net/wp-content/uploads/2025/05/Matic-59-Open-Wahana-Baru-Bandung.jpg',
    },
  ];

  final List<Map<String, String>> upcomingEvents = const [
    {
      'title': 'Superbike Championship 2026',
      'location': 'Mandalika Circuit',
      'image': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentEvents = selectedFilterIndex == 0 ? ongoingEvents : upcomingEvents;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Filter tabs: [Ongoing] Upcoming
        Row(
          children: [
            _buildTabButton('Ongoing', 0),
            const SizedBox(width: 8),
            _buildTabButton('Upcoming', 1),
          ],
        ),
        const SizedBox(height: 16),

        // List of cards
        ...currentEvents.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildEventCard(event),
            )),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, String> event) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(event: event),
            ),
          );
        },
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar / Image banner
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                event['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
              ),
            ),

            // Detail Event
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['location']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 6),
            Text(
              '[gambar]',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  final UserModel? currentUser;
  const ProfileContent({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final isPanitia = user?.role == 'panitia';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Avatar
          CircleAvatar(
            radius: 42,
            backgroundColor: isPanitia ? Colors.amber.shade700 : Theme.of(context).colorScheme.primary,
            child: Icon(
              isPanitia ? Icons.admin_panel_settings : Icons.person,
              size: 46,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Nama User
          Text(
            user?.name ?? 'Tamu / Penonton',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          // Badge Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isPanitia ? Colors.amber.shade100 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPanitia ? Colors.amber.shade400 : Colors.blue.shade300,
              ),
            ),
            child: Text(
              isPanitia
                  ? '👑 PANITIA EVENT'
                  : (user?.role == 'pengguna' ? '🏍️ RIDER / PENGGUNA' : '👀 TAMU'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isPanitia ? Colors.brown.shade800 : Colors.blue.shade900,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Menu Aksi berdasarkan Role
          if (isPanitia) ...[
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_box_outlined, color: Colors.deepPurple),
                    title: const Text('Buat Event Baru'),
                    subtitle: const Text('Atur jadwal, sirkuit & kelas balap'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka Formulir Event Baru')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined, color: Colors.deepPurple),
                    title: const Text('Catat Hasil Balap'),
                    subtitle: const Text('Input waktu tempuh (ET) & pemenang'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka Pencatatan Hasil Balap')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.photo_camera_back_outlined, color: Colors.deepPurple),
                    title: const Text('Input Dokumentasi'),
                    subtitle: const Text('Unggah foto & galeri event'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka Unggah Dokumentasi')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.two_wheeler, color: Colors.deepPurple),
                    title: const Text('Data Motor & Garasi'),
                    subtitle: const Text('Kelola spek motor & kelas balap'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.confirmation_number_outlined, color: Colors.deepPurple),
                    title: const Text('Nomor Start Favorit'),
                    subtitle: const Text('Nomor start terdaftar: #46'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.emoji_events_outlined, color: Colors.deepPurple),
                    title: const Text('Prestasi / Podium'),
                    subtitle: const Text('Lihat piala yang pernah diraih'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Tombol Keluar / Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Keluar / Ganti Akun',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryContent extends StatelessWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Riwayat Event',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
