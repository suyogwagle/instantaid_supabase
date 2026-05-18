import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/services/avatar_service.dart';
import 'package:instant_aid/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;
  String? _displayAvatarUrl;

  // ── Personal info controllers (email removed)
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;

  // ── Medical info controllers
  String? _bloodGroup;
  final _allergiesCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  // ── Emergency contact controllers
  final _ecNameCtrl = TextEditingController();
  final _ecPhoneCtrl = TextEditingController();
  final _ecRelationCtrl = TextEditingController();

  static const _bloodGroups = ['A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'];
  static const _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ProfileService().getUserProfile(widget.user.id);
    if (data != null) {
      _fullNameCtrl.text = data['full_name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _addressCtrl.text = data['address'] ?? '';
      _allergiesCtrl.text = data['allergies'] ?? '';
      _conditionsCtrl.text = data['medical_conditions'] ?? '';
      _medicationsCtrl.text = data['medications'] ?? '';
      _weightCtrl.text = data['weight_kg']?.toString() ?? '';
      _heightCtrl.text = data['height_cm']?.toString() ?? '';
      _ecNameCtrl.text = data['emergency_contact_name'] ?? '';
      _ecPhoneCtrl.text = data['emergency_contact_phone'] ?? '';
      _ecRelationCtrl.text = data['emergency_contact_relation'] ?? '';

      _bloodGroup = _bloodGroups.contains(data['blood_group'])
          ? data['blood_group']
          : null;
      _gender = _genders.contains(data['gender']) ? data['gender'] : null;

      if (data['date_of_birth'] != null) {
        try {
          _dateOfBirth = DateTime.parse(data['date_of_birth']);
        } catch (_) {}
      }
    }
    _avatarUrl = data?['avatar_url'] as String?;
    _displayAvatarUrl = _avatarUrl;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await ProfileService().updateUserProfile(widget.user.id, {
      'email': widget.user.email,
      'avatar_url': _avatarUrl,
      'full_name': _fullNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'date_of_birth': _dateOfBirth?.toIso8601String(),
      'gender': _gender,
      'blood_group': _bloodGroup,
      'allergies': _allergiesCtrl.text.trim(),
      'medical_conditions': _conditionsCtrl.text.trim(),
      'medications': _medicationsCtrl.text.trim(),
      'weight_kg': double.tryParse(_weightCtrl.text.trim()),
      'height_cm': double.tryParse(_heightCtrl.text.trim()),
      'emergency_contact_name': _ecNameCtrl.text.trim(),
      'emergency_contact_phone': _ecPhoneCtrl.text.trim(),
      'emergency_contact_relation': _ecRelationCtrl.text.trim(),
    });

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully'),
          backgroundColor: Color(0xff3b6d11),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _uploadAvatar(ImageSource source) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final service = AvatarService();
    final file = await service.pickImage(source: source);
    if (file == null) return;
    if (!mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final url = await service.uploadAndSave(widget.user.id, file);
      if (mounted) {
        final cleanUrl = url.contains('?t=') ? url.split('?t=')[0] : url;
        setState(() {
          _avatarUrl = cleanUrl;
          _displayAvatarUrl = url;
        });
        widget.user.avatarUrl = cleanUrl;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo updated successfully'),
            backgroundColor: Color(0xff3b6d11),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Change photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffe6f1fb),
                child: Icon(Icons.photo_library_outlined, color: Color(0xff185fa5)),
              ),
              title: const Text('Choose from gallery'),
              onTap: () => _uploadAvatar(ImageSource.gallery),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffeaf3de),
                child: Icon(Icons.camera_alt_outlined, color: Color(0xff3b6d11)),
              ),
              title: const Text('Take a photo'),
              onTap: () => _uploadAvatar(ImageSource.camera),
            ),
            if (_avatarUrl != null ||
                _displayAvatarUrl != null ||
                (widget.user.avatarUrl?.isNotEmpty ?? false))
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xfffcebeb),
                  child: Icon(Icons.delete_outline, color: Color(0xffa32d2d)),
                ),
                title: const Text('Remove photo',
                    style: TextStyle(color: Color(0xffa32d2d))),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _uploadingAvatar = true);
                  try {
                    await AvatarService().deleteAvatar(widget.user.id);
                    setState(() {
                      _avatarUrl = null;
                      _displayAvatarUrl = null;
                    });
                    widget.user.avatarUrl = null;
                  } finally {
                    if (mounted) setState(() => _uploadingAvatar = false);
                  }
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _allergiesCtrl.dispose();
    _conditionsCtrl.dispose();
    _medicationsCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ecNameCtrl.dispose();
    _ecPhoneCtrl.dispose();
    _ecRelationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xff0043ba),
        foregroundColor: Colors.white,
        title: const Text('Edit profile'),
        elevation: 0,
        actions: [
          if (!_saving)
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AvatarPicker(
              avatarUrl: _displayAvatarUrl ?? widget.user.avatarUrl,
              uploading: _uploadingAvatar,
              onTap: _showAvatarOptions,
            ),
            const SizedBox(height: 20),
            _SectionHeader(label: 'Personal info', icon: Icons.person_outline),
            _Card(children: [
              // Email shown as read-only — populated from widget.user.email
              _ReadOnlyField(
                label: 'Email',
                value: widget.user.email ?? '',
                icon: Icons.email_outlined,
              ),
              _Field(
                controller: _fullNameCtrl,
                label: 'Full name',
                icon: Icons.badge_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              _Field(
                controller: _phoneCtrl,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _Field(
                controller: _addressCtrl,
                label: 'Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              _DateField(
                label: 'Date of birth',
                value: _dateOfBirth,
                onTap: _pickDate,
              ),
              _DropdownField<String>(
                label: 'Gender',
                icon: Icons.person_outline,
                value: _gender,
                items: _genders,
                onChanged: (v) => setState(() => _gender = v),
              ),
            ]),
            const SizedBox(height: 16),
            _SectionHeader(
                label: 'Medical info',
                icon: Icons.medical_information_outlined),
            _Card(children: [
              _DropdownField<String>(
                label: 'Blood group',
                icon: Icons.bloodtype_outlined,
                value: _bloodGroup,
                items: _bloodGroups,
                onChanged: (v) => setState(() => _bloodGroup = v),
              ),
              _Field(
                controller: _allergiesCtrl,
                label: 'Allergies',
                icon: Icons.warning_amber_outlined,
                hint: 'e.g. Penicillin, Peanuts',
                maxLines: 2,
              ),
              _Field(
                controller: _conditionsCtrl,
                label: 'Medical conditions',
                icon: Icons.monitor_heart_outlined,
                hint: 'e.g. Asthma, Diabetes',
                maxLines: 2,
              ),
              _Field(
                controller: _medicationsCtrl,
                label: 'Current medications',
                icon: Icons.medication_outlined,
                hint: 'e.g. Metformin 500mg',
                maxLines: 2,
              ),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: _weightCtrl,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      controller: _heightCtrl,
                      label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _SectionHeader(
                label: 'Emergency contact', icon: Icons.emergency_outlined),
            _Card(children: [
              _Field(
                controller: _ecNameCtrl,
                label: 'Contact name',
                icon: Icons.person_outline,
              ),
              _Field(
                controller: _ecRelationCtrl,
                label: 'Relation',
                icon: Icons.family_restroom_outlined,
                hint: 'e.g. Father, Spouse',
              ),
              _Field(
                controller: _ecPhoneCtrl,
                label: 'Contact phone',
                icon: Icons.phone_in_talk_outlined,
                keyboardType: TextInputType.phone,
              ),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0043ba),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Save changes',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable form widgets
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xff0043ba)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xff0043ba),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: children
            .expand((w) => [w, const SizedBox(height: 12)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[400], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff006df1), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(text: value != null ? _fmt(value!) : ''),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon:
            Icon(Icons.cake_outlined, color: Colors.blue[400], size: 20),
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xff006df1), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[400], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff006df1), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
          .toList(),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[400], size: 20),
        suffixIcon: const Tooltip(
          message: 'Email cannot be changed here',
          child: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      style: const TextStyle(color: Colors.grey),
    );
  }
}

// ─────────────────────────────────────────────
// Avatar picker widget
// ─────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.avatarUrl,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: uploading ? null : onTap,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: ClipOval(
                child: uploading
                    ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
            ),
          ),
          if (!uploading)
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xff0043ba),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xffe6f1fb),
      child: const Icon(Icons.person, size: 48, color: Color(0xff185fa5)),
    );
  }
}