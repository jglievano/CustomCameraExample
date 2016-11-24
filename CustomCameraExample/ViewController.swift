//
//  ViewController.swift
//  CustomCameraExample
//
//  Created by Gabriel Lievano on 11/16/16.
//  Copyright © 2016 Juan Gabriel Lievano. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

  var session: AVCaptureSession!
  var input: AVCaptureDeviceInput!
  var output: AVCapturePhotoOutput!
  var previewLayer: AVCaptureVideoPreviewLayer!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Swipe, Pan, Pinch
    let tap = UITapGestureRecognizer(target: self, action: #selector(capturePhoto))
    tap.numberOfTapsRequired = 1
    view.addGestureRecognizer(tap)
  }

  func capturePhoto(gestureRecognizer: UITapGestureRecognizer) {
    guard let connection = output.connection(withMediaType: AVMediaTypeVideo) else { return }
    connection.videoOrientation = .portrait

    let settings = AVCapturePhotoSettings()
    let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
    settings.previewPhotoFormat = [
      kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
      kCVPixelBufferWidthKey as String: 160,
      kCVPixelBufferHeightKey as String: 160,
    ]
    output.capturePhoto(with: settings, delegate: self)
  }

  // Let autocomplete do this. Type:
  // capturedidFinishProcessingPhotoSampleBuffer
  func capture(_ captureOutput: AVCapturePhotoOutput,
               didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
               previewPhotoSampleBuffer: CMSampleBuffer?,
               resolvedSettings: AVCaptureResolvedPhotoSettings,
               bracketSettings: AVCaptureBracketedStillImageSettings?,
               error: Error?) {
    if let error = error {
      print(error.localizedDescription)
    }

    if let sampleBuffer = photoSampleBuffer,
    let previewBuffer = previewPhotoSampleBuffer,
      let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
      guard let image = UIImage(data: dataImage) else { return }
      let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
      present(activity, animated: true, completion: nil)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    session = AVCaptureSession()
    session.sessionPreset = AVCaptureSessionPresetPhoto

    let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    do {
      input = try AVCaptureDeviceInput(device: camera)
    } catch { return }

    output = AVCapturePhotoOutput()

    guard session.canAddInput(input) && session.canAddOutput(output) else { return }

    session.addInput(input)
    session.addOutput(output)

    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
    previewLayer.frame = view.bounds
    previewLayer.connection?.videoOrientation = .portrait

    view.layer.addSublayer(previewLayer)

    session.startRunning()
  }
}

