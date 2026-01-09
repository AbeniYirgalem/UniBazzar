import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../listing/domain/entities/listing.dart';
import '../providers/cart_controller.dart';

class AddToCartButton extends ConsumerStatefulWidget {
  const AddToCartButton({super.key, required this.listing, this.iconColor});

  final Listing listing;
  final Color? iconColor;

  @override
  ConsumerState<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<AddToCartButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.add_shopping_cart_outlined,
              color: widget.iconColor ?? Colors.white70,
            ),
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await ref
                    .read(cartControllerProvider.notifier)
                    .addItem(widget.listing);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                }
              } catch (e) {
                if (mounted) showCartError(context, e);
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
    );
  }
}
