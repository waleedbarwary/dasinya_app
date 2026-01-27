import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../services/supabase_service.dart';
import '../../models/video_model.dart';
import 'manage_content_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentColor,
          indicatorWeight: 3,
          labelColor: AppColors.accentColor,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.live_tv),
              text: 'LIVE STREAM',
            ),
            Tab(
              icon: Icon(Icons.video_library),
              text: 'ARCHIVE VIDEO',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'MANAGE',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiveStreamTab(),
          ArchiveVideoTab(),
          ManageContentTab(),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: LIVE STREAM
// ============================================================================
class LiveStreamTab extends StatefulWidget {
  const LiveStreamTab({Key? key}) : super(key: key);

  @override
  State<LiveStreamTab> createState() => _LiveStreamTabState();
}

class _LiveStreamTabState extends State<LiveStreamTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _streamUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _thumbnailImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _streamUrlController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _thumbnailImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _uploadLiveStream() async {
    if (!_formKey.currentState!.validate()) return;

    if (_thumbnailImage == null) {
      _showSnackBar('Please select a thumbnail image', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final supabaseService = SupabaseService();

      // 1. Upload Thumbnail to Supabase Storage
      final thumbnailUrl = await supabaseService.uploadThumbnail(_thumbnailImage!);

      // 2. Add to Supabase Database
      await supabaseService.addVideo(
        title: _titleController.text.trim(),
        url: _streamUrlController.text.trim(),
        thumbnailUrl: thumbnailUrl,
        logoUrl: thumbnailUrl,
        category: _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        duration: 'LIVE',
        description: _descriptionController.text.trim().isEmpty
            ? 'Live stream'
            : _descriptionController.text.trim(),
        isLive: true,
        featured: false,
      );

      _showSnackBar('Live stream added successfully! 🎉', isError: false);

      // Clear form
      _titleController.clear();
      _streamUrlController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      setState(() {
        _thumbnailImage = null;
      });
    } catch (e) {
      _showSnackBar('Error uploading: $e', isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Title
            _buildTextField(
              controller: _titleController,
              label: 'Title *',
              hint: 'Enter stream title',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Stream URL
            _buildTextField(
              controller: _streamUrlController,
              label: 'Stream URL *',
              hint: 'https://example.com/stream.m3u8',
              icon: Icons.link,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Stream URL is required';
                }
                if (!value.trim().startsWith('http')) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category
            _buildTextField(
              controller: _categoryController,
              label: 'Category',
              hint: 'News, Sports, Music, etc.',
              icon: Icons.category,
            ),

            const SizedBox(height: 16),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter description (optional)',
              icon: Icons.description,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Thumbnail Picker
            _buildSectionLabel('Thumbnail Image *'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickThumbnail,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: _thumbnailImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _thumbnailImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to select thumbnail',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadLiveStream,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.accentColor.withOpacity(0.5),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Upload Live Stream',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: AppColors.accentColor),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.accentColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

// ============================================================================
// TAB 2: ARCHIVE VIDEO
// ============================================================================
class ArchiveVideoTab extends StatefulWidget {
  const ArchiveVideoTab({Key? key}) : super(key: key);

  @override
  State<ArchiveVideoTab> createState() => _ArchiveVideoTabState();
}

class _ArchiveVideoTabState extends State<ArchiveVideoTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  File? _thumbnailImage;
  File? _videoFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _thumbnailImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        setState(() {
          _videoFile = File(video.path);
        });
        _showSnackBar('Video selected: ${_getFileName(video.path)}', isError: false);
      }
    } catch (e) {
      _showSnackBar('Error picking video: $e', isError: true);
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  Future<void> _uploadArchiveVideo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_thumbnailImage == null) {
      _showSnackBar('Please select a thumbnail image', isError: true);
      return;
    }

    if (_videoFile == null) {
      _showSnackBar('Please select a video file', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final supabaseService = SupabaseService();

      // 1. Upload Thumbnail
      setState(() => _uploadProgress = 0.1);
      final thumbnailUrl = await supabaseService.uploadThumbnail(_thumbnailImage!);
      
      setState(() => _uploadProgress = 0.3);

      // 2. Upload Video
      final videoUrl = await supabaseService.uploadVideo(
        _videoFile!,
        onProgress: (progress) {
          setState(() {
            // Map progress from 0.3 to 0.9
            _uploadProgress = 0.3 + (progress * 0.6);
          });
        },
      );

      setState(() => _uploadProgress = 0.95);

      // 3. Add to Supabase Database
      await supabaseService.addVideo(
        title: _titleController.text.trim(),
        url: videoUrl,
        thumbnailUrl: thumbnailUrl,
        category: _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        duration: _durationController.text.trim().isEmpty
            ? '0:00'
            : _durationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? 'Archive video'
            : _descriptionController.text.trim(),
        isLive: false,
        featured: false,
      );

      setState(() => _uploadProgress = 1.0);

      _showSnackBar('Archive video uploaded successfully! 🎉', isError: false);

      // Clear form
      _titleController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _durationController.clear();
      setState(() {
        _thumbnailImage = null;
        _videoFile = null;
        _uploadProgress = 0.0;
      });
    } catch (e) {
      _showSnackBar('Error uploading: $e', isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Title
            _buildTextField(
              controller: _titleController,
              label: 'Title *',
              hint: 'Enter video title',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category
            _buildTextField(
              controller: _categoryController,
              label: 'Category',
              hint: 'Drama, Action, Comedy, etc.',
              icon: Icons.category,
            ),

            const SizedBox(height: 16),

            // Duration
            _buildTextField(
              controller: _durationController,
              label: 'Duration',
              hint: 'e.g., 1h 30m or 45m',
              icon: Icons.timer,
            ),

            const SizedBox(height: 16),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter description (optional)',
              icon: Icons.description,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Thumbnail Picker
            _buildSectionLabel('Thumbnail Image *'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickThumbnail,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: _thumbnailImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _thumbnailImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to select thumbnail',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Video Picker
            _buildSectionLabel('Video File *'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _videoFile != null
                        ? AppColors.accentColor
                        : Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _videoFile != null
                            ? AppColors.accentColor.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _videoFile != null ? Icons.check_circle : Icons.video_library,
                        color: _videoFile != null
                            ? AppColors.accentColor
                            : Colors.white.withOpacity(0.3),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _videoFile != null
                                ? _getFileName(_videoFile!.path)
                                : 'Select Video File',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _videoFile != null
                                ? 'Tap to change'
                                : 'Tap to select from gallery',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.3),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            if (_isUploading) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Uploading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadArchiveVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.accentColor.withOpacity(0.5),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Upload Archive Video',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: AppColors.accentColor),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.accentColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
