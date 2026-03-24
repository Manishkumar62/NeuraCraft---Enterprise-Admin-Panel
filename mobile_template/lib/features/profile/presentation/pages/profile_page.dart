import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/session/session_manager.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? user;

  const ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final profile = user ?? getIt<SessionManager>().user;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text("No profile data available")),
      );
    }

    final theme = Theme.of(context);
    final roles = List<Map<String, dynamic>>.from(
      profile['roles'] as List? ?? const [],
    );
    final department = profile['department'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.07),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.28, 1],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(context, profile, department, roles),
              const SizedBox(height: 18),
              _buildQuickStats(context, profile, roles, department),
              const SizedBox(height: 18),
              _buildSectionCard(
                context,
                title: "Personal Details",
                icon: Icons.badge_outlined,
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: "Username",
                      value: _stringValue(profile['username']),
                    ),
                    _buildDetailRow(
                      icon: Icons.alternate_email_rounded,
                      label: "Email",
                      value: _stringValue(profile['email']),
                    ),
                    _buildDetailRow(
                      icon: Icons.phone_outlined,
                      label: "Phone",
                      value: _stringValue(profile['phone']),
                    ),
                    _buildDetailRow(
                      icon: Icons.fingerprint,
                      label: "Employee ID",
                      value: _stringValue(profile['employee_id']),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                context,
                title: "Organization",
                icon: Icons.apartment_rounded,
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.apartment_outlined,
                      label: "Department",
                      value: _stringValue(department?['name']),
                    ),
                    _buildDetailRow(
                      icon: Icons.qr_code_rounded,
                      label: "Department Code",
                      value: _stringValue(department?['code']),
                    ),
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: "Joined On",
                      value: _formatDate(profile['date_joined']),
                    ),
                    _buildDetailRow(
                      icon: Icons.verified_user_outlined,
                      label: "Account Status",
                      value: (profile['is_active'] as bool? ?? false)
                          ? "Active"
                          : "Inactive",
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildRolesSection(context, roles),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    Map<String, dynamic> profile,
    Map<String, dynamic>? department,
    List<Map<String, dynamic>> roles,
  ) {
    final theme = Theme.of(context);
    final displayName = _displayName(profile);
    final subtitle = [
      _stringValue(department?['name']),
      if (roles.isNotEmpty) _stringValue(roles.first['name']),
    ].where((value) => value != "-").join("  |  ");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.20),
            theme.colorScheme.primary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.16),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Center(
                  child: Text(
                    _initialsFromProfile(profile),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stringValue(profile['email']),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(
                context,
                isActive: profile['is_active'] as bool? ?? false,
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    Map<String, dynamic> profile,
    List<Map<String, dynamic>> roles,
    Map<String, dynamic>? department,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            context,
            label: "Roles",
            value: roles.length.toString(),
            icon: Icons.shield_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(
            context,
            label: "Department",
            value: department == null ? "None" : "Assigned",
            icon: Icons.apartment_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(
            context,
            label: "Joined",
            value: _formatMonthYear(profile['date_joined']),
            icon: Icons.event_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRolesSection(
    BuildContext context,
    List<Map<String, dynamic>> roles,
  ) {
    return _buildSectionCard(
      context,
      title: "Roles & Access",
      icon: Icons.security_rounded,
      child: roles.isEmpty
          ? Text(
              "No roles assigned",
              style: TextStyle(color: Colors.grey.shade500),
            )
          : Column(
              children: roles.map((role) {
                final departmentName = _stringValue(role['department_name']);

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.03),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _stringValue(role['name']),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildMetaChip(
                                context,
                                icon: Icons.apartment_outlined,
                                label: departmentName == "-"
                                    ? "Global Role"
                                    : departmentName,
                              ),
                              _buildRoleStatusBadge(
                                context,
                                isActive: role['is_active'] as bool? ?? false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, {required bool isActive}) {
    final color = isActive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRoleStatusBadge(BuildContext context, {required bool isActive}) {
    final color = isActive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? "Enabled" : "Disabled",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _displayName(Map<String, dynamic> profile) {
    final first = _stringValue(profile['first_name']);
    final last = _stringValue(profile['last_name']);
    final full = [first, last].where((value) => value != "-").join("  |  ");

    return full.isEmpty ? _stringValue(profile['username']) : full;
  }

  String _stringValue(dynamic value) {
    if (value == null) return "-";

    final text = value.toString().trim();
    if (text.isEmpty) return "-";

    return text;
  }

  String _formatDate(dynamic value) {
    if (value == null) return "-";

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();

    final local = parsed.toLocal();
    final month = _monthName(local.month);
    return "${local.day} $month ${local.year}";
  }

  String _formatMonthYear(dynamic value) {
    if (value == null) return "-";

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return "-";

    final local = parsed.toLocal();
    final month = _monthName(local.month);
    return "$month ${local.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _initialsFromProfile(Map<String, dynamic> profile) {
    final first = _stringValue(profile['first_name']);
    final last = _stringValue(profile['last_name']);

    if (first != "-" && last != "-") {
      return (first[0] + last[0]).toUpperCase();
    }

    if (first != "-") {
      return first.substring(0, 1).toUpperCase();
    }

    final username = _stringValue(profile['username']);
    if (username == "-") return "U";

    return username.substring(0, 1).toUpperCase();
  }
}
