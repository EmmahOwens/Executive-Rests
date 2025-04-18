import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/glass_container.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const PropertiesTab(),
    const TenantsTab(),
    const FinancesTab(),
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
        title: const Text('Landlord Dashboard'),
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
            icon: Icon(Icons.apartment),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Tenants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Finances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          // TODO: Add new property
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}

// Properties Tab
class PropertiesTab extends StatelessWidget {
  const PropertiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Properties',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildPropertyCard(
                  'Sunset Apartments',
                  '123 Main Street, City',
                  '12 Units',
                  '95% Occupied',
                  Colors.green,
                ),
                _buildPropertyCard(
                  'Riverside Condos',
                  '456 River Road, City',
                  '8 Units',
                  '75% Occupied',
                  Colors.orange,
                ),
                _buildPropertyCard(
                  'Mountain View Homes',
                  '789 Mountain Ave, City',
                  '5 Units',
                  '100% Occupied',
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String name, String address, String units, String occupancy, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(address),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPropertyInfo(Icons.home, units),
                _buildPropertyInfo(Icons.people, occupancy, color: statusColor),
                _buildPropertyInfo(Icons.attach_money, 'View Finances'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyInfo(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}

// Tenants Tab
class TenantsTab extends StatelessWidget {
  const TenantsTab({super.key});

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
                'Your Tenants',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: () {
                  // TODO: Implement add tenant
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildTenantCard(
                  'John Doe',
                  'Sunset Apartments, Unit 301',
                  'Lease ends: Dec 31, 2023',
                  'Active',
                  Colors.green,
                ),
                _buildTenantCard(
                  'Jane Smith',
                  'Riverside Condos, Unit 205',
                  'Lease ends: Mar 15, 2024',
                  'Active',
                  Colors.green,
                ),
                _buildTenantCard(
                  'Robert Johnson',
                  'Sunset Apartments, Unit 102',
                  'Lease ends: Aug 1, 2023',
                  'Expiring Soon',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantCard(String name, String property, String leaseInfo, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(name.substring(0, 1)),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(property),
            Text(leaseInfo, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
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
        isThreeLine: true,
        onTap: () {
          // TODO: Show tenant details
        },
      ),
    );
  }
}

// Finances Tab
class FinancesTab extends StatelessWidget {
  const FinancesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFinancialSummary('Monthly Income', 'UGX 15,600,000', Icons.arrow_upward, Colors.green),
                  _buildFinancialSummary('Expenses', 'UGX 4,200,000', Icons.arrow_downward, Colors.red),
                  _buildFinancialSummary('Net Profit', 'UGX 11,400,000', Icons.attach_money, Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildTransactionCard(
                  'Rent Payment',
                  'John Doe - Sunset Apartments, Unit 301',
                  'UGX 1,200',
                  DateTime.now().subtract(const Duration(days: 2)),
                  TransactionType.income,
                ),
                _buildTransactionCard(
                  'Maintenance',
                  'Plumbing Repair - Riverside Condos',
                  'UGX 350',
                  DateTime.now().subtract(const Duration(days: 5)),
                  TransactionType.expense,
                ),
                _buildTransactionCard(
                  'Rent Payment',
                  'Jane Smith - Riverside Condos, Unit 205',
                  'UGX 1,400',
                  DateTime.now().subtract(const Duration(days: 7)),
                  TransactionType.income,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(String title, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(
              amount.replaceAll('\$', 'UGX '),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionCard(String title, String description, String amount, DateTime date, TransactionType type) {
    // Get the device's local time format
    final now = DateTime.now();
    final localDate = DateTime(date.year, date.month, date.day, now.hour, now.minute);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type == TransactionType.income ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          child: Icon(
            type == TransactionType.income ? Icons.arrow_upward : Icons.arrow_downward,
            color: type == TransactionType.income ? Colors.green : Colors.red,
          ),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            Text(
              '${localDate.day}/${localDate.month}/${localDate.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Text(
          amount.replaceAll('\$', 'UGX '),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: type == TransactionType.income ? Colors.green : Colors.red,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

enum TransactionType { income, expense }

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
              user?.name.substring(0, 1) ?? 'L',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'Landlord Name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'landlord@example.com',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          _buildProfileSection('Business Information', [
            _buildProfileItem('Phone', user?.phoneNumber ?? '+1 234 567 8900', Icons.phone),
            _buildProfileItem('Address', user?.address ?? '123 Business Ave, Suite 100', Icons.business),
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
            _buildProfileItem('Payment Methods', 'Manage your payment methods', Icons.payment, onTap: () {
              // TODO: Implement payment methods
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