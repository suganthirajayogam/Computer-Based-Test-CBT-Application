import 'package:flutter/material.dart';
 
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
 
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}
 
class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showLoginOptions = false;
 
  void _toggleLoginOptions() {
    setState(() {
      showLoginOptions = true;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 90, 17),
        foregroundColor: Colors.white,
        title: const Text(' Visteon Computer Based Test(VCBT)'),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       const DrawerHeader(
      //         decoration: BoxDecoration(
      //           gradient: LinearGradient(
      //             colors: [Colors.indigo, Colors.deepPurple],
      //           ),
      //         ),
      //         child: Center(
      //           child: Text(
      //             'Visteon App',
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontSize: 26,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //         ),
      //       ),
      //       // ListTile(
      //       //   leading: const Icon(Icons.login, color: Colors.indigo),
      //       //   title: const Text('Login'),
      //       //   onTap: () {
      //       //     Navigator.pop(context);
      //       //     _toggleLoginOptions();
      //       //   },
      //       // ),
      //       // ListTile(
      //       //   leading: const Icon(Icons.info, color: Colors.teal),
      //       //   title: const Text('About Us'),
      //       //   onTap: () {
      //       //     Navigator.pop(context);
      //       //     ScaffoldMessenger.of(context).showSnackBar(
      //       //       const SnackBar(content: Text('About Us clicked!')),
      //       //     );
      //       //   },
      //       // ),
      //     ],
      //   ),
      // ),
      body: Stack(
  fit: StackFit.expand,
  children: [
    Image.asset(
      'assets/images/visteon_exam_logo.png',
      fit: BoxFit.cover,
    ),
    Container(
      color: Colors.black.withOpacity(0.3),
    ),
    Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome Employee to Take Test!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (!showLoginOptions)
              ElevatedButton.icon(
                onPressed: _toggleLoginOptions,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("LOGIN"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 30),
                  textStyle: const TextStyle(fontSize: 18),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 270,
                    height: 55,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.quiz, color: Colors.deepPurple),
                              SizedBox(width: 8),
                              Text(
                                'MCQ Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 270,
                    height: 55,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/vision_login');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Vision Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
 
    // ✅ Positioned version text at bottom-left
    const Positioned(
      left: 16,
      bottom: 16,
      child: Text(
        ' V.2.0',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
 
    );
  }
}