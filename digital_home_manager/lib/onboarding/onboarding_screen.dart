import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final List<_OnboardPageData> _pages = [
    _OnboardPageData(
      icon: Icons.home,
      title: "Welcome to Digital Home Manager!",
      description: "Your all-in-one app for managing home deadlines, documents, services, and risk.",
      color: Colors.indigo,
    ),
    _OnboardPageData(
      icon: Icons.event_note,
      title: "Never miss crucial deadlines",
      description: "Get reminders for inspections, insurance, and maintenance. Schedule, check off, and get peace of mind.",
      color: Colors.deepOrange,
    ),
    _OnboardPageData(
      icon: Icons.archive,
      title: "All documents, in one place",
      description: "Archive reports, invoices, project files & more. Access them anytime, anywhere.",
      color: Colors.teal,
    ),
    _OnboardPageData(
      icon: Icons.health_and_safety,
      title: "Monitor Home Health",
      description: "See your property's technical status and get smart recommendations to prevent risks or underinsurance.",
      color: Colors.green,
    ),
    _OnboardPageData(
      icon: Icons.handyman,
      title: "Book Trusted Services",
      description: "Find and book verified providers for any job. Track history, cycles, and repeat service easily.",
      color: Colors.purple,
    ),
    _OnboardPageData(
      icon: Icons.workspace_premium,
      title: "Unlock Premium Features",
      description: "Go premium for advanced analytics, unlimited uploads, smart alerts, and priority support.",
      color: Colors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_pageIndex].color.withOpacity(0.07),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onFinish,
                child: const Text("Skip", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: page.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(34),
                        child: Icon(page.icon, size: 54, color: page.color.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 24),
                      Text(page.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(page.description, 
                          style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                width: _pageIndex == i ? 25 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _pageIndex == i ? _pages[i].color : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pageIndex < _pages.length - 1
                      ? () {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 330), curve: Curves.easeOut);
                        }
                      : widget.onFinish,
                  child: Text(_pageIndex < _pages.length - 1 ? "Next" : "Start Managing Home"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  const _OnboardPageData(
      {required this.title, required this.description, required this.icon, required this.color});
}
