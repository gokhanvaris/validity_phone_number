import '../utils/converter.dart';
import 'package:flutter/material.dart';
import 'package:validity_phone_number/validity_phone_number.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as parserNumber;

class ValidityPhoneNumberController extends ChangeNotifier {
  final BuildContext _context;

  ValidityPhoneNumberController(
    this._context,
  );

  late List<Country> _allCountriesList;
  late List<Country> _countriesViewed;
  String? _errorTitle;
  String? _initCountryByCode;
  String? _initNumber;
  List<String>? _allowedCountries;
  List<String>? _notAllowedCountries;
  Function(String)? _onUnsupportedCountrySelected;

  late Country _selectedCountry;
  String _phoneNumber = '';
  String _searchTitle = '';
  bool _isValidPhoneOrNot = false;

  set initPhoneNumber(String initPhoneNumber) {
    _phoneNumber = initPhoneNumber;
    notifyListeners();
  }

  set errorTitle(String errorTitle) {
    _errorTitle = errorTitle;
  }

  Future init({String? initCountryByCode, List<String>? notAllowedCountries, List<String>? allowedCountries, String? initPhoneNumber, String? locale, String? errorTitle}) async {
    _allCountriesList = await loadCountries(_context, locale: locale);
    _countriesViewed = _allCountriesList;
    _selectedCountry = _allCountriesList.first;
    _errorTitle = errorTitle;
    _initCountryByCode = initCountryByCode;
    _notAllowedCountries = notAllowedCountries;
    _allowedCountries = allowedCountries;
    _initNumber = initPhoneNumber;
    _setValues();
  }

  set selectedCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  set searchKey(String search) {
    _searchTitle = search;
    notifyListeners();
  }

  set phoneNumber(String phone) {
    try {
      final phoneInfo = getPhoneNumberInfo(phone);
      _phoneNumber = phoneInfo.nsn;
      _selectedCountry = getCountryByDial(phoneInfo.countryCode);
    } catch (e) {
      _phoneNumber = phone;
    } finally {
      notifyListeners();
    }
  }

  Country get selectedCountry => _selectedCountry;
  String get phoneNumber => _phoneNumber;
  String get searchKey => _searchTitle;
  String get fullPhoneNumber => '${_selectedCountry.dialCode}$_phoneNumber';
  bool get isValidNumber => _isValidPhoneOrNot;

  List<Country> get getCountries {
    if (_searchTitle.isEmpty) {
      return _countriesViewed;
    }

    return _countriesViewed.where((element) => element.dialCode.contains(_searchTitle) || element.code.contains(_searchTitle.toUpperCase()) || element.name.contains(_searchTitle)).toList();
  }

  Country getCountryByDial(String dialCode) {
    return getCountries.firstWhere((country) => country.dialCode.replaceFirst('+', '') == dialCode, orElse: () {
      if (_onUnsupportedCountrySelected != null) {
        _onUnsupportedCountrySelected!(dialCode);
      }
      return _selectedCountry;
    });
  }

  Country getCountryByCode(String countryCode) {
    return getCountries.firstWhere((country) => country.code == countryCode, orElse: () {
      return _selectedCountry;
    });
  }

  String? validator(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _isValidPhoneOrNot = false;
      return _errorTitle ?? "enter a valid phone number";
    } else {
      try {
        final englishNumber = arabicNumberConverter(phoneNumber);
        final phoneInfo = getPhoneNumberInfo('${_selectedCountry.dialCode}$englishNumber');
        final isValid = phoneInfo.validate();
        _isValidPhoneOrNot = isValid;
        if (!isValid) {
          return _errorTitle ?? "enter a valid phone number";
        }
        return null;
      } catch (e) {
        return null;
      }
    }
  }

  parserNumber.PhoneNumber getPhoneNumberInfo(String phoneNumber) {
    return parserNumber.PhoneNumber.fromRaw(phoneNumber);
  }

  void _setValues() {
    try {
      if (_initCountryByCode != null) {
        _selectedCountry = getCountries.firstWhere(
          (country) => country.code == _initCountryByCode?.toUpperCase(),
        );
      } else {
        _selectedCountry = getCountries.first;
      }
      if (_initNumber != null && _initNumber!.isNotEmpty) {
        phoneNumber = _initNumber!;
      }
      if (_notAllowedCountries != null && _allowedCountries != null) {
        assert(false, ' You have to choose one. allowedCountries or notAllowedCountries');
      }
      if (_allowedCountries != null) {
        _countriesViewed = [..._allCountriesList.where((country) => _allowedCountries!.map((e) => e.toUpperCase()).contains(country.code)).toList()];
      } else if (_notAllowedCountries != null) {
        _countriesViewed = [..._allCountriesList.where((country) => !_notAllowedCountries!.map((e) => e.toUpperCase()).contains(country.code)).toList()];
      }

      notifyListeners();
    } catch (e) {
      assert(false, 'init country not included in all country list');
    }
  }

  void resetSearchTitle() {
    _searchTitle = '';
  }
}
