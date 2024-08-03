
import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/error_handling.dart';
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
  final mockImagePicker = MockImagePicker();
  final mockImageCropper = MockImageCropper();
  final mockPermission = MockPermission();

  setUp(() {
    when(mockBuildContext.mounted).thenReturn(true);
  });

  group('PictureManager', () {
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
