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

struct PictureDetailViewModel: Identifiable, Codable {
    var id: String {
        return date
    }
    
    let title: String
    let explanation: String
    let date: String
    let imageData: Data?
}

@MainActor final class NASAPictureDetailsViewModel: ObservableObject, Identifiable {
    @Published var title: String?
    @Published var date: String?
    @Published var pictureDescription: String?
    @Published var imageData: Data?
    @Published var isFavourite: Bool?
    @Published var errorMessage: String?
    
    @Published var favouritePictures = [PictureDetailViewModel]()
    
    private let apiProvider: NASAFeaturePictureDetailsAPIProvider
    private let cache = Cache<String, PictureDetailViewModel>()
    
    let cacheKey = "NASAPictureDetails"
    
    private var genericErrorMessage: String {
        return NSLocalizedString("We couldnt fetch data at this time. There is some internal error occured. Please try after sometime", comment: "")
    }
    
    init(withAPIProvider apiProvider: NASAFeaturePictureDetailsAPIProvider) {
        self.apiProvider = apiProvider
        self.fetchPictureDetails()
    }
    
    var pictureViewModel: PictureDetailViewModel {
        return PictureDetailViewModel(title: self.title ?? "",
                                      explanation: self.pictureDescription ?? "",
                                      date: self.date ?? "",
                                      imageData: self.imageData)
    }
    
    func fetchPictureDetails(forDate date: String = Date().stringFormat) {
        guard date != self.date else { return }
        self.resetPreviousData()
        
        Task {
            do {
                let result = try await self.apiProvider.fetchPictureDetails(forTheDate: date)
                self.handleResult(result)
            } catch  {
                self.handleError(error)
            }
        }
    }
    
    func addItemToFavouritePictures() {
        self.isFavourite?.toggle()

        if self.isFavourite == false {
            guard let indexTobeDeleted = self.favouritePictures.firstIndex(where: { $0.date == self.date }) else {
                print("something went wrong with favouritepictures")
                return
            }
            
            self.favouritePictures.remove(at: indexTobeDeleted)
        } else {
            self.favouritePictures.append(self.pictureViewModel)
        }
    }
    
    private func resetPreviousData() {
        self.isFavourite = false
        self.errorMessage = nil
        self.imageData = nil
    }
    
    private func handleResult(_ result: JSONResult<PictureDetails>) {
        switch result {
        case .success(let pictureDetails):
            self.title = pictureDetails.title
            self.date = pictureDetails.date
            self.pictureDescription = pictureDetails.explanation
            
            // TODO: can be enum
            if pictureDetails.mediaType == "image" {
                self.downloadImage(fromURLString: pictureDetails.url)
            } else if pictureDetails.mediaType == "video"  {
                // TODO: download video and play
            }
        case .failure(let errorDetails):
            self.errorMessage = errorDetails.message
        case .parserError:
            self.errorMessage = self.genericErrorMessage
            print("Parser error")
        }
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
                
                // Cache data only after image download is completed.
                self.cacheData()
            } catch {
                self.imageData = nil
            }
        }
    }
    
    private func cacheData() {
        self.cache.insert(self.pictureViewModel, forKey: self.cacheKey)
        do {
            try self.cache.saveToDisk(withName: "APOD")
        } catch {
            print(error)
        }
    }
    
    // We always try to show last cached data when internet is not there
    private var isCacheLoaded: Bool  {
        do {
            let cache = try self.cache.fetchData(withName: "APOD")
            let pictureDetails = cache?.valueForKey(self.cacheKey)
            self.title = pictureDetails?.title
            self.pictureDescription = pictureDetails?.explanation
            self.imageData =  pictureDetails?.imageData
            self.date =  pictureDetails?.date
            return true
        } catch {
            print(error)
        }
                
        return false
    }
    
    private func handleError(_ error: Error) {
        
        // Network not found error, can be enum
        if error._code == -1009, self.isCacheLoaded {
            print("Network is not present, hence loaded cache data")
            return
        }
        
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
