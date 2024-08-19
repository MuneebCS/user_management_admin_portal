import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false, // Default value is false
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isLoading ? null : widget.onPressed,
      onHover: (hovering) {
        setState(() {
          _isHovered = hovering;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: widget.isLoading
              ? Colors.grey
              : _isHovered
                  ? Colors.grey
                  : Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            if (!_isHovered && !widget.isLoading)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).secondaryHeaderColor,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isHovered
                        ? Theme.of(context).secondaryHeaderColor
                        : Colors.grey,
                    fontFamily: 'Roboto',
                  ),
                ),
        ),
      ),
    );
  }
}
