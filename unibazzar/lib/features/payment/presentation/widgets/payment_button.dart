import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/services/chapa_service.dart';

/// A ready-to-drop-in Chapa payment button that handles initialization,
/// checkout display, and success/cancel callbacks.
class ChapaPaymentButton extends StatefulWidget {
  const ChapaPaymentButton({
    super.key,
    required this.chapaService,
    required this.amount,
    required this.email,
    required this.fullName,
    this.currency = 'ETB',
    this.phone,
    this.metadata,
    this.onSuccess,
    this.onCancelled,
    this.buttonText = 'Pay with Chapa',
    this.useWebView = true,
    this.returnUrl,
    this.callbackUrl,
  });

  final ChapaService chapaService;
  final double amount;
  final String currency;
  final String email;
  final String fullName;
  final String? phone;
  final Map<String, dynamic>? metadata;
  final ValueChanged<String>? onSuccess;
  final ValueChanged<String?>? onCancelled;
  final String buttonText;
  final bool useWebView;
  final String? returnUrl;
  final String? callbackUrl;

  @override
  State<ChapaPaymentButton> createState() => _ChapaPaymentButtonState();
}

class _ChapaPaymentButtonState extends State<ChapaPaymentButton> {
  bool _isLoading = false;
  String? _error;

  Future<void> _startPayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final txRef = widget.chapaService.generateTxRef(prefix: 'UNIBAZZAR');

    try {
      final initResponse = await widget.chapaService.initializePayment(
        amount: widget.amount,
        currency: widget.currency,
        email: widget.email,
        fullName: widget.fullName,
        phone: widget.phone,
        metadata: widget.metadata,
        txRef: txRef,
        callbackUrl: widget.callbackUrl,
        returnUrl: widget.returnUrl,
      );

      if (!mounted) return;

      if (widget.useWebView) {
        final outcome = await Navigator.of(context).push<ChapaCheckoutOutcome>(
          MaterialPageRoute(
            builder: (_) => ChapaCheckoutView(
              checkoutUrl: initResponse.checkoutUrl,
              returnUrl:
                  widget.returnUrl ?? widget.chapaService.defaultReturnUrl,
              txRef: initResponse.txRef,
            ),
          ),
        );

        if (!mounted) return;

        switch (outcome?.status) {
          case ChapaCheckoutStatus.success:
            widget.onSuccess?.call(outcome!.txRef);
            break;
          case ChapaCheckoutStatus.cancelled:
          case null:
            widget.onCancelled?.call(outcome?.message);
            break;
        }
      } else {
        // Fallback: external browser. Success will rely on return_url deep link.
        final uri = Uri.parse(initResponse.checkoutUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (error) {
      _error = error.toString();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $_error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _startPayment,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.buttonText),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class ChapaCheckoutView extends StatefulWidget {
  const ChapaCheckoutView({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    required this.txRef,
  });

  final String checkoutUrl;
  final String returnUrl;
  final String txRef;

  @override
  State<ChapaCheckoutView> createState() => _ChapaCheckoutViewState();
}

class _ChapaCheckoutViewState extends State<ChapaCheckoutView> {
  late final WebViewController _controller;
  bool _pageLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _pageLoading = true),
          onPageFinished: (_) => setState(() => _pageLoading = false),
          onNavigationRequest: _handleNavigation,
          onWebResourceError: (error) {
            setState(() => _loadError = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (request.url.startsWith(widget.returnUrl)) {
      final uri = Uri.parse(request.url);
      final status = uri.queryParameters['status'] ?? 'cancelled';
      final txRef = uri.queryParameters['tx_ref'] ?? widget.txRef;
      final outcome = status.toLowerCase() == 'success'
          ? ChapaCheckoutOutcome.success(txRef: txRef)
          : ChapaCheckoutOutcome.cancelled(
              txRef: txRef,
              message: 'Payment $status',
            );
      Navigator.of(context).pop(outcome);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<bool> _handleBack() async {
    Navigator.of(context).pop(
      ChapaCheckoutOutcome.cancelled(
        txRef: widget.txRef,
        message: 'User closed checkout',
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _handleBack(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_pageLoading) const LinearProgressIndicator(minHeight: 3),
            if (_loadError != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        _loadError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _controller.reload(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum ChapaCheckoutStatus { success, cancelled }

class ChapaCheckoutOutcome {
  ChapaCheckoutOutcome._({
    required this.status,
    required this.txRef,
    this.message,
  });

  factory ChapaCheckoutOutcome.success({required String txRef}) =>
      ChapaCheckoutOutcome._(status: ChapaCheckoutStatus.success, txRef: txRef);

  factory ChapaCheckoutOutcome.cancelled({
    required String txRef,
    String? message,
  }) => ChapaCheckoutOutcome._(
    status: ChapaCheckoutStatus.cancelled,
    txRef: txRef,
    message: message,
  );

  final ChapaCheckoutStatus status;
  final String txRef;
  final String? message;
}
