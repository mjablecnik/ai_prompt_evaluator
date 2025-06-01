import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import '../prompt_evaluator.dart';

class ChartClient {
  /// Generates a bar chart using QuickChart.io and saves it as a PNG.
  Future<void> generateChart(List<PromptEvaluationResult> results, String path) async {
    print('Generating chart to $path...');
    final labels = results.asMap().keys.map((i) => 'P${i + 1}').toList();
    final scores = results.map((r) => r.score).toList();

    final chartConfig = {
      'type': 'bar',
      'data': {
        'labels': labels,
        'datasets': [
          {
            'label': 'Score',
            'data': scores,
            'backgroundColor': 'rgba(54, 162, 235, 0.7)',
          }
        ]
      },
      'options': {
        'scales': {
          'y': {
            'beginAtZero': true,
            'max': 5,
          }
        }
      }
    };

    final url = 'https://quickchart.io/chart';
    final dio = Dio();
    final response = await dio.get(
      url,
      queryParameters: {
        'c': jsonEncode(chartConfig),
        'format': 'png',
        'width': 600,
        'height': 400,
        'backgroundColor': 'white',
      },
      options: Options(responseType: ResponseType.bytes),
    );

    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(response.data);
    print('Chart saved.');
  }
}
