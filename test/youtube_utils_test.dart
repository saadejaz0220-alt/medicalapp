import 'package:flutter_test/flutter_test.dart';
import 'package:medicalapp/app/utils/youtube_utils.dart';

void main() {
  group('YoutubeUtils.convertUrlToId', () {
    test('standard watch URL', () {
      expect(
        YoutubeUtils.convertUrlToId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
    });

    test('short URL (youtu.be)', () {
      expect(
        YoutubeUtils.convertUrlToId('https://youtu.be/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
    });

    test('embed URL', () {
      expect(
        YoutubeUtils.convertUrlToId('https://www.youtube.com/embed/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
    });

    test('shorts URL', () {
      expect(
        YoutubeUtils.convertUrlToId('https://www.youtube.com/shorts/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
    });

    test('URL with extra params', () {
      expect(
        YoutubeUtils.convertUrlToId('https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s'),
        'dQw4w9WgXcQ',
      );
    });

    test('invalid URL returns null', () {
      expect(
        YoutubeUtils.convertUrlToId('https://google.com'),
        null,
      );
    });

    test('empty string returns null', () {
      expect(
        YoutubeUtils.convertUrlToId(''),
        null,
      );
    });
  });
}
