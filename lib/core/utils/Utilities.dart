import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MySharedPreferences {
  MySharedPreferences._privateConstructor();

  static final MySharedPreferences instance = MySharedPreferences._privateConstructor();

  setStringValue(String key, String value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setString(key, value);
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.containsKey(key) ? myPrefs.getString(key) ?? "" : "";
  }

  setStringWithEncodeValue(String key, String value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setString(key, json.encode(value));
  }

  Future<dynamic> getStringWithDecodeValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.containsKey(key) ? json.decode(myPrefs.getString(key) ?? "") : "";
  }

  setStringListValue(String key, List<String> value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setStringList(key, value);
  }

  Future<List<String>> getStringListValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.containsKey(key) ? myPrefs.getStringList(key) ?? [] : [];
  }

  setIntegerValue(String key, int value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setInt(key, value);
  }

  Future<int> getIntegerValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.containsKey(key) ? myPrefs.getInt(key) ?? 0 : 0;
  }

  setBooleanValue(String key, bool value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setBool(key, value);
  }

  Future<bool> getBooleanValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.containsKey(key) ? myPrefs.getBool(key) ?? false : false;
  }

  Future<bool> containsKey(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.containsKey(key);
  }

  removeValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.remove(key);
  }

  removeAll() async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.clear();
  }
}

// ignore: non_constant_identifier_names, unnecessary_question_mark
void debugLog(dynamic? obj) {
  DDTraceModel model = DDTraceModel(StackTrace.current);

  var list = [
    DateTime.now().toString(),
    model.fileName,
    model.className,
    model.selectorName,
    model.lineNumber == "" ? "" : "[${model.lineNumber}:${model.columnNumber}]"
  ].where((element) => element != "");
  print("${list.join(" ")}: $obj");
}

/// TraceModel
class DDTraceModel {
  final StackTrace _trace;

  String fileName = "";
  String className = "";
  String selectorName = "";
  String lineNumber = "";
  String columnNumber = "";

  DDTraceModel(this._trace) {
    _parseTrace();
  }

  /// parse trace
  void _parseTrace() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        {
          var traceString2 = _trace.toString().split("\n")[2];

          List<String> list = traceString2.split(" ").where((element) => element != "").toList();
          // this.selectorName = list.last.replaceAll("[", "").replaceAll("]", "()").trim();
          selectorName = list[1];

          var nameAndLines = list.last.split("/").last.split(".dart:");
          className = "${nameAndLines.first}.dart";
          _parseLineAndColumn(location: nameAndLines.last);
        }
        break;
      default:
        {
          var traceString1 = _trace.toString().split("\n")[1];

          List<String> list = traceString1
              .replaceAll("#1", "")
              .replaceAll(".<anonymous closure>", "")
              .replaceAll(")", "")
              .replaceAll("(", "")
              .replaceAll(".dart:", ".dart ")
              .split(" ")
              .where((element) => element != "")
              .toList();

          var fileInfo = list.first.split(".").toList();
          className = fileInfo.first;
          selectorName = "${fileInfo.last}()";

          _parseClassName(path: list[1]);
          _parseLineAndColumn(location: list.last);
        }
        break;
    }
  }

  /// parse className
  void _parseClassName({required String path}) {
    if (path.contains("/")) {
      List<String> list =
          path.split("/").last.split(" ").where((element) => element != "").toList();
      fileName = list.first.trim();
    }
  }

  /// parse Line and column
  void _parseLineAndColumn({required String location}) {
    if (location.contains(":")) {
      List<String> list = location.split(":");
      lineNumber = list.first.trim();
      columnNumber = list.last.trim().replaceAll(")", "");
    }
  }
}
