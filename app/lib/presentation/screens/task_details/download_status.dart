enum DownloadState { notDownloaded, downloading, completed, failed }

class DownloadStatus {
  final double progress;
  final DownloadState state;

  DownloadStatus({this.progress = 0.0, this.state = DownloadState.notDownloaded});

  DownloadStatus copyWith({
    double? progress,
    DownloadState? state,
  }) {
    return DownloadStatus(
      progress: progress ?? this.progress,
      state: state ?? this.state,
    );
  }
}
