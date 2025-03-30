  double round(double value, {double precision = 100000000}) {
    return (value * precision).round() / precision;
  }