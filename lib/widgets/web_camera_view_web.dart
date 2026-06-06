import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:convert';
import 'package:flutter/material.dart';

bool _isRegistered = false;
Function(double angle, String status)? _currentOnUpdate;

Widget buildWebCameraView(Function(double angle, String status) onUpdate) {
  _currentOnUpdate = onUpdate;
  final viewType = 'mediapipe-iframe';
  
  if (!_isRegistered) {
    // Listen to messages globally ONCE, to prevent duplicate listeners on reload
    html.window.onMessage.listen((event) {
      if (_currentOnUpdate == null) return;
      if (event.data != null) {
        try {
          Map<String, dynamic> data;
          if (event.data is String) {
            data = jsonDecode(event.data);
          } else {
            data = Map<String, dynamic>.from(event.data);
          }
          
          if (data['type'] == 'POSE_UPDATE') {
            _currentOnUpdate!((data['angle'] as num).toDouble(), data['status'] as String);
          }
        } catch(e) {
          // ignore
        }
      }
    });

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'mediapipe.html'
        ..style.border = 'none'
        ..style.pointerEvents = 'none'
        ..allow = 'camera';
      
      return iframe;
    });
    _isRegistered = true;
  }
  
  return HtmlElementView(viewType: viewType);
}
