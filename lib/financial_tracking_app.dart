import 'package:flutter/material.dart';


class FinancialTrackingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Tracking',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FinancialTrackingScreen(),
    );
  }
}

class FinancialTrackingScreen extends StatefulWidget {
  @override
  _FinancialTrackingScreenState createState() =>
      _FinancialTrackingScreenState();
}

class _FinancialTrackingScreenState extends State<FinancialTrackingScreen> {
  List<Transaction> transactions = [];
  double balance = 0.0;
  DateTime selectedDate = DateTime.now();

  void addBalance(double amountToAdd) {
    final depositTransaction = Transaction(
      title: 'Поповнення',
      amount: amountToAdd,
      date: selectedDate,
      time: DateTime.now(),
    );

    setState(() {
      transactions.insert(0, depositTransaction);
      balance += amountToAdd;
    });
  }

  void addTransaction(String title, double amount) {
    if (balance < amount) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Недостатньо коштів'),
          content: Text('На вашому балансі недостатньо коштів для цієї транзакції.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final newTransaction = Transaction(
        title: title,
        amount: amount,
        date: selectedDate,
        time: DateTime.now(),
      );

      setState(() {
        transactions.insert(0, newTransaction);
        balance -= amount;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }


  void deleteTransaction(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Видалення транзакції'),
        content: Text('Ви дійсно хочете видалити цю транзакцію?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ні'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (transactions[index].title == 'Поповнення') {
                  balance -= transactions[index].amount;
                } else {
                  balance += transactions[index].amount;
                }
                transactions.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text('Так'),
          ),
        ],
      ),
    );
  }

  void Sum() {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Додати кошти'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Сума'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  addBalance(amount);
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text('Додати'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Tracking'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                BalanceDisplay(balance),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Вибрати дату'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: TransactionList(transactions, deleteTransaction),
            ),
            SizedBox(height: 20),
            TransactionForm(addTransaction),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: Sum,
              child: Text('Додати кошти'),
            ),
          ],
        ),
      ),
    );
  }
}

class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final DateTime time;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.time,
  });
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) onDelete;

  TransactionList(this.transactions, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: transactions.isEmpty
          ? Center(
        child: Text(
          'Немає транзакцій',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              onDelete(index);
            },
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            child: Card(
              child: ListTile(
                title: Text(transaction.title),
                subtitle:
                Text('₴${transaction.amount.toStringAsFixed(2)}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                    ),
                    Text(
                      '${transaction.time.hour}:${transaction.time.minute}:${transaction.time.second}',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  final Function(String, double) onSubmit;

  TransactionForm(this.onSubmit);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Назва'),
              controller: titleController,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Вартість'),
              controller: amountController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final amount = double.tryParse(amountController.text);

                if (title.isNotEmpty && amount != null && amount > 0) {
                  widget.onSubmit(title, amount);
                  titleController.clear();
                  amountController.clear();
                }
              },
              child: Text('Додати транзакцію'),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceDisplay extends StatelessWidget {
  final double balance;

  BalanceDisplay(this.balance);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Balance: ₴${balance.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}