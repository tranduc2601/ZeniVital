import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Error: lib directory does not exist.');
    exit(1);
  }

  bool hasComments = false;

  final files = libDir.listSync(recursive: true);
  for (final entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final normalizedPath = entity.path.replaceAll('\\', '/');
      if (normalizedPath.contains('l10n/')) continue;

      final content = entity.readAsStringSync();
      final commentIndices = findComments(content);
      if (commentIndices.isNotEmpty) {
        stderr.writeln('File contains comments: ${entity.path}');
        for (final idx in commentIndices) {
          final lineInfo = getLineInfo(content, idx);
          stderr.writeln('  Comment found at line ${lineInfo.line}, column ${lineInfo.column}: "${lineInfo.snippet}"');
        }
        hasComments = true;
      }
    }
  }

  if (hasComments) {
    stderr.writeln('Verification failed: Comments found in lib/');
    exit(1);
  } else {
    stdout.writeln('Verification success: No comments found in lib/');
    exit(0);
  }
}

class LineInfo {
  final int line;
  final int column;
  final String snippet;
  LineInfo(this.line, this.column, this.snippet);
}

LineInfo getLineInfo(String content, int index) {
  int line = 1;
  int col = 1;
  for (int i = 0; i < index; i++) {
    if (content[i] == '\n') {
      line++;
      col = 1;
    } else {
      col++;
    }
  }
  final endIdx = content.indexOf('\n', index);
  final lineContent = endIdx == -1 ? content.substring(index) : content.substring(index, endIdx);
  final snippet = lineContent.length > 40 ? '${lineContent.substring(0, 40)}...' : lineContent;
  return LineInfo(line, col, snippet);
}

abstract class ParserState {}

class NormalState extends ParserState {}

class StringState extends ParserState {
  final String quoteType;
  final bool isTriple;
  final bool isRaw;
  StringState({required this.quoteType, required this.isTriple, required this.isRaw});
}

class InterpolationState extends ParserState {
  int braceDepth;
  InterpolationState({required this.braceDepth});
}

List<int> findComments(String content) {
  final List<int> commentIndices = [];
  final len = content.length;
  int i = 0;

  final List<ParserState> stateStack = [NormalState()];

  while (i < len) {
    final state = stateStack.last;

    if (state is NormalState || state is InterpolationState) {
      if (i + 1 < len && content[i] == '/' && content[i + 1] == '/') {
        commentIndices.add(i);
        i += 2;
        while (i < len && content[i] != '\n') {
          i++;
        }
        continue;
      }

      if (i + 1 < len && content[i] == '/' && content[i + 1] == '*') {
        commentIndices.add(i);
        i += 2;
        while (i < len) {
          if (i + 1 < len && content[i] == '*' && content[i + 1] == '/') {
            i += 2;
            break;
          }
          i++;
        }
        continue;
      }

      bool isRaw = false;
      if (content[i] == 'r' && i + 1 < len && (content[i + 1] == "'" || content[i + 1] == '"')) {
        isRaw = true;
        i++;
      }

      if (i < len && (content[i] == "'" || content[i] == '"')) {
        final char = content[i];
        final isTriple = i + 2 < len && content[i + 1] == char && content[i + 2] == char;
        stateStack.add(StringState(
          quoteType: char,
          isTriple: isTriple,
          isRaw: isRaw,
        ));
        i += isTriple ? 3 : 1;
        continue;
      }

      if (state is InterpolationState) {
        if (content[i] == '{') {
          state.braceDepth++;
        } else if (content[i] == '}') {
          state.braceDepth--;
          if (state.braceDepth == 0) {
            stateStack.removeLast();
            i++;
            continue;
          }
        }
      }

      i++;
    } else if (state is StringState) {
      if (state.isRaw) {
        if (state.isTriple) {
          if (i + 2 < len &&
              content[i] == state.quoteType &&
              content[i + 1] == state.quoteType &&
              content[i + 2] == state.quoteType) {
            stateStack.removeLast();
            i += 3;
            continue;
          }
        } else {
          if (content[i] == state.quoteType) {
            stateStack.removeLast();
            i++;
            continue;
          }
          if (content[i] == '\n') {
            stateStack.removeLast();
            i++;
            continue;
          }
        }
        i++;
      } else {
        if (content[i] == '\\') {
          i += 2;
          continue;
        }

        if (content[i] == '\$' && i + 1 < len && content[i + 1] == '{') {
          stateStack.add(InterpolationState(braceDepth: 1));
          i += 2;
          continue;
        }

        if (content[i] == '\$' && i + 1 < len) {
          final next = content[i + 1];
          if ((next == '_') ||
              (next.codeUnitAt(0) >= 'a'.codeUnitAt(0) && next.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
              (next.codeUnitAt(0) >= 'A'.codeUnitAt(0) && next.codeUnitAt(0) <= 'Z'.codeUnitAt(0))) {
            i += 2;
            while (i < len) {
              final c = content[i];
              if ((c == '_') ||
                  (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) && c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
                  (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) && c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
                  (c.codeUnitAt(0) >= '0'.codeUnitAt(0) && c.codeUnitAt(0) <= '9'.codeUnitAt(0))) {
                i++;
              } else {
                break;
              }
            }
            continue;
          }
        }

        if (state.isTriple) {
          if (i + 2 < len &&
              content[i] == state.quoteType &&
              content[i + 1] == state.quoteType &&
              content[i + 2] == state.quoteType) {
            stateStack.removeLast();
            i += 3;
            continue;
          }
        } else {
          if (content[i] == state.quoteType) {
            stateStack.removeLast();
            i++;
            continue;
          }
          if (content[i] == '\n') {
            stateStack.removeLast();
            i++;
            continue;
          }
        }
        i++;
      }
    }
  }

  return commentIndices;
}
