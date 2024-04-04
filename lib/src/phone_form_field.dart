import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_country_selector/flutter_country_selector.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:phone_form_field/src/phone_field_semantics.dart';
import 'package:phone_form_field/src/validation/allowed_characters.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

part 'phone_controller.dart';
part 'phone_form_field_state.dart';

/// Phone input extending form field.
///
/// ### controller:
/// {@template controller}
/// Use a [PhoneController] for PhoneFormField when you need to dynamically
/// change the value.
///
/// Whenever the user modifies the phone field with an
/// associated [controller], the phone field updates
/// the display value and the controller notifies its listeners.
/// {@endtemplate}
///
/// You can also use an [initialValue]:
/// {@template initialValue}
/// The initial value used.
///
/// Only one of [initialValue] and [controller] can be specified.
/// If [controller] is specified the [initialValue] will be
/// the first value of the [PhoneController]
/// {@endtemplate}
class PhoneFormField extends FormField<PhoneNumber> {
  /// {@macro controller}
  final PhoneController? controller;

  final bool shouldFormat;

  /// callback called when the input value changes
  final Function(PhoneNumber)? onChanged;

  /// country that is displayed when there is no value
  final IsoCode defaultCountry;

  /// the focusNode of the national number
  final FocusNode? focusNode;

  /// how to display the country selection
  final CountrySelectorNavigator countrySelectorNavigator;

  /// whether the user can select a new country when pressing the country button
  final bool isCountrySelectionEnabled;

  /// This controls wether the country button is alway shown or is hidden by
  /// the label when the national number is empty. In flutter terms this controls
  /// whether the country button is shown as a prefix or prefixIcon inside
  /// the text field.
  final bool isCountryButtonPersistent;

  /// The style of the country selector button
  final CountryButtonStyle countryButtonStyle;

  /// Whether the flag assets should be preloaded. It improves performance
  /// by downloading them upfront (default). If set to false the assets will be
  /// lazy loaded.
  final bool isFlagPreloadEnabled;

  // textfield inputs
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  final bool? showCursor;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final Function(PointerDownEvent)? onTapOutside;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  bool get selectionEnabled => enableInteractiveSelection;
  final MouseCursor? mouseCursor;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final Iterable<String>? autofillHints;
  final bool enableIMEPersonalizedLearning;
  final List<TextInputFormatter>? inputFormatters;

  PhoneFormField({
    super.key,
    this.controller,
    @Deprecated('This is now always true and has no effect anymore')
    this.shouldFormat = true,
    this.onChanged,
    this.focusNode,
    this.countrySelectorNavigator = const CountrySelectorNavigator.page(),
    @Deprecated(
        'Use [initialValue] or [controller] to set the initial phone number')
    this.defaultCountry = IsoCode.US,
    this.isCountrySelectionEnabled = true,
    bool? isCountryButtonPersistent,
    @Deprecated('Use [isCountryButtonPersistent]')
    bool? isCountryChipPersistent,
    @Deprecated('Use [CountryButtonStyle] instead') bool? showFlagInInput,
    @Deprecated('Use [CountryButtonStyle] instead') bool? showDialCode,
    @Deprecated('Use [CountryButtonStyle] instead') bool? showIsoCodeInInput,
    @Deprecated('Use [CountryButtonStyle] instead')
    EdgeInsets? countryButtonPadding,
    @Deprecated('Use [CountryButtonStyle] instead') double? flagSize,
    @Deprecated('Use [CountryButtonStyle] instead') TextStyle? countryCodeStyle,
    CountryButtonStyle countryButtonStyle = const CountryButtonStyle(),
    // form field inputs
    super.validator,
    PhoneNumber? initialValue,
    super.onSaved,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
    super.enabled = true,
    // textfield inputs
    this.decoration = const InputDecoration(),
    this.keyboardType = TextInputType.phone,
    this.textInputAction,
    this.style,
    this.strutStyle,
    @Deprecated('Has no effect, Change text directionality instead')
    this.textAlign,
    this.textAlignVertical,
    this.autofocus = false,
    this.obscuringCharacter = '*',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.contextMenuBuilder,
    this.showCursor,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.onTapOutside,
    this.inputFormatters,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.mouseCursor,
    this.scrollPhysics,
    this.scrollController,
    this.autofillHints,
    this.enableIMEPersonalizedLearning = true,
    this.isFlagPreloadEnabled = true,
  })  : assert(
          initialValue == null || controller == null,
          'One of initialValue or controller can be specified at a time',
        ),
        isCountryButtonPersistent =
            isCountryButtonPersistent ?? isCountryChipPersistent ?? true,
        countryButtonStyle = countryButtonStyle.copyWith(
          showFlag: showFlagInInput,
          showDialCode: showDialCode,
          showIsoCode: showIsoCodeInInput,
          padding: countryButtonPadding,
          flagSize: flagSize,
          textStyle: countryCodeStyle,
        ),
        super(
          builder: (state) => (state as PhoneFormFieldState).builder(),
          initialValue: controller?.value ?? initialValue,
        );

  @override
  PhoneFormFieldState createState() => PhoneFormFieldState();
}
