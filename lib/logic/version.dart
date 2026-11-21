import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'progress.dart';
import 'settings.dart';

/// This app's version. Keep it the same as `version:` in pubspec.yaml (a test checks).
const appVersion = '1.6.1';

const latestReleaseApi = 'https://api.github.com/repos/Neclenic/hanzi-steps/releases/latest';
const releasesPage = 'https://github.com/Neclenic/hanzi-steps/releases/latest';

/// "v1.10.0" → [1, 10, 0]. Anything that isn't a number counts as 0.
List<int> versionParts(String v) {
  final clean = v.trim().replaceFirst(RegExp('^[vV]'), '').split(RegExp('[-+ ]')).first;
  final parts = [for (final p in clean.split('.')) int.tryParse(p) ?? 0];
  while (parts.length < 3) {
    parts.add(0);
  }
  return parts;
}

/// Whether [other] is a later version than [current].
bool isNewerVersion(String other, String current) {
  final a = versionParts(other), b = versionParts(current);
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return a.length > b.length;
}

class UpdateInfo {
  final String version; // e.g. "1.3.0"
  final String url; // the release page
  const UpdateInfo(this.version, this.url);
}

/// Reads the latest release from GitHub: returns its JSON body, or null.
typedef ReleaseFetcher = Future<String?> Function();

Future<String?> _fetchFromGitHub() async {
  final r = await http
      .get(Uri.parse(latestReleaseApi), headers: {'Accept': 'application/vnd.github+json'})
      .timeout(const Duration(seconds: 10));
  return r.statusCode == 200 ? r.body : null;
}

/// Looks on GitHub for a newer version, at most once a day.
class UpdateChecker extends ChangeNotifier {
  UpdateChecker._();
  static final UpdateChecker instance = UpdateChecker._();

  ReleaseFetcher fetcher = _fetchFromGitHub;

  UpdateInfo? _available;
  UpdateInfo? get available => _dismissed ? null : _available;
  bool _dismissed = false;

  void dismiss() {
    _dismissed = true;
    notifyListeners();
  }

  /// [force] checks even if it already checked today (the Settings button).
  /// Returns the newer version found, or null (none, or no internet).
  Future<UpdateInfo?> check(Progress p, {bool force = false, String current = appVersion}) async {
    if (!force && (!Settings.instance.updateCheck || p.updateChecked == Progress.todayKey)) return _available;
    try {
      final body = await fetcher();
      await p.setUpdateChecked();
      if (body == null) return null;
      final j = jsonDecode(body) as Map<String, dynamic>;
      final tag = (j['tag_name'] as String?) ?? '';
      if (j['draft'] == true || j['prerelease'] == true || !isNewerVersion(tag, current)) {
        _available = null;
      } else {
        _available = UpdateInfo(tag.replaceFirst(RegExp('^[vV]'), ''), (j['html_url'] as String?) ?? releasesPage);
        _dismissed = false;
      }
      notifyListeners();
      return _available;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }
}
