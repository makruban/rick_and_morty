import 'dart:convert';
import 'dart:io';

import 'package:riky_and_morty/core/error/exception.dart';
import 'package:riky_and_morty/feature/data/models/person_model.dart';

abstract class PersonRemoteDataSource {
  /// Calls the https://rickandmortyapi.com/api/character/?page=1 endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<PersonModel>> getAllPersons(int page);

  /// Calls the https://rickandmortyapi.com/api/character/?name=rick endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<PersonModel>> searchPerson(String query);
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  // final http.Client client;
  final HttpClient client;

  PersonRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PersonModel>> getAllPersons(int page) => _getPersonFromUrl(
      'https://rickandmortyapi.com/api/character/?page=$page');

  @override
  Future<List<PersonModel>> searchPerson(String query) => _getPersonFromUrl(
      'https://rickandmortyapi.com/api/character/?name=$query');

  Future<List<PersonModel>> _getPersonFromUrl(String url) async {
    print(url);
    // final response = await client
    //     .get(Uri.parse(url), headers: {'Content-Type': 'application/json'});
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    final response = await request.close();

    if (response.statusCode == 200) {
      final jsonStrings = await response.transform(utf8.decoder).toList();
      final jsonString = jsonStrings.join();

      final persons = json.decode(jsonString);
      return (persons['results'] as List)
          .map((person) => PersonModel.fromJson(person))
          .toList();
    } else {
      throw ServerException();
    }
  }
}
