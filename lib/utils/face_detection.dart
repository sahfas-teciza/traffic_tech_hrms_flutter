class FaceDetectionUtils {
  static double euclideanDistance(List<double> v1, List<double> v2) {
    double sum = 0.0;
    for (int i = 0; i < v1.length; i++) {
      sum += (v1[i] - v2[i]) * (v1[i] - v2[i]);
    }
    return sum;
  }

  static bool isFaceMatched(List<double> newFace, List<double> storedFace) {
    double distance = euclideanDistance(newFace, storedFace);
    return distance < 1.0; // Threshold
  }
}
