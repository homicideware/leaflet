// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:potato_notes/internal/utils.dart';

/// A material design checkbox.
///
/// The checkbox itself does not maintain any state. Instead, when the state of
/// the checkbox changes, the widget calls the [onChanged] callback. Most
/// widgets that use a checkbox will listen for the [onChanged] callback and
/// rebuild the checkbox with a new [value] to update the visual appearance of
/// the checkbox.
///
/// The checkbox can optionally display three values - true, false, and null -
/// if [tristate] is true. When [value] is null a dash is displayed. By default
/// [tristate] is false and the checkbox's [value] must be true or false.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [CheckboxListTile], which combines this widget with a [ListTile] so that
///    you can give the checkbox a label.
///  * [Switch], a widget with semantics similar to [Checkbox].
///  * [Radio], for selecting among a set of explicit values.
///  * [Slider], for selecting a value in a range.
///  * <https://material.io/design/components/selection-controls.html#checkboxes>
///  * <https://material.io/design/components/lists.html#types>
class NoteViewCheckbox extends StatefulWidget {
  /// Creates a material design checkbox.
  ///
  /// The checkbox itself does not maintain any state. Instead, when the state of
  /// the checkbox changes, the widget calls the [onChanged] callback. Most
  /// widgets that use a checkbox will listen for the [onChanged] callback and
  /// rebuild the checkbox with a new [value] to update the visual appearance of
  /// the checkbox.
  ///
  /// The following arguments are @required:
  ///
  /// * [value], which determines whether the checkbox is checked. The [value]
  ///   can only be null if [tristate] is true.
  /// * [onChanged], which is called when the value of the checkbox should
  ///   change. It can be set to null to disable the checkbox.
  ///
  /// The values of [tristate] and [autofocus] must not be null.
  const NoteViewCheckbox({
    Key key,
    @required this.value,
    this.tristate = false,
    @required this.onChanged,
    this.mouseCursor,
    this.activeColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.splashRadius,
    this.focusNode,
    this.autofocus = false,
    this.width = 16.0,
    this.inactiveColor,
    this.shapeRadius = const Radius.circular(2),
  })  : assert(tristate != null),
        assert(tristate || value != null),
        assert(autofocus != null),
        super(key: key);

  /// Whether this checkbox is checked.
  ///
  /// This property must not be null.
  final bool value;

  /// Called when the value of the checkbox should change.
  ///
  /// The checkbox passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the checkbox with the new
  /// value.
  ///
  /// If this callback is null, the checkbox will be displayed as disabled
  /// and will not respond to input gestures.
  ///
  /// When the checkbox is tapped, if [tristate] is false (the default) then
  /// the [onChanged] callback will be applied to `!value`. If [tristate] is
  /// true this callback cycle from false to true to null.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// Checkbox(
  ///   value: _throwShotAway,
  ///   onChanged: (bool newValue) {
  ///     setState(() {
  ///       _throwShotAway = newValue;
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<bool> onChanged;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.selected].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// When [value] is null and [tristate] is true, [MaterialState.selected] is
  /// included as a state.
  ///
  /// If this property is null, [MaterialStateMouseCursor.clickable] will be used.
  final MouseCursor mouseCursor;

  /// The color to use when this checkbox is checked.
  ///
  /// Defaults to [ThemeData.toggleableActiveColor].
  final Color activeColor;

  /// The color to use for the check icon when this checkbox is checked.
  ///
  /// Defaults to Color(0xFFFFFFFF)
  final Color checkColor;

  /// If true the checkbox's [value] can be true, false, or null.
  ///
  /// Checkbox displays a dash when its value is null.
  ///
  /// When a tri-state checkbox ([tristate] is true) is tapped, its [onChanged]
  /// callback will be applied to true if the current value is false, to null if
  /// value is true, and to false if value is null (i.e. it cycles through false
  /// => true => null => false when tapped).
  ///
  /// If tristate is false (the default), [value] must not be null.
  final bool tristate;

  /// The color for the checkbox's [Material] when it has the input focus.
  final Color focusColor;

  /// The color for the checkbox's [Material] when a pointer is hovering over it.
  final Color hoverColor;

  /// The splash radius of the circular [Material] ink response.
  ///
  /// If null, then [kRadialReactionRadius] is used.
  final double splashRadius;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The width of a checkbox widget.
  final double width;

  final Color inactiveColor;

  final Radius shapeRadius;

  @override
  _CheckboxState createState() => _CheckboxState();
}

class _CheckboxState extends State<NoteViewCheckbox>
    with TickerProviderStateMixin {
  bool get enabled => widget.onChanged != null;
  Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _actionHandler),
    };
  }

  void _actionHandler(ActivateIntent intent) {
    if (widget.onChanged != null) {
      switch (widget.value) {
        case false:
          widget.onChanged(true);
          break;
        case true:
          widget.onChanged(widget.tristate ? null : false);
          break;
        default:
          widget.onChanged(false);
          break;
      }
    }
    final RenderObject renderObject = context.findRenderObject();
    renderObject.sendSemanticsEvent(const TapSemanticEvent());
  }

  bool _focused = false;
  void _handleFocusHighlightChanged(bool focused) {
    if (focused != _focused) {
      setState(() {
        _focused = focused;
      });
    }
  }

  bool _hovering = false;
  void _handleHoverChanged(bool hovering) {
    if (hovering != _hovering) {
      setState(() {
        _hovering = hovering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = context.theme;
    Size size = Size.square(24);
    final BoxConstraints additionalConstraints = BoxConstraints.tight(size);
    final MouseCursor effectiveMouseCursor =
        MaterialStateProperty.resolveAs<MouseCursor>(
      widget.mouseCursor ?? MaterialStateMouseCursor.clickable,
      <MaterialState>{
        if (!enabled) MaterialState.disabled,
        if (_hovering) MaterialState.hovered,
        if (_focused) MaterialState.focused,
        if (widget.tristate || widget.value) MaterialState.selected,
      },
    );

    return FocusableActionDetector(
      actions: _actionMap,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: enabled,
      onShowFocusHighlight: _handleFocusHighlightChanged,
      onShowHoverHighlight: _handleHoverChanged,
      mouseCursor: effectiveMouseCursor,
      child: Builder(
        builder: (BuildContext context) {
          return _CheckboxRenderObjectWidget(
            value: widget.value,
            tristate: widget.tristate,
            activeColor: widget.activeColor ?? themeData.toggleableActiveColor,
            checkColor: widget.checkColor ?? const Color(0xFFFFFFFF),
            inactiveColor: enabled
                ? widget.inactiveColor ?? themeData.unselectedWidgetColor
                : themeData.disabledColor,
            focusColor: widget.focusColor ?? themeData.focusColor,
            hoverColor: widget.hoverColor ?? themeData.hoverColor,
            splashRadius: widget.splashRadius ?? kRadialReactionRadius,
            onChanged: widget.onChanged,
            additionalConstraints: additionalConstraints,
            vsync: this,
            hasFocus: _focused,
            hovering: _hovering,
            width: widget.width,
            shapeRadius: widget.shapeRadius,
          );
        },
      ),
    );
  }
}

class _CheckboxRenderObjectWidget extends LeafRenderObjectWidget {
  const _CheckboxRenderObjectWidget({
    Key key,
    @required this.value,
    @required this.tristate,
    @required this.activeColor,
    @required this.checkColor,
    @required this.inactiveColor,
    @required this.focusColor,
    @required this.hoverColor,
    @required this.splashRadius,
    @required this.onChanged,
    @required this.vsync,
    @required this.additionalConstraints,
    @required this.hasFocus,
    @required this.hovering,
    @required this.width,
    @required this.shapeRadius,
  })  : assert(tristate != null),
        assert(tristate || value != null),
        assert(activeColor != null),
        assert(inactiveColor != null),
        assert(vsync != null),
        super(key: key);

  final bool value;
  final bool tristate;
  final bool hasFocus;
  final bool hovering;
  final Color activeColor;
  final Color checkColor;
  final Color inactiveColor;
  final Color focusColor;
  final Color hoverColor;
  final double splashRadius;
  final ValueChanged<bool> onChanged;
  final TickerProvider vsync;
  final BoxConstraints additionalConstraints;
  final double width;
  final Radius shapeRadius;

  @override
  _RenderCheckbox createRenderObject(BuildContext context) => _RenderCheckbox(
        value: value,
        tristate: tristate,
        activeColor: activeColor,
        checkColor: checkColor,
        inactiveColor: inactiveColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        splashRadius: splashRadius,
        onChanged: onChanged,
        vsync: vsync,
        additionalConstraints: additionalConstraints,
        hasFocus: hasFocus,
        hovering: hovering,
        width: width,
        shapeRadius: shapeRadius,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderCheckbox renderObject) {
    renderObject
      // The `tristate` must be changed before `value` due to the assertion at
      // the beginning of `set value`.
      ..tristate = tristate
      ..value = value
      ..activeColor = activeColor
      ..checkColor = checkColor
      ..inactiveColor = inactiveColor
      ..focusColor = focusColor
      ..hoverColor = hoverColor
      ..splashRadius = splashRadius
      ..onChanged = onChanged
      ..additionalConstraints = additionalConstraints
      ..vsync = vsync
      ..hasFocus = hasFocus
      ..hovering = hovering
      ..width = width
      ..shapeRadius = shapeRadius;
  }
}

const double _kStrokeWidth = 2.0;

class _RenderCheckbox extends RenderToggleable {
  _RenderCheckbox({
    bool value,
    @required bool tristate,
    @required Color activeColor,
    @required this.checkColor,
    @required Color inactiveColor,
    Color focusColor,
    Color hoverColor,
    @required double splashRadius,
    @required BoxConstraints additionalConstraints,
    ValueChanged<bool> onChanged,
    @required bool hasFocus,
    @required bool hovering,
    @required TickerProvider vsync,
    @required this.width,
    @required this.shapeRadius,
  })  : _oldValue = value,
        super(
          value: value,
          tristate: tristate,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          splashRadius: splashRadius,
          onChanged: onChanged,
          additionalConstraints: additionalConstraints,
          vsync: vsync,
          hasFocus: hasFocus,
          hovering: hovering,
        );

  bool _oldValue;
  Color checkColor;
  double width;
  Radius shapeRadius;

  @override
  set value(bool newValue) {
    if (newValue == value) return;
    _oldValue = value;
    super.value = newValue;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isChecked = value == true;
  }

  // The square outer bounds of the checkbox at t, with the specified origin.
  // At t == 0.0, the outer rect's size is _kEdgeSize (Checkbox.width)
  // At t == 0.5, .. is _kEdgeSize - _kStrokeWidth
  // At t == 1.0, .. is _kEdgeSize
  RRect _outerRectAt(Offset origin, double t, double strokeWidth) {
    final double inset = 1.0 - (t - 0.5).abs() * 2.0;
    final double size = width - inset * strokeWidth;
    final Rect rect =
        Rect.fromLTWH(origin.dx + inset, origin.dy + inset, size, size);
    return RRect.fromRectAndRadius(rect, shapeRadius);
  }

  // The checkbox's border color if value == false, or its fill color when
  // value == true or null.
  Color _colorAt(double t) {
    // As t goes from 0.0 to 0.25, animate from the inactiveColor to activeColor.
    return onChanged == null
        ? inactiveColor
        : (t >= 0.25
            ? activeColor
            : Color.lerp(inactiveColor, activeColor, t * 4.0));
  }

  // White stroke used to paint the check and dash.
  Paint _createStrokePaint() {
    return Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeWidth;
  }

  void _drawBorder(Canvas canvas, RRect outer, double t, Paint paint) {
    assert(t >= 0.0 && t <= 0.5);
    final double size = outer.width;
    // As t goes from 0.0 to 1.0, gradually fill the outer RRect.
    final RRect inner =
        outer.deflate(math.min(size / 2.0, _kStrokeWidth + size * t));
    canvas.drawDRRect(outer, inner, paint);
  }

  void _drawCheck(Canvas canvas, Offset origin, double t, Paint paint) {
    assert(t >= 0.0 && t <= 1.0);
    // As t goes from 0.0 to 1.0, animate the two check mark strokes from the
    // short side to the long side.
    final Path path = Path();
    Offset start = Offset(width * 0.15, width * 0.45);
    Offset mid = Offset(width * 0.4, width * 0.7);
    Offset end = Offset(width * 0.85, width * 0.25);
    if (t < 0.5) {
      final double strokeT = t * 2.0;
      final Offset drawMid = Offset.lerp(start, mid, strokeT);
      path.moveTo(origin.dx + start.dx, origin.dy + start.dy);
      path.lineTo(origin.dx + drawMid.dx, origin.dy + drawMid.dy);
    } else {
      final double strokeT = (t - 0.5) * 2.0;
      final Offset drawEnd = Offset.lerp(mid, end, strokeT);
      path.moveTo(origin.dx + start.dx, origin.dy + start.dy);
      path.lineTo(origin.dx + mid.dx, origin.dy + mid.dy);
      path.lineTo(origin.dx + drawEnd.dx, origin.dy + drawEnd.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawDash(Canvas canvas, Offset origin, double t, Paint paint) {
    assert(t >= 0.0 && t <= 1.0);
    // As t goes from 0.0 to 1.0, animate the horizontal line from the
    // mid point outwards.
    Offset start = Offset(width * 0.2, width * 0.5);
    Offset mid = Offset(width * 0.5, width * 0.5);
    Offset end = Offset(width * 0.8, width * 0.5);
    final Offset drawStart = Offset.lerp(start, mid, 1.0 - t);
    final Offset drawEnd = Offset.lerp(mid, end, t);
    canvas.drawLine(origin + drawStart, origin + drawEnd, paint);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    paintRadialReaction(canvas, offset, size.center(Offset.zero));

    final Paint strokePaint = _createStrokePaint();
    final Offset origin =
        offset + (size / 2.0 - Size.square(width) / 2.0 as Offset);
    final AnimationStatus status = position.status;
    final double tNormalized =
        status == AnimationStatus.forward || status == AnimationStatus.completed
            ? position.value
            : 1.0 - position.value;

    // Four cases: false to null, false to true, null to false, true to false
    if (_oldValue == false || value == false) {
      final double t = value == false ? 1.0 - tNormalized : tNormalized;
      final RRect outer = _outerRectAt(origin, t, _kStrokeWidth);
      final Paint paint = Paint()..color = _colorAt(t);

      if (t <= 0.5) {
        _drawBorder(canvas, outer, t, paint);
      } else {
        canvas.drawRRect(outer, paint);

        final double tShrink = (t - 0.5) * 2.0;
        if (_oldValue == null || value == null)
          _drawDash(canvas, origin, tShrink, strokePaint);
        else
          _drawCheck(canvas, origin, tShrink, strokePaint);
      }
    } else {
      // Two cases: null to true, true to null
      final RRect outer = _outerRectAt(origin, 1.0, _kStrokeWidth);
      final Paint paint = Paint()..color = _colorAt(1.0);
      canvas.drawRRect(outer, paint);

      if (tNormalized <= 0.5) {
        final double tShrink = 1.0 - tNormalized * 2.0;
        if (_oldValue == true)
          _drawCheck(canvas, origin, tShrink, strokePaint);
        else
          _drawDash(canvas, origin, tShrink, strokePaint);
      } else {
        final double tExpand = (tNormalized - 0.5) * 2.0;
        if (value == true)
          _drawCheck(canvas, origin, tExpand, strokePaint);
        else
          _drawDash(canvas, origin, tExpand, strokePaint);
      }
    }
  }
}
