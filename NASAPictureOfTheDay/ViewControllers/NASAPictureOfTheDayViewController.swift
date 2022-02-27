//
//  ViewController.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 26/02/22.
//

import UIKit
import Combine

class NASAPictureOfTheDayViewController: UIViewController {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var titleOfThePicture: UILabel!
    @IBOutlet weak var favouriteIcon: UIButton!
    @IBOutlet weak var detailsOfPicture: UILabel!
    @IBOutlet weak var datePicket: UIDatePicker!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel: NASAPictureDetailsViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViewModel()
        self.datePicket.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .allEvents)
    }
    
    private func bindViewModel() {
        self.viewModel?.$title.sink { [weak self] title in
            self?.searchBar.text = nil
            self?.titleOfThePicture.text = title
        }.store(in: &cancellables)
        
        self.viewModel?.$date.sink { [weak self] date in
            self?.date.text = date
        }.store(in: &cancellables)
        
        self.viewModel?.$pictureDescription.sink { [weak self] explanation in
            self?.detailsOfPicture.text = explanation
        }.store(in: &cancellables)
        
        self.viewModel?.$imageData.sink { [weak self] newImageData in
            if let imageData = newImageData, let image = UIImage(data: imageData) {
                self?.picture.image = image
            } else {
                self?.picture.image = UIImage(systemName: "photo.fille")
            }
        }.store(in: &cancellables)
    }
    

    // MARK: IBACtions
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date.stringFormat
        self.datePicket.isHidden = true
        self.searchBar.text = selectedDate
        self.viewModel?.fetchPictureDetails(forDate: selectedDate)
    }

    @IBAction func favouriteIconTapped(_ sender: Any) {
        var imageName = "heart.fill"
        
        if self.viewModel?.isFavourite == true {
            imageName = "heart"
        }
        
        self.favouriteIcon.setImage(UIImage(systemName: imageName), for: .normal)
        self.viewModel?.addItemToFavouritePictures()
    }
}

extension NASAPictureOfTheDayViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.datePicket.isHidden = false
        return false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // show picker
        // insert text in picker text field
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.datePicket.isHidden = true
        let selectedDate = self.datePicket.date.stringFormat
        self.searchBar.text = selectedDate
        self.viewModel?.fetchPictureDetails(forDate: selectedDate)
    }
}
