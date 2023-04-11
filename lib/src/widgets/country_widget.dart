import 'package:flutter/material.dart';
import 'package:validity_phone_number/src/controller/controller.dart';
import 'package:validity_phone_number/validity_phone_number.dart';

class CountryCodeList extends StatefulWidget {
  final ValidityPhoneNumberController validityPhoneNumberController;
  final bool allowSearch;
  final String? searchHint;
  const CountryCodeList({Key? key, required this.validityPhoneNumberController, this.allowSearch = true, this.searchHint = 'Search...'}) : super(key: key);

  @override
  State createState() => _CountryCodeListState();
}

class _CountryCodeListState extends State<CountryCodeList> {
  final TextEditingController _searchController = TextEditingController(text: '');
  late List<Country> _countries;

  @override
  void initState() {
    _countries = widget.validityPhoneNumberController.getCountries;
    _searchController.addListener(_refresh);
    super.initState();
  }

  void _refresh() {
    widget.validityPhoneNumberController.searchKey = _searchController.text;
    setState(() {
      _countries = widget.validityPhoneNumberController.getCountries;
    });
  }

  @override
  void dispose() {
    widget.validityPhoneNumberController.resetSearchTitle();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, top: 10),
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.close)),
          ),
          if (widget.allowSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _countries.length,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    widget.validityPhoneNumberController.selectedCountry = _countries[index];
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            _countries[index].flagPath,
                            width: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _countries[index].dialCode,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _countries[index].name,
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
