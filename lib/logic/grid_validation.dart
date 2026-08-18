class GridValidation {
  static const int minSize = 2;
  static const int maxSize = 15;
  static const int maxImagesPerStage = 5;
  static const int minImagesPerStage = 1;

  /// Portrait-compatible grids are square, or have one extra column so tiles
  /// stay tall when the source image is portrait.
  static bool isPortraitCompatible(int rows, int columns) {
    if (rows < minSize || columns < minSize) return false;
    if (rows > maxSize || columns > maxSize) return false;
    if (columns < rows) return false;
    if (columns > rows + 1) return false;
    return true;
  }

  static String? validate(int rows, int columns) {
    if (rows < minSize || columns < minSize) {
      return 'Minimum grid size is $minSize × $minSize.';
    }
    if (rows > maxSize || columns > maxSize) {
      return 'Maximum grid size is $maxSize × $maxSize.';
    }
    if (!isPortraitCompatible(rows, columns)) {
      return 'Grid must be square or portrait (rows × columns, columns = rows or rows + 1).';
    }
    return null;
  }
}
