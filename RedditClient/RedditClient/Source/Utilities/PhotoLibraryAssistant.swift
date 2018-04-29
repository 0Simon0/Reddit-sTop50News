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

	private static func isAuthorizedAccess(_ status: PHAuthorizationStatus) -> Bool {
		switch status {
		case .authorized:
			return true
		case .restricted, .denied, .notDetermined:
			return false
		}
	}

	static func isAuthorizedAccess() -> Bool {
		return isAuthorizedAccess(PHPhotoLibrary.authorizationStatus())
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

	static func showAuthorizationRequiredAlert(uiPresenter: UIViewController, completion: ((_ isAuthorizedAccess: Bool) -> Void)?) {

		switch PHPhotoLibrary.authorizationStatus() {
		case .authorized:
			assert(false, "Ask to show authorization required alert when access has already authorized.")
			completion?(true)
			break
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization { (status) in
				completion?(isAuthorizedAccess(status))
			}
			break
		default:
			let alertController = UIAlertController(title: "Access to Photos required", message: "Please give access to your Photos. Go to your phone settings and turn on permission.", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
				completion?(isAuthorizedAccess(PHPhotoLibrary.authorizationStatus()))
			}))
			alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
				openSystemSettings()
				completion?(isAuthorizedAccess(PHPhotoLibrary.authorizationStatus()))
			}))

			uiPresenter.present(alertController, animated: true, completion: nil)
			break
		}
	}

	private static func openSystemSettings() {
		if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
			UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
		}
	}
}
