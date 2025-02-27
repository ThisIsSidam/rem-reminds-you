extension DurationX on Duration {
  String friendly({
    bool addPlusSymbol = false,
  }) {
    final int minutes = inMinutes;
    String strDuration = '';

    if (addPlusSymbol) {
      if (minutes > 0) {
        strDuration += '+';
      }
    }

    if ((minutes < 59) && (minutes > -59)) {
      strDuration += '$minutes Min';
    } else if ((minutes < 1439) && (minutes > -1439)) {
      strDuration += '${minutes ~/ 60} Hr';
    } else {
      strDuration += '${(minutes ~/ 60) ~/ 24} Day';
    }

    return strDuration;
  }
}
