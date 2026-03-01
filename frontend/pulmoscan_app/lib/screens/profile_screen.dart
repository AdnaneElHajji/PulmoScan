// lib/screens/profile_screen.dart
// Écran profil du médecin - basé sur le design Figma

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Carte profil ──
            _buildCarteProfil(),
            const SizedBox(height: 16),

            // ── Paramètres ──
            _buildSection(
              titre: 'Paramètres',
              items: [
                _buildItem(
                  icone: Icons.edit_outlined,
                  titre: 'Modifier le profil',
                  sousTitre: 'Mettre à jour vos informations',
                  onTap: () => _afficherBientot(context),
                ),
                _buildItem(
                  icone: Icons.lock_outlined,
                  titre: 'Changer le mot de passe',
                  sousTitre: 'Sécurisez votre compte',
                  onTap: () => _afficherBientot(context),
                ),
                _buildItem(
                  icone: Icons.notifications_outlined,
                  titre: 'Notifications',
                  sousTitre: 'Gérer les préférences',
                  onTap: () => _afficherBientot(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── À propos ──
            _buildSection(
              titre: 'À propos',
              items: [
                _buildItem(
                  icone: Icons.help_outline,
                  titre: 'Aide et support',
                  onTap: () => _afficherBientot(context),
                ),
                _buildItem(
                  icone: Icons.description_outlined,
                  titre: 'Conditions d\'utilisation',
                  onTap: () => _afficherBientot(context),
                ),
                _buildItem(
                  icone: Icons.privacy_tip_outlined,
                  titre: 'Politique de confidentialité',
                  onTap: () => _afficherBientot(context),
                ),
                _buildItem(
                  icone: Icons.info_outline,
                  titre: 'Version de l\'application',
                  sousTitre: 'PulmoScan IA v1.0.0',
                  onTap: null,
                  afficherChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Bouton déconnexion ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _confirmerDeconnexion(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Color(0xFFD32F2F), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Carte avec photo et infos du médecin
  Widget _buildCarteProfil() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0059FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.person,
              size: 44,
              color: Color(0xFF0059FF),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Dr. Amina Benkirane',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pneumologue',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          // Infos rapides
          Row(
            children: [
              Expanded(
                child: _buildInfoRapide(
                  icone: Icons.email_outlined,
                  valeur: 'a.benkirane@hopital.ma',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoRapide(
                  icone: Icons.local_hospital_outlined,
                  valeur: 'CHU Ibn Rochd, Casablanca',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoRapide(
                  icone: Icons.calendar_today_outlined,
                  valeur: 'Membre depuis 2020',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRapide({required IconData icone, required String valeur}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icone, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Section avec titre et liste d'items
  Widget _buildSection({
    required String titre,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              titre,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icone,
    required String titre,
    String? sousTitre,
    required VoidCallback? onTap,
    bool afficherChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, size: 20, color: const Color(0xFF374151)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (sousTitre != null)
                    Text(
                      sousTitre,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
            if (afficherChevron)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _afficherBientot(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
    );
  }

  // Dialogue de confirmation de déconnexion
  void _confirmerDeconnexion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}