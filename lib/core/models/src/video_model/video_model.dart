class VideoModel {
  final String id;
  final String title;
  final String filePath;
  final int duration;
  final int size;
  final DateTime modifiedDate;

  VideoModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.duration,
    required this.size,
    required this.modifiedDate,
  });

  String get formattedDuration {
    Duration durationObj = Duration(seconds: duration);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(durationObj.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(durationObj.inSeconds.remainder(60));
    return "${durationObj.inHours > 0 ? '${twoDigits(durationObj.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}