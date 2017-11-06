//
//  MyViewController.swift
//  Visionary
//
//  Created by Thijs van der Heijden on 11/5/17.
//  Copyright © 2017 Thijs van der Heijden. All rights reserved.
//

import UIKit
import MobileCoreServices
import Vision
import CoreML
import AVKit

class MyViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var roundedView: RoundedShadowView!
    @IBOutlet weak var confidenceLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCaptureSession()
    }
    
    fileprivate func setLayerAsBackground(layer: CALayer) {
        view.layer.addSublayer(layer)
        layer.frame = view.bounds
        view.bringSubview(toFront: resultLabel)
        view.bringSubview(toFront: roundedView)
    }
    
    fileprivate func prepareCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let backCamera = AVCaptureDevice.default(for: .video)!
        let input = try! AVCaptureDeviceInput(device: backCamera)
        
        captureSession.addInput(input)
        
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        setLayerAsBackground(layer: cameraPreviewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        videoOutput.recommendedVideoSettings(forVideoCodecType: .jpeg, assetWriterOutputFileType: .mp4)
        
        captureSession.addOutput(videoOutput)
        captureSession.sessionPreset = .high
        captureSession.startRunning()
    }
    
    fileprivate func predict(_ pixelBuffer: CVPixelBuffer) {
        let model = try! VNCoreMLModel(for: Inceptionv3().model)
        let request = VNCoreMLRequest(model: model, completionHandler: didGetPredictionResults)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try! handler.perform([request])
    }
    
    fileprivate func didGetPredictionResults(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            resultLabel.text = "??🙀??"
            return
        }
        
        guard results.count != 0 else {
            resultLabel.text = "??🙀??"
            return
        }
        
        let highestConfidenceResult = results.first!
        
        // Sometimes results come back as comma delimited lists of synonyms. We should just take the first one if that is the case.
        let identifier = String(describing: highestConfidenceResult.identifier.split(separator: ",").first!)
        let confidence = highestConfidenceResult.confidence*100
        
        resultLabel.text = identifier
        confidenceLbl.text = "\(confidence)% certain"
    }
}

extension MyViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { fatalError("Pixel Buffer is nil.") }
            
        DispatchQueue.main.sync {
            predict(pixelBuffer)
        }
    }
}


