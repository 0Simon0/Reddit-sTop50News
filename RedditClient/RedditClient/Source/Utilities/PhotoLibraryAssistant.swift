//
//  PhotoLibraryAssistant.swift
//  RedditClient
//
//  Created by Yana VV on 4/24/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Photos

class PhotoLibraryAssistant {

	enum PhotoLibraryAssistantError : Error {
		case notAuthorizedAccessToPhotos
	}

	public static func isAuthorizedAccess() -> Bool {
		switch PHPhotoLibrary.authorizationStatus() {
		case .authorized, .notDetermined:
			return true
		case .restricted, .denied:
			return false
		}
	}

	static func addImageToPhotos(_ image: UIImage, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
		
		let addImageToPhotos = {
			PHPhotoLibrary.shared().performChanges({
				PHAssetChangeRequest.creationRequestForAsset(from: image)
			}, completionHandler: { success, error in
				DispatchQueue.main.async {
					completion?(success, error)
				}
			})
		}

		PHPhotoLibrary.requestAuthorization { status in
			if status == .authorized {
				addImageToPhotos()
			} else {
				completion?(false, PhotoLibraryAssistantError.notAuthorizedAccessToPhotos)
			}
		}
	}

	static func showAuthorizationRequiredAlert(uiPresenter: UIViewController) {

		let alertController = UIAlertController(title: "Access to Photos required", message: "Please give access to your Photos. Go to your phone settings and turn on permission.", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
		alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
			openSystemSettings()
		}))

		uiPresenter.present(alertController, animated: true, completion: nil)
	}

	private static func openSystemSettings() {
		if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
			UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
		}
	}
}
