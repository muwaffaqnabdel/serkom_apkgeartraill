import 'package:flutter/material.dart';

/// SkeletonShimmer — Reusable shimmering animation widget for loading states
class SkeletonShimmer extends StatefulWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-2.0 + (_controller.value * 4.0), -0.3),
              end: Alignment(-1.0 + (_controller.value * 4.0), 0.3),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Basic Shimmer Box component
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Preset Skeleton Loaders for different pages
class SkeletonLoader {
  const SkeletonLoader();

  /// Skeleton for Home Page (Hero Banner, Categories, Product Grid)
  static Widget buildHomeSkeleton() {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Skeleton
            const SkeletonBox(height: 220, borderRadius: 24),
            const SizedBox(height: 24),

            // Categories Title Skeleton
            const SkeletonBox(width: 140, height: 20, borderRadius: 6),
            const SizedBox(height: 12),

            // Categories Horizontal Scroll Skeleton
            Row(
              children: List.generate(
                4,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SkeletonBox(width: 80, height: 75, borderRadius: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Banner LBS Skeleton
            const SkeletonBox(height: 70, borderRadius: 16),
            const SizedBox(height: 24),

            // Product Grid Title Skeleton
            const SkeletonBox(width: 180, height: 20, borderRadius: 6),
            const SizedBox(height: 14),

            // Product Grid Skeleton (2x2)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => buildProductCardSkeleton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton for Catalog Page (Search Bar, Category Chips, Product Grid)
  static Widget buildCatalogSkeleton() {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar skeleton
            const SkeletonBox(height: 50, borderRadius: 14),
            const SizedBox(height: 16),

            // Category Chips Skeleton
            Row(
              children: List.generate(
                4,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SkeletonBox(width: 75, height: 36, borderRadius: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Grid Skeleton
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => buildProductCardSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton for Cart Page
  static Widget buildCartSkeleton() {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Cart Items Card Skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const SkeletonBox(width: 70, height: 70, borderRadius: 12),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonBox(width: 140, height: 16, borderRadius: 4),
                              SizedBox(height: 8),
                              SkeletonBox(width: 90, height: 14, borderRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location Box Skeleton
            const SkeletonBox(height: 60, borderRadius: 12),
            const SizedBox(height: 20),

            // Shipping Details Box Skeleton
            const SkeletonBox(height: 200, borderRadius: 16),
          ],
        ),
      ),
    );
  }

  /// Skeleton for Profile Page
  static Widget buildProfileSkeleton() {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Avatar Skeleton
            const Center(
              child: SkeletonBox(width: 100, height: 100, borderRadius: 50),
            ),
            const SizedBox(height: 16),
            const SkeletonBox(width: 160, height: 22, borderRadius: 6),
            const SizedBox(height: 8),
            const SkeletonBox(width: 100, height: 16, borderRadius: 12),
            const SizedBox(height: 32),

            // Menu Items Skeletons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: List.generate(
                  4,
                  (index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        SkeletonBox(width: 36, height: 36, borderRadius: 8),
                        SizedBox(width: 14),
                        Expanded(child: SkeletonBox(height: 16, borderRadius: 4)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single Product Card Skeleton
  static Widget buildProductCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          const SizedBox(height: 10),
          const SkeletonBox(width: 110, height: 14, borderRadius: 4),
          const SizedBox(height: 6),
          const SkeletonBox(width: 70, height: 12, borderRadius: 4),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 60, height: 16, borderRadius: 4),
              SkeletonBox(width: 28, height: 28, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}
