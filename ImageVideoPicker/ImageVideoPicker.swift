//
//  ImageVideoPicker.swift
//  Youtech PROD
//
//  Created by Ion Utale on 30/01/2018.
//  Copyright © 2018 Florence-Consulting. All rights reserved.
//

import Foundation
import Photos
import AVFoundation

enum CaptureType: Int {
    case photo
    case video
}

class MediaFile {
    var mimetype: String?
    var path: URL?
}

protocol ImageVideoPickerDelegate {
    func onCancel()
//    func onDoneSelection(urls: [MediaFile])
    func onDoneSelection(assets: [PHAsset])
}

class ImageVideoPicker: UIViewController {
    
    var destinationPath: URL?
    
    var captureType: CaptureType! = CaptureType.video
    var filePath: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("video.mov")
    }
    
    // camera capture
    var session: AVCaptureSession?
    var imageOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureMovieFileOutput? //AVCaptureVideoDataOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet var previewView: UIView!
    
    // photos/video library
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var mediaModeButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var toggleCollectionView: UIView!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    var allPhotos: PHFetchResult<PHAsset>!
    var selectedPhotos: [PHAsset] = []
    var delegate: ImageVideoPickerDelegate?
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!

    override func viewDidLoad() {
        print("ciao")
        collectionView.register(UINib(nibName: "ImageVideoPickerCell", bundle: nil), forCellWithReuseIdentifier: "asset")
        preparePhotoLibrary()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(toggleCollectionViewAction))
        toggleCollectionView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeMode(nil)
    }
    
    @objc func toggleCollectionViewAction() {
        if(collectionViewHeight.constant != 0) {
            UIView.animate(withDuration: 0.3) {
                self.collectionViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.collectionViewHeight.constant = 160
                self.view.layoutIfNeeded()
            }
        }
    }
    @IBAction func doneAction(_ sender: Any) {
        delegate?.onDoneSelection(assets: selectedPhotos)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeMode(_ sender: UIButton!) {
        if(captureType == .photo) {
            captureType = .video
            cameraButton.setImage(#imageLiteral(resourceName: "ic_start_rec"), for: .normal)
            mediaModeButton.setImage(#imageLiteral(resourceName: "ic_camera_white_24dp"), for: .normal)
        } else {
            captureType = .photo
            cameraButton.setImage(#imageLiteral(resourceName: "ic_save_photo"), for: .normal)
            mediaModeButton.setImage(#imageLiteral(resourceName: "video"), for: .normal)
        }
        setupCamera()
        videoPreviewLayer?.frame = previewView.bounds
    }
    
    @IBAction func savePicture(_ sender: UIButton!) {
        guard imageOutput != nil || videoOutput != nil else  { return }

        switch captureType {
        case .photo:
            capturePhoto()
        case .video:
            if videoOutput!.isRecording {
                cameraButton.setImage(#imageLiteral(resourceName: "ic_start_rec"), for: .normal)
                videoOutput?.stopRecording()
                mediaModeButton.isEnabled = true
                collectionView.isHidden = false
            } else {
                mediaModeButton.isEnabled = false
                collectionView.isHidden = true
                cameraButton.setImage(#imageLiteral(resourceName: "ic_stop_rec"), for: .normal)
                captureVideo()
            }
        default:
            print("capture type not recognized")
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

}

extension ImageVideoPicker: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ImageVideoPickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "asset", for: indexPath) as! ImageVideoPickerCell
        
        cell.asset = allPhotos.object(at: indexPath.item)
        cell.selection = false

        let index = selectedPhotos.index(of: cell.asset!)
        if index != nil {
            cell.selection = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = allPhotos.object(at: indexPath.item)
        
        let cell = collectionView.cellForItem(at: indexPath) as! ImageVideoPickerCell
        if cell.selection! {
            let index = selectedPhotos.index(of: asset)
            selectedPhotos.remove(at: index!)
            cell.selection = false
        } else {
            selectedPhotos.append(asset)
            cell.selection = true
        }
        
    }
}

extension ImageVideoPicker: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.height - 10, height: collectionView.frame.size.height - 10)
    }
}

extension ImageVideoPicker: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("did finish registering")
        
        if FileManager.default.fileExists(atPath: outputFileURL.path) {
            print("video found at path", outputFileURL.path)
        } else {
            print("video not found at path", outputFileURL.path)
        }
        
        do {
            let data = try Data.init(contentsOf: URL.init(string: outputFileURL.path)!)
            print (data)
        } catch (let error ) {
            print("no data found")
        }
        
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, nil, nil);
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("did start registering")
    }
}

// capture photo
extension ImageVideoPicker: AVCapturePhotoCaptureDelegate {
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { print(error.localizedDescription) }
        
        if let imageData = photo.fileDataRepresentation() {
            if let uiImage = UIImage(data: imageData) {
                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            }
        }
    }
    
    //For iOS 10 or below
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            UIImageWriteToSavedPhotosAlbum(UIImage(data: dataImage)!, nil, nil, nil)
        }
        
    }

}

extension ImageVideoPicker {
    
    func captureVideo() {
        guard videoOutput != nil else  { return }
        if videoOutput!.connection(with: AVMediaType.video) == nil { return }
        videoOutput?.startRecording(to: filePath, recordingDelegate: self)
    }
    
    func capturePhoto() {
        guard imageOutput != nil else  { return }
        if imageOutput!.connection(with: AVMediaType.video) == nil { return }
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        imageOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func setupCamera () {
        // Setup your camera here...
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("simulator has no camera")
            return
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput?
        (input, error) = captureDeviceInput(camera: backCamera)
        
        if error == nil && !(session!.canAddInput(input!)) { return }
        session!.addInput(input!)

        switch captureType {
        case .photo:
            prepareSessionForPhoto()
        case .video:
            prepareSessionForVideo()
        default:
            print("capture type not recognized")
        }
    }
    
    
    func prepareSessionForPhoto() {
        // The remainder of the session setup will go here...
        
        imageOutput = AVCapturePhotoOutput()
        if #available(iOS 11.0, *) {
            imageOutput?.supportedPhotoCodecTypes(for: AVFileType.jpg)
        } else {
            // Fallback on earlier versions
            /*let settings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecJPEG])
            imageOutput?.setPreparedPhotoSettingsArray([settings], completionHandler: nil)*/
        }
        //imageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session!.canAddOutput(imageOutput!) {
            session!.addOutput(imageOutput!)
            // ...
            // Configure the Live Preview here...
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            //                videoPreviewLayer!.frame = previewView.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            session!.startRunning()
        }
    }
    
    func prepareSessionForVideo() {
        
        videoOutput = AVCaptureMovieFileOutput() // AVCaptureVideoDataOutput() // 2
      
        if session!.canAddOutput(videoOutput!) {
            session!.addOutput(videoOutput!)
            // ...
            // Configure the Live Preview here...
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            previewView.layer.addSublayer(videoPreviewLayer!)
            session!.startRunning()
        }
        
    }
    
    func captureDeviceInput(camera: AVCaptureDevice) -> (AVCaptureDeviceInput?, NSError?) {
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        return (input, error)
    }
}


// MARK : - get images and videos
extension ImageVideoPicker: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                // Update the cached fetch result.
                allPhotos = changeDetails.fetchResultAfterChanges
                // (The table row for this one doesn't need updating, it always says "All Photos".)
                self.collectionView.reloadData()
            }
        }
    }
}

extension ImageVideoPicker {
    
    func preparePhotoLibrary() {
        PHPhotoLibrary.shared().register(self)
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        print(allPhotos.count)
        updateItemSize()
    }
    
    private func updateItemSize() {
        
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
}
