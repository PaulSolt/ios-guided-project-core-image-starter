import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    private let context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {
            // 414 * 3 = 1,242 pixels (portrait on iPhone 11 Pro Max)
            guard let originalImage = originalImage else {
                scaledImage = nil // clear out image if set to nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }

    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Printing the attributes helps you learn about the filter
        let filter = CIFilter.colorControls()
        filter.brightness = 1 // ranges are dependent on implementation / documentation
        print(filter.attributes)
        
        originalImage = imageView.image
    }
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        // UIImage -> CGImage -> CIImage

        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Filtering
        let filter = CIFilter.colorControls()  // May not work for some custom filters (KVC protocol)
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        // CIImage -> CGImage -> UIImage
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render image
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
	
    private func updateViews() {
        guard let scaledImage = scaledImage else { return }
        imageView.image = filterImage(scaledImage)
    }
    
	// MARK: Actions
	
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        presentImagePickerController()
    }

    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
	
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
		// TODO: Save to photo library
	}
	

	// MARK: Slider events
	
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateViews()
    }

    @IBAction func contrastChanged(_ sender: Any) {
        updateViews()
    }

    @IBAction func saturationChanged(_ sender: Any) {
        updateViews()
    }
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension PhotoFilterViewController: UINavigationControllerDelegate {
    
}
