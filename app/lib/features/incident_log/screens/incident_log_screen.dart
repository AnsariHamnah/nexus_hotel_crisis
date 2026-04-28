import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../widgets/main_scaffold.dart';

class IncidentLogScreen extends StatelessWidget {
  const IncidentLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const textOnSurface = Color(0xFF021D34);

    return MainScaffold(
      currentIndex: 4,
      title: 'AUDIT_LOGS',
      body: Column(
        children: [
          // AI Summary Header (Placeholder for donor's Gemini feature)
          Container(
            padding: const EdgeInsets.all(24),
            color: const Color(0xFFEFF6FF), // blue-50
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 20),
                    const SizedBox(width: 8),
                    Text('AI AFTER-ACTION REPORT', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('alerts')
                      .where('ai_summary_formatted', isNotEqualTo: null)
                      .orderBy('ai_summary_formatted') // Required for where clause
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String summaryText = 'INITIALIZING INTELLIGENCE SYNTHESIS... [NO RECENT INCIDENTS FOUND FOR SUMMARY]';
                    
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      summaryText = snapshot.data!.docs.first.get('ai_summary_formatted') ?? summaryText;
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: textOnSurface, width: 2),
                      ),
                      child: Text(
                        summaryText,
                        style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(height: 2, color: textOnSurface),

          // Real-time Audit Logs List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('audit_logs_global')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final logs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final logData = logs[index].data() as Map<String, dynamic>;
                    return _buildLogCard(logData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'NO_LOGS_AVAILABLE',
        style: GoogleFonts.spaceGrotesk(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> data) {
    const textOnSurface = Color(0xFF021D34);
    final String action = data['action'] ?? 'UNKNOWN';
    final String details = data['details'] ?? '';
    final String performedBy = data['performedBy'] ?? 'System';
    final Timestamp? timestamp = data['timestamp'];
    final String timeString = timestamp != null
        ? DateFormat('HH:mm:ss • MMM dd').format(timestamp.toDate())
        : 'Pending...';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: textOnSurface, width: 2),
        boxShadow: const [BoxShadow(color: Color(0xFF94A3B8), offset: Offset(4, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            border: Border.all(color: textOnSurface, width: 1.5),
          ),
          child: Icon(
            action.contains('SWEEP') ? Icons.cleaning_services :
            action.contains('DISPATCH') ? Icons.local_police :
            Icons.history,
            color: textOnSurface,
          ),
        ),
        title: Text(
          action,
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16, color: textOnSurface),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(details, style: GoogleFonts.spaceGrotesk(fontSize: 14, color: const Color(0xFF64748B))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('OPERATOR: ${performedBy.toUpperCase()}', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: textOnSurface)),
                Text(timeString, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: const Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
