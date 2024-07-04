
import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/utilities/models.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/data/picture_manager.dart';

import 'picture_manager_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BuildContext>(),
  MockSpec<Bubble>(),
  MockSpec<PictureQuery>(),
  MockSpec<UserManager>(),
  MockSpec<DeviceInfoPlugin>(),
  MockSpec<ImagePicker>(),
  MockSpec<ImageCropper>(),
  MockSpec<Permission>(),
  MockSpec<ErrorHandling>(),
])
void main() {
  final mockBuildContext = MockBuildContext();
  final mockBubble = MockBubble();
  final mockPictureQuery = MockPictureQuery();
  final mockUserManager = MockUserManager();
  final mockImagePicker = MockImagePicker();
  final mockImageCropper = MockImageCropper();
  final mockPermission = MockPermission();

  setUp(() {
    when(mockBuildContext.mounted).thenReturn(true);
  });

  group('PictureManager', () {
    test('removeMainPicture should remove profile picture and update bubble avatar', () async {
      Models.pictureQuery = mockPictureQuery;

      when(mockPictureQuery.removeProfilePicture(any)).thenAnswer((_) async {});

      await PictureManager.removeMainPicture(mockBuildContext, mockBubble);

      verify(mockPictureQuery.removeProfilePicture(any)).called(1);
      verify(mockBubble.avatar = Image.asset(Constants.defaultPictureAddress).image).called(1);
    });

    test('changeMainPicture should update bubble avatar on successful upload', () async {
      Models.pictureQuery = mockPictureQuery;
      Models.userManager = mockUserManager;

      when(mockPictureQuery.uploadAvatar(any)).thenAnswer((_) async => 'http://example.com/avatar.png');
      when(mockUserManager.refreshAvatar(any)).thenAnswer((_) async => const NetworkImage('http://example.com/avatar.png'));

      await PictureManager.changeMainPicture(mockBuildContext, 'test_path', mockBubble);

      verify(mockPictureQuery.uploadAvatar(any)).called(1);
      verify(mockUserManager.refreshAvatar(any)).called(1);
    });

    testWidgets('changeMainPicture should show error on failure', (WidgetTester tester) async {
      // Mock
      Models.pictureQuery = mockPictureQuery;
      when(mockPictureQuery.uploadAvatar(any)).thenThrow(Exception('Error'));
      BuildContext? ctx;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    ctx = context;
                    await PictureManager.changeMainPicture(ctx!, 'test_path', mockBubble);
                  },
                  child: const Text('Show Terms and Conditions'),
                ),
              );
            },
          ),
        ),
      );

      // Trigger the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify
      verifyNever(mockBubble.avatar = Image.asset(Constants.defaultPictureAddress).image);
      verify(ErrorHandling.showError(ctx!, 'Failed to update your profile picture. Please try again.')).called(1);
    });

    testWidgets('takeProfilePicture should show choice dialog', (WidgetTester tester) async {
      // Mock
      Models.pictureQuery = mockPictureQuery;
      BuildContext? ctx;
      when(mockBuildContext.mounted).thenReturn(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    ctx = context;
                    await PictureManager.takeProfilePicture(ctx!, (String? val) {});
                  },
                  child: const Text('Show Terms and Conditions'),
                ),
              );
            },
          ),
        ),
      );

      // Trigger the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(mockBuildContext.mounted).called(1);
    });

    test('cameraPicture should request permission and pick image', () async {
      when(mockBuildContext.mounted).thenReturn(true);
      when(mockPermission.status).thenAnswer((_) async => PermissionStatus.granted);
      when(mockImagePicker.pickImage(source: anyNamed('source'), imageQuality: anyNamed('imageQuality'))).thenAnswer((_) async => XFile('test_path'));
      when(mockImageCropper.cropImage(
        sourcePath: anyNamed('sourcePath'),
        compressQuality: anyNamed('compressQuality'),
        aspectRatioPresets: anyNamed('aspectRatioPresets'),
        uiSettings: anyNamed('uiSettings'),
      )).thenAnswer((_) async => CroppedFile('test_path'));

      await PictureManager.cameraPicture(mockBuildContext, (String? path) {});

      verify(mockImagePicker.pickImage(source: ImageSource.camera, imageQuality: 20)).called(1);
      verify(mockImageCropper.cropImage(sourcePath: 'test_path', compressQuality: 100)).called(1);
    });

    test('cameraPicture should show error on failure', () async {
      when(mockBuildContext.mounted).thenReturn(true);
      when(mockPermission.status).thenAnswer((_) async => PermissionStatus.denied);

      await PictureManager.cameraPicture(mockBuildContext, (String? path) {});

      verify(mockPermission.request()).called(1);
    });
  });
}
