import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'model_part.dart';

class ModelViewerScreen extends StatefulWidget {
  const ModelViewerScreen({super.key});

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  Model3DConfig? _config;
  bool _isLoading = true;
  bool _partsEnabled = false;
  bool _wireframeEnabled = false;
  ModelPart? _selectedPart;

  // Fallback GLB URL if local model not found
  static const String _fallbackModelUrl =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/config/model_config.json');
      final data = json.decode(jsonString);
      setState(() {
        _config = Model3DConfig.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      // Use placeholder config
      setState(() {
        _config = Model3DConfig.placeholder();
        _isLoading = false;
      });
    }
  }

  void _onPartTapped(ModelPart part) {
    setState(() {
      _selectedPart = part;
    });
  }

  void _closePartDetails() {
    setState(() {
      _selectedPart = null;
      _wireframeEnabled = false;
    });
  }

  String _getModelUrl(String filename) {
    // If already a URL, use it directly
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    // Load from local assets - model_viewer_plus supports asset paths
    if (filename.endsWith('.glb') || filename.endsWith('.gltf')) {
      return 'assets/models/$filename';
    }
    return _fallbackModelUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
            : _buildMainView(),
      ),
    );
  }

  Widget _buildMainView() {
    return Stack(
      children: [
        // 3D Model Viewer (full screen, centered with auto-rotation)
        Positioned.fill(
          child: _build3DViewer(),
        ),
        // Inspect menu (top right)
        Positioned(
          top: 16,
          right: 16,
          child: _buildInspectMenu(),
        ),
        // Part details overlay with 3D view
        if (_selectedPart != null) _buildPartDetailsOverlay(),
      ],
    );
  }

  Widget _build3DViewer() {
    final modelUrl = _getModelUrl(_config?.mainModel ?? 'placeholder.glb');

    return Container(
      color: const Color(0xFF0f0f1a),
      child: ModelViewer(
        src: modelUrl,
        alt: _config?.name ?? 'Kenny 3D Model',
        autoRotate: true,
        autoRotateDelay: 10000, // 10 seconds before resuming rotation after interaction
        rotationPerSecond: '10deg', // Slower rotation (was 30deg)
        cameraControls: true,
        disableZoom: false,
        backgroundColor: const Color(0xFF0f0f1a),
        cameraOrbit: '0deg 75deg 105%',
        minCameraOrbit: 'auto auto 50%',
        maxCameraOrbit: 'auto auto 300%',
        exposure: 1.2,
      ),
    );
  }

  Widget _buildInspectMenu() {
    final parts = _config?.parts ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Inspect button
        GestureDetector(
          onTap: () {
            setState(() {
              _partsEnabled = !_partsEnabled;
              if (!_partsEnabled) {
                _wireframeEnabled = false;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _partsEnabled
                  ? Colors.blue.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _partsEnabled
                    ? Colors.blue
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.view_in_ar,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Parts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _partsEnabled ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        // Parts list dropdown
        if (_partsEnabled && parts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 180),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: parts.map((part) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _onPartTapped(part);
                      setState(() {
                        _partsEnabled = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              part.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white38,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPartDetailsOverlay() {
    final part = _selectedPart!;
    final partModelUrl = _getModelUrl(part.filename);

    return Positioned.fill(
      child: GestureDetector(
        onTap: _closePartDetails,
        child: Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: SafeArea(
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _closePartDetails,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          part.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3D Model View of the Part
                // Increased flex so the 3D view gets more space
                Expanded(
                  flex: 19,
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from closing
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f0f1a),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _wireframeEnabled
                              ? Colors.cyan.withValues(alpha: 0.5)
                              : Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            ModelViewer(
                              key: ValueKey('${part.id}_$_wireframeEnabled'),
                              src: partModelUrl,
                              alt: part.name,
                              autoRotate: !_wireframeEnabled,
                              autoRotateDelay: 10000,
                              rotationPerSecond: '30deg',
                              cameraControls: true,
                              disableZoom: false,
                              backgroundColor: const Color(0xFF0f0f1a),
                              cameraOrbit: '0deg 75deg 105%',
                              loading: _wireframeEnabled ? Loading.eager : Loading.auto,
                              relatedJs: '''
                                (function() {
                                  const mv = document.querySelector('model-viewer');
                                  const STORAGE_KEY = 'kenny_camera_orbit_${part.id}';

                                  // Save camera position on every camera change
                                  mv.addEventListener('camera-change', function() {
                                    try {
                                      const orbit = mv.getCameraOrbit();
                                      const orbitStr = orbit.theta + 'rad ' + orbit.phi + 'rad ' + orbit.radius + 'm';
                                      localStorage.setItem(STORAGE_KEY, orbitStr);
                                    } catch(e) {}
                                  });

                                  // Restore camera position on load
                                  function restoreCamera() {
                                    try {
                                      const saved = localStorage.getItem(STORAGE_KEY);
                                      if (saved) {
                                        mv.cameraOrbit = saved;
                                      }
                                    } catch(e) {}
                                  }

                                  ${_wireframeEnabled ? '''
                                  function enableWireframe() {
                                    try {
                                      const symbols = Object.getOwnPropertySymbols(mv);
                                      for (const sym of symbols) {
                                        const val = mv[sym];
                                        if (val && val.scene) {
                                          let applied = false;
                                          val.scene.traverse((obj) => {
                                            if (obj.isMesh && obj.material) {
                                              obj.material.wireframe = true;
                                              obj.material.needsUpdate = true;
                                              if (obj.material.color && obj.material.color.setRGB) {
                                                obj.material.color.setRGB(0, 0.9, 1);
                                              }
                                              applied = true;
                                            }
                                          });

                                          if (applied) {
                                            // Force multiple redraws to ensure wireframe shows
                                            if (val.renderer && val.camera) {
                                              val.renderer.render(val.scene, val.camera);
                                            }

                                            // Trigger model-viewer's internal render
                                            mv.requestUpdate();

                                            // Force camera nudge to trigger render
                                            const orbit = mv.getCameraOrbit();
                                            const epsilon = 0.0001;
                                            mv.cameraOrbit = (orbit.theta + epsilon) + 'rad ' + orbit.phi + 'rad ' + orbit.radius + 'm';

                                            // Restore after a tiny delay
                                            setTimeout(function() {
                                              mv.cameraOrbit = orbit.theta + 'rad ' + orbit.phi + 'rad ' + orbit.radius + 'm';
                                            }, 10);

                                            return true;
                                          }
                                        }
                                      }
                                    } catch(e) { console.error('Wireframe error:', e); }
                                    return false;
                                  }

                                  // Keep trying until wireframe is applied and rendered
                                  let attempts = 0;
                                  function tryWireframe() {
                                    attempts++;
                                    if (enableWireframe()) {
                                      // Keep forcing redraws for a bit to ensure it shows
                                      for (let i = 0; i < 5; i++) {
                                        setTimeout(function() {
                                          const orbit = mv.getCameraOrbit();
                                          mv.cameraOrbit = (orbit.theta + 0.0001) + 'rad ' + orbit.phi + 'rad ' + orbit.radius + 'm';
                                          setTimeout(function() {
                                            mv.cameraOrbit = orbit.theta + 'rad ' + orbit.phi + 'rad ' + orbit.radius + 'm';
                                          }, 5);
                                        }, i * 50);
                                      }
                                    } else if (attempts < 100) {
                                      requestAnimationFrame(tryWireframe);
                                    }
                                  }

                                  mv.addEventListener('load', function() {
                                    restoreCamera();
                                    setTimeout(tryWireframe, 10);
                                  });

                                  // Start trying immediately
                                  tryWireframe();
                                  ''' : '''
                                  mv.addEventListener('load', restoreCamera);
                                  setTimeout(restoreCamera, 300);
                                  '''}
                                })();
                              ''',
                            ),
                            // Wireframe toggle inside 3D viewer
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _wireframeEnabled = !_wireframeEnabled;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _wireframeEnabled
                                        ? Colors.cyan.withValues(alpha: 0.9)
                                        : Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _wireframeEnabled
                                          ? Colors.cyan
                                          : Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.grid_4x4,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Wireframe',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Part Details
                // Reduced height (about 40% smaller than before)
                Expanded(
                  flex: 6,
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from closing
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a1a2e),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description
                            if (part.description != null) ...[
                                Text(
                                  part.description!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                            ],

                            // Metadata
                            if (part.metadata != null && part.metadata!.isNotEmpty) ...[
                              Text(
                                'Details',
                                style: TextStyle(
                                  color: Colors.orange.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...part.metadata!.entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],

                            // File info
                            const SizedBox(height: 8),
                            Text(
                              part.filename,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
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
          ),
        ),
      ),
    );
  }

}
