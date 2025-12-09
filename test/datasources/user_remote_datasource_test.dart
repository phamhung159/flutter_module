import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_module/data/api/api_client.dart';
import 'package:flutter_module/data/datasources/user_remote_datasource.dart';
import 'package:flutter_module/data/models/base_dto.dart';
import 'package:flutter_module/data/models/user_dto.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late UserRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = UserRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('UserRemoteDataSource - getUsers', () {
    group('Success Cases', () {
      test('getUsers returns BaseDTO with users when API call successful', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [
            UserDTO(name: 'User 1'), 
            UserDTO(name: 'User 2')
          ],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers(page: 1, pageSize: 10);

        // Assert
        expect(result, isNotNull);
        expect(result.code, 200);
        expect(result.message, 'Success');
        expect(result.data, isNotNull);
        expect(result.data?.length, 2);
        expect(result.data?.first.name, 'User 1');
        expect(result.data?.last.name, 'User 2');

        // Verify
        verify(() => mockApiClient.getUsers(1, 10)).called(1);
      });

      test('getUsers returns BaseDTO with single user', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [UserDTO(name: 'Single User')],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers();

        // Assert
        expect(result.data?.length, 1);
        expect(result.data?.first.name, 'Single User');
      });

      test('getUsers returns BaseDTO with empty list', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [],
        );

        when(() => mockApiClient.getUsers(2, 20))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers(page: 2, pageSize: 20);

        // Assert
        expect(result.data, isNotNull);
        expect(result.data, isEmpty);
        expect(result.data?.length, 0);
      });

      test('getUsers returns BaseDTO with null data', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'No data',
          data: null,
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers();

        // Assert
        expect(result.data, isNull);
        expect(result.code, 200);
      });

      test('getUsers passes correct pagination parameters', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [],
        );

        when(() => mockApiClient.getUsers(3, 25))
            .thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.getUsers(page: 3, pageSize: 25);

        // Assert - Verify parameters
        verify(() => mockApiClient.getUsers(3, 25)).called(1);
      });

      test('getUsers uses default pagination parameters', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.getUsers();

        // Assert - Verify default values
        verify(() => mockApiClient.getUsers(1, 10)).called(1);
      });
    });

    group('Error Cases', () {
      test('getUsers throws exception when API fails', () async {
        // Arrange
        when(() => mockApiClient.getUsers(1, 10))
            .thenThrow(Exception('Network Error'));

        // Act & Assert
        expect(
          () => dataSource.getUsers(),
          throwsA(isA<Exception>()
              .having((e) => e.toString(), 'message', contains('Network Error'))),
        );

        // Verify
        verify(() => mockApiClient.getUsers(1, 10)).called(1);
      });

      test('getUsers throws TimeoutException', () async {
        // Arrange
        when(() => mockApiClient.getUsers(1, 10))
            .thenThrow(TimeoutException('Request timeout'));

        // Act & Assert
        expect(
          () => dataSource.getUsers(),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('getUsers throws on socket exception', () async {
        // Arrange
        when(() => mockApiClient.getUsers(1, 10))
            .thenThrow(Exception('Socket exception'));

        // Act & Assert
        expect(
          () => dataSource.getUsers(),
          throwsException,
        );
      });

      test('getUsers rethrows original exception', () async {
        // Arrange
        final originalException = Exception('Original error');
        when(() => mockApiClient.getUsers(1, 10))
            .thenThrow(originalException);

        // Act & Assert
        expect(
          () => dataSource.getUsers(),
          throwsA(originalException),
        );
      });

      test('getUsers throws on 400 Bad Request', () async {
        // Arrange
        when(() => mockApiClient.getUsers(1, 10))
            .thenThrow(Exception('400 Bad Request'));

        // Act & Assert
        expect(
          () => dataSource.getUsers(),
          throwsException,
        );
      });

      test('getUsers throws on 401 Unauthorized', () async {
        // Arrange
        when(() => mockApiClient.getUsers(1, 10))
            .thenThrow(Exception('401 Unauthorized'));

        // Act & Assert
        expect(
          () => dataSource.getUsers(),
          throwsException,
        );
      });

      test('getUsers throws on 500 Internal Server Error', () async {
        // Arrange
        when(() => mockApiClient.getUsers(1, 10))
            .thenThrow(Exception('500 Internal Server Error'));

        // Act & Assert
        expect(
          () => dataSource.getUsers(),
          throwsException,
        );
      });
    });

    group('Multiple Calls', () {
      test('getUsers called exactly once', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.getUsers();

        // Assert
        verify(() => mockApiClient.getUsers(1, 10)).called(1);
      });

      test('getUsers called multiple times with different pages', () async {
        // Arrange
        final mockResponse1 = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [UserDTO(name: 'Page 1')],
        );
        final mockResponse2 = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [UserDTO(name: 'Page 2')],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse1);
        when(() => mockApiClient.getUsers(2, 10))
            .thenAnswer((_) async => mockResponse2);

        // Act
        final result1 = await dataSource.getUsers(page: 1, pageSize: 10);
        final result2 = await dataSource.getUsers(page: 2, pageSize: 10);

        // Assert
        expect(result1.data?.first.name, 'Page 1');
        expect(result2.data?.first.name, 'Page 2');
        verify(() => mockApiClient.getUsers(1, 10)).called(1);
        verify(() => mockApiClient.getUsers(2, 10)).called(1);
      });
    });

    group('Response Content Validation', () {
      test('getUsers validates response code', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 201,
          message: 'Created',
          data: [],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers();

        // Assert
        expect(result.code, 201);
      });

      test('getUsers validates response message', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Custom message',
          data: [],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers();

        // Assert
        expect(result.message, 'Custom message');
      });

      test('getUsers preserves UserDTO properties', () async {
        // Arrange
        final mockUserDTO = UserDTO(name: 'Test User');
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [mockUserDTO],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers();

        // Assert
        expect(result.data?.first.name, 'Test User');
      });

      test('getUsers handles large data sets', () async {
        // Arrange
        final largeDataSet = List.generate(
          100,
          (i) => UserDTO(name: 'User $i'),
        );
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: largeDataSet,
        );

        when(() => mockApiClient.getUsers(1, 100))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers(pageSize: 100);

        // Assert
        expect(result.data?.length, 100);
        expect(result.data?.first.name, 'User 0');
        expect(result.data?.last.name, 'User 99');
      });
    });

    group('Integration Scenarios', () {
      test('getUsers pagination flow: first page', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: List.generate(10, (i) => UserDTO(name: 'User $i')),
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers(page: 1, pageSize: 10);

        // Assert
        expect(result.data?.length, 10);
      });

      test('getUsers pagination flow: next page', () async {
        // Arrange
        final mockResponse = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: List.generate(10, (i) => UserDTO(name: 'User ${i + 10}')),
        );

        when(() => mockApiClient.getUsers(2, 10))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUsers(page: 2, pageSize: 10);

        // Assert
        expect(result.data?.first.name, 'User 10');
      });

      test('getUsers sequential calls maintain state', () async {
        // Arrange
        final response1 = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [UserDTO(name: 'User 1')],
        );
        final response2 = BaseDTO<List<UserDTO>>(
          code: 200,
          message: 'Success',
          data: [UserDTO(name: 'User 2')],
        );

        when(() => mockApiClient.getUsers(1, 10))
            .thenAnswer((_) async => response1);
        when(() => mockApiClient.getUsers(2, 10))
            .thenAnswer((_) async => response2);

        // Act
        final result1 = await dataSource.getUsers(page: 1);
        final result2 = await dataSource.getUsers(page: 2);

        // Assert
        expect(result1.data?.first.name, 'User 1');
        expect(result2.data?.first.name, 'User 2');
      });
    });
  });
}