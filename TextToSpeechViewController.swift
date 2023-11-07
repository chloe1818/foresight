//
//  TextToSpeechViewController.swift
//  ObjectDetection
//
//  Created by Chloe Wu on 10/30/22.
//

import UIKit
import Vision
import VisionKit
import AVFoundation

class TextToSpeechViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    var recognizedText = ""
    
    let textRecognizationQueue = DispatchQueue(label: "TextRecognitionQueue", qos: .userInitiated,
        attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var request = [VNRequest]()

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVision()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func scanTextButtonTapped(_ sender: Any) {
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion:nil)
    }
    
    func setUpVision(){
        let textRecognizationRequest = VNRecognizeTextRequest {(request, Error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No Results Found")
                return
            }
            //recognizedText = ""
            let maximumCandidates = 1;
            for observation in observations {
                let candidate = observation.topCandidates(maximumCandidates).first
                self.recognizedText += candidate?.string ?? ""
            }
            self.textView.text = self.recognizedText
        }
        textRecognizationRequest.recognitionLevel = .accurate
        self.request = [textRecognizationRequest]
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true, completion: nil)
        for i in 0..<scan.pageCount {
            let scannedImage = scan.imageOfPage(at: i)
            if let cgImage = scannedImage.cgImage {
                let requestHandler = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
                do{
                try requestHandler.perform(self.request)
                }
                catch{
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    let synthesizer = AVSpeechSynthesizer()
   
    @IBAction func readTextButtonTapped(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: recognizedText)
        synthesizer.speak(utterance)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
