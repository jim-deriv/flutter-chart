import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/chart_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'assets_search_bar.dart';
import 'market_item.dart';
import 'models.dart';
import 'no_result_page.dart';

/// Handles the tap on [Asset] in market selector.
///
/// [favouriteClicked] is true when the user has tapped on the favourite icon of
/// the item.
typedef OnAssetClicked = void Function({
  required Asset asset,
  required bool favouriteClicked,
});

/// The duration of animating the scroll to the selected item in the
/// [MarketSelector] widget.
const Duration scrollToSelectedDuration = Duration.zero;

/// A widget which is used to select the market of the chart.
class MarketSelector extends StatefulWidget {
  /// Initializes a widget which is used to select the market of the chart.
  const MarketSelector({
    required this.markets,
    Key? key,
    this.onAssetClicked,
    this.selectedItem,
    this.favouriteAssets,
    this.theme,
  }) : super(key: key);

  /// It will be called when a symbol item [Asset] is tapped.
  final OnAssetClicked? onAssetClicked;

  /// A `list` of markets which the user can select from.
  final List<Market> markets;

  /// The selected asset item which contains the details of the selected market.
  final Asset? selectedItem;

  /// `Optional` whenever it is null, it will be substituted with a list of
  /// assets that their [Asset.isFavourite] is true.
  final List<Asset?>? favouriteAssets;

  /// The theme of the chart which the market selector is being placed inside.
  final ChartTheme? theme;

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector>
    with SingleTickerProviderStateMixin {
  /// List of markets after applying the [_filterText].
  List<Market>? _marketsToDisplay;

  String _filterText = '';

  /// Is used to scroll to the selected symbol(Asset).
  GlobalObjectKey? _selectedItemKey;

  @override
  void initState() {
    super.initState();

    if (widget.selectedItem != null) {
      _selectedItemKey = GlobalObjectKey(widget.selectedItem!.name);
    }

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      if (_selectedItemKey != null &&
          _selectedItemKey!.currentContext != null) {
        Scrollable.ensureVisible(
          _selectedItemKey!.currentContext!,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _fillMarketsList();

    return ChartBottomSheet(
      theme: widget.theme,
      child: Column(
        children: <Widget>[
          AssetsSearchBar(
            onSearchTextChanged: (String text) =>
                setState(() => _filterText = text),
          ),
          _buildMarketsList(),
        ],
      ),
    );
  }

  void _fillMarketsList() {
    _marketsToDisplay = _filterText.isEmpty
        ? widget.markets
        : widget.markets
            .where((Market market) =>
                market.containsAssetWithText(lowerCaseFilterText))
            .toList();
  }

  List<Asset?> _getFavouritesList() {
    if (widget.favouriteAssets != null) {
      return _filterText.isEmpty
          ? widget.favouriteAssets as List<Asset?>
          : widget.favouriteAssets!
              .map((Asset? asset) => asset!.containsText(lowerCaseFilterText))
              .toList() as List<Asset?>;
    }

    final List<Asset?> favouritesList = <Asset?>[];

    for (final Market market in widget.markets) {
      for (final SubMarket? subMarket in market.subMarkets) {
        if (subMarket != null) {
          for (final Asset? asset in subMarket.assets) {
            if (asset != null &&
                asset.isFavourite &&
                asset.containsText(lowerCaseFilterText)) {
              favouritesList.add(asset);
            }
          }
        }
      }
    }

    return favouritesList;
  }

  Widget _buildMarketsList() {
    final List<Asset?> favouritesList = _getFavouritesList();

    return widget.markets.isEmpty || _marketsToDisplay == null
        ? const Expanded(child: Center(child: Text('No asset is available!')))
        : Expanded(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      _buildFavouriteSection(favouritesList),
                      ..._marketsToDisplay!
                          .map((Market market) => _buildMarketItem(market))
                    ],
                  ),
                ),
                if (_marketsToDisplay!.isEmpty) NoResultPage(text: _filterText),
              ],
            ),
          );
  }

  Widget _buildFavouriteSection(List<Asset?> favouritesList) => AnimatedSize(
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
        child: favouritesList.isEmpty
            ? const SizedBox(width: double.infinity)
            : _buildMarketItem(
                Market.fromSubMarketAssets(
                  name: 'favourites',
                  displayName: 'Favourites',
                  assets: favouritesList,
                ),
                isCategorized: false,
              ),
      );

  Widget _buildMarketItem(Market market, {bool isCategorized = true}) =>
      MarketItem(
        isSubMarketsCategorized: isCategorized,
        selectedItemKey: _selectedItemKey,
        filterText:
            market.containsText(lowerCaseFilterText) ? '' : lowerCaseFilterText,
        market: market,
        onAssetClicked: (
            {required Asset asset, required bool favouriteClicked}) {
          widget.onAssetClicked
              ?.call(asset: asset, favouriteClicked: favouriteClicked);

          if (favouriteClicked) {
            setState(() {
              asset.toggleFavourite();
            });
          }
        },
      );

  String get lowerCaseFilterText => _filterText.toLowerCase();
}
