//
//  AddReviewViewController.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/23/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import UIKit
import Speech
import FirebaseFirestore
import CodableFirebase
import FirebaseStorage

// View Controller for submitting a study spot review
class AddReviewViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, SFSpeechRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var reviewsService = ReviewsService.shared
    private var studySpotsService = StudySpotsService.shared
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let audioEngine = AVAudioEngine()
    // Request to recognize speech in a recorded audio file
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    // Recognition task for the speech recognition session
    private var recognitionTask: SFSpeechRecognitionTask?
    // Access to Firebase Storage
    private let storage = Storage.storage().reference()

    @IBOutlet weak var studySpotImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var isFavorite: UISwitch!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    // Set up custom UI for view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up background tapping to dismiss keyboard
        let singleTap = UITapGestureRecognizer(target: self,
        action: #selector(singleTappedRecognized))
        self.view.addGestureRecognizer(singleTap)

        // Set up UI for description text view
        setUpDescriptionTextViewUI()
        // Set up UI for buttons
        setUpButtonsUI()
    }
    
    // Configures speech recognition feature and requests for authorization if not yet granted
    override func viewDidAppear(_ animated: Bool) {
        // Configuration for speech recognition
        speechRecognizer.delegate = self
        
        // Asynchronously make the authorization request
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Execute updating the user interface in main thread
            DispatchQueue.main.async {
                // Check status of request authorization
                switch authStatus {
                    case .authorized:
                        self.transcribeButton.isEnabled = true
                        self.transcribeButton.setTitle("Start Transcription", for: .normal)
                        self.transcribeButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
                    case .notDetermined:
                        self.transcribeButton.isEnabled = false
                        self.transcribeButton.setTitle("Start Transcription (disabled)", for: .disabled)
                        self.transcribeButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
                    case .denied:
                        self.transcribeButton.isEnabled = false
                        self.transcribeButton.setTitle("Start Transcription (disabled)", for: .disabled)
                        self.transcribeButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
                    case .restricted:
                        self.transcribeButton.isEnabled = false
                        self.transcribeButton.setTitle("Start Transcription (disabled)", for: .disabled)
                        self.transcribeButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
                    @unknown default:
                        self.transcribeButton.isEnabled = false
                        self.transcribeButton.setTitle("Start Transcription (disabled)", for: .disabled)
                        self.transcribeButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
                }
            }
        }
    }
    
    // Clicking on background dismisses keyboard
    @objc func singleTappedRecognized (recognizer: UITapGestureRecognizer) {
        // If user clicks on background, then dismiss keyboard
        if descriptionTextView.isFirstResponder {
            descriptionTextView.resignFirstResponder()
        }
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
        if addressTextField.isFirstResponder {
            addressTextField.resignFirstResponder()
        }
        if cityTextField.isFirstResponder {
            cityTextField.resignFirstResponder()
        }
        if stateTextField.isFirstResponder {
            stateTextField.resignFirstResponder()
        }
        if zipCodeTextField.isFirstResponder {
            zipCodeTextField.resignFirstResponder()
        }
    }
    
    // Clear description placeholder text (if applicable) when user begins to edit text
    func textViewDidBeginEditing(_ textView: UITextView) {
        // If placeholder text is present, then clear input and set color to black first
        if descriptionTextView.textColor == UIColor.gray.withAlphaComponent(0.3) {
            descriptionTextView.textColor = .black
            descriptionTextView.text = ""
        }
    }
    
    // Add description placeholder text if empty after user finishes editing
    func textViewDidEndEditing(_ textView: UITextView) {
        // If text is empty, then add back placeholder text
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Use your keyboard to type or use the voice-to-text option below."
            descriptionTextView.textColor = UIColor.gray.withAlphaComponent(0.3)
        }
    }
    
    // Add placeholder text and customize text view UI to be rounded
    func setUpDescriptionTextViewUI() {
        descriptionTextView.text = "Use your keyboard to type or use the voice-to-text option below."
        descriptionTextView.textColor = UIColor.gray.withAlphaComponent(0.3)
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.clipsToBounds = true
    }
    
    // Customize buttons to have specific color and font
    func setUpButtonsUI() {
        transcribeButton.backgroundColor = UIColor(red: 89/255, green: 115/255, blue: 147/255, alpha: 1.0)
        transcribeButton.layer.cornerRadius = 5
        transcribeButton.clipsToBounds = true
        transcribeButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
        // Disable transcription button unless authorization has been granted
        transcribeButton.isEnabled = false
        transcribeButton.setTitle("Start Transcription (disabled)", for: .disabled)
        submitButton.backgroundColor = UIColor(red: 89/255, green: 115/255, blue: 147/255, alpha: 1.0)
        submitButton.layer.cornerRadius = 5
        submitButton.clipsToBounds = true
        submitButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
        cancelButton.backgroundColor = .lightGray
        cancelButton.layer.cornerRadius = 5
        cancelButton.clipsToBounds = true
        cancelButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
        selectPhotoButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
    }
    
    // Pressing return for description text view will dismiss keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
        // If return was clicked, then dismiss keyboard
        if string == "\n" {
            descriptionTextView.resignFirstResponder()
        }
        return true
    }
    
    //  Pressing return on the keyboard associated with text fields dismisses keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // If return was clicked, then dismiss keyboard
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
        if addressTextField.isFirstResponder {
            addressTextField.resignFirstResponder()
        }
        if cityTextField.isFirstResponder {
            cityTextField.resignFirstResponder()
        }
        if stateTextField.isFirstResponder {
            stateTextField.resignFirstResponder()
        }
        if zipCodeTextField.isFirstResponder {
            zipCodeTextField.resignFirstResponder()
        }
        return true
    }
    
    // Called whenever availability of speech recognizer changes
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // If speech recognizer is available, then enable start transcription option
        if available {
            transcribeButton.isEnabled = true
            transcribeButton.setTitle("Start Transcription", for: .normal)
        }
        // Else speech recognizer not available, then disable transcription option
        else {
            transcribeButton.isEnabled = false
            transcribeButton.setTitle("Start Transcription (disabled)", for: .disabled)
        }
    }
    
    // Clear UI for inputs
    func resetInputs() {
        nameTextField.text = ""
        addressTextField.text = ""
        cityTextField.text = ""
        stateTextField.text = ""
        zipCodeTextField.text = ""
        descriptionTextView.text = "Use your keyboard to type or use the voice-to-text option below."
        descriptionTextView.textColor = UIColor.gray.withAlphaComponent(0.3)
    }

    // Show photo library
    @IBAction func selectPhotoDidTapped(_ sender: UIButton) {
        // View Controller that will allow the user to select a picture from their photo library
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    // When user selects a photo, then show image preview
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        studySpotImageView.image = image
        picker.dismiss(animated: true)
    }
    
    // When user taps cancel for image picker, just dismiss
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // When user taps cancel, then reset all inputs
    @IBAction func cancelDidTapped(_ sender: UIButton) {
        resetInputs()
        dismiss(animated: true)
    }
    
    // Upload study spot review to Firestore
    @IBAction func submitDidTapped(_ sender: UIButton) {
        // Check that inputs are not empty
        guard let description = descriptionTextView.text, !description.isEmpty else {
            displayMissingInputsAlert()
            return
        }
        // If description is placeholder text, then still considered empty
        if description.caseInsensitiveCompare("Use your keyboard to type or use the voice-to-text option below.") == .orderedSame {
            displayMissingInputsAlert()
            return
        }
        guard let name = nameTextField.text, !name.isEmpty else {
            displayMissingInputsAlert()
            return
        }
        guard let street = addressTextField.text, !street.isEmpty else {
            displayMissingInputsAlert()
            return
        }
        guard let city = cityTextField.text, !city.isEmpty else {
            displayMissingInputsAlert()
            return
        }
        guard let state = stateTextField.text, !state.isEmpty else {
            displayMissingInputsAlert()
            return
        }
        guard let zipCode = zipCodeTextField.text, !zipCode.isEmpty else {
            displayMissingInputsAlert()
            return
        }
        
        // Compress selected image to smallest file
        guard let imageData = studySpotImageView.image?.jpegData(compressionQuality: 0.0) else {
            return
        }
        // Use current date time to give unique image path reference on Storage
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let path = "images/\(dateString)"
        // Upload image to Storage
        storage.child(path).putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("Failed to upload to Firebase Storage")
                return
            }
            // Get a download URL after upload
            self.storage.child(path).downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    print("Failed to get download URL...")
                    return
                }
                let urlString = url.absoluteString
                let address = Address(street: street, city: city, state: state, zipCode: zipCode)
                let studySpot = StudySpot(name: name, address: address)
                let studySpotReview = StudySpotReview(userId: User.shared.userID, studySpot: studySpot, description: description, isFavorite: self.isFavorite.isOn, imageURL: urlString)
                self.reviewsService.studySpotReviews.append(studySpotReview)
                // Add new review to study spot reviews collection on Firestore
                let docData = try! FirestoreEncoder().encode(studySpotReview)
                Firestore.firestore().collection("studySpotReviews").addDocument(data: docData) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                // If study spot is favorite, add to the current user
                if self.isFavorite.isOn {
                    // If the very first time we load favorites, then get from Firestore
                    if self.studySpotsService.favList.favStudySpots.isEmpty {
                        self.studySpotsService.getFavStudySpots { studySpots in
                            self.studySpotsService.favList = studySpots
                            self.studySpotsService.favList.favStudySpots.append(studySpot)
                            self.studySpotsService.uploadFavStudySpots()
                        }
                    }
                    // Else just add the new study spot and rewrite the array
                    else {
                        self.studySpotsService.favList.favStudySpots.append(studySpot)
                        self.studySpotsService.uploadFavStudySpots()
                    }
                }
                self.resetInputs()
                self.dismiss(animated: true)
            })
        })
    }
    
    // Displays alert to inform user about missing inputs
    func displayMissingInputsAlert() {
        let alertController = UIAlertController(title: "Missing Inputs", message: "Please make sure to provide all inputs.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Start or stop transcription
    @IBAction func transcribeDidTapped(_ sender: UIButton) {
        // If already recording audio, then stop recording and transcription feature
        if audioEngine.isRunning {
            audioEngine.stop()
            // Marks end of audio input for recognition request
            recognitionRequest?.endAudio()
            transcribeButton.isEnabled = false
            transcribeButton.setTitle("Start Transcription", for: .normal)
        }
        // Else start recording and transcription feature
        else {
            do {
                try startTranscription()
                transcribeButton.setTitle("Stop Transcription", for: [])
            } catch {
                transcribeButton.setTitle("Unable to Transcribe", for: [])
            }
        }
    }
    
    // Start recording and live transcription feature. Throws exception if unable to access microphone.
    func startTranscription() throws {
        // Cancel the previous task if it's running
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure the audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        // Represents the current audio input path, which can be device's built-in microphone or a microphone connected to a set of headphones
        let inputNode = audioEngine.inputNode
        
        // Create and configure speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        // Returns intermediate results as they are recognized
        recognitionRequest.shouldReportPartialResults = true
        // Keep speech recognition data on device if available
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        // Create a recognition task for the speech recognition session
        // Keep a reference to the task so that it can be canceled
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            // Update the description text view with results
            if let result = result {
                self.descriptionTextView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            // If transcription is done, then stop recognition
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.transcribeButton.isEnabled = true
                self.transcribeButton.setTitle("Start Transcription", for: [])
            }
        }
        // Configure the microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        // Install a tap on the input node and start up the audio engine, which begin collecting samples into an internal buffer
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        // If placeholder text, then first clear input and set color to black
        if self.descriptionTextView.textColor == UIColor.gray.withAlphaComponent(0.3) {
            self.descriptionTextView.textColor = .black
            self.descriptionTextView.text = ""
        }
    }
}
