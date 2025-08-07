// ======================= screens/cart/checkout_screen.dart =======================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../config/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../orders/order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
const CheckoutScreen({super.key});

@override
State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
final _formKey = GlobalKey<FormState>();
final _addressController = TextEditingController();
final _phoneController = TextEditingController();
final _notesController = TextEditingController();
final OrderService _orderService = OrderService();

bool _isProcessing = false;
String _paymentMethod = 'Cash on Delivery';
final List<String> _paymentMethods = [
'Cash on Delivery',
'Credit Card',
'Mobile Payment',
];

@override
void dispose() {
_addressController.dispose();
_phoneController.dispose();
_notesController.dispose();
super.dispose();
}

Future<void> _placeOrder() async {
if (!_formKey.currentState!.validate()) return;

final authProvider = Provider.of<AuthProvider>(context, listen: false);
final cartProvider = Provider.of<CartProvider>(context, listen: false);

if (authProvider.user == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please sign in to place an order'),
backgroundColor: Colors.red,
),
);
return;
}

if (cartProvider.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Your cart is empty'),
backgroundColor: Colors.red,
),
);
return;
}

setState(() {
_isProcessing = true;
});

try {
// Calculate order totals
final subtotal = cartProvider.totalAmount;
final deliveryFee = 5.0; // Fixed delivery fee
final tax = subtotal * 0.1; // 10% tax
final total = subtotal + deliveryFee + tax;

// Create order items from cart
final orderItems = cartProvider.items.map((cartItem) {
return OrderItem(
productId: cartItem.productId,
productName: cartItem.name,
productImage: cartItem.imageUrl,
price: cartItem.price,
quantity: cartItem.quantity,
);
}).toList();

// Create delivery info
final deliveryInfo = DeliveryInfo(
address: _addressController.text.trim(),
phone: _phoneController.text.trim(),
instructions: _notesController.text.trim().isNotEmpty
? _notesController.text.trim()
    : null,
);

// Create order
final order = OrderModel(
id: '', // Will be set by Firestore
userId: authProvider.user!.uid,
items: orderItems,
total: total,
subtotal: subtotal,
deliveryFee: deliveryFee,
tax: tax,
status: OrderStatus.pending,
createdAt: DateTime.now(),
deliveryInfo: deliveryInfo,
);

// Save order to database
await _orderService.createOrder(order);

// Clear cart
cartProvider.clearCart();

setState(() {
_isProcessing = false;
});

if (mounted) {
// Show success message
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Order placed successfully!'),
backgroundColor: Colors.green,
),
);

// Navigate to order history
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => const OrderHistoryScreen(),
),
);
}
} catch (e) {
setState(() {
_isProcessing = false;
});

if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Failed to place order: $e'),
backgroundColor: Colors.red,
),
);
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: const CustomAppBar(
title: 'Checkout',
),
body: Consumer2<CartProvider, AuthProvider>(
builder: (context, cartProvider, authProvider, child) {
if (authProvider.user == null) {
return _buildSignInPrompt();
}

if (cartProvider.isEmpty) {
return _buildEmptyCart();
}

return _buildCheckoutForm(cartProvider);
},
),
);
}

Widget _buildSignInPrompt() {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.person_outline,
size: 80,
color: Colors.grey,
),
const SizedBox(height: 16),
const Text(
'Sign in required',
style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
const Text(
'Please sign in to proceed with checkout',
style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 24),
ElevatedButton(
onPressed: () {
Navigator.pushNamed(context, '/login');
},
child: const Text('Sign In'),
),
],
),
);
}

Widget _buildEmptyCart() {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.shopping_cart_outlined,
size: 80,
color: Colors.grey,
),
const SizedBox(height: 16),
const Text(
'Your cart is empty',
style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
const Text(
'Add some items to proceed with checkout',
style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 24),
ElevatedButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text('Continue Shopping'),
),
],
),
);
}

Widget _buildCheckoutForm(CartProvider cartProvider) {
final subtotal = cartProvider.totalAmount;
final deliveryFee = 5.0;
final tax = subtotal * 0.1;
final total = subtotal + deliveryFee + tax;

return SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Order Summary
_buildOrderSummary(cartProvider, subtotal, deliveryFee, tax, total),
const SizedBox(height: 24),

// Delivery Information
_buildDeliveryForm(),
const SizedBox(height: 24),

// Payment Method
_buildPaymentMethod(),
const SizedBox(height: 32),

// Place Order Button
SizedBox(
width: double.infinity,
height: 56,
child: ElevatedButton(
onPressed: _isProcessing ? null : _placeOrder,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: _isProcessing
? const SizedBox(
width: 20,
height: 20,
child: CircularProgressIndicator(
strokeWidth: 2,
valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
),
)
    : Text(
'Place Order - \$${total.toStringAsFixed(2)}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),
],
),
),
);
}

Widget _buildOrderSummary(CartProvider cartProvider, double subtotal,
double deliveryFee, double tax, double total) {
return Card(
elevation: 2,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Order Summary',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const SizedBox(height: 16),
...cartProvider.items.map((item) => _buildOrderItem(item)),
const Divider(),
_buildSummaryRow('Subtotal', subtotal),
_buildSummaryRow('Delivery Fee', deliveryFee),
_buildSummaryRow('Tax (10%)', tax),
const Divider(),
_buildSummaryRow('Total', total, isTotal: true),
],
),
),
);
}

Widget _buildOrderItem(dynamic item) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8.0),
child: Row(
children: [
Expanded(
child: Text(
'${item.name} x${item.quantity}',
style: const TextStyle(fontSize: 14),
),
),
Text(
'\$${(item.price * item.quantity).toStringAsFixed(2)}',
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w500,
),
),
],
),
);
}

Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 4.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
label,
style: TextStyle(
fontSize: isTotal ? 16 : 14,
fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
),
),
Text(
'\$${amount.toStringAsFixed(2)}',
style: TextStyle(
fontSize: isTotal ? 16 : 14,
fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
),
),
],
),
);
}

Widget _buildDeliveryForm() {
return Card(
elevation: 2,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Delivery Information',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const SizedBox(height: 16),
TextFormField(
controller: _addressController,
decoration: const InputDecoration(
labelText: 'Delivery Address *',
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.location_on),
),
maxLines: 2,
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter delivery address';
}
return null;
},
),
const SizedBox(height: 16),
TextFormField(
controller: _phoneController,
decoration: const InputDecoration(
labelText: 'Phone Number *',
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.phone),
),
keyboardType: TextInputType.phone,
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter phone number';
}
return null;
},
),
const SizedBox(height: 16),
TextFormField(
controller: _notesController,
decoration: const InputDecoration(
labelText: 'Delivery Instructions (Optional)',
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.note),
),
maxLines: 2,
),
],
),
),
);
}

Widget _buildPaymentMethod() {
return Card(
elevation: 2,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Payment Method',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const SizedBox(height: 16),
..._paymentMethods.map((method) {
return RadioListTile<String>(
title: Text(method),
value: method,
groupValue: _paymentMethod,
onChanged: (value) {
setState(() {
_paymentMethod = value!;
});
},
contentPadding: EdgeInsets.zero,
);
}),
],
),
),
);
}
}
