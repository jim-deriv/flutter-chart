import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/dropdown_menu.dart'
    as deriv_dropdown;
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/field_widget.dart';

import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:flutter/material.dart' hide DropdownMenu;

import '../callbacks.dart';
import '../indicator_item.dart';
import 'smi_indicator_config.dart';

/// SMI indicator item in the list of indicator which provide this
/// indicators options menu.
class SMIIndicatorItem extends IndicatorItem {
  /// Initializes
  const SMIIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    SMIIndicatorConfig config = const SMIIndicatorConfig(),
  }) : super(
          key: key,
          title: 'SMI',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      SMIIndicatorItemState();
}

/// SMIItem State class
class SMIIndicatorItemState extends IndicatorItemState<SMIIndicatorConfig> {
  int? _period;
  int? _smoothingPeriod;
  int? _doubleSmoothingPeriod;
  double? _overboughtValue;
  double? _oversoldValue;
  MovingAverageType? _maType;
  int? _signalPeriod;

  @override
  SMIIndicatorConfig updateIndicatorConfig() =>
      (widget.config as SMIIndicatorConfig).copyWith(
          period: _currentPeriod,
          smoothingPeriod: _currentSmoothingPeriod,
          doubleSmoothingPeriod: _currentDoubleSmoothingPeriod,
          maType: _currentMAType,
          signalPeriod: _currentSignalPeriod,
          smiOscillatorLimits: OscillatorLinesConfig(
            overboughtValue: _currentOverboughtValue,
            oversoldValue: _currentOversoldValue,
          ));

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildSmoothingPeriodField(),
          _buildDoubleSmoothingPeriodField(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
          _buildMATypeField(),
          _buildSignalPeriodField(),
        ],
      );

  Widget _buildPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelPeriod,
        initialValue: _currentPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _period = int.tryParse(text);
          } else {
            _period = 10;
          }
          updateIndicator();
        },
      );

  Widget _buildSmoothingPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelSmoothingPeriod,
        initialValue: _currentSmoothingPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _smoothingPeriod = int.tryParse(text);
          } else {
            _smoothingPeriod = 3;
          }
          updateIndicator();
        },
      );

  Widget _buildDoubleSmoothingPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelDoubleSmoothingPeriod,
        initialValue: _currentDoubleSmoothingPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _doubleSmoothingPeriod = int.tryParse(text);
          } else {
            _doubleSmoothingPeriod = 3;
          }
          updateIndicator();
        },
      );

  Widget _buildSignalPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelSignalPeriod,
        initialValue: _currentSignalPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _signalPeriod = int.tryParse(text);
          } else {
            _signalPeriod = 10;
          }
          updateIndicator();
        },
      );

  int get _currentPeriod =>
      _period ?? (widget.config as SMIIndicatorConfig).period;

  int get _currentSmoothingPeriod =>
      _smoothingPeriod ?? (widget.config as SMIIndicatorConfig).smoothingPeriod;

  int get _currentDoubleSmoothingPeriod =>
      _doubleSmoothingPeriod ??
      (widget.config as SMIIndicatorConfig).doubleSmoothingPeriod;

  int get _currentSignalPeriod =>
      _signalPeriod ?? (widget.config as SMIIndicatorConfig).signalPeriod;

  Widget _buildOverBoughtPriceField() => FieldWidget(
        label: ChartLocalization.of(context).labelOverBoughtPrice,
        initialValue: _currentOverboughtValue.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overboughtValue = double.tryParse(text);
          } else {
            _overboughtValue = 80;
          }
          updateIndicator();
        },
      );

  double get _currentOverboughtValue =>
      _overboughtValue ??
      (widget.config as SMIIndicatorConfig).smiOscillatorLimits.overboughtValue;

  Widget _buildOverSoldPriceField() => FieldWidget(
        label: ChartLocalization.of(context).labelOverSoldPrice,
        initialValue: _currentOversoldValue.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _oversoldValue = double.tryParse(text);
          } else {
            _oversoldValue = 20;
          }
          updateIndicator();
        },
      );

  double get _currentOversoldValue =>
      _oversoldValue ??
      (widget.config as SMIIndicatorConfig).smiOscillatorLimits.oversoldValue;

  MovingAverageType get _currentMAType =>
      _maType ?? (widget.config as SMIIndicatorConfig).maType;

  Widget _buildMATypeField() => deriv_dropdown.DropdownMenu<MovingAverageType>(
        initialValue: _currentMAType,
        items: MovingAverageType.values,
        label: ChartLocalization.of(context).labelType,
        labelForItem: (MovingAverageType type) => type.name,
        onItemSelected: (MovingAverageType? newType) => setState(
          () {
            _maType = newType ?? MovingAverageType.simple;
            updateIndicator();
          },
        ),
      );
}
