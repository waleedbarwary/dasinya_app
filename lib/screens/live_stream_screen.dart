import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'video_player_screen.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DASINYA TV'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Live Stream Card
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoPlayerScreen(
                          videoUrl: Constants.liveStreamUrl,
                          videoTitle: 'Live Stream',
                          isLive: true,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildAnimatedLiveBadge(large: true),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '1.2K',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CachedNetworkImage(
                          imageUrl: 'https://i.ibb.co/MkmXyttP/5278332249655342554-removebg-preview.png', // Replace with your logo URL
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.play_circle_filled,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Watch Live Now',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'DASINYA TV',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // More TV Channels Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'More TV Channels',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildTVChannelItem(
                    context,
                    'Dasinya News',
                    'https://i.ibb.co/MkmXyttP/5278332249655342554-removebg-preview.png',
                    'https://your-stream-url.com/news.m3u8',
                  ),
                  _buildTVChannelItem(
                    context,
                    'Dasinya Sports',
                    'https://i.ibb.co/C5kzBDmc/5278332249655342558-removebg-preview.png',
                    'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
                  ),
                  _buildTVChannelItem(
                    context,
                    'Dasinya Kids',
                    'https://i.ibb.co/RKsHBqH/5278332249655342559-removebg-preview.png',
                    'https://your-stream-url.com/kids.m3u8',
                  ),
                  _buildTVChannelItem(
                    context,
                    'Dasinya Music',
                    'https://i.ibb.co/wFSDRrgP/5278332249655342553-removebg-preview.png',
                    'https://your-stream-url.com/music.m3u8',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTVChannelItem(
    BuildContext context,
    String title,
    String logoUrl,
    String streamUrl,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoUrl: streamUrl,
              videoTitle: title,
              isLive: true,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.cardColor,
              AppTheme.cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.tv,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _buildAnimatedLiveBadge(large: false),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLiveBadge({required bool large}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 12 : 10,
            vertical: large ? 6 : 5,
          ),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(large ? 20 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(_animation.value * 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: large ? 8 : 6,
                height: large ? 8 : 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_animation.value),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: large ? 6 : 4),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: large ? 12 : 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



