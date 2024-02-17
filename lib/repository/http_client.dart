import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/common/app_logger.dart';

final httpClientProvider = Provider((ref) => _HttpClient(ref));
final _dioProvider = Provider((_) => Dio());

class _HttpClient {
  const _HttpClient(this.ref);

  final Ref ref;

  Future<String> postForWhisper({required String apiKey, required MultipartFile multipartFile}) async {
    final dio = ref.read(_dioProvider);

    try {
      dio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'multipart/form-data',
      };
      final response = await dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        data: FormData.fromMap({
          'file': multipartFile,
          'model': 'whisper-1',
        }),
      );
      return response.data['text'];
    } on DioException catch (e) {
      AppLogger.e('WhisperAPIでエラー header=${e.response?.headers} \n data=${e.response?.data}', error: e);
      throw HttpException('音声変換処理でエラーが発生しました。\n ${e.response?.data}');
    }
  }
}
