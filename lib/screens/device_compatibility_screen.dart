import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/device_compatibility_service.dart';
import '../l10n/app_localizations.dart';

class DeviceCompatibilityScreen extends StatefulWidget {
  const DeviceCompatibilityScreen({Key? key}) : super(key: key);

  @override
  State<DeviceCompatibilityScreen> createState() => _DeviceCompatibilityScreenState();
}

class _DeviceCompatibilityScreenState extends State<DeviceCompatibilityScreen> {
  DeviceCompatibilityResult? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCompatibility();
  }

  Future<void> _checkCompatibility() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await DeviceCompatibilityService.checkCompatibility();
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: theme.brightness == Brightness.dark 
                ? Colors.black.withAlpha((0.32 * 255).toInt()) 
                : null,
              colorBlendMode: theme.brightness == Brightness.dark 
                ? BlendMode.darken 
                : null,
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.phone_android,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Device Compatibility Check',
                          style: GoogleFonts.poiretOne(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check if your device can run GitaWisdom smoothly',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Results
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingWidget(theme)
                        : _result != null
                            ? _buildResultWidget(theme)
                            : _buildErrorWidget(theme),
                  ),
                ],
              ),
            ),
          ),
          
          // Back button
          Positioned(
            top: 40,
            right: 20,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Checking your device compatibility...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultWidget(ThemeData theme) {
    final result = _result!;
    final isCompatible = result.isCompatible;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Overall status
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isCompatible 
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
              border: Border.all(
                color: isCompatible ? Colors.green : Colors.orange,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  isCompatible ? Icons.check_circle : Icons.warning,
                  size: 64,
                  color: isCompatible ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  isCompatible 
                    ? 'Your Device is Compatible! ✅'
                    : 'Compatibility Issues Found ⚠️',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCompatible ? Colors.green : Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Compatibility Score: ${result.compatibilityScore}/100',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Device info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                if (result.manufacturer != null)
                  _buildInfoRow('Device', '${result.manufacturer} ${result.deviceModel}', theme),
                if (result.androidVersion != null)
                  _buildInfoRow('Android Version', '${result.androidVersion} (API ${result.androidSdkInt})', theme),
                _buildCheckRow('Minimum Android Version', result.meetsMinimumVersion, theme),
                _buildCheckRow('RAM Requirements', result.hasEnoughRam, theme),
                _buildCheckRow('Storage Requirements', result.hasEnoughStorage, theme),
                _buildCheckRow('Graphics Support', result.supportsGraphics, theme),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          if (!isCompatible) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Having trouble installing?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _sendSupportEmail,
                    icon: const Icon(Icons.email),
                    label: const Text('Contact Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _checkCompatibility,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Again'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to check compatibility',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _checkCompatibility,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool isOk, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isOk ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSupportEmail() async {
    if (_result == null) return;
    
    final emailContent = DeviceCompatibilityService.generateSupportEmailContent(_result!);
    final emailUrl = Uri(
      scheme: 'mailto',
      path: 'support@hub4apps.com',
      query: Uri.encodeQueryComponent(emailContent),
    );
    
    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please contact support@hub4apps.com for help'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please contact support@hub4apps.com for help'),
          ),
        );
      }
    }
  }
}