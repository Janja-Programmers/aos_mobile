import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upload use cases map to canonical backend purposes', () {
    expect(
      MediaPolicies.forUseCase(MediaUseCase.adImage).uploadPurpose,
      MediaUploadPurpose.adImage,
    );
    expect(
      MediaPolicies.forUseCase(MediaUseCase.reviewImage).uploadPurpose,
      MediaUploadPurpose.reviewImage,
    );
    expect(
      MediaPolicies.forUseCase(MediaUseCase.liveCover).uploadPurpose,
      MediaUploadPurpose.liveCover,
    );
    expect(
      MediaPolicies.forUseCase(MediaUseCase.verificationDocument).uploadPurpose,
      MediaUploadPurpose.verificationDocument,
    );
    expect(
      MediaPolicies.forUseCase(MediaUseCase.shortVideo).uploadPurpose,
      MediaUploadPurpose.shortVideoRaw,
    );
  });

  test('upload limits mirror the canonical backend purpose registry', () {
    const mb = 1024 * 1024;
    final adImage = MediaPolicies.forUseCase(MediaUseCase.adImage);
    final adVideo = MediaPolicies.forUseCase(MediaUseCase.adVideo);
    final review = MediaPolicies.forUseCase(MediaUseCase.reviewImage);
    final profile = MediaPolicies.forUseCase(MediaUseCase.profileImage);
    final liveCover = MediaPolicies.forUseCase(MediaUseCase.liveCover);
    final verification = MediaPolicies.forUseCase(
      MediaUseCase.verificationDocument,
    );
    final seller = MediaPolicies.forUseCase(MediaUseCase.sellerBanner);
    final chat = MediaPolicies.forUseCase(MediaUseCase.chatFile);
    final short = MediaPolicies.forUseCase(MediaUseCase.shortVideo);
    final sound = MediaPolicies.forUseCase(MediaUseCase.soundUpload);

    expect(adImage.maxBytes, 10 * mb);
    expect(adVideo.maxBytes, 200 * mb);
    expect(review.maxItems, 5);
    expect(review.maxBytes, 10 * mb);
    expect(review.allowedKinds, contains(MediaKind.image));
    expect(profile.maxBytes, 5 * mb);
    expect(profile.maxSourceBytes, 25 * mb);
    expect(liveCover.maxBytes, 10 * mb);
    expect(verification.maxBytes, 20 * mb);
    expect(verification.allowedExtensions, containsAll(<String>['pdf', 'jpg']));
    expect(seller.maxBytes, 10 * mb);
    expect(chat.maxBytes, 50 * mb);
    expect(short.maxBytes, 300 * mb);
    expect(sound.maxBytes, 50 * mb);
  });

  test('non-transcoded upload formats stay within backend allowlists', () {
    final adVideo = MediaPolicies.forUseCase(MediaUseCase.adVideo);
    final chatFile = MediaPolicies.forUseCase(MediaUseCase.chatFile);
    final sound = MediaPolicies.forUseCase(MediaUseCase.soundUpload);

    expect(
      adVideo.allowedExtensions,
      unorderedEquals(<String>['mp4', 'm4v', 'mov']),
    );
    expect(
      sound.allowedExtensions,
      unorderedEquals(<String>['mp3', 'm4a', 'aac', 'wav', 'ogg']),
    );
    expect(chatFile.allowedExtensions, contains('pdf'));
    expect(chatFile.allowedExtensions, isNot(contains('docx')));
    expect(chatFile.allowedExtensions, isNot(contains('webm')));
    expect(chatFile.allowedExtensions, isNot(contains('flac')));
  });

  test('local search and wallpaper policies are never upload purposes', () {
    expect(
      MediaPolicies.forUseCase(MediaUseCase.searchImage).uploadPurpose,
      isNull,
    );
    expect(
      MediaPolicies.forUseCase(MediaUseCase.chatWallpaper).uploadPurpose,
      isNull,
    );
  });
}
