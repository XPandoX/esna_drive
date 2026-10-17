import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../core/theme/app_theme.dart';

class WeatherBanner extends StatelessWidget {
  const WeatherBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProv, child) {
        final weather = weatherProv.weather;
        if (weather == null) return const SizedBox.shrink();

        final isHot = weather.isExtremeHeat;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isHot ? const Color(0xFF3E2010) : AppTheme.darkSurface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHot ? AppTheme.warningOrange : AppTheme.darkBorder,
              width: isHot ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isHot ? Icons.wb_sunny_rounded : (weather.isDay ? Icons.wb_sunny_outlined : Icons.nightlight_round),
                color: isHot ? AppTheme.warningOrange : AppTheme.primaryLime,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'طقس إسنا: ${weather.temperature.toStringAsFixed(1)}°م',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  weather.weatherDescription,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isHot) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+5 ج.م حافز حرارة للكابتن',
                    style: TextStyle(
                      color: AppTheme.warningOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
