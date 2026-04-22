import 'package:flutter/material.dart';

class TradeIcon {
  TradeIcon._();

  static IconData forTrade(String trade) =>
      switch (trade.toLowerCase().trim()) {
        'electrician' => Icons.bolt_rounded,
        'plumber' => Icons.plumbing_rounded,
        'hvac' || 'ac' => Icons.ac_unit_rounded,
        'carpenter' => Icons.handyman_rounded,
        _ => Icons.build_rounded,
      };
}
