class Logger {
  Logger._();

  static final Logger instance = Logger._();

  String _stamp() => DateTime.now().toIso8601String();

  String _fmt(String level, String msg, Object? meta) {
    if (meta == null) return '[${_stamp()}] [$level] $msg';
    return '[${_stamp()}] [$level] $msg ${_safeJson(meta)}';
  }

  String _safeJson(Object meta) {
    try {
      return meta.toString();
    } catch (_) {
      return '<meta_unprintable>';
    }
  }

  void info(String msg, [Object? meta]) {
    // ignore: avoid_print
    print(_fmt('INFO', msg, meta));
  }

  void warn(String msg, [Object? meta]) {
    // ignore: avoid_print
    print(_fmt('WARN', msg, meta));
  }

  void error(String msg, [Object? meta]) {
    // ignore: avoid_print
    print(_fmt('ERROR', msg, meta));
  }
}
