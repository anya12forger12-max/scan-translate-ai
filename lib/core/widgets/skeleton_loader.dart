import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
        highlightColor:
            isDark ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class CardSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final Axis direction;
  final double? itemHeight;
  final double? itemWidth;

  const CardSkeletonLoader({
    super.key,
    this.itemCount = 4,
    this.direction = Axis.vertical,
    this.itemHeight,
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: direction == Axis.vertical ? 12 : 0,
            right: direction == Axis.horizontal ? 12 : 0,
          ),
          child: SkeletonLoader(
            width: itemWidth ?? double.infinity,
            height: itemHeight ?? 100,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}
