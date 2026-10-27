import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../common/bottom_nav/admin_bottom_navbar.dart';
import '../../../database_handler.dart';

class OrderDashboard extends StatefulWidget {
  @override
  _OrderDashboardState createState() => _OrderDashboardState();
}

class _OrderDashboardState extends State<OrderDashboard> {
  DateTime _selectedDate = DateTime.now();
  int _dailyTotal = 0;
  int _monthlyTotal = 0;
  int _yearlyTotal = 0;
  int _dailyOrderCount = 0;
  int _monthlyOrderCount = 0;
  int _yearlyOrderCount = 0;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchTotals();
    _fetchOrderDates();
  }

  void _fetchTotals() async {
    int dailyTotal = await DatabaseService().getTotalForDate(_selectedDate);
    int monthlyTotal = await DatabaseService().getTotalForMonth(_selectedDate);
    int yearlyTotal = await DatabaseService().getTotalForYear(_selectedDate);

    int dailyOrderCount =
        await DatabaseService().getOrderCountForDate(_selectedDate);
    int monthlyOrderCount =
        await DatabaseService().getOrderCountForMonth(_selectedDate);
    int yearlyOrderCount =
        await DatabaseService().getOrderCountForYear(_selectedDate);

    if (mounted) {
      setState(() {
        _dailyTotal = dailyTotal;
        _monthlyTotal = monthlyTotal;
        _yearlyTotal = yearlyTotal;

        _dailyOrderCount = dailyOrderCount;
        _monthlyOrderCount = monthlyOrderCount;
        _yearlyOrderCount = yearlyOrderCount;
      });
    }
  }

  void _fetchOrderDates() async {
    List<DateTime> orderDates = await DatabaseService().getOrderDates();

    if (mounted) {
      setState(() {
        _events = {
          for (var date in orderDates)
            DateTime(date.year, date.month, date.day).toLocal(): ['Order']
        };
      });
    }
  }

  void _onDateSelected(DateTime date, DateTime _) {
    setState(() {
      _selectedDate = date.toUtc(); // Mengonversi ke UTC
    });
    _fetchTotals();
    print('Selected date: ${_selectedDate.toUtc()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order Dashboard'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          TableCalendar(
            firstDay: DateTime.utc(2021, 9, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: _onDateSelected,
            eventLoader: (day) =>
                _events[DateTime(day.year, day.month, day.day)] ?? [],
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomCenter,
              markersMaxCount: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoCard('Bulan Ini', _monthlyTotal),
              _buildInfoCard('Tanggal Ini', _dailyTotal),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: _buildSummaryDetails(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomAdminNavbar(index: 2),
    );
  }

  Widget _buildInfoCard(String title, int amount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Rp.${NumberFormat('#,###').format(amount)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Total Order (tanggal)', _dailyOrderCount),
            _buildSummaryRow('Total Order (bulan)', _monthlyOrderCount),
            _buildSummaryRow('Total Order (tahun)', _yearlyOrderCount),
            _buildSummaryRow('Total Pendapatan (tahun)', _yearlyTotal,
                isCurrency: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value, {bool isCurrency = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            isCurrency
                ? 'Rp.${NumberFormat('#,###').format(value)}'
                : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
