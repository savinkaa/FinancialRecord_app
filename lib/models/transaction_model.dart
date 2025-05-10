class TransactionModel {
  final int? id;
  final String type;
  final int amount;
  final String label;
  final String date;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.label,
    required this.date,
  });

  // Method untuk konversi data ke dalam format map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'label': label,
      'date': date,
    };
  }

  // Method untuk membaca data dari map
  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      label: map['label'],
      date: map['date'],
    );
  }

  // Menambahkan metode copyWith
  TransactionModel copyWith({
    int? id,
    String? type,
    int? amount,
    String? label,
    String? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      label: label ?? this.label,
      date: date ?? this.date,
    );
  }
}
