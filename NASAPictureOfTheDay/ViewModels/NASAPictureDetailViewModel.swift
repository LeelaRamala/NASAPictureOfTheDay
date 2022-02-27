//
//  NASAPictureDetailViewModel.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 26/02/22.
//

import Foundation

//protocol NASAPictureDetailsViewModelProtocol {
//    init(withAPIProvider apiProvider: NASAFeaturePictureDetailsAPIProvider)
//    var title: String? { get  }
//    var date: String? { get  }
//    var details: String? { get  }
//    var image: UIImage? { get  }
//    var isFavourite: Bool? { get set }
//    var errorMessage: String? { get  }
//    var hasImageFetchFailed: Bool { get  }
//}
//

struct PictureDetailViewModel: Identifiable {
    var id: String {
        return date
    }
    
    let title: String
    let date: String
    let imageData: Data?
}

@MainActor final class NASAPictureDetailsViewModel: ObservableObject, Identifiable {
    @Published var title: String?
    @Published var date: String?
    @Published var pictureDescription: String?
    @Published var imageData: Data?
     var isFavourite: Bool?
    @Published var errorMessage: String?
    
    @Published var favouritePictures = [PictureDetailViewModel]()
    
    private let apiProvider: NASAFeaturePictureDetailsAPIProvider
    
    init(withAPIProvider apiProvider: NASAFeaturePictureDetailsAPIProvider) {
        self.apiProvider = apiProvider
        self.fetchPictureDetails()
    }
    
    func fetchPictureDetails(forDate date: String = Date().stringFormat) {
        Task {
            do {
                let pictureDetails = try await self.apiProvider.fetchPictureDetails(forTheDate: date)
                self.title = pictureDetails.title
                self.date = pictureDetails.date
                self.pictureDescription = pictureDetails.explanation
                self.isFavourite = false
                self.errorMessage = nil
                
                // TODO: can be enum,
                if pictureDetails.mediaType == "image" {
                    self.downloadImage(fromURLString: pictureDetails.url)
                } else if pictureDetails.mediaType == "video"  {
                    // download video and play
                }
            } catch  {
                self.handleError(error)
            }
        }
    }
    
    func addItemToFavouritePictures() {
        if self.isFavourite == true {
            guard let indexTobeDeleted = self.favouritePictures.firstIndex(where: { $0.date == self.date }) else {
                print("something went wrong with favouritepictures")
                return
            }
            
            self.favouritePictures.remove(at: indexTobeDeleted)
        } else {
            self.favouritePictures.append(PictureDetailViewModel(title: self.title ?? "", date: self.date ?? "", imageData: self.imageData))
        }
        
        self.isFavourite?.toggle()
    }
    
    private func downloadImage(fromURLString urlValue: String) {
        guard let url = URL(string: urlValue) else {
            self.imageData = nil
            return
        }
        
        Task {
            do {
               let imageData = try await ImageDownloader.fetchImage(fromURL: url)
                self.imageData = imageData
            } catch {
                self.imageData = nil
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let genericErrorMessage = NSLocalizedString("We couldnt fetch data at this time. There is some internal error occured. Please try after sometime", comment: "")
        
        guard let pictureDetailsError = error as? FetchPictureDetailsError else {
            self.errorMessage = genericErrorMessage
            return
        }
        
        switch pictureDetailsError {
        case .urlInvalid, .fetchDetailsFailed:
            
            // can be customised to display function name later
            print("Url is invalid or fetching Data from API is failed")
            self.errorMessage = genericErrorMessage
        }
    }
}
