import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final IconData? leadingIcon;
  final bool isCompact;

  const GradientButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    required this.text,
    this.leadingIcon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isCompact ? 52 : 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnabled
              ? _getEcoGradient()
              : [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: _getEcoShadowColor(),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? _buildLoadingIndicator()
                  : _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getEcoGradient() {
    return const [
      Color(0xFF4CAF50), // Fresh green
      Color(0xFF45a049), // Deep green
      Color(0xFF388E3C), // Eco green
    ];
  }

  Color _getEcoShadowColor() {
    return const Color(0xFF4CAF50).withOpacity(0.4);
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: 20,
            color: Colors.white.withOpacity(0.95),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 16 : 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}