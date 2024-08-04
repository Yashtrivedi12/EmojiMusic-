// import 'package:flutter/material.dart';

// class AdminPanel extends StatefulWidget {
//   const AdminPanel({super.key});

//   @override
//   State<AdminPanel> createState() => _AdminPanelState();
// }

// class _AdminPanelState extends State<AdminPanel> {
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Center(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               // mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 50),
//                 Image.asset(
//                   'assets/admin.jpg', // Replace with your image URL
//                   width: 350,
//                   height: 300,
//                 ),
//                 Text(
//                   'ADMIN PANEL',
//                   style: TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 210, 19, 6),
//                     decoration: TextDecoration
//                         .underline, // Add this line to add an underline
//                     decorationColor: Color.fromARGB(
//                         255, 210, 19, 6), // Customize underline color if needed
//                     decorationThickness:
//                         1, // Customize underline thickness if needed
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: TextFormField(
//                     controller: email,
//                     decoration: InputDecoration(
//                       labelText: 'Enter Email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(50),
//                         ),
//                       ),
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     validator: (value) {
//                       if (value!.isEmpty || value == Null) {
//                         return "Email is Required";
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//                 // const SizedBox(height: 30),
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: TextFormField(
//                     controller: password,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: 'Enter Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(50),
//                         ),
//                       ),
//                       prefixIcon: Icon(Icons.password),
//                     ),
//                     validator: (value) {
//                       if (value!.isEmpty || value == Null) {
//                         return "Password is Required";
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Do something when the form is validated
//                     }
//                   },
//                   style: ButtonStyle(
//                     fixedSize: MaterialStateProperty.all(const Size(110, 50)),
//                     backgroundColor: MaterialStateProperty.all(
//                       const Color.fromARGB(255, 206, 25, 12),
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'Login',
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
