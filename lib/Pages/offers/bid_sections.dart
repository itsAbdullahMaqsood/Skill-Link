import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/models/sent_bid.dart';

Widget buildBidSection({
  required String label,
  required Color labelColor,
  required BidRequirement? offer,
  required BidRequirement? request,
  required String offerType,
  required String requestType,
}) {
  final isOfferSkill = offerType.toUpperCase() == 'SKILL';
  final isRequestSkill = requestType.toUpperCase() == 'SKILL';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: labelColor,
        ),
      ),
      const SizedBox(height: 8),
      _buildSideRow(
        sideLabel: 'Offers',
        icon: Icons.arrow_upward,
        color: Colors.green,
        requirement: offer,
        isSkill: isOfferSkill,
      ),
      const SizedBox(height: 8),
      _buildSideRow(
        sideLabel: 'Needs',
        icon: Icons.check_circle,
        color: Colors.purple,
        requirement: request,
        isSkill: isRequestSkill,
      ),
    ],
  );
}

Widget buildCounterSection({
  required String label,
  required Color accentColor,
  required String offerType,
  required String requestType,
  int? counterTimeCoins,
  int? counterBidderTeachingDuration,
  int? counterPosterTeachingDuration,
}) {
  final isSkillExchange =
      offerType.toUpperCase() == 'SKILL' &&
      requestType.toUpperCase() == 'SKILL';

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: accentColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        if (isSkillExchange) ...[
          _counterRow(
            icon: Icon(Icons.school_outlined, size: 13, color: accentColor),
            label: "Poster's learning duration",
            value: counterBidderTeachingDuration != null
                ? formatDuration(counterBidderTeachingDuration)
                : null,
            accentColor: accentColor,
          ),
        ] else ...[
          _counterRow(
            icon: SvgPicture.asset(
              'assets/images/timecoin.svg',
              width: 13,
              height: 13,
            ),
            label: 'TimeCoins',
            value: counterTimeCoins != null
                ? '$counterTimeCoins TimeCoins'
                : null,
            accentColor: accentColor,
          ),
        ],
        const SizedBox(height: 6),
        _counterRow(
          icon: Icon(Icons.timer_outlined, size: 13, color: accentColor),
          label: "Bidder's learning duration",
          value: counterPosterTeachingDuration != null
              ? formatDuration(counterPosterTeachingDuration)
              : null,
          accentColor: accentColor,
        ),
      ],
    ),
  );
}


Widget _buildSideRow({
  required String sideLabel,
  required IconData icon,
  required MaterialColor color,
  required BidRequirement? requirement,
  required bool isSkill,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.shade50,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color.shade700),
            const SizedBox(width: 6),
            Text(
              sideLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (isSkill)
          _buildSkillRow(requirement: requirement, color: color)
        else
          _buildTimecoinRow(requirement: requirement, color: color),
      ],
    ),
  );
}

Widget _buildSkillRow({
  required BidRequirement? requirement,
  required MaterialColor color,
}) {
  final skills = requirement?.skillNames ?? [];
  final originalDuration = requirement?.durationMinutes;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (skills.isNotEmpty)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                skill,
                style: TextStyle(fontSize: 11, color: color.shade700),
              ),
            );
          }).toList(),
        ),
      if (skills.isNotEmpty) const SizedBox(height: 4),
      Row(
        children: [
          Icon(Icons.timer_outlined, size: 13, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            originalDuration != null
                ? formatDuration(originalDuration)
                : 'Not specified',
            style: TextStyle(fontSize: 11, color: color.shade700),
          ),
        ],
      ),
    ],
  );
}

Widget _buildTimecoinRow({
  required BidRequirement? requirement,
  required MaterialColor color,
}) {
  final originalCoins = requirement?.timeCoins;

  return Row(
    children: [
      SvgPicture.asset('assets/images/timecoin.svg', width: 16, height: 16),
      const SizedBox(width: 6),
      Text(
        originalCoins != null ? '$originalCoins TimeCoins' : 'Not specified',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    ],
  );
}


Widget _counterRow({
  required Widget icon,
  required String label,
  required String? value,
  required Color accentColor,
}) {
  final hasValue = value != null;
  return Row(
    children: [
      icon,
      const SizedBox(width: 6),
      Text('$label: ', style: TextStyle(fontSize: 12, color: accentColor)),
      Flexible(
        child: Text(
          hasValue ? value : 'Same as original',
          style: TextStyle(
            fontSize: 12,
            fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
            fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
            color: hasValue ? accentColor : accentColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    ],
  );
}


String formatDuration(int minutes) {
  if (minutes >= 60) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }
  return '${minutes}m';
}

String timeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 365) return '${diff.inDays ~/ 365}y ago';
  if (diff.inDays >= 30) return '${diff.inDays ~/ 30}mo ago';
  if (diff.inDays >= 1) return '${diff.inDays}d ago';
  if (diff.inHours >= 1) return '${diff.inHours}h ago';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
  return 'Just now';
}
