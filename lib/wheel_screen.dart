import 'package:flutter/material.dart';
import 'package:flutter_wheel_picker/text_effect.dart';
import 'package:flutter_wheel_picker/wheel_picker.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  double _padding = 10;

  double _value = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              'Wheel Picker',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            Text(
              "PADDING",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
              ),
              child: Slider(
                value: _padding,
                thumbColor: Colors.green,
                activeColor: Colors.green,
                inactiveColor: Colors.grey,
                max: 40,
                onChanged: (value) {
                  setState(() {
                    _padding = value;
                  });
                },
              ),
            ),
            SizedBox(height: 100),
            Center(
              child: SizedBox(
                child: WheelPicker(
                  radius: 180 - _padding,
                  maxValue: 150,
                  onValueChanged: (value) {
                    setState(() {
                      _value = value;
                    });
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            AnimatedNumberTextWithBlur(value: _value.toInt()),
                            Text(
                              "KG",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            "WHEEL PICKER BY\n SAM.DEV",
                            style: TextStyle(
                              fontSize: 14,

                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
