import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

/// Enum to identify which color is being modified
enum ColorType {
  /// Color for the body of bullish candles
  bullishBody,

  /// Color for the body of bearish candles
  bearishBody,

  /// Color for the wick of bullish candles
  bullishWick,

  /// Color for the wick of bearish candles
  bearishWick
}

/// Screen that displays an OHLC chart with an indicator.
class OHLCChartWithIndicatorScreen extends BaseChartScreen {
  /// Initialize the OHLC chart with indicator screen.
  const OHLCChartWithIndicatorScreen({Key? key}) : super(key: key);

  @override
  State<OHLCChartWithIndicatorScreen> createState() =>
      _OHLCChartWithIndicatorScreenState();
}

class _OHLCChartWithIndicatorScreenState
    extends BaseChartScreenState<OHLCChartWithIndicatorScreen> {
  Color _bullishBodyColor = CandleBullishThemeColors.candleBullishBodyDefault;
  Color _bearishBodyColor = CandleBearishThemeColors.candleBearishBodyDefault;
  Color _bullishWickColor = CandleBullishThemeColors.candleBullishWickDefault;
  Color _bearishWickColor = CandleBearishThemeColors.candleBearishWickDefault;
  bool _showBollingerBands = true;
  int _bollingerPeriod = 20;
  double _bollingerDeviation = 2;
  final MovingAverageType _bollingerMAType = MovingAverageType.simple;
  bool _showCrosshair = true;
  bool _useLargeScreenCrosshair = kIsWeb; // Default based on platform
  bool _useDarkTheme = false;
  bool _useDrawingToolsV2 = true;

  // Create an indicators repository to manage indicators
  late final Repository<IndicatorConfig> _indicatorsRepo;

  @override
  void initState() {
    super.initState();
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      sharedPrefKey: 'ohlc_chart_with_indicator',
    );

    // Add initial indicators
    _updateIndicators();
  }

  void _updateIndicators() {
    // Clear existing indicators
    _indicatorsRepo.clear();

    // Add Bollinger Bands if enabled
    if (_showBollingerBands) {
      _indicatorsRepo.add(
        BollingerBandsIndicatorConfig(
          period: _bollingerPeriod,
          standardDeviation: _bollingerDeviation,
          movingAverageType: _bollingerMAType,
          upperLineStyle: const LineStyle(color: Colors.purple),
          middleLineStyle: const LineStyle(color: Colors.blue),
          lowerLineStyle: const LineStyle(color: Colors.purple),
        ),
      );
    }
  }

  @override
  String getTitle() => 'OHLC Chart with Indicator';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('ohlc_chart_with_indicator'),
      mainSeries: OhlcCandleSeries(
        candles,
        style: CandleStyle(
          candleBullishBodyColor: _bullishBodyColor,
          candleBearishBodyColor: _bearishBodyColor,
          candleBullishWickColor: _bullishWickColor,
          candleBearishWickColor: _bearishWickColor,
        ),
      ),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      activeSymbol: 'OHLC_CHART_WITH_INDICATOR',
      indicatorsRepo: _indicatorsRepo, // Pass the indicators repository
      showCrosshair: _showCrosshair,
      crosshairVariant: _useLargeScreenCrosshair
          ? CrosshairVariant.largeScreen
          : CrosshairVariant.smallScreen,
      theme: _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
      useDrawingToolsV2: _useDrawingToolsV2,
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Theme:'),
              const SizedBox(width: 8),
              const Text('Light'),
              Switch(
                value: _useDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _useDarkTheme = value;
                  });
                },
              ),
              const Text('Dark'),
            ],
          ),
          const SizedBox(height: 16),

          // Crosshair controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Show Crosshair:'),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showCrosshair,
                    onChanged: (value) {
                      setState(() {
                        _showCrosshair = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _useLargeScreenCrosshair = !_useLargeScreenCrosshair;
                  });
                },
                child: Text(
                  'Crosshair: ${_useLargeScreenCrosshair ? 'Large' : 'Small'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Drawing Tools V2 toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Drawing Tools V2:'),
              const SizedBox(width: 8),
              Switch(
                value: _useDrawingToolsV2,
                onChanged: (value) {
                  setState(() {
                    _useDrawingToolsV2 = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bollinger Bands Indicator controls
          Row(
            children: [
              const Text('Bollinger Bands:'),
              const SizedBox(width: 8),
              Switch(
                value: _showBollingerBands,
                onChanged: (value) {
                  setState(() {
                    _showBollingerBands = value;
                    _updateIndicators();
                  });
                },
              ),
            ],
          ),
          if (_showBollingerBands) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Period:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _bollingerPeriod.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 45,
                    label: _bollingerPeriod.toString(),
                    onChanged: (value) {
                      setState(() {
                        _bollingerPeriod = value.toInt();
                        _updateIndicators();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: Text(_bollingerPeriod.toString(),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Deviation:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _bollingerDeviation,
                    min: 1,
                    max: 4,
                    divisions: 6,
                    label: _bollingerDeviation.toString(),
                    onChanged: (value) {
                      setState(() {
                        _bollingerDeviation = value;
                        _updateIndicators();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: Text(_bollingerDeviation.toString(),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // OHLC chart controls
          _buildColorRow(
            label: 'Bullish Body:',
            colors: [
              CandleBullishThemeColors.candleBullishBodyDefault,
              CandleBullishThemeColors.candleBullishBodyActive,
              Colors.green,
              Colors.blue,
            ],
            colorType: ColorType.bullishBody,
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'Bearish Body:',
            colors: [
              CandleBearishThemeColors.candleBearishBodyDefault,
              CandleBearishThemeColors.candleBearishBodyActive,
              Colors.red,
              Colors.orange,
            ],
            colorType: ColorType.bearishBody,
          ),
          const SizedBox(height: 20),
          _buildColorRow(
            label: 'Bullish Wick:',
            colors: [
              CandleBullishThemeColors.candleBullishWickDefault,
              CandleBullishThemeColors.candleBullishWickActive,
              Colors.green,
              Colors.blue,
            ],
            colorType: ColorType.bullishWick,
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'Bearish Wick:',
            colors: [
              CandleBearishThemeColors.candleBearishWickDefault,
              CandleBearishThemeColors.candleBearishWickActive,
              Colors.red,
              Colors.orange,
            ],
            colorType: ColorType.bearishWick,
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow({
    required String label,
    required List<Color> colors,
    required ColorType colorType,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120, // Fixed width for labels to ensure alignment
          child: Text(label),
        ),
        ...colors
            .map((color) => _buildColorButton(color, colorType: colorType)),
      ],
    );
  }

  Widget _buildColorButton(Color color, {required ColorType colorType}) {
    late Color currentColor;

    switch (colorType) {
      case ColorType.bullishBody:
        currentColor = _bullishBodyColor;
        break;
      case ColorType.bearishBody:
        currentColor = _bearishBodyColor;
        break;
      case ColorType.bullishWick:
        currentColor = _bullishWickColor;
        break;
      case ColorType.bearishWick:
        currentColor = _bearishWickColor;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            switch (colorType) {
              case ColorType.bullishBody:
                _bullishBodyColor = color;
                break;
              case ColorType.bearishBody:
                _bearishBodyColor = color;
                break;
              case ColorType.bullishWick:
                _bullishWickColor = color;
                break;
              case ColorType.bearishWick:
                _bearishWickColor = color;
                break;
            }
          });
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: currentColor == color ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
