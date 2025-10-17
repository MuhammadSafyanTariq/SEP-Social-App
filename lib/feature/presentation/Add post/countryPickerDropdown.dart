import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/size.dart';

class CountryPickerDropdown extends StatefulWidget {
  final Function(String) onCountrySelected; // Callback to handle country selection

  CountryPickerDropdown({required this.onCountrySelected});

  @override
  _CountryPickerDropdownState createState() => _CountryPickerDropdownState();
}

class _CountryPickerDropdownState extends State<CountryPickerDropdown> {
  TextEditingController _searchController = TextEditingController();
  List<Country> _allCountries = CountryService().getAll();
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = _allCountries; // Initialize with all countries
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = _allCountries
          .where((country) => country.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Select Country",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Country",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                _filterCountries(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  title: Text(country.name),
                  onTap: () {
                    widget.onCountrySelected(country.name); // Call the callback
                    Navigator.pop(context); // Close the modal
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}