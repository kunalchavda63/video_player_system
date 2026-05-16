import '../../../app_ui.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {


  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.validator,
    this.border,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.padding,
    this.textInputAction,
    this.textInputType,
    this.textCapitalization,
    this.isExpand,
    this.filled,
    this.fillColor,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.focusNode,
    this.maxLength,
    this.initialValue,
    this.cursorColor,
    this.obscureText = false,
    this.onChanged,
    this.inputFormatter,
    this.readOnly = false,
    this.floatingLabelAlignment,
    this.floatingLabelBehavior,
    this.focusColor,
    this.onSubmitted, this.textAlign
  }
      );
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final InputBorder? border;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final EdgeInsets? padding;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final TextCapitalization? textCapitalization;
  final bool? isExpand;
  final bool? filled;
  final Color? fillColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final FocusNode? focusNode;
  final int? maxLength;
  final String? initialValue;
  final Color? cursorColor;
  final bool? obscureText;
  final void Function(String? val)? onChanged;
  final List<TextInputFormatter>? inputFormatter;
  final bool? readOnly;
  final FloatingLabelAlignment? floatingLabelAlignment;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final Color? focusColor;
  final void Function(String? val)? onSubmitted;
  final TextAlign? textAlign;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText ?? false;
  }
  @override
  Widget build(BuildContext context) {

    return TextFormField(
      cursorErrorColor: widget.cursorColor,
      onFieldSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly ?? false,
      onChanged: widget.onChanged,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      inputFormatters: widget.inputFormatter,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      initialValue: widget.initialValue,
      focusNode: widget.focusNode,
      keyboardType: widget.textInputType,
      style: widget.style,
      expands: widget.isExpand ?? false,
      controller: widget.controller,
      cursorColor: widget.cursorColor,
      cursorHeight: 20,
      textInputAction: widget.textInputAction,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign ?? TextAlign.start,

      decoration: InputDecoration(
        floatingLabelAlignment: widget.floatingLabelAlignment,
        floatingLabelBehavior: widget.floatingLabelBehavior,
        focusColor: widget.focusColor,
        border: widget.border,
        focusedErrorBorder: widget.border,
        errorBorder: widget.border,
        enabledBorder: widget.border,
        disabledBorder: widget.border,
        focusedBorder: widget.border,
        contentPadding: widget.padding,
        hintText: widget.hintText,
        labelText: widget.label,
        floatingLabelStyle: widget.labelStyle,
        hintStyle: widget.hintStyle,
        labelStyle: widget.labelStyle,
        filled: widget.filled,
        fillColor: widget.fillColor,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText==true
            ? GestureDetector(
            onTap: () => setState(() {
              _obscure = !_obscure;
            }),
            child:SvgPicture.asset(
              _obscure == true ? AssetIcons.icStrEye:AssetIcons.icEye,colorFilter: const ColorFilter.mode(AppColors.black,BlendMode.srcIn),)).padH(10.r):
        widget.suffixIcon,
        counterText: '',
      ),
      validator: widget.validator,
      obscureText: _obscure,

    );
  }
}