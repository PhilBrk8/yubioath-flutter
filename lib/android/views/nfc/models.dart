/*
 * Copyright (C) 2024 Yubico.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

class NfcEvent {
  const NfcEvent();
}

class NfcHideViewEvent extends NfcEvent {
  final Duration delay;

  const NfcHideViewEvent({this.delay = Duration.zero});
}

class NfcSetViewEvent extends NfcEvent {
  final Widget child;
  final bool showIfHidden;

  const NfcSetViewEvent({required this.child, this.showIfHidden = true});
}

@freezed
class NfcActivityWidgetProperties with _$NfcActivityWidgetProperties {
  factory NfcActivityWidgetProperties({
    required Widget child,
    @Default(false) bool visible,
    @Default(false) bool hasCloseButton,
  }) = _NfcActivityWidgetProperties;
}
