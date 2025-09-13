import 'button_values.dart';
import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = "0";
  String operand = "";
  String number2 = "";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 32),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.view_headline),
          onSelected: (value) {
            // Handle menu item selection
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'Basic', child: Row(
              children: [
                Icon(Icons.calculate),
                SizedBox(width: 12),
                Text('Basic'),
              ],
            )),
            const PopupMenuItem<String>(value: 'Scientific', child: Row(
              children: [
                Icon(Icons.functions),
                SizedBox(width: 12),
                Text('Scientific'),
              ],
            )),
            const PopupMenuItem<String>(value: 'Conversion', child: Row(
              children: [
                Icon(Icons.swap_horiz),
                SizedBox(width: 12),
                Text('Conversion'),
              ],
            )),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history)),
          SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(0, 5, 0, 25),
        bottom: false,
        child: Column(
          children: [
            // Display Area
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "$number1 $operand $number2".isEmpty
                        ? "0"
                        : "$number1 $operand $number2",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 255, 255, 90),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            // Button Grid
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: value == Btn.n0
                          ? screenSize.width / 2
                          : (screenSize.width / 4),
                      height: screenSize.width / 5,
                      child: buildButton(value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  Color getBtnColor(String value) {
    return [Btn.clr].contains(value)
        ? Colors.blueGrey
        : [
            Btn.changeSign,
            Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.divide,
            Btn.calculate,
          ].contains(value)
        ? Colors.orangeAccent
        : Colors.black87;
  }

  TextStyle getBtnTextStyle(String value) {
    return TextStyle(
      fontSize: [Btn.clr].contains(value)
          ? 48
          : [
              Btn.changeSign,
              Btn.per,
              Btn.multiply,
              Btn.add,
              Btn.subtract,
              Btn.divide,
              Btn.calculate,
            ].contains(value)
          ? 48
          : 24,
    );
  }

  void onBtnTap(String value) {
    if (value == Btn.changeSign) {
      changeSign();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }

    // Replace "0" with first digit pressed
    if (number1 == "0" && RegExp(r'^\d$').hasMatch(value)) {
      setState(() {
        number1 = value;
      });
      return;
    }

    appendValue(value);
  }

  void calculate() {
    if (number1.isEmpty || operand.isEmpty || number2.isEmpty) return;

    final double num1 = double.parse(number1);
    final double num2 = double.parse(number2);
    var result = 0.0;

    switch (operand) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
      default:
    }

    setState(() {
      //number1 = result.toStringAsPrecision(3);
      if (result % 1 == 0) {
        number1 = result.toInt().toString();
      } else {
        number1 = result.toString();
      }
      // if (number1.endsWith(".0")) {
      //   number1 = number1.substring(0, number1.length - 2);
      // }
      operand = "";
      number2 = "";
    });
  }

  void convertToPercentage() {
    if (number1.isNotEmpty && operand.isEmpty && number2.isEmpty) {
      final number = double.parse(number1);
      setState(() {
        number1 = "${number / 100}";
      });
    } else if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      // calculate before conversion
      calculate();
      // then convert
      final number = double.parse(number1);
      setState(() {
        number1 = "${number / 100}";
      });
    }
  }

  void clearAll() {
    setState(() {
      number1 = "0";
      operand = "";
      number2 = "";
    });
  }

  void changeSign() {
    if (number1.isNotEmpty && operand.isEmpty && number2.isEmpty) {
      final number = double.parse(number1);
      final changed = number * (-1);
      setState(() {
        if (changed % 1 == 0) {
          number1 = changed.toInt().toString();
        } else {
          number1 = changed.toString();
        }
      });
    }
    if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      final number = double.parse(number2);
      final changed = number * (-1);
      setState(() {
        if (changed % 1 == 0) {
          number2 = changed.toInt().toString();
        } else {
          number2 = changed.toString();
        }
      });
    }
  }

  void appendValue(String value) {
    // if is operand and not ".":
    if (value != Btn.dot && int.tryParse(value) == null) {
      // operand pressed
      if (operand.isNotEmpty && number2.isNotEmpty) {
        calculate();
      }
      setState(() {
        operand = value;
      });
    }
    // assign value to number1 variable
    else if (number1.isEmpty || operand.isEmpty) {
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        value = "0.";
      }
      setState(() {
        number1 += value;
      });
    }
    // assign value to number2 variable
    else if (number2.isEmpty || operand.isNotEmpty) {
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        value = "0.";
      }
      setState(() {
        number2 += value;
      });
    }
  }
}
