import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

/// Screen that displays a chart with barriers.
class BarriersScreen extends BaseChartScreen {
  /// Initialize the barriers screen.
  const BarriersScreen({Key? key}) : super(key: key);

  @override
  State<BarriersScreen> createState() => _BarriersScreenState();
}

class _BarriersScreenState extends BaseChartScreenState<BarriersScreen> {
  bool _showHorizontalBarrier = true;
  bool _showVerticalBarrier = true;
  bool _showTickIndicator = true;
  bool _showCrosshair = true;
  bool _useLargeScreenCrosshair = kIsWeb; // Default based on platform
  bool _useDarkTheme = false;
  bool _useDrawingToolsV2 = true;

  HorizontalBarrier? _horizontalBarrier;
  VerticalBarrier? _verticalBarrier;
  TickIndicator? _tickIndicator;

  Color _horizontalBarrierColor = Colors.green;
  Color _verticalBarrierColor = Colors.red;
  bool _isDashed = false;

  @override
  void initState() {
    super.initState();
    // Initialize barriers after the frame is rendered to ensure ticks are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBarriers();
    });
  }

  @override
  void didUpdateWidget(BarriersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize barriers when the widget updates
    _initializeBarriers();
  }

  void _initializeBarriers() {
    if (ticks.isEmpty) {
      debugPrint('Ticks list is empty, cannot initialize barriers');
      return;
    }

    final lastTick = ticks.last;

    // Calculate a price level in the middle of the range
    final quotes = ticks.map((tick) => tick.quote).toList();
    final minQuote = quotes.reduce((a, b) => a < b ? a : b);
    final maxQuote = quotes.reduce((a, b) => a > b ? a : b);
    final midQuote = (minQuote + maxQuote) / 2;

    _horizontalBarrier = HorizontalBarrier(midQuote,
        title: 'Price Level',
        style: HorizontalBarrierStyle(
          color: _horizontalBarrierColor,
          isDashed: _isDashed,
        ),
        visibility: HorizontalBarrierVisibility.normal);

    _verticalBarrier = VerticalBarrier.onTick(
      lastTick,
      title: 'Time Point',
      style: VerticalBarrierStyle(
        color: _verticalBarrierColor,
        isDashed: _isDashed,
      ),
    );

    final theme = Theme.of(context).brightness == Brightness.dark
        ? ChartDefaultDarkTheme()
        : ChartDefaultLightTheme();

    _tickIndicator = TickIndicator(
      lastTick,
      style: theme.currentSpotStyle.copyWith(
        color: Colors.orange,
      ),
      visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
    );

    // Force a rebuild to show the barriers
    if (mounted) {
      setState(() {});
    }
  }

  @override
  String getTitle() => 'Chart with Barriers';

  Widget _buildColorButton(Color color, {required bool isHorizontal}) {
    final currentColor =
        isHorizontal ? _horizontalBarrierColor : _verticalBarrierColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isHorizontal) {
              _horizontalBarrierColor = color;
            } else {
              _verticalBarrierColor = color;
            }
            _initializeBarriers();
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

  @override
  Widget buildChart() {
    final List<ChartAnnotation<ChartObject>> annotations = [];

    if (_showHorizontalBarrier &&
        ticks.isNotEmpty &&
        _horizontalBarrier != null) {
      annotations.add(_horizontalBarrier!);
    }

    if (_showVerticalBarrier && ticks.isNotEmpty && _verticalBarrier != null) {
      annotations.add(_verticalBarrier!);
    }

    if (_showTickIndicator && ticks.isNotEmpty && _tickIndicator != null) {
      annotations.add(_tickIndicator!);
    }

    return DerivChart(
      key: const Key('barriers_chart'),
      mainSeries: LineSeries(ticks, style: const LineStyle(hasArea: true)),
      annotations: annotations,
      controller: controller,
      pipSize: 2,
      granularity: 60000, // 1 minute
      activeSymbol: 'BARRIERS_CHART',
      showCrosshair: _showCrosshair,
      crosshairVariant: _useLargeScreenCrosshair
          ? CrosshairVariant.largeScreen
          : CrosshairVariant.smallScreen,
      theme: _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
      useDrawingToolsV2: _useDrawingToolsV2,
    );
  }

  Widget _buildBarrierToggle(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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

          // First row: Horizontal and Vertical toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildBarrierToggle(
                      'Horizontal:', _showHorizontalBarrier, (value) {
                    setState(() {
                      _showHorizontalBarrier = value;
                    });
                  }),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: _buildBarrierToggle('Vertical:', _showVerticalBarrier,
                      (value) {
                    setState(() {
                      _showVerticalBarrier = value;
                    });
                  }),
                ),
              ),
            ],
          ),

          // Crosshair controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildBarrierToggle('Show Crosshair:', _showCrosshair,
                      (value) {
                    setState(() {
                      _showCrosshair = value;
                    });
                  }),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _useLargeScreenCrosshair = !_useLargeScreenCrosshair;
                      });
                    },
                    child: Text(
                      'Crosshair: ${_useLargeScreenCrosshair ? 'Large' : 'Small'}',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Second row: Tick toggle centered
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildBarrierToggle('Tick:', _showTickIndicator, (value) {
              setState(() {
                _showTickIndicator = value;
              });
            }),
          ),

          // Third row: Dashed toggle and H-Color
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildBarrierToggle('Dashed:', _isDashed, (value) {
                    setState(() {
                      _isDashed = value;
                      _initializeBarriers();
                    });
                  }),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('H-Color:'),
                      const SizedBox(width: 8),
                      _buildColorButton(Colors.green, isHorizontal: true),
                      _buildColorButton(Colors.blue, isHorizontal: true),
                      _buildColorButton(Colors.purple, isHorizontal: true),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fourth row: V-Color centered
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('V-Color:'),
                const SizedBox(width: 8),
                _buildColorButton(Colors.red, isHorizontal: false),
                _buildColorButton(Colors.orange, isHorizontal: false),
                _buildColorButton(Colors.pink, isHorizontal: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
