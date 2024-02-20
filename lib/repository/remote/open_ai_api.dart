import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';

final openAiApiProvider = Provider((ref) => _OpenAiApi(ref));
final _dioProvider = Provider((_) => Dio());

class _OpenAiApi {
  const _OpenAiApi(this.ref);

  final Ref ref;

  Future<String> speechToText(RecordFile recordFile) async {
    final dio = ref.read(_dioProvider);
    final apiKey = ref.read(appSettingProvider).apiKey;

    try {
      dio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'multipart/form-data',
      };
      final response = await dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(recordFile.filePath, filename: recordFile.fileName()),
          'model': 'whisper-1',
        }),
      );
      return response.data['text'];
    } on DioException catch (e) {
      AppLogger.e('WhisperAPIでエラー header=${e.response?.headers} \n data=${e.response?.data}', error: e);
      throw HttpException('音声変換処理でエラーが発生しました。\n ${e.response?.data}');
    }
  }

  Future<String> requestSummary(String text) async {
    final dio = ref.read(_dioProvider);
    final apiKey = ref.read(appSettingProvider).apiKey;

    try {
      dio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
      final response = await dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {'role': 'user', 'content': '次の文章は複数の音声録音からの文字起こしをつなげて作成されたものです。このテキストに含まれる主要な情報を要約してください: $text'},
          ],
        },
      );
      return response.data['choices'][0]['message']['content'].trim();
    } on DioException catch (e) {
      AppLogger.e('GPT APIでエラー header=${e.response?.headers} \n data=${e.response?.data}', error: e);
      throw HttpException('サマリー処理でエラーが発生しました。\n ${e.response?.data}');
    }
  }
}