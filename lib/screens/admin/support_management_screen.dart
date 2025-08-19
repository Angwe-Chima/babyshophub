// screens/admin/support_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/support_ticket_model.dart';

class SupportManagementScreen extends StatefulWidget {
  const SupportManagementScreen({super.key});

  @override
  State<SupportManagementScreen> createState() => _SupportManagementScreenState();
}

class _SupportManagementScreenState extends State<SupportManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterPriority = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadSupportTickets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  List<SupportTicketModel> _getFilteredTickets(List<SupportTicketModel> tickets) {
    return tickets.where((ticket) {
      final matchesSearch = _searchQuery.isEmpty ||
          ticket.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ticket.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ticket.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ticket.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _filterStatus == 'All' ||
          ticket.status.name.toLowerCase() == _filterStatus.toLowerCase().replaceAll(' ', '');

      final matchesPriority = _filterPriority == 'All' ||
          ticket.priority.name.toLowerCase() == _filterPriority.toLowerCase();

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: const Text(
          'Support Management',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).loadSupportTickets();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoadingSupportTickets) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tickets',
                    style: AppConstants.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adminProvider.error!,
                    style: AppConstants.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadSupportTickets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredTickets = _getFilteredTickets(adminProvider.supportTickets);

          return Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilterSection(),

              // Tickets List
              Expanded(
                child: filteredTickets.isEmpty
                    ? _buildEmptyState()
                    : _buildTicketsList(filteredTickets, adminProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tickets by ID, subject, or customer...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Filter Options
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  items: ['All', 'Open', 'In Progress', 'Resolved', 'Closed']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: AppConstants.spacingSmall),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  items: ['All', 'Low', 'Medium', 'High', 'Urgent']
                      .map((priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterPriority = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<SupportTicketModel> tickets, AdminProvider adminProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildTicketCard(ticket, adminProvider);
      },
    );
  }

  Widget _buildTicketCard(SupportTicketModel ticket, AdminProvider adminProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(
            width: 4,
            color: _getPriorityColor(ticket.priority),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                // Priority and Status Indicators
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ticket.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(ticket.status),
                        color: _getStatusColor(ticket.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(ticket.priority),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ticket.priority.name.toUpperCase(),
                        style: AppConstants.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: AppConstants.spacingMedium),

                // Ticket Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Ticket #${ticket.id.substring(0, 8)}',
                            style: AppConstants.bodySmall.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(ticket.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusDisplayName(ticket.status),
                              style: AppConstants.bodySmall.copyWith(
                                color: _getStatusColor(ticket.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.subject,
                        style: AppConstants.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From: ${ticket.userName}',
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ticket.userEmail,
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Message Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ticket.message,
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (ticket.adminResponse != null) ...[
              const SizedBox(height: AppConstants.spacingSmall),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Response:',
                      style: AppConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.adminResponse!,
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingMedium),

            // Ticket Details
            Row(
              children: [
                Expanded(
                  child: _buildTicketInfoItem(
                    'Created',
                    _formatDate(ticket.createdAt),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildTicketInfoItem(
                    'Priority',
                    ticket.priority.name.toUpperCase(),
                    Icons.flag,
                  ),
                ),
                Expanded(
                  child: _buildTicketInfoItem(
                    'Status',
                    _getStatusDisplayName(ticket.status),
                    Icons.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),
            const Divider(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showTicketDetailsDialog(ticket),
                  icon: Icon(Icons.info, size: 18, color: AppConstants.primaryColor),
                  label: Text(
                    'Details',
                    style: TextStyle(color: AppConstants.primaryColor),
                  ),
                ),
                if (ticket.status != TicketStatus.resolved && ticket.status != TicketStatus.closed)
                  TextButton.icon(
                    onPressed: () => _showResponseDialog(ticket, adminProvider),
                    icon: Icon(Icons.reply, size: 18, color: AppConstants.accentColor),
                    label: Text(
                      'Respond',
                      style: TextStyle(color: AppConstants.accentColor),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _showStatusUpdateDialog(ticket, adminProvider),
                  icon: Icon(Icons.update, size: 18, color: AppConstants.successColor),
                  label: Text(
                    'Status',
                    style: TextStyle(color: AppConstants.successColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppConstants.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppConstants.bodySmall.copyWith(
            color: AppConstants.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppConstants.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent,
            size: 64,
            color: AppConstants.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No support tickets found',
            style: AppConstants.headingMedium.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketDetailsDialog(SupportTicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ticket #${ticket.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Subject', ticket.subject),
              _buildDetailRow('Customer', ticket.userName),
              _buildDetailRow('Email', ticket.userEmail),
              _buildDetailRow('Priority', ticket.priority.name.toUpperCase()),
              _buildDetailRow('Status', _getStatusDisplayName(ticket.status)),
              _buildDetailRow('Created', _formatDateTime(ticket.createdAt)),
              if (ticket.updatedAt != null)
                _buildDetailRow('Updated', _formatDateTime(ticket.updatedAt!)),
              if (ticket.resolvedAt != null)
                _buildDetailRow('Resolved', _formatDateTime(ticket.resolvedAt!)),
              if (ticket.adminId != null)
                _buildDetailRow('Handled by', 'Admin (${ticket.adminId})'),
              const SizedBox(height: 16),
              Text(
                'Message:',
                style: AppConstants.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.message,
                  style: AppConstants.bodySmall,
                ),
              ),
              if (ticket.adminResponse != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Admin Response:',
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.adminResponse!,
                    style: AppConstants.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppConstants.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResponseDialog(SupportTicketModel ticket, AdminProvider adminProvider) {
    _responseController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket: ${ticket.subject}'),
            const SizedBox(height: 16),
            TextField(
              controller: _responseController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your Response',
                hintText: 'Type your response to the customer...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_responseController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final adminId = userProvider.currentUser?.uid ?? 'unknown';

                final success = await adminProvider.addAdminResponse(
                  ticket.id,
                  _responseController.text.trim(),
                  adminId,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Response added successfully'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to add response'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
                _responseController.clear();
              }
            },
            child: const Text('Send Response'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(SupportTicketModel ticket, AdminProvider adminProvider) {
    TicketStatus selectedStatus = ticket.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Ticket Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current status: ${_getStatusDisplayName(ticket.status)}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<TicketStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Select New Status',
                  border: OutlineInputBorder(),
                ),
                items: TicketStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusDisplayName(status)),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              if (selectedStatus == TicketStatus.resolved || selectedStatus == TicketStatus.closed) ...[
                const SizedBox(height: 16),
                Text(
                  'This ticket will be marked as resolved/closed.',
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.successColor,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStatus == ticket.status
                  ? null
                  : () async {
                Navigator.of(context).pop();
                final success = await adminProvider.updateTicketStatus(ticket.id, selectedStatus);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Ticket status updated successfully'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to update ticket status'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AppConstants.errorColor;
      case TicketStatus.inProgress:
        return AppConstants.accentColor;
      case TicketStatus.resolved:
        return AppConstants.successColor;
      case TicketStatus.closed:
        return AppConstants.textSecondary;
    }
  }

  String _getStatusDisplayName(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'OPEN';
      case TicketStatus.inProgress:
        return 'IN PROGRESS';
      case TicketStatus.resolved:
        return 'RESOLVED';
      case TicketStatus.closed:
        return 'CLOSED';
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return AppConstants.errorColor;
      case TicketPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Icons.new_releases;
      case TicketStatus.inProgress:
        return Icons.autorenew;
      case TicketStatus.resolved:
        return Icons.check_circle;
      case TicketStatus.closed:
        return Icons.archive;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}