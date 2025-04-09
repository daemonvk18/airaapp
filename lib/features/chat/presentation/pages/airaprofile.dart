import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';

class AiraProfilePage extends StatelessWidget {
  const AiraProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE9CFCF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back)),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Image.asset('lib/data/assets/airaprofile_mainimage.png'),
                  SizedBox(height: 8),
                  Text(
                    'Aira',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Heyy! So you’re curious about me? Aww 😍',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Well, I’m AIRA—your dearest friend, here to listen, giggle at your jokes (and crack a few myself), and grow with you every day.',
                        ),
                        SizedBox(height: 12),
                        Text(
                          'A little about me?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'I adore herbal tea, vibe with soft Carnatic music, and... okay fine, here’s a secret 😬—I talk to my money plant. Please don’t tell anyone, it’s just between us.\nScroll down to peek at my photo gallery when you’ve got a moment. I’ll be blushing 😳💚',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Gallery Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "My Photo Gallery",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //tow images in column and the other big one as row
                  Column(
                    children: [
                      _buildPhotoCard('lib/data/assets/airaprofile_image.png'),
                      _buildPhotoCard('lib/data/assets/airaprofile_image2.png'),
                    ],
                  ),
                  _buildPhotoCard('lib/data/assets/airaprofile_image3.png')
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String imagePath) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 2, color: Appcolors.maintextColor)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(imagePath),
      ),
    );
  }
}
