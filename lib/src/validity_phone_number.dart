import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:validity_phone_number/src/controller/controller.dart';
import 'package:validity_phone_number/src/widgets/country_widget.dart';
import 'package:validity_phone_number/validity_phone_number.dart';

class PhoneNumberInput extends StatefulWidget {
  final ValidityPhoneNumberController? controller;
  final String? initValue;
  final String? initCountry;
  final List<String>? notAllowedCountries;
  final List<String>? allowedCountries;
  final void Function(String)? onChanged;
  final String? hintText;
  final bool showSelectedFlag;
  final InputBorder? border;
  final String locale;
  final String? searchHint;
  final bool allowSearch;
  final CountryMode countryListMode;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final String? errorText;
  const PhoneNumberInput({
    Key? key,
    this.controller,
    this.onChanged,
    this.initValue,
    this.initCountry,
    this.notAllowedCountries,
    this.allowedCountries,
    this.hintText,
    this.showSelectedFlag = true,
    this.border,
    this.locale = 'en',
    this.searchHint,
    this.allowSearch = true,
    this.countryListMode = CountryMode.bottomSheet,
    this.enabledBorder,
    this.focusedBorder,
    this.errorText,
  }) : super(key: key);

  @override
  _CountryCodePickerState createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<PhoneNumberInput> {
  late ValidityPhoneNumberController _validityPhoneNumberController;
  late TextEditingController _phoneNumberTextFieldController;
  late Future _initFuture;
  Country? _selectedCountry;

  @override
  void initState() {
    if (widget.controller == null) {
      _validityPhoneNumberController = ValidityPhoneNumberController(
        context,
      );
    } else {
      _validityPhoneNumberController = widget.controller!;
    }
    _initFuture = _init();
    _validityPhoneNumberController.addListener(_refresh);
    _phoneNumberTextFieldController = TextEditingController();
    super.initState();
  }

  Future _init() async {
    await _validityPhoneNumberController.init(
        initCountryByCode: widget.initCountry,
        notAllowedCountries: widget.notAllowedCountries,
        allowedCountries: widget.allowedCountries,
        initPhoneNumber: widget.initValue,
        errorTitle: widget.errorText,
        locale: widget.locale);
  }

  void _refresh() {
    _phoneNumberTextFieldController.value = TextEditingValue(
        text: _validityPhoneNumberController.phoneNumber,
        selection: TextSelection(baseOffset: _validityPhoneNumberController.phoneNumber.length, extentOffset: _validityPhoneNumberController.phoneNumber.length));

    setState(() {
      _selectedCountry = _validityPhoneNumberController.selectedCountry;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(_validityPhoneNumberController.fullPhoneNumber);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _phoneNumberTextFieldController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      FilteringTextInputFormatter.allow(kNumberRegex),
                    ],
                    onChanged: (v) {
                      _validityPhoneNumberController.initPhoneNumber = v;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validityPhoneNumberController.validator,
                    keyboardType: TextInputType.phone,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hintText,
                      border: widget.border,
                      hintStyle: const TextStyle(color: Color(0xFFB6B6B6)),
                      enabledBorder: widget.enabledBorder,
                      focusedBorder: widget.focusedBorder,
                      prefixIcon: InkWell(
                        onTap: _openCountryList,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_drop_down),
                            if (_selectedCountry != null && widget.showSelectedFlag)
                              Image.asset(
                                _selectedCountry!.flagPath,
                                height: 12,
                              ),
                            const SizedBox(
                              width: 4,
                            ),
                            if (_selectedCountry != null)
                              Text(
                                _selectedCountry!.dialCode,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: const Color(0xFFB9BFC5),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _openCountryList() {
    switch (widget.countryListMode) {
      case CountryMode.bottomSheet:
        showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            enableDrag: true,
            context: context,
            builder: (_) => SizedBox(
                  height: 500,
                  child: CountryCodeList(searchHint: widget.searchHint, allowSearch: widget.allowSearch, validityPhoneNumberController: _validityPhoneNumberController),
                ));
        break;
      case CountryMode.dialog:
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: SizedBox(
                    width: double.maxFinite,
                    child: CountryCodeList(searchHint: widget.searchHint, allowSearch: widget.allowSearch, validityPhoneNumberController: _validityPhoneNumberController),
                  ),
                ));
        break;
    }
  }
}
