import 'package:flutter/widgets.dart';


/// Telugu display text for fixed values that come from the server or are sent
/// to it (module names, rate types, languages, gender). Only what is shown
/// changes; the original English value is what the app keeps and sends.
/// Anything not listed (for example a customer's service name) stays as sent.
const Map<String, String> _teluguLabels = {
  'home services': 'ఇంటి సేవలు',
  'online': 'ఆన్‌లైన్',
  'offline': 'ఆఫ్‌లైన్',
  'outstation': 'బయటి ఊరు',
  'manual gare': 'మాన్యువల్ గేర్',
  'auto gare': 'ఆటో గేర్',
  'electric vehicle': 'ఎలక్ట్రిక్ వాహనం',
  'highway driving expert': 'హైవే డ్రైవింగ్ నిపుణులు',
  'women-friendly driver': 'మహిళలకు అనుకూలమైన డ్రైవర్',
  'trained for elderly assistance': 'వృద్ధుల సహాయంలో శిక్షణ పొందినవారు',
  'personal care services': 'వ్యక్తిగత సంరక్షణ సేవలు',
  'physiotherapy': 'ఫిజియోథెరపీ',
  'nursing': 'నర్సింగ్',
  'learning services': 'విద్యా సేవలు',
  'caregiver': 'కేర్‌గివర్',
  'main branch': 'ప్రధాన శాఖ',
  '0 - 5 yrs': '0 - 5 సంవత్సరాలు',
  '6 - 10 yrs': '6 - 10 సంవత్సరాలు',
  '10 - 20 yrs': '10 - 20 సంవత్సరాలు',
  '20+ yrs': '20+ సంవత్సరాలు',
  'personal driver': 'పర్సనల్ డ్రైవర్',
  'pandit / purohit': 'పండిట్ / పురోహితులు',
  'medical & personal care': 'వైద్య & వ్యక్తిగత సంరక్షణ',
  'medical service': 'వైద్య సేవ',
  'hourly': 'గంటల వారీగా',
  'days': 'రోజుల వారీగా',
  '24 hours': '24 గంటలు',
  'per hour': 'గంటకు',
  'per day': 'రోజుకు',
  'per 24 hours': '24 గంటలకు',
  'fixed': 'స్థిర ధర',
  'per service': 'ఒక్కో సేవకు',
  'per trip / day': 'ఒక్కో ట్రిప్ / రోజుకు',
  'service order': 'సేవ ఆర్డర్',
  'wallet': 'వాలెట్',
  'english': 'ఇంగ్లీష్',
  'hindi': 'హిందీ',
  'telugu': 'తెలుగు',
  'male': 'పురుషుడు',
  'female': 'స్త్రీ',
};

/// Telugu names the server itself sends (`mlName.te`), learned as lists load.
final Map<String, String> _learnedTelugu = {};

/// Remembers a row's Telugu name, so any screen can show it.
void learnTeluguName(Map<String, dynamic> row) {
  final name = row['Name'];
  final ml = row['mlName'];
  final te = ml is Map ? ml['te'] : null;
  if (name is String && te is String && te.trim().isNotEmpty) {
    _learnedTelugu[name.trim().toLowerCase()] = te.trim();
  }
}

extension ServerLabels on BuildContext {
  String serverLabel(String value) {
    if (Localizations.maybeLocaleOf(this)?.languageCode != 'te') return value;
    final key = value.trim().toLowerCase();
    return _learnedTelugu[key] ?? _teluguLabels[key] ?? value;
  }
}
