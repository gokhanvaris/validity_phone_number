A Highly customizable Phone input Flutter widget that supports country code, validation.

<p float="center">
  <img src="https://www.mindinventory.com/blog/wp-content/uploads/2022/10/flutter-3.png" width="30%" />
  <img src="https://www.mindinventory.com/blog/wp-content/uploads/2022/10/flutter-3.png" width="30%" />
  <img src="https://www.mindinventory.com/blog/wp-content/uploads/2022/10/flutter-3.png" width="30%" />
  

</p>

## Features

- Phone number with international validation
- Include only specific countries
- Exclude specific countries
- Set a phone number using a controller (Selected country will be updated automatically)

## Getting started
Install the package `validity_phone_number`:
```
flutter pub add validity_phone_number
```


## Usage
A full and rich example can be found in [`/example`](example/) folder.


### Simple usage
```dart
 ValidityPhoneNumber(initialCountry: 'TR', locale: 'tr' etc.)
```

### Show countries as dialog (default is bottom sheet)
```dart
 const ValidityPhoneNumber(
    initialCountry: 'TR',
    locale: 'tr',
    countryListMode: CountryMode.dialog,
    )
```

### Custom borders
```dart
 ValidityPhoneNumber(
    initialCountry: 'TR',
    locale: 'tr',
    countryListMode: CountryMode.dialog,
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.blue)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue))
    )
```

### Select Phone number programmatically
To be able to select a phone number programmatically, we first need to define a `ValidityPhoneNumberController` :

```dart
ValidityPhoneNumberController _validityPhoneNumberController = ValidityPhoneNumberController(context);
```
```dart
 ValidityPhoneNumber(
     controller: _validityPhoneNumberController
    ...
```

Select the desired phone number:
```dart
_validityPhoneNumberController.phoneNumber = '+90...'
```


