// ignore_for_file: avoid_field_initializers_in_const_classes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends ConsumerWidget {
  const AsyncValueWidget({
    required this.value,
    required Widget Function(T) this.data,
    required Widget Function() this.loading,
    required Widget Function(Object, StackTrace) this.error,
    super.key,
  }) : orElse = null;

  const AsyncValueWidget.orElse({
    required this.value,
    required Widget Function() this.orElse,
    this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T)? data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace)? error;
  final Widget Function()? orElse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return value.when(
      loading: loading ?? orElse!,
      error: error ?? (_, __) => orElse!.call(),
      data: data ?? (_) => orElse!.call(),
    );
  }
}
