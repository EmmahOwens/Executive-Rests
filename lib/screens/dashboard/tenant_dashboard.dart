import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/glass_container.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeTab(),
    const PaymentsTab(),
    const MaintenanceTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Home Tab
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Rental',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Apartment 301'),
                    subtitle: const Text('123 Main Street, City'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard('Rent', 'UGX 500,000/mo'),
                      _buildInfoCard('Due Date', '1st of month'),
                      _buildInfoCard('Status', 'Paid'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Announcements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildAnnouncementCard(
            'Building Maintenance',
            'Water will be shut off on June 15th from 10am-2pm for routine maintenance.',
            DateTime.now().subtract(const Duration(days: 2)),
          ),
          _buildAnnouncementCard(
            'Community Event',
            'Join us for a resident mixer in the common area this Saturday at 6pm.',
            DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String content, DateTime date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(content),
            const SizedBox(height: 5),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Payments Tab
class PaymentsTab extends StatelessWidget {
  const PaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildPaymentCard('May 2023', 'UGX 500,000', 'Paid', Colors.green),
                _buildPaymentCard('April 2023', 'UGX 500,000', 'Paid', Colors.green),
                _buildPaymentCard('March 2023', 'UGX 500,000', 'Paid', Colors.green),
                _buildPaymentCard('February 2023', 'UGX 500,000', 'Paid', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String month, String amount, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(month),
        subtitle: Text('Due on 1st'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          // TODO: Show payment details
        },
      ),
    );
  }
}

// Maintenance Tab
class MaintenanceTab extends StatelessWidget {
  const MaintenanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Maintenance Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New'),
                onPressed: () {
                  // TODO: Implement new maintenance request
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildRequestCard(
                  'Leaking Faucet',
                  'The kitchen sink faucet is leaking.',
                  'In Progress',
                  Colors.orange,
                  DateTime.now().subtract(const Duration(days: 3)),
                ),
                _buildRequestCard(
                  'Broken Light',
                  'The light in the bathroom is not working.',
                  'Completed',
                  Colors.green,
                  DateTime.now().subtract(const Duration(days: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(String title, String description, String status, Color statusColor, DateTime date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(description),
            const SizedBox(height: 5),
            Text(
              'Submitted: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user?.name.substring(0, 1) ?? 'T',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'Tenant Name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'tenant@example.com',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          _buildProfileSection('Personal Information', [
            _buildProfileItem('Phone', user?.phoneNumber ?? '+1 234 567 8900', Icons.phone),
            _buildProfileItem('Address', user?.address ?? '123 Main St, Apt 301', Icons.home),
          ]),
          const SizedBox(height: 20),
          _buildProfileSection('Account Settings', [
            _buildProfileItem('Edit Profile', 'Update your information', Icons.edit, onTap: () {
              // TODO: Implement edit profile
            }),
            _buildProfileItem('Change Password', 'Update your password', Icons.lock, onTap: () {
              // TODO: Implement change password
            }),
            _buildProfileItem('Notifications', 'Manage your notifications', Icons.notifications, onTap: () {
              // TODO: Implement notifications settings
            }),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}