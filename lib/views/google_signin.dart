import 'package:flutter/material.dart';
import 'package:mytravely_app/views/hotel_list_page.dart';
import 'package:sign_in_button/sign_in_button.dart';

class GoogleSigninView extends StatelessWidget {
  const GoogleSigninView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 👇 Background Image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(255, 255, 255, 0.3),
                Color.fromRGBO(255, 255, 255, 0.3),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),

          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.travel_explore, size: 70, color: Colors.white),

                const SizedBox(height: 20),
                const Text(
                  'Welcome to MyTravaly',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 253, 253),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: const Text(
                    'Sign in to explore amazing stays around the world',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SignInButton(
                      Buttons.google,
                      text: "Continue with Google",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HotelListPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
