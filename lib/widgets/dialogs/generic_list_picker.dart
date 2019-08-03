import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/model_structures.dart';
import 'package:log_ride/data/search_comparators.dart';
import 'package:log_ride/ui/dialogs/single_value_dialog.dart';

class GenericListPicker<T> extends StatefulWidget {
  GenericListPicker(this.toPickFrom,
      {this.itemBuilder,
      this.searchLabel = "Search",
      this.emptyString = "No Items in List",
      this.allowCustomSubmit = false,
      this.customLabel = "Custom Item...",
      this.customItemCallback});

  /// Generic list composed of entries in the list that is being picked from
  final List<T> toPickFrom;

  /// ItemBuilder for the list
  final Widget Function(
      BuildContext context, int index, dynamic item, String filter) itemBuilder;

  /// SearchLabel, defaults to "Search"
  final String searchLabel;

  /// Displayed when the list contains no items
  final String emptyString;

  /// Determines whether or not users can submit their own entries / items. Defaults to false
  final bool allowCustomSubmit;

  /// The label used on the custom submit list item. Defaults to "Custom Item..."
  final String customLabel;

  /// Callback given when the custom item is tapped. The list picker will close after the
  /// callback returns
  final Future<T> Function() customItemCallback;

  @override
  _GenericListPickerState createState() => _GenericListPickerState();
}

class _GenericListPickerState extends State<GenericListPicker> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  String filter = "";

  void _close<T>({T result}) {
    Navigator.of(context).pop(result);
  }

  @override
  void initState() {
    _textEditingController.addListener(() {
      if (_textEditingController.text != filter && mounted) {
        setState(() {
          filter = _textEditingController.text;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Dismissible(
          key: Key('key'),
          direction: DismissDirection.down,
          resizeDuration: null,
          onDismissed: (_) => _close(),
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: _close,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: BoxConstraints.expand(),
                    child: Container(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 56.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(15.0))),
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Container(),
                        ),

                        // Header
                        _buildSearchBar(context),

                        // Content
                        Expanded(
                          child: (widget.toPickFrom.length == 0)
                              ? (widget.allowCustomSubmit)
                                  ? SingleChildScrollView(
                                      child: _buildSuggestTile(context))
                                  : Center(child: Text(widget.emptyString))
                              : ListView.builder(
                                  itemCount: widget.toPickFrom.length + 1,
                                  physics: ClampingScrollPhysics(),
                                  controller: _scrollController,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < widget.toPickFrom.length) {
                                      return widget.itemBuilder(context, index,
                                          widget.toPickFrom[index], filter);
                                    } else if (widget.allowCustomSubmit) {
                                      return _buildSuggestTile(context);
                                    } else {
                                      return Container();
                                    }
                                  }),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.search),
        suffixIcon: (_textEditingController.text != "")
            ? IconButton(
                icon: Icon(FontAwesomeIcons.times),
                onPressed: () {
                  _textEditingController.text = "";
                },
              )
            : IconButton(
                icon: Icon(FontAwesomeIcons.times),
                onPressed: null,
              ),
        hintText: widget.searchLabel,
        labelText: widget.searchLabel,
      ),
    );
  }

  Widget _buildSuggestTile(BuildContext context) {
    return ListTile(
      title: Text(widget.customLabel),
      onTap: () async {
        if (widget.customItemCallback != null) {
          dynamic result = await widget.customItemCallback();
          _close(result: result);
        } else {
          _close();
        }
      },
    );
  }
}

class ManufacturerPicker extends StatelessWidget {
  ManufacturerPicker({@required this.manufacturers});

  final List<Manufacturer> manufacturers;

  @override
  Widget build(BuildContext context) {
    return GenericListPicker<Manufacturer>(
      manufacturers,
      searchLabel: "Search Manufacturers",
      emptyString: "No Manufacturers Found",
      itemBuilder: (BuildContext context, int index, dynamic m, String filter) {
        if (isManufacturerInSearch(m, filter)) {
          return ListTile(
            title: Text(m.name),
            onTap: () {
              Navigator.of(context).pop(m);
            },
          );
        } else {
          return Container();
        }
      },
      allowCustomSubmit: true,
      customLabel: "Suggest Manufacturer...",
      customItemCallback: () async {
        dynamic manName = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SingleValueDialog(
                type: SingleValueDialogType.TEXT,
                title: "Manufacturer Name",
                hintText: "ex: Intamin",
                submitText: "Submit",
              );
            });

        if (manName == null || manName == "") return null;

        return Manufacturer(name: manName);
      },
    );
  }
}

class ModelPicker extends StatelessWidget {
  ModelPicker({@required this.models});

  final List<Model> models;

  @override
  Widget build(BuildContext context) {
    return GenericListPicker<Model>(
      models,
      searchLabel: "Search Models",
      emptyString: "No Models Found",
      itemBuilder: (BuildContext context, int index, dynamic m, String filter) {
        if (isModelInSearch(m, filter)) {
          return ListTile(
            title: Text(m.name),
            onTap: () {
              Navigator.of(context).pop(m);
            },
          );
        } else {
          return Container();
        }
      },
      allowCustomSubmit: true,
      customLabel: "Suggest Model...",
      customItemCallback: () async {
        dynamic modName = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SingleValueDialog(
                type: SingleValueDialogType.TEXT,
                title: "Model Name",
                hintText: "ex: Omnimover",
                submitText: "Submit",
              );
            });

        if (modName == null || modName == "") return null;

        return Model(name: modName);
      },
    );
  }
}
