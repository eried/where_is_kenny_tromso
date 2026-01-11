import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _locationRevealed = false;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showRevealConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text(
              'Reveal Location?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reveal Kenny\'s exact location?\n\n'
          'Half the fun is finding him yourself on Finnlandsfjellet!',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep it Hidden',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _locationRevealed = true);
            },
            child: const Text('Reveal', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f0f1a),
        title: const Text('About Kenny'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kenny Header
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'K',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'The Kenny Statue',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Text(
                'Finnlandsfjellet, Tromsø, Norway',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // The Story
            _buildSection(
              'The Mystery on the Mountain',
              'In July 2025, hikers on Finnlandsfjellet mountain in Tromsø, Norway, '
              'discovered something unusual. A golden bronze statue standing in a ring '
              'of carefully arranged stones.\n\n'
              'Aina Wikestad Sundfær (52) was hiking with her dog when she spotted '
              'something shiny in the open landscape. At first, she thought it was '
              'a Buddha or religious figure. But the hidden face and distinctive hood '
              'revealed the truth. It was Kenny McCormick from South Park!\n\n'
              'The mysterious appearance made national news and became a summer sensation '
              'in northern Norway.',
            ),
            const SizedBox(height: 24),

            // The Artist
            _buildSection(
              'The Artist Behind the Statue',
              '',
            ),
            const SizedBox(height: 8),
            Text(
              'The mystery was solved when the artist came forward. Erwin Ried, '
              'a Chilean software engineer living in Tromsø, created the statue.\n\n'
              'Kenny had to "come out" earlier than planned when a local newspaper '
              'discovered an old Reddit post about the statue\'s construction. The post sparked '
              'an unexpected cultural divide. Americans criticized placing '
              'a statue in pristine nature, while Norwegians embraced it with enthusiasm. '
              'Some Norwegians even argued that Kenny "beriker naturen" (enriches nature), '
              'adding character to the mountain landscape.\n\n'
              'When asked why Kenny, Erwin explained:\n'
              '"South Park is my favorite series! I feel Kenny and Tromsø are a good '
              'match. He\'s going to love the snow, the northern lights (nordlys) and more."\n\n'
              'Together with his friend Cristophe Dierick, Erwin carried the 14 kg Kenny '
              'sculpture up to Finnlandsfjellet.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 24),

            // The Creation
            _buildSection('The Creation', ''),
            const SizedBox(height: 8),
            Text(
              'This isn\'t just any statue. It\'s a labor of love and engineering:\n\n'
              '• 14 kilograms of ABS plastic\n'
              '• 3D printed over two weeks\n'
              '• Printed in multiple parts\n'
              '• Countless hours of assembly and gluing\n'
              '• Weather-resistant construction\n'
              '• Carried up the mountain by two people\n\n'
              'The statue was designed to withstand harsh Arctic conditions. '
              'From freezing winters to midnight sun summers.\n\n'
              'See Credits section below for 3D model and printing details.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 24),

            // The Location (Hidden by default)
            _buildSection('The Location', ''),
            const SizedBox(height: 12),
            if (!_locationRevealed)
              _buildHiddenLocation()
            else
              _buildRevealedLocation(),
            const SizedBox(height: 24),

            // Official Response
            _buildSection(
              'Official Response',
              'Henrik Romsaas, outdoor recreation advisor in Tromsø municipality, '
              'told Nordlys newspaper:\n\n'
              '"Kenny doesn\'t have permission to \'live\' on Finnlandsfjellet. '
              'However, as long as there\'s no pollution from it and it doesn\'t '
              'pose a danger to others or obstruct passage, I think it can just '
              'stay there until someone decides otherwise."',
            ),
            const SizedBox(height: 24),

            // Why Kenny?
            _buildSection(
              'Why Kenny?',
              '"Oh my God, they placed Kenny!"\n\n'
              'Kenny McCormick is known for his muffled speech (due to his hood), '
              'his unfortunate tendency to die in nearly every episode, and his '
              'immortal catchphrase: "Oh my God, they killed Kenny! You bastard!"\n\n'
              'The choice of Kenny represents humor, resilience, and the unexpected '
              'joy of finding something absurd in a beautiful, remote place.',
            ),
            const SizedBox(height: 32),

            // News Sources
            _buildSection('In the News', ''),
            const SizedBox(height: 12),
            _buildNewsLink(
              'Dagbladet',
              'Dukket opp - ler fortsatt',
              'https://www.dagbladet.no/nyheter/dukket-opp-ler-fortsatt/83374210',
            ),
            _buildNewsLink(
              'Dagbladet',
              'Fjellsjokk: Kunstneren står fram',
              'https://www.dagbladet.no/nyheter/fjellsjokk-star-fram/83378163',
            ),
            _buildNewsLink(
              'Nordlys',
              'Mysteriet er løst: Jeg tror Kenny kommer til å elske Tromsø',
              'https://www.nordlys.no/mysteriet-er-lost-jeg-tror-kenny-kommer-til-a-elske-tromso/s/5-34-2194006',
            ),
            _buildNewsLink(
              'Nordlys',
              'Hvem har gjort dette? – Jeg lo hele veien ned',
              'https://www.nordlys.no/hvem-har-gjort-dette-jeg-lo-hele-veien-ned/s/5-34-2193691',
            ),
            _buildNewsLink(
              'iTromsø',
              'Sjekk hvem som dukket opp på en fjelltopp på Kvaløya',
              'https://www.itromso.no/nyheter/i/0V1KjG/sjekk-hvem-som-dukket-opp-paa-en-fjelltopp-paa-kvaloeya',
            ),
            _buildNewsLink(
              'iTromsø',
              'Har skapt kontrovers: Nå svarer kunstneren på kritikken',
              'https://www.itromso.no/nyheter/i/QMVxpW/fjellskulptur-i-plast-skaper-kontrovers-visuell-forurensning',
            ),
            _buildNewsLink(
              'Reddit',
              'South Park Kenny statue discussion',
              'https://www.reddit.com/r/southpark/comments/1m8w1cq/this_thing_was_randomly_placed_in_a_mountain_in/',
            ),
            const SizedBox(height: 24),

            // Tag Kenny Online
            _buildSection('Tag Kenny Online', ''),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () async {
                  const hashtags = '#WhereIsKenny #KennyTromsø #Finnlandsfjellet #SouthPark #Tromso';
                  await Clipboard.setData(const ClipboardData(text: hashtags));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Hashtags copied to clipboard!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.3),
                        Colors.pink.withValues(alpha: 0.3),
                        Colors.orange.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.pink.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    '#WhereIsKenny #KennyTromsø\n#Finnlandsfjellet #SouthPark #Tromso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to copy all hashtags',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Visit Kenny
            _buildSection(
              'Visit Kenny',
              'Kenny is waiting for you! Whether you\'re a South Park fan, a hiking '
              'enthusiast, or someone who appreciates creative art installations, '
              'the trek to meet Kenny is worth it.\n\n'
              'Don\'t forget to:\n'
              '• Take a photo with Kenny\n'
              '• Respect the stone ring arrangement\n'
              '• Leave no trace (except footprints)\n'
              '• Share your visit online!',
            ),
            const SizedBox(height: 32),

            // Credits
            _buildSection('Credits', ''),
            const SizedBox(height: 12),
            _buildCreditLink(
              icon: Icons.brush,
              label: 'App & Statue',
              name: 'Erwin Ried',
              url: 'https://ried.cl',
            ),
            const SizedBox(height: 8),
            _buildCreditLink(
              icon: Icons.view_in_ar,
              label: '3D Model',
              name: 'JHN_K on Cults3D',
              url: 'https://cults3d.com/en/3d-model/art/kenny-mccormick-south-park',
            ),
            const SizedBox(height: 8),
            _buildCreditLink(
              icon: Icons.print,
              label: 'Printed on',
              name: 'BambuLab H2D by @eried',
              url: 'https://makerworld.com/en/@eried',
            ),
            const SizedBox(height: 8),
            _buildCreditLink(
              icon: Icons.volume_up,
              label: 'Sound effects',
              name: 'MyInstants.com',
              url: 'https://www.myinstants.com/en/search/?name=kenny',
            ),
            const SizedBox(height: 32),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'DISCLAIMER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'South Park, Kenny McCormick, and all related characters and elements '
                    'are trademarks of Comedy Central / Paramount Global.\n\n'
                    'This is an unofficial fan project. Neither this app nor its creator '
                    'have any affiliation with, authorization from, or endorsement by '
                    'Comedy Central, Paramount, South Park Studios, Matt Stone, or Trey Parker.\n\n'
                    'This project was made with love and respect for the show. '
                    'No copyright infringement is intended.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenLocation() {
    return Center(
      child: GestureDetector(
        onTap: _showRevealConfirmation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_open, color: Colors.orange, size: 20),
              SizedBox(width: 10),
              Text(
                'Reveal Location',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInMaps() {
    // Open in device's default map app
    final url = 'geo:69.705561,18.832721?q=69.705561,18.832721(Kenny)';
    final webUrl = 'https://www.google.com/maps/search/?api=1&query=69.705561,18.832721';

    // Try geo: URI first (works on Android), fallback to web URL
    _launchUrl(url).catchError((_) => _launchUrl(webUrl));
  }

  Widget _buildRevealedLocation() {
    return GestureDetector(
      onTap: _openInMaps,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green.withValues(alpha: 0.8)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Kenny\'s Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: Colors.green.withValues(alpha: 0.6),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLocationRow('Latitude', '69.705561°N'),
            _buildLocationRow('Longitude', '18.832721°E'),
            _buildLocationRow('Altitude', '488.8 meters'),
            const SizedBox(height: 12),
            Text(
              'Tap to open in Maps',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNewsLink(String source, String title, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.article, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditLink({
    required IconData icon,
    required String label,
    required String name,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramTag(String tag) {
    return GestureDetector(
      onTap: () => _launchUrl('https://www.instagram.com/explore/tags/${tag.replaceAll('#', '').replaceAll('ø', 'o')}/'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withValues(alpha: 0.3),
              Colors.pink.withValues(alpha: 0.3),
              Colors.orange.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.pink.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, color: Colors.pink.withValues(alpha: 0.8), size: 14),
            const SizedBox(width: 6),
            Text(
              tag,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
