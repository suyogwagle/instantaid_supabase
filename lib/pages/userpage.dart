import 'package:flutter/material.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/pages/edit_profile.dart';
import 'package:instant_aid/emergency_page.dart';
import 'package:instant_aid/pages/history_page.dart';
import 'package:instant_aid/pages/homepage.dart';
import 'package:instant_aid/pages/settings_page.dart';
import 'package:instant_aid/services/hybrid_intent_classifier.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/profile_service.dart';
import 'package:instant_aid/services/whisper_service.dart';
import 'package:instant_aid/widget/bottom_nav.dart';
import '../main.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const navy       = Color(0xFF0A1628);
  static const navyMid    = Color(0xFF0D3B5E);
  static const teal       = Color(0xFF00897B);
  static const tealLight  = Color(0xFFB2DFDB);
  static const tealFaint  = Color(0xFFE0F2F1);
  static const tealDark   = Color(0xFF00695C);
  static const bg         = Color(0xFFF4F6F9);
  static const surface    = Colors.white;
  static const textPri    = Color(0xFF0A1628);
  static const textSec    = Color(0xFF64748B);
  static const divider    = Color(0xFFECEFF4);
  static const red        = Color(0xFFD32F2F);
  static const redFaint   = Color(0xFFFFEBEE);
  static const redLight   = Color(0xFFFFCDD2);
  static const amber      = Color(0xFFF57C00);
  static const amberFaint = Color(0xFFFFF3E0);
  static const green      = Color(0xFF2E7D32);
  static const greenFaint = Color(0xFFE8F5E9);
  static const blue       = Color(0xFF1565C0);
  static const blueFaint  = Color(0xFFE3F2FD);
  static const purple     = Color(0xFF6A1B9A);
  static const purpleFaint= Color(0xFFF3E5F5);

  static List<BoxShadow> shadow = [
    const BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> shadowSm = [
    const BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// UserPage
// ─────────────────────────────────────────────────────────────────────────────
class UserPage extends StatefulWidget {
  final UserModel user;
  const UserPage({super.key, required this.user});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;
  late final InjuryClassifier classifier;
  late final WhisperService whisper;
  late final HybridIntentClassifier hybridClassifier;

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    classifier = InjuryClassifier();
    whisper = WhisperService();
    hybridClassifier = HybridIntentClassifier(classifier);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ProfileService().getUserProfile(widget.user.id);
    setState(() { profile = data; loading = false; });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      setState(() => _selectedIndex = index);
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => HomePage(user: widget.user, hybridClassifier: hybridClassifier)),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      setState(() => _selectedIndex = index);
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => EmergencyModeScreen(
            classifier: classifier, whisper: whisper, hybridClassifier: hybridClassifier)),
      ).then((_) => setState(() => _selectedIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _C.teal))
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(profile: profile, user: widget.user),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _StatsStrip(profile: profile),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Personal info'),
                const SizedBox(height: 8),
                _PersonalInfoCard(profile: profile),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Medical info'),
                const SizedBox(height: 8),
                _MedicalInfoCard(profile: profile),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Emergency contact'),
                const SizedBox(height: 8),
                _EmergencyContactCard(profile: profile),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Quick actions'),
                const SizedBox(height: 8),
                _QuickActions(
                  onEditProfile: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EditProfileScreen(user: widget.user)));
                    _loadProfile();
                  },
                  onHistory: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => HistoryPage(historyItems: const []))),
                  onSettings: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SettingsPage(user: widget.user))),
                  onSignOut: () => _confirmSignOut(context),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w700, color: _C.textPri)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: _C.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.textSec)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await supabase.auth.signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: _C.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                }
              }
            },
            child: const Text('Sign out', style: TextStyle(color: _C.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile header — navy gradient, matches HomePage hero
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final UserModel user;
  const _ProfileHeader({required this.profile, required this.user});

  @override
  Widget build(BuildContext context) {
    final completeness = ProfileService().profileCompleteness(profile);
    final isComplete   = completeness >= 1.0;
    final initials     = _initials(profile?['full_name'] ?? user.email ?? '');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.navy, _C.navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            children: [
              // Back button row
              Align(
                alignment: Alignment.centerLeft,
                child: _GlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),

              // Avatar
              _AvatarRing(
                avatarUrl: profile?['avatar_url'] as String? ?? user.avatarUrl,
                initials: initials,
              ),
              const SizedBox(height: 12),

              // Completeness badge / bar
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.teal.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.tealLight.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: _C.tealLight),
                      SizedBox(width: 5),
                      Text('Profile complete',
                          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              else
                _CompletenessBar(completeness: completeness),

              const SizedBox(height: 10),
              Text(
                profile?['full_name'] ?? 'User',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? profile?['email'] ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
      ),
    );
  }
}

class _CompletenessBar extends StatelessWidget {
  final double completeness;
  const _CompletenessBar({required this.completeness});

  @override
  Widget build(BuildContext context) {
    final pct = (completeness * 100).round();
    return Column(
      children: [
        Text('Profile $pct% complete',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65))),
        const SizedBox(height: 8),
        SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completeness,
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(_C.tealLight),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats strip
// ─────────────────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _StatsStrip({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _C.shadow,
      ),
      child: Row(
        children: [
          _StatItem(value: profile?['sos_count']?.toString() ?? '0',
              label: 'SOS sent', color: _C.red),
          _VerticalDivider(),
          _StatItem(value: profile?['guides_used']?.toString() ?? '0',
              label: 'Guides used', color: _C.teal),
          _VerticalDivider(),
          _StatItem(value: profile?['blood_group'] ?? '—',
              label: 'Blood group', color: _C.blue),
          _VerticalDivider(),
          _StatItem(value: _memberDays(profile?['created_at']),
              label: 'Member', color: _C.amber),
        ],
      ),
    );
  }

  String _memberDays(String? createdAt) {
    if (createdAt == null) return '—';
    try {
      final created = DateTime.parse(createdAt);
      return '${DateTime.now().difference(created).inDays}d';
    } catch (_) { return '—'; }
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: _C.textSec), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: _C.divider);
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: _C.textSec, letterSpacing: 1.0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info card base
// ─────────────────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> rows;
  final Color? borderColor;
  final Widget? header;
  const _InfoCard({required this.rows, this.borderColor, this.header});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!, width: 0.8) : null,
        boxShadow: _C.shadow,
      ),
      child: Column(children: [if (header != null) header!, ...rows]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final bool tappable;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.label, required this.value,
    this.tappable = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty || value == 'Not provided' || value == 'Not set' || value == 'None added';

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _C.textSec)),
                const SizedBox(height: 2),
                Text(
                  isEmpty ? 'Not added' : value,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: isEmpty ? Colors.grey[400] : _C.textPri,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (tappable)
            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
        ],
      ),
    );

    if (tappable && onTap != null) {
      return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: row);
    }
    return row;
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 0, thickness: 0.5, indent: 64, color: _C.divider);
}

// ─────────────────────────────────────────────────────────────────────────────
// Personal info card
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalInfoCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _PersonalInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(rows: [
      _InfoRow(icon: Icons.phone_outlined, iconBg: _C.blueFaint, iconColor: _C.blue,
          label: 'Phone', value: profile?['phone'] ?? '', tappable: true),
      _RowDivider(),
      _InfoRow(icon: Icons.location_on_outlined, iconBg: _C.blueFaint, iconColor: _C.blue,
          label: 'Address', value: profile?['address'] ?? '', tappable: true),
      _RowDivider(),
      _InfoRow(icon: Icons.cake_outlined, iconBg: _C.purpleFaint, iconColor: _C.purple,
          label: 'Date of birth', value: _formatDate(profile?['date_of_birth']), tappable: true),
      _RowDivider(),
      _InfoRow(icon: Icons.person_outline_rounded, iconBg: _C.purpleFaint, iconColor: _C.purple,
          label: 'Gender', value: profile?['gender'] ?? '', tappable: true),
    ]);
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final d = DateTime.parse(raw);
      return '${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year}';
    } catch (_) { return raw; }
  }

  String _month(int m) => ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}

// ─────────────────────────────────────────────────────────────────────────────
// Medical info card
// ─────────────────────────────────────────────────────────────────────────────
class _MedicalInfoCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _MedicalInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final weightKg = profile?['weight_kg'];
    final heightCm = profile?['height_cm'];
    final bodyStats = (weightKg != null && heightCm != null) ? '$weightKg kg · $heightCm cm' : '';

    return _InfoCard(rows: [
      _InfoRow(icon: Icons.bloodtype_outlined, iconBg: _C.redFaint, iconColor: _C.red,
          label: 'Blood group', value: profile?['blood_group'] ?? ''),
      _RowDivider(),
      _InfoRow(icon: Icons.warning_amber_outlined, iconBg: _C.redFaint, iconColor: _C.red,
          label: 'Allergies', value: profile?['allergies'] ?? '', tappable: true),
      _RowDivider(),
      _InfoRow(icon: Icons.monitor_heart_outlined, iconBg: _C.amberFaint, iconColor: _C.amber,
          label: 'Medical conditions', value: profile?['medical_conditions'] ?? '', tappable: true),
      _RowDivider(),
      _InfoRow(icon: Icons.medication_outlined, iconBg: _C.amberFaint, iconColor: _C.amber,
          label: 'Current medications', value: profile?['medications'] ?? '', tappable: true),
      _RowDivider(),
      _InfoRow(icon: Icons.accessibility_new_outlined, iconBg: _C.greenFaint, iconColor: _C.green,
          label: 'Weight / Height', value: bodyStats, tappable: true),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Emergency contact card
// ─────────────────────────────────────────────────────────────────────────────
class _EmergencyContactCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _EmergencyContactCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name     = profile?['emergency_contact_name'] ?? '';
    final phone    = profile?['emergency_contact_phone'] ?? '';
    final relation = profile?['emergency_contact_relation'] ?? '';
    final displayName = (name.isNotEmpty && relation.isNotEmpty) ? '$name ($relation)' : name;

    return _InfoCard(
      borderColor: _C.redLight,
      header: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: const BoxDecoration(
          color: _C.redFaint,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(children: const [
          Icon(Icons.emergency_outlined, color: _C.red, size: 16),
          SizedBox(width: 8),
          Text('Primary emergency contact',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.red)),
        ]),
      ),
      rows: [
        _InfoRow(icon: Icons.person_outline_rounded, iconBg: _C.redFaint, iconColor: _C.red,
            label: 'Name & relation', value: displayName, tappable: true),
        _RowDivider(),
        _EmergencyPhoneRow(phone: phone),
      ],
    );
  }
}

class _EmergencyPhoneRow extends StatelessWidget {
  final String phone;
  const _EmergencyPhoneRow({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _C.redFaint, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.phone_in_talk_outlined, color: _C.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phone', style: TextStyle(fontSize: 11, color: _C.textSec)),
                const SizedBox(height: 2),
                Text(
                  phone.isNotEmpty ? phone : 'Not added',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: phone.isEmpty ? Colors.grey[400] : _C.textPri,
                    fontStyle: phone.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (phone.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _C.tealFaint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.tealLight),
              ),
              child: const Text('Call',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.teal)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick actions
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  const _QuickActions({
    required this.onEditProfile, required this.onHistory,
    required this.onSettings, required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(icon: Icons.edit_outlined, label: 'Edit',
            iconBg: _C.blueFaint, iconColor: _C.blue, onTap: onEditProfile),
        const SizedBox(width: 10),
        _ActionButton(icon: Icons.history_rounded, label: 'History',
            iconBg: _C.tealFaint, iconColor: _C.teal, onTap: onHistory),
        const SizedBox(width: 10),
        _ActionButton(icon: Icons.settings_outlined, label: 'Settings',
            iconBg: _C.amberFaint, iconColor: _C.amber, onTap: onSettings),
        const SizedBox(width: 10),
        _ActionButton(icon: Icons.logout_rounded, label: 'Sign out',
            iconBg: _C.redFaint, iconColor: _C.red, onTap: onSignOut),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon, required this.label,
    required this.iconBg, required this.iconColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _C.shadowSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _C.textSec),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar ring
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarRing extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  const _AvatarRing({required this.avatarUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = avatarUrl != null && avatarUrl!.isNotEmpty;
    return Container(
      width: 104, height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
        boxShadow: [BoxShadow(color: _C.navy.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
          avatarUrl!, fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null ? child : _initialsWidget(),
          errorBuilder: (_, __, ___) => _initialsWidget(),
        )
            : _initialsWidget(),
      ),
    );
  }

  Widget _initialsWidget() => Container(
    color: _C.teal,
    child: Center(
      child: Text(initials,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
    ),
  );
}