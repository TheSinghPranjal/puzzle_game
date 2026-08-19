class GridValidation {
  static const int minSize = 2;
  static const int maxSize = 15;
  static const int maxImagesPerStage = 5;
  static const int minImagesPerStage = 1;

  /// Portrait-compatible grids are square, or one extra row so the board
  /// stays taller than it is wide (for example 3×2).
  static bool isPortraitCompatible(int rows, int columns) {
    if (rows < minSize || columns < minSize) return false;
    if (rows > maxSize || columns > maxSize) return false;
    if (rows < columns) return false;
    if (rows > columns + 1) return false;
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
      return 'Grid must be square or portrait (rows × columns, rows = columns or columns + 1).';
    }
    return null;
  }
}
