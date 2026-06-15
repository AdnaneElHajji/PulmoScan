# ML Model Integration - pulmoscan_model.tflite

## Model Details
- **Name**: pulmoscan_model.tflite
- **Framework**: TensorFlow Lite
- **Type**: Image Classification
- **Purpose**: Pulmonary disease classification from chest X-ray images
- **Use Case**: Medical diagnosis and screening for lung diseases

## Model I/O Specifications

### Input
- **Shape**: [1, 240, 240, 3]
  - Batch size: 1
  - Image dimensions: 240 × 240 pixels
  - Channels: 3 (RGB)
- **Type**: Float32
- **Expected Input**: Chest X-ray image (RGB)
- **Preprocessing Required**: 
  - Resize image to 240×240 pixels
  - Normalize pixel values to float32
  - Input as RGB format

### Output
- **Shape**: [1, 14]
  - Batch size: 1
  - Number of classes: 14 different lung diseases/conditions
- **Type**: Float32
- **Output Format**: Probability distribution across 14 disease classes
- **Classes**: [List the 14 diseases - add from your training documentation]

## Model Performance
- **Model Size**: 8.07 MB
- **Inference Time**: [Test on your device - typically ~50-200ms for mobile]
- **Accuracy**: [Add from your training metrics]
- **Quantization**: None (Full precision Float32)
- **Input Tensor Name**: `serving_default_keras_tensor_344:0`
- **Output Tensor Name**: `StatefulPartitionedCall_1:0`

## Flutter Integration
- **Package Used**: `tflite_flutter`
- **Asset Path**: `assets/models/pulmoscan_model.tflite`
- **Model Loading**: Eager loading (on app startup)
- **GPU Acceleration**: [Configure as needed]

## Dependencies
```yaml
tflite_flutter: ^0.9.0
image: ^4.0.0
camera: ^0.10.0
```

## Usage Flow in App
1. Load model on app startup via `PulmoscanMLService.init()`
2. Capture or select chest X-ray image from gallery
3. Preprocess image to 240×240 RGB in `ImageProcessor`
4. Run inference via `PulmoscanMLService.predict(image)`
5. Get probability scores for 14 disease classes
6. Post-process results in `ResultProcessor` (get top predictions)
7. Display diagnosis results and confidence scores in UI

## Raw Model Details (TensorFlow Lite)

**Input Tensor:**
- Name: `serving_default_keras_tensor_344:0`
- Shape: [1, 240, 240, 3]
- Data Type: float32
- Quantization: None

**Output Tensor:**
- Name: `StatefulPartitionedCall_1:0`
- Shape: [1, 14]
- Data Type: float32
- Quantization: None