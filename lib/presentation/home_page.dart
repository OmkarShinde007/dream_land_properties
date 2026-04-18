import 'package:flutter/material.dart';

import '../data/company_content.dart';
import '../data/repositories/company_repository.dart';
import '../models/project.dart';
import '../viewmodels/contact_form_view_model.dart';
import '../viewmodels/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
  });

  final CompanyRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late final ScrollController _scrollController;
  late final AnimationController _backgroundAnimationController;
  bool _isHeaderMinimized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(repository: widget.repository);
    _scrollController = ScrollController()..addListener(_handleScroll);
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _backgroundAnimationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF6EFE4),
              Color(0xFFE7D8BB),
              Color(0xFFCAD8CB),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _viewModel,
            builder: (BuildContext context, Widget? child) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isMobile = constraints.maxWidth < 820;
                  return Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: _HeaderBackdropGallery(
                              animation: _backgroundAnimationController,
                              mobile: isMobile,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          isMobile
                              ? (_isHeaderMinimized ? 142 : 196)
                              : (_isHeaderMinimized ? 112 : 132),
                          20,
                          28,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.03),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildPage(),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: _AppHeader(
                              currentSection: _viewModel.selectedSection,
                              compact: isMobile,
                              minimized: _isHeaderMinimized,
                              onSelect: _viewModel.selectSection,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleScroll() {
    final shouldMinimize = _scrollController.hasClients &&
        _scrollController.offset > 40;
    if (shouldMinimize != _isHeaderMinimized) {
      setState(() {
        _isHeaderMinimized = shouldMinimize;
      });
    }
  }

  Widget _buildPage() {
    switch (_viewModel.selectedSection) {
      case AppSection.home:
        return HomeOverviewPage(
          key: const ValueKey<String>('home-page'),
          onNavigate: _viewModel.selectSection,
        );
      case AppSection.about:
        return const AboutPage(
          key: ValueKey<String>('about-page'),
        );
      case AppSection.projects:
        return ProjectsPage(
          key: const ValueKey<String>('projects-page'),
          selectedStatus: _viewModel.selectedStatus,
          onStatusChanged: _viewModel.selectProjectStatus,
        );
      case AppSection.contact:
        return ContactPage(
          key: ValueKey<String>('contact-page'),
          viewModel: _viewModel.contactFormViewModel,
        );
    }
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({
    required this.currentSection,
    required this.compact,
    required this.minimized,
    required this.onSelect,
  });

  final AppSection currentSection;
  final bool compact;
  final bool minimized;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = AppSection.values;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: minimized ? 20 : 24,
        vertical: minimized ? 12 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(minimized ? 0.9 : 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.85)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _BrandBlock(compact: true, light: true, minimized: minimized),
                SizedBox(height: minimized ? 8 : 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items
                        .map(
                          (AppSection section) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _NavPill(
                              label: _labelForSection(section),
                              selected: section == currentSection,
                              onTap: () => onSelect(section),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (!minimized) ...<Widget>[
                  const SizedBox(height: 10),
                  const _TopActionBar(compact: true),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: _BrandBlock(
                    compact: false,
                    light: true,
                    minimized: minimized,
                  ),
                ),
                SizedBox(width: minimized ? 16 : 24),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.all(minimized ? 6 : 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EEE3),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4D7BF)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: items
                          .map(
                            (AppSection section) => _NavPill(
                              label: _labelForSection(section),
                              selected: section == currentSection,
                              onTap: () => onSelect(section),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if (!minimized) ...<Widget>[
                  const SizedBox(width: 18),
                  const _TopActionBar(),
                ],
              ],
            ),
    );
  }

  String _labelForSection(AppSection section) {
    switch (section) {
      case AppSection.home:
        return 'Home';
      case AppSection.about:
        return 'About Us';
      case AppSection.projects:
        return 'Projects';
      case AppSection.contact:
        return 'Contact Us';
    }
  }
}

class _TopActionBar extends StatelessWidget {
  const _TopActionBar({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF203A2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.call_outlined, color: Color(0xFFE9D7AC), size: 18),
          const SizedBox(width: 8),
          Text(
            CompanyContent.phone,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBackdropGallery extends StatelessWidget {
  const _HeaderBackdropGallery({
    required this.animation,
    required this.mobile,
  });

  final Animation<double> animation;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final images = CompanyContent.galleryImages.take(3).toList();

    return IgnorePointer(
      child: SizedBox(
        height: mobile ? 520 : 430,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final progress = animation.value;

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Row(
                    children: List<Widget>.generate(images.length, (int index) {
                      final baseShift = (progress * 70) - 35;
                      final shift = baseShift * (index.isEven ? 1 : -1) * 0.6;

                      return Expanded(
                        child: Transform.translate(
                          offset: Offset(shift, 0),
                          child: Opacity(
                            opacity: 0.22,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 0 : 6,
                                right: index == images.length - 1 ? 0 : 6,
                              ),
                              child: _RemoteImage(
                                url: images[index],
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.white.withOpacity(0.36),
                          const Color(0xFFF7F0E4).withOpacity(0.72),
                          const Color(0xFFF5EFE4),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          const Color(0xFFF5EFE4).withOpacity(0.58),
                          Colors.transparent,
                          const Color(0xFFF5EFE4).withOpacity(0.58),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({
    required this.compact,
    this.light = false,
    this.minimized = false,
  });

  final bool compact;
  final bool light;
  final bool minimized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accentTone = light ? const Color(0xFFB78628) : const Color(0xFFE9D7AC);
    final titleTone = light ? const Color(0xFF18261F) : Colors.white;
    final subtitleTone = light ? const Color(0xFF607063) : const Color(0xFFC8D4CA);
    final bodyTone = light ? const Color(0xFF536155) : const Color(0xFFC4D0C5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: minimized ? 40 : compact ? 46 : 52,
              height: minimized ? 40 : compact ? 46 : 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF203A2D),
                    Color(0xFF426350),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'DL',
                style: (compact ? textTheme.titleLarge : textTheme.headlineSmall)
                    ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  fontSize: minimized
                      ? (compact ? 18 : 20)
                      : null,
                ),
              ),
            ),
            SizedBox(width: minimized ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Dream Land',
                    style: (compact ? textTheme.headlineSmall : textTheme.headlineMedium)
                        ?.copyWith(
                      color: titleTone,
                      fontWeight: FontWeight.w900,
                      height: 0.92,
                      fontSize: minimized
                          ? (compact ? 22 : 24)
                          : null,
                    ),
                  ),
                  Text(
                    'PROPERTIES',
                    style: (compact ? textTheme.labelMedium : textTheme.labelLarge)
                        ?.copyWith(
                      color: subtitleTone,
                      fontWeight: FontWeight.w700,
                      letterSpacing: minimized ? 2.6 : 3.4,
                      height: 1.1,
                    ),
                  ),
                  if (!minimized) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'Legacy Since 2000',
                      style: textTheme.labelMedium?.copyWith(
                        color: accentTone,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!compact && !minimized) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Trusted construction legacy with a modern property presentation experience.',
            style: textTheme.bodySmall?.copyWith(
              color: bodyTone,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarSupportCard extends StatelessWidget {
  const _SidebarSupportCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Quick Support',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            CompanyContent.phone,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFE7D7AE),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CompanyContent.email,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFC7D1C8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(
                Icons.schedule_outlined,
                size: 16,
                color: Color(0xFFC7D1C8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  CompanyContent.officeHours,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFC7D1C8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavPill extends StatefulWidget {
  const _NavPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dark = false,
    this.fullWidth = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dark;
  final bool fullWidth;

  @override
  State<_NavPill> createState() => _NavPillState();
}

class _NavPillState extends State<_NavPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final dark = widget.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: selected
                ? (dark ? const Color(0xFFE9D7AC) : const Color(0xFF203A2D))
                : _hovered
                    ? (dark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFE8DFC8))
                    : (dark ? Colors.white.withOpacity(0.02) : Colors.transparent),
            borderRadius: BorderRadius.circular(widget.fullWidth ? 14 : 14),
            border: Border.all(
              color: selected
                  ? (dark ? const Color(0xFFE9D7AC) : const Color(0xFF203A2D))
                  : (dark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFD2C2A4)),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: selected
                  ? (dark ? const Color(0xFF183126) : Colors.white)
                  : (dark ? const Color(0xFFD4DDD5) : const Color(0xFF314034)),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeOverviewPage extends StatelessWidget {
  const HomeOverviewPage({super.key, required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final featuredProject = CompanyContent.projects.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isWide = constraints.maxWidth > 980;

            final introCard = Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF7EF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF203A2D),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Property Dashboard',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Dream Land Properties Information Website',
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    CompanyContent.homeHeadline,
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF4C5A4E),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    CompanyContent.companyTagline,
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF546256),
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton(
                        onPressed: () => onNavigate(AppSection.projects),
                        child: const Text('Explore Projects'),
                      ),
                      OutlinedButton(
                        onPressed: () => onNavigate(AppSection.about),
                        child: const Text('View Company Journey'),
                      ),
                    ],
                  ),
                ],
              ),
            );

            final spotlightCard = _FeaturedProjectPanel(project: featuredProject);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 6, child: introCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: spotlightCard),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                introCard,
                const SizedBox(height: 20),
                spotlightCard,
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        const _ImageMosaic(),
        const SizedBox(height: 28),
        const _InteractiveCard(
          child: _KeyFiguresSection(),
        ),
        const SizedBox(height: 28),
        _SectionHeading(
          eyebrow: 'Why Choose Us',
          title: 'A better organized and more complete property web experience.',
          subtitle:
              'The current web app structure is strong, so this version adds more information depth and modern web components around it: clear summaries, stronger trust signals, FAQs, and service highlights.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final cards = <Widget>[
              _InteractiveCard(
                child: _FeatureList(
                  title: 'Customer-facing features',
                  items: CompanyContent.userFeatures,
                ),
              ),
              _InteractiveCard(
                child: _FeatureList(
                  title: 'Construction services',
                  items: CompanyContent.services,
                ),
              ),
              _InteractiveCard(
                child: _FeatureList(
                  title: 'Modern buyer amenities',
                  items: CompanyContent.amenities,
                ),
              ),
            ];

            return _ResponsiveCardGrid(children: cards);
          },
        ),
        const SizedBox(height: 28),
        _ResponsiveCardGrid(
          children: <Widget>[
            _InteractiveCard(
              child: _FeatureList(
                title: 'Delivery process',
                items: CompanyContent.processHighlights,
              ),
            ),
            _InteractiveCard(
              child: _FeatureList(
                title: 'Service areas',
                items: CompanyContent.serviceAreas,
              ),
            ),
            _InteractiveCard(
              child: _FeatureList(
                title: 'Compliance and support',
                items: CompanyContent.compliance,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _InteractiveCard(
          child: _TestimonialsSection(),
        ),
        const SizedBox(height: 28),
        const _InteractiveCard(
          child: _FaqSection(),
        ),
        const SizedBox(height: 28),
        const _FooterPanel(),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeading(
          eyebrow: 'About Us',
          title: 'A clearer story about the company, its values, and its process.',
          subtitle:
              'This page is focused on trust-building content so new buyers and investors can understand who Dream Land Properties is before looking at project details.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isWide = constraints.maxWidth > 980;

            final textBlock = _InteractiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _MiniEyebrow(text: 'Company Profile'),
                  const SizedBox(height: 12),
                  Text(
                    CompanyContent.about,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: const Color(0xFF4F5B51),
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    CompanyContent.aboutExtended,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: const Color(0xFF4F5B51),
                        ),
                  ),
                ],
              ),
            );

            final imageBlock = _InteractiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _MiniEyebrow(text: 'Visual Identity'),
                  const SizedBox(height: 14),
                  const _RemoteImage(
                    url:
                        'https://images.unsplash.com/photo-1448630360428-65456885c650?auto=format&fit=crop&w=1200&q=80',
                    height: 280,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A dedicated about page creates a stronger first impression and gives you room to add founder details, company milestones, certifications, and construction quality standards later.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: const Color(0xFF4F5B51),
                        ),
                  ),
                ],
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: textBlock),
                  const SizedBox(width: 20),
                  Expanded(child: imageBlock),
                ],
              );
            }

            return Column(
              children: <Widget>[
                textBlock,
                const SizedBox(height: 20),
                imageBlock,
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const _SectionHeading(
          eyebrow: 'Leadership',
          title: 'Meet the directors behind Dream Land Properties.',
          subtitle:
              'A dedicated leadership section helps visitors connect the company legacy with the people guiding its quality, planning, and customer trust.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final directorCards = CompanyContent.directors
                .map((DirectorProfile director) => _DirectorCard(director: director))
                .toList();

            if (constraints.maxWidth > 980) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: directorCards[0]),
                  const SizedBox(width: 20),
                  Expanded(child: directorCards[1]),
                ],
              );
            }

            return Column(
              children: <Widget>[
                directorCards[0],
                const SizedBox(height: 20),
                directorCards[1],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const _InteractiveCard(
          child: _LegacyTimelineSection(),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final items = <Widget>[
              _InteractiveCard(
                child: _FeatureList(
                  title: 'Mission and Vision',
                  items: <String>[
                    CompanyContent.mission,
                    CompanyContent.vision,
                  ],
                ),
              ),
              _InteractiveCard(
                child: _FeatureList(
                  title: 'Trust and Quality',
                  items: CompanyContent.trustPoints,
                ),
              ),
              _InteractiveCard(
                child: _FeatureList(
                  title: 'Buyer Journey',
                  items: CompanyContent.buyerJourney,
                ),
              ),
            ];

            if (constraints.maxWidth > 1100) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: items[0]),
                  const SizedBox(width: 18),
                  Expanded(child: items[1]),
                  const SizedBox(width: 18),
                  Expanded(child: items[2]),
                ],
              );
            }

            return Column(
              children: <Widget>[
                items[0],
                const SizedBox(height: 18),
                items[1],
                const SizedBox(height: 18),
                items[2],
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        const _FooterPanel(),
      ],
    );
  }
}

class _DirectorCard extends StatelessWidget {
  const _DirectorCard({required this.director});

  final DirectorProfile director;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D7B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: _RemoteImage(
              url: director.imageUrl,
              height: 320,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF203A2D).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    director.role,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF203A2D),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  director.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  director.bio,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: const Color(0xFF4F5B51),
                      ),
                ),
                const SizedBox(height: 16),
                ...director.details
                    .map((String item) => _BulletItem(text: item))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final ProjectStatus? selectedStatus;
  final ValueChanged<ProjectStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final List<PropertyProject> visibleProjects = selectedStatus == null
        ? CompanyContent.projects
        : CompanyContent.projects
            .where((PropertyProject project) => project.status == selectedStatus)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeading(
          eyebrow: 'Projects',
          title: 'Separate project page with filters, images, and clearer status.',
          subtitle:
              'This page helps users compare all current developments without mixing company profile and contact information into the same screen.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _FilterChipButton(
              label: 'All Projects',
              selected: selectedStatus == null,
              onTap: () => onStatusChanged(null),
            ),
            ...ProjectStatus.values.map(
              (ProjectStatus status) => _FilterChipButton(
                label: _labelForStatus(status),
                selected: selectedStatus == status,
                onTap: () => onStatusChanged(status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final width = constraints.maxWidth;
            final columns = width > 1150 ? 3 : width > 700 ? 2 : 1;
            final itemWidth = (width - ((columns - 1) * 18)) / columns;

            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: visibleProjects
                  .map(
                    (PropertyProject project) => SizedBox(
                      width: itemWidth,
                      child: _ProjectCard(project: project),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 28),
        const _FooterPanel(),
      ],
    );
  }

  String _labelForStatus(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.upcoming:
        return 'Upcoming';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.pending:
        return 'Pending';
    }
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({
    super.key,
    required this.viewModel,
  });

  final ContactFormViewModel viewModel;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionHeading(
              eyebrow: 'Contact Us',
              title: 'Give visitors direct and confident ways to reach your team.',
              subtitle:
                  'This page keeps support, enquiry, booking, and office details in one simple place and is ready for a future form or WhatsApp integration.',
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final isWide = constraints.maxWidth > 980;

                final details = _InteractiveCard(
                  child: _ContactInfoPanel(onSubmitQuickAction: _handleSubmit),
                );

                final formPanel = _InteractiveCard(
                  child: _EnquiryForm(
                    viewModel: widget.viewModel,
                    onSubmit: _handleSubmit,
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: details),
                      const SizedBox(width: 20),
                      Expanded(child: formPanel),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    details,
                    const SizedBox(height: 20),
                    formPanel,
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const _InteractiveCard(
              child: _MapSection(),
            ),
            const SizedBox(height: 28),
            const _FooterPanel(),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    if (!widget.viewModel.submit()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enquiry submitted successfully. Our team will contact you soon.'),
      ),
    );
  }
}

class _FeaturedProjectPanel extends StatelessWidget {
  const _FeaturedProjectPanel({required this.project});

  final PropertyProject project;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF203A2D),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: _RemoteImage(
              url: project.imageUrl,
              height: 250,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Featured Project',
                  style: TextStyle(
                    color: Color(0xFFE5D4AA),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.location,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFD6DFD8),
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFD4DDD6),
                        height: 1.6,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _ProjectMetaChip(label: project.progressLabel),
                    _ProjectMetaChip(label: project.deliveryWindow),
                    _ProjectMetaChip(label: '${project.units} units'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectMetaChip extends StatelessWidget {
  const _ProjectMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE7E0D2),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ImageMosaic extends StatelessWidget {
  const _ImageMosaic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _InteractiveCard(
                    padding: EdgeInsets.zero,
                    child: _RemoteImage(
                      url: CompanyContent.galleryImages[0],
                      height: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _InteractiveCard(
                    padding: EdgeInsets.zero,
                    child: _RemoteImage(
                      url: CompanyContent.galleryImages[1],
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _InteractiveCard(
              padding: EdgeInsets.zero,
              child: _RemoteImage(
                url: CompanyContent.galleryImages[2],
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  const _InteractiveCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _hovered
                ? const Color(0xFFD7B97B)
                : const Color(0xFFF1E6D3),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0x22000000).withOpacity(_hovered ? 0.15 : 0.08),
              blurRadius: _hovered ? 28 : 18,
              offset: Offset(0, _hovered ? 18 : 10),
            ),
          ],
        ),
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          eyebrow.toUpperCase(),
          style: textTheme.labelLarge?.copyWith(
            color: const Color(0xFF8A6724),
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF4F5B51),
            height: 1.65,
          ),
        ),
      ],
    );
  }
}

class _LegacyTimelineSection extends StatelessWidget {
  const _LegacyTimelineSection();

  @override
  Widget build(BuildContext context) {
    final milestones = CompanyContent.timeline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _MiniEyebrow(text: 'Legacy Journey'),
        const SizedBox(height: 12),
        Text(
          'From 2000 to 2026, the company story becomes part of the brand experience.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'This visual timeline gives visitors a stronger sense of trust by showing when the company started, how it expanded, and where it stands today.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: const Color(0xFF4F5B51),
              ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F2E8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE8DCC8)),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final isWide = constraints.maxWidth > 900;

              final summary = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF203A2D),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '2000 to 2026',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFFECD8A9),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A steady journey from a small beginning to a modern real-estate brand with stronger process, trust, and digital presentation.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFFD6DFD8),
                            height: 1.55,
                          ),
                    ),
                  ],
                ),
              );

              final timeline = Column(
                children: milestones
                    .asMap()
                    .entries
                    .map(
                      (MapEntry<int, CompanyMilestone> entry) => _LegacyStep(
                        milestone: entry.value,
                        isLast: entry.key == milestones.length - 1,
                      ),
                    )
                    .toList(),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 260, child: summary),
                    const SizedBox(width: 22),
                    Expanded(child: timeline),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  summary,
                  const SizedBox(height: 20),
                  timeline,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LegacyStep extends StatelessWidget {
  const _LegacyStep({
    required this.milestone,
    required this.isLast,
  });

  final CompanyMilestone milestone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Column(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF203A2D),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    milestone.year,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFEAD8AD),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9C8A1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE7D7B8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      milestone.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF203A2D),
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      milestone.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: const Color(0xFF4F5B51),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniEyebrow extends StatelessWidget {
  const _MiniEyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF8A6724),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 18),
        ...items.map((String item) => _BulletItem(text: item)),
      ],
    );
  }
}

class _ResponsiveCardGrid extends StatelessWidget {
  const _ResponsiveCardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool threeCol = constraints.maxWidth > 1120;
        final bool twoCol = constraints.maxWidth > 760;

        if (threeCol) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: children[0]),
              const SizedBox(width: 20),
              Expanded(child: children[1]),
              const SizedBox(width: 20),
              Expanded(child: children[2]),
            ],
          );
        }

        if (twoCol && children.length >= 2) {
          return Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: children[0]),
                  const SizedBox(width: 20),
                  Expanded(child: children[1]),
                ],
              ),
              if (children.length > 2) ...<Widget>[
                const SizedBox(height: 20),
                children[2],
              ],
            ],
          );
        }

        return Column(
          children: children
              .expand<Widget>((Widget child) => <Widget>[
                    child,
                    if (child != children.last) const SizedBox(height: 20),
                  ])
              .toList(),
        );
      },
    );
  }
}

class _KeyFiguresSection extends StatelessWidget {
  const _KeyFiguresSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _MiniEyebrow(text: 'Quick Overview'),
        const SizedBox(height: 10),
        Text(
          'High-level business numbers that help visitors trust the brand faster.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: CompanyContent.keyFigures
              .map((KeyFigure figure) => _KeyFigureCard(figure: figure))
              .toList(),
        ),
      ],
    );
  }
}

class _KeyFigureCard extends StatelessWidget {
  const _KeyFigureCard({required this.figure});

  final KeyFigure figure;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF203A2D),
            Color(0xFF365644),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            figure.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            figure.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFF5EAD3),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _MiniEyebrow(text: 'Testimonials'),
        const SizedBox(height: 10),
        Text(
          'Customer confidence is one of the most important parts of a property website.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final cards = CompanyContent.testimonials
                .map((TestimonialItem item) => _TestimonialCard(item: item))
                .toList();
            return _ResponsiveCardGrid(children: cards);
          },
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.item});

  final TestimonialItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9DDC6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.format_quote, color: Color(0xFFB78628), size: 28),
          const SizedBox(height: 12),
          Text(
            item.message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: const Color(0xFF48544A),
                ),
          ),
          const SizedBox(height: 16),
          Text(
            item.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            item.role,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B736B),
                ),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _MiniEyebrow(text: 'FAQs'),
        const SizedBox(height: 10),
        Text(
          'Common buyer questions answered in one place.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 18),
        ...CompanyContent.faqs.map(
          (FaqItem item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7D7B8)),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                title: Text(
                  item.question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.answer,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: const Color(0xFF4F5B51),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterPanel extends StatelessWidget {
  const _FooterPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3228),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final info = <Widget>[
            _FooterColumn(
              title: 'Dream Land Properties',
              lines: <String>[
                CompanyContent.companyTagline,
                CompanyContent.office,
              ],
            ),
            _FooterColumn(
              title: 'Quick Contact',
              lines: <String>[
                CompanyContent.phone,
                CompanyContent.email,
                CompanyContent.officeHours,
              ],
            ),
            _FooterColumn(
              title: 'Website Focus',
              lines: <String>[
                'Company information',
                'Project tracking',
                'Buyer support and enquiries',
                'Modern responsive UI',
              ],
            ),
          ];

          if (constraints.maxWidth > 980) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: info[0]),
                const SizedBox(width: 24),
                Expanded(child: info[1]),
                const SizedBox(width: 24),
                Expanded(child: info[2]),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              info[0],
              const SizedBox(height: 18),
              info[1],
              const SizedBox(height: 18),
              info[2],
            ],
          );
        },
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        ...lines.map(
          (String line) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFE7E2D6),
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7D7B8)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF324034),
            ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF203A2D),
      backgroundColor: Colors.white.withOpacity(0.75),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF334135),
        fontWeight: FontWeight.w700,
      ),
      side: const BorderSide(color: Color(0xFFD6C7AA)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final PropertyProject project;

  @override
  Widget build(BuildContext context) {
    return _InteractiveCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: _RemoteImage(
              url: project.imageUrl,
              height: 220,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _StatusPill(status: project.status),
                const SizedBox(height: 14),
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  project.location,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF637066),
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: const Color(0xFF4F5B51),
                      ),
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'Stage', value: project.progressLabel),
                _DetailRow(label: 'Units', value: '${project.units}'),
                _DetailRow(label: 'Timeline', value: project.deliveryWindow),
                const SizedBox(height: 12),
                ...project.highlights.map((String item) => _BulletItem(text: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteImage extends StatelessWidget {
  const _RemoteImage({
    required this.url,
    required this.height,
  });

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: const Color(0xFFE8E1D3),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return Container(
            color: const Color(0xFFE2D6C5),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_outlined,
              size: 40,
              color: Color(0xFF6B6B6B),
            ),
          );
        },
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: const Color(0xFF8A6724)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF6A726C),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF233326),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoPanel extends StatelessWidget {
  const _ContactInfoPanel({required this.onSubmitQuickAction});

  final VoidCallback onSubmitQuickAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _MiniEyebrow(text: 'Contact Details'),
        const SizedBox(height: 14),
        _ContactRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: CompanyContent.phone,
        ),
        _ContactRow(
          icon: Icons.mail_outline,
          label: 'Email',
          value: CompanyContent.email,
        ),
        _ContactRow(
          icon: Icons.location_on_outlined,
          label: 'Office',
          value: CompanyContent.office,
        ),
        _ContactRow(
          icon: Icons.schedule_outlined,
          label: 'Office Hours',
          value: CompanyContent.officeHours,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F1E5),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE6D7BA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Office Address',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                CompanyContent.addressLineOne,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                CompanyContent.addressLineTwo,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: onSubmitQuickAction,
              child: const Text('Book a Site Visit'),
            ),
            OutlinedButton(
              onPressed: onSubmitQuickAction,
              child: const Text('Request Callback'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EnquiryForm extends StatelessWidget {
  const _EnquiryForm({
    required this.viewModel,
    required this.onSubmit,
  });

  final ContactFormViewModel viewModel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _MiniEyebrow(text: 'Required Enquiry Form'),
          const SizedBox(height: 14),
          _FormField(
            label: 'Full Name',
            controller: viewModel.nameController,
            validator: viewModel.validateName,
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Phone Number',
            controller: viewModel.phoneController,
            keyboardType: TextInputType.phone,
            validator: viewModel.validatePhone,
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Email Address',
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: viewModel.validateEmail,
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Project Interest',
            controller: viewModel.projectController,
            validator: viewModel.validateProject,
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Message',
            controller: viewModel.messageController,
            maxLines: 4,
            validator: viewModel.validateMessage,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              child: const Text('Submit Enquiry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.82),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD6C7AA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD6C7AA)),
        ),
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isWide = constraints.maxWidth > 950;

        final map = Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFFE2E8D8),
                Color(0xFFF0E6D1),
                Color(0xFFD9E1EB),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapPainter(),
                ),
              ),
              Positioned(
                left: 120,
                top: 92,
                child: _MapMarker(label: 'Business Plaza'),
              ),
              Positioned(
                left: 230,
                top: 150,
                child: _MapMarker(
                  label: 'Dream Land Office',
                  highlighted: true,
                ),
              ),
              Positioned(
                right: 88,
                top: 90,
                child: _MapMarker(label: 'Bank Street'),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CompanyContent.mapCaption,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF425248),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );

        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _MiniEyebrow(text: 'Location Map'),

            const SizedBox(height: 12),

            Text(
              'Office location with address guidance and nearby references.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Use this map section to help customers understand where your office is located before they call or visit. You can later replace this with a live Google Maps embed if needed.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: const Color(0xFF4F5B51),
                  ),
            ),
            const SizedBox(height: 18),
            const _BulletItem(text: 'Near Business Plaza and main road connectivity'),
            const _BulletItem(text: 'Easy access for site visits and customer meetings'),
            const _BulletItem(text: 'Ready for future live map embedding and lead tracking'),
          ],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 5, child: details),
              const SizedBox(width: 20),
              Expanded(flex: 6, child: map),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            details,
            const SizedBox(height: 20),
            map,
          ],
        );
      },
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.label,
    this.highlighted = false,
  });

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Color color = highlighted ? const Color(0xFF9D1F1F) : const Color(0xFF203A2D);

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Icon(Icons.location_on, color: color, size: highlighted ? 28 : 24),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.85)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final subRoadPaint = Paint()
      ..color = const Color(0xFFF4F0E7)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.25),
      Offset(size.width * 0.92, size.height * 0.72),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.82),
      Offset(size.width * 0.74, size.height * 0.18),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.52),
      Offset(size.width * 0.88, size.height * 0.52),
      subRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.08),
      Offset(size.width * 0.52, size.height * 0.88),
      subRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFB78628),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: const Color(0xFF4F5B51),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B736B),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F3B31),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status) {
      case ProjectStatus.upcoming:
        color = const Color(0xFF2B6CB0);
        label = 'Upcoming';
      case ProjectStatus.completed:
        color = const Color(0xFF2F855A);
        label = 'Completed';
      case ProjectStatus.pending:
        color = const Color(0xFFC05621);
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
