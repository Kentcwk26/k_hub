import 'package:flutter/material.dart';

class ChatInfoWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isCompact;

  const ChatInfoWidget({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: isCompact 
          ? const EdgeInsets.symmetric(vertical: 2, horizontal: 12)
          : padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: isCompact
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showIcon;
  final int? maxLines;
  final TextOverflow? overflow;

  const IconTextWidget({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.padding,
    this.margin,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.showIcon = true,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Icon(
                icon,
                color: iconColor ?? Theme.of(context).colorScheme.onSurface,
                size: iconSize ?? 60,
              ),
            )
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            ),
          ),
        ],
      ),
    );
  }
}

class IconTextVariants {
  static Widget success({
    required String text,
    IconData icon = Icons.check_circle,
    double? iconSize,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool showIcon = true,
    int? maxLines,
  }) {
    return IconTextWidget(
      icon: icon,
      text: text,
      iconColor: Colors.green,
      textColor: Colors.green.shade700,
      iconSize: iconSize,
      fontSize: fontSize,
      padding: padding,
      margin: margin,
      mainAxisAlignment: mainAxisAlignment,
      showIcon: showIcon,
      maxLines: maxLines,
    );
  }

  static Widget error({
    required String text,
    IconData icon = Icons.error,
    double? iconSize,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool showIcon = true,
    int? maxLines,
  }) {
    return IconTextWidget(
      icon: icon,
      text: text,
      iconColor: Colors.red,
      textColor: Colors.red.shade700,
      iconSize: iconSize,
      fontSize: fontSize,
      padding: padding,
      margin: margin,
      mainAxisAlignment: mainAxisAlignment,
      showIcon: showIcon,
      maxLines: maxLines,
    );
  }

  static Widget warning({
    required String text,
    IconData icon = Icons.warning,
    double? iconSize,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool showIcon = true,
    int? maxLines,
  }) {
    return IconTextWidget(
      icon: icon,
      text: text,
      iconColor: Colors.orange,
      textColor: Colors.orange.shade700,
      iconSize: iconSize,
      fontSize: fontSize,
      padding: padding,
      margin: margin,
      mainAxisAlignment: mainAxisAlignment,
      showIcon: showIcon,
      maxLines: maxLines,
    );
  }

  static Widget info({
    required String text,
    IconData icon = Icons.info,
    double? iconSize,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool showIcon = true,
    int? maxLines,
  }) {
    return IconTextWidget(
      icon: icon,
      text: text,
      iconColor: Colors.blue,
      textColor: Colors.blue.shade700,
      iconSize: iconSize,
      fontSize: fontSize,
      padding: padding,
      margin: margin,
      mainAxisAlignment: mainAxisAlignment,
      showIcon: showIcon,
      maxLines: maxLines,
    );
  }

  static Widget neutral({
    required String text,
    IconData icon = Icons.help_outline,
    double? iconSize,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool showIcon = true,
    int? maxLines,
  }) {
    return IconTextWidget(
      icon: icon,
      text: text,
      iconColor: Colors.grey,
      textColor: Colors.grey.shade700,
      iconSize: iconSize,
      fontSize: fontSize,
      padding: padding,
      margin: margin,
      mainAxisAlignment: mainAxisAlignment,
      showIcon: showIcon,
      maxLines: maxLines,
    );
  }
}