import 'package:flutter/material.dart';
import 'package:skilllink/models/exchange_type.dart';

Widget buildStatusBadge(String status) {
  Color backgroundColor;
  Color textColor;
  Color borderColor;
  String statusText;

  switch (status.toLowerCase()) {
    case 'active':
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      borderColor = Colors.green.shade200;
      statusText = 'Active';
      break;
    case 'pending':
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      borderColor = Colors.orange.shade200;
      statusText = 'Pending';
      break;
    case 'completed':
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      borderColor = Colors.blue.shade200;
      statusText = 'Completed';
      break;
    case 'expired':
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      borderColor = Colors.red.shade200;
      statusText = 'Expired';
      break;
    default:
      backgroundColor = Colors.grey.shade50;
      textColor = Colors.grey.shade700;
      borderColor = Colors.grey.shade200;
      statusText = status;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 1),
    ),
    child: Text(
      statusText,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ),
  );
}

Widget buildExchangeTypeBadge({
  required ExchangeType type,
  double iconSize = 14,
  double fontSize = 12,
}) {
  final isSkillExchange = type == ExchangeType.skillExchange;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: isSkillExchange ? Colors.green.shade50 : Colors.blue.shade50,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSkillExchange
            ? Colors.green.shade200
            : Colors.blue.shade200,
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSkillExchange ? Icons.swap_horiz : Icons.monetization_on,
          size: iconSize,
          color: isSkillExchange
              ? Colors.green.shade700
              : Colors.blue.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          isSkillExchange ? 'Skill Exchange' : 'Timecoin Exchange',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isSkillExchange
                ? Colors.green.shade700
                : Colors.blue.shade700,
          ),
        ),
      ],
    ),
  );
}
