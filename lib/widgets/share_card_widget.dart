// lib/widgets/share_card_widget.dart

import 'package:flutter/material.dart';
import '../services/share_card_service.dart';
import '../models/verse.dart';
import '../models/scenario.dart';

/// Widget for sharing content with beautiful card designs
/// Provides simple sharing functionality
class ShareCardWidget extends StatefulWidget {
  final Verse? verse;
  final Scenario? scenario;
  final VoidCallback? onShared;

  const ShareCardWidget({
    Key? key,
    this.verse,
    this.scenario,
    this.onShared,
  }) : super(key: key);

  @override
  State<ShareCardWidget> createState() => _ShareCardWidgetState();
}

class _ShareCardWidgetState extends State<ShareCardWidget> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 20),

          // Simple description
          _buildDescription(),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Share',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.share,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.verse != null
                  ? '🕉️ Bhagavad Gita ${widget.verse!.chapterId}.${widget.verse!.verseId}'
                  : widget.scenario?.title ?? 'Share this wisdom',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel Button - transparent
        Expanded(
          child: SizedBox(
            height: 52,
            child: TextButton(
              onPressed: _isSharing ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                backgroundColor: Colors.transparent,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Share Button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSharing
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: _isSharing ? 2 : 6,
                shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
              icon: _isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.share, size: 18),
              label: Text(
                _isSharing ? 'Creating...' : 'Share Card',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _shareCard() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      bool success = false;

      if (widget.verse != null) {
        success = await ShareCardService.instance.shareVerseCard(
          verse: widget.verse!,
        );
      } else if (widget.scenario != null) {
        success = await ShareCardService.instance.shareScenarioCard(
          scenario: widget.scenario!,
        );
      }

      if (success) {
        widget.onShared?.call();
        if (mounted) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Card shared successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to share card. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Share card error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

}