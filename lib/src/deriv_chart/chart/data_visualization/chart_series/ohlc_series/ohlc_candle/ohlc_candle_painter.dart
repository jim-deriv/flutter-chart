import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../../data_painter.dart';
import '../../data_series.dart';
import '../ohlc_painting.dart';
import '../ohlc_painter.dart';

/// A [DataPainter] for painting Ohlc CandleStick data.
class OhlcCandlePainter extends OhlcPainter {
  /// Initializes
  OhlcCandlePainter(DataSeries<Candle> series) : super(series);

  late Color _candleBullishBodyColor;
  late Color _candleBearishBodyColor;
  late Color _neutralColor;

  @override
  void onPaintCandle(
    Canvas canvas,
    OhlcPainting currentPainting,
    OhlcPainting prevPainting,
  ) {
    final CandleStyle style = series.style as CandleStyle? ?? theme.candleStyle;

    _candleBullishBodyColor = style.candleBullishBodyColor;
    _candleBearishBodyColor = style.candleBearishBodyColor;
    _neutralColor = style.neutralColor;

    final Color _candleColor = currentPainting.yClose > prevPainting.yClose
        ? _candleBearishBodyColor
        : currentPainting.yClose < prevPainting.yClose
            ? _candleBullishBodyColor
            : _neutralColor;

    _drawWick(canvas, _candleColor, currentPainting);
    _drawOpenCloseLines(canvas, _candleColor, currentPainting);
  }

  void _drawWick(Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas.drawLine(
      Offset(currentPainting.xCenter, currentPainting.yHigh),
      Offset(currentPainting.xCenter, currentPainting.yLow),
      Paint()
        ..color = color
        ..strokeWidth = 1.2,
    );
  }

  void _drawOpenCloseLines(
      Canvas canvas, Color color, OhlcPainting currentPainting) {
    // Paint openning
    canvas
      ..drawLine(
        Offset(currentPainting.xCenter - currentPainting.width / 2,
            currentPainting.yOpen),
        Offset(currentPainting.xCenter, currentPainting.yOpen),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      )

      // Paint closing
      ..drawLine(
        Offset(currentPainting.xCenter + currentPainting.width / 2,
            currentPainting.yClose),
        Offset(currentPainting.xCenter, currentPainting.yClose),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );
  }
}
