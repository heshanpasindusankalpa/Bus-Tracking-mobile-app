import 'package:flutter/material.dart';
import 'package:bus_tracking_app/features/admin/admin_route_selection_screen.dart';
import 'package:bus_tracking_app/core/services/firestore_service.dart';
import 'package:bus_tracking_app/core/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  
  int totalBuses = 0;
  int activeBuses = 0;
  int totalRoutes = 0;
  int estimatedPassengers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Fetch all buses
      final allBuses = await _firestoreService.getAllBuses();
      print('✅ Total buses fetched: ${allBuses.length}');
      
      // Fetch all routes
      final routes = await _firestoreService.getAllRoutes();
      print('✅ Total routes fetched: ${routes.length}');
      
      // Fetch all registered passengers
      final passengers = await _firestoreService.getAllPassengers();
      print('✅ Total registered passengers fetched: ${passengers.length}');
      
      setState(() {
        // Count total buses
        totalBuses = allBuses.length;
        
        // Count active buses (all buses added to database)
        activeBuses = allBuses.length;
        
        // Total routes
        totalRoutes = routes.length;
        
        // Passengers count - actual registered users
        estimatedPassengers = passengers.length;
        
        isLoading = false;
        print('🔄 Dashboard updated - Total: $totalBuses, Active: $activeBuses, Routes: $totalRoutes, Passengers: $estimatedPassengers');
      });
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AuthService().signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error logging out: $e')),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 8,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 26,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _loadDashboardData();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              onPressed: _handleLogout,
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFd32f2f),
                Color(0xFF8b0000),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFd32f2f).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Section
              Text(
                '📊 Fleet Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFd32f2f),
                          ),
                        ),
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                      children: [
                        _buildPremiumStatCard(
                          emoji: '🚌',
                          iconColor: Color(0xFFd32f2f),
                          bgGradient: LinearGradient(
                            colors: [Color(0xFFd32f2f).withOpacity(0.15), Color(0xFFd32f2f).withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          title: 'Total Fleet',
                          value: totalBuses.toString(),
                          context: context,
                        ),
                        _buildPremiumStatCard(
                          emoji: '✅',
                          iconColor: Color(0xFF43a047),
                          bgGradient: LinearGradient(
                            colors: [Color(0xFF43a047).withOpacity(0.15), Color(0xFF43a047).withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          title: 'Active Buses',
                          value: activeBuses.toString(),
                          context: context,
                        ),
                        _buildPremiumStatCard(
                          emoji: '🗺️',
                          iconColor: Color(0xFFd32f2f),
                          bgGradient: LinearGradient(
                            colors: [Color(0xFFd32f2f).withOpacity(0.15), Color(0xFFd32f2f).withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          title: 'Routes',
                          value: totalRoutes.toString(),
                          context: context,
                        ),
                        _buildPremiumStatCard(
                          emoji: '👥',
                          iconColor: Color(0xFFffa726),
                          bgGradient: LinearGradient(
                            colors: [Color(0xFFffa726).withOpacity(0.15), Color(0xFFffa726).withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          title: 'Passengers',
                          value: estimatedPassengers > 999
                              ? '${(estimatedPassengers / 1000).toStringAsFixed(1)}k'
                              : estimatedPassengers.toString(),
                          context: context,
                        ),
                      ],
                    ),

              const SizedBox(height: 40),

              // Action Cards Section with Creative Design
              Text(
                '⚡ Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              // Register Bus Card
              _buildPremiumActionCard(
                icon: Icons.directions_bus_filled,
                emoji: '🚐',
                iconColor: Color(0xFFd32f2f),
                title: 'Register New Bus',
                subtitle: 'Add buses to your fleet',
                bgGradient: LinearGradient(
                  colors: [Color(0xFFd32f2f), Color(0xFF8b0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/manage-buses');
                },
              ),

              const SizedBox(height: 12),

              // Manage Routes Card
              _buildPremiumActionCard(
                icon: Icons.edit_location_alt,
                emoji: '🗺️',
                iconColor: Color(0xFFd32f2f),
                title: 'Manage Routes',
                subtitle: 'Create & manage bus routes',
                bgGradient: LinearGradient(
                  colors: [Color(0xFFd32f2f), Color(0xFF8b0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/admin-route-selection');
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatCard({
    required String emoji,
    required Color iconColor,
    required Gradient bgGradient,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: bgGradient,
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionCard({
    required IconData icon,
    required String emoji,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Gradient bgGradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Gradient bgGradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
