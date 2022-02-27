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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var viewModel: NASAPictureDetailsViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.searchBar.isHidden = true

        self.bindViewModel()
        self.datePicket.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .allEvents)
    }
    
    
    private func bindViewModel() {
        self.viewModel?.$title.sink { [weak self] title in
            self?.activityIndicator.stopAnimating()
            self?.searchBar.isHidden = false
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
                self?.favouriteIcon.isHidden = false
                self?.picture.image = image
            } else {
                self?.picture.image = UIImage(systemName: "photo.fill")
            }
        }.store(in: &cancellables)
        
        self.viewModel?.$isFavourite.sink { [weak self] isFavourite in
            var imageName = "heart"
            
            if isFavourite == true {
                imageName = "heart.fill"
            }
            
            self?.favouriteIcon.setImage(UIImage(systemName: imageName), for: .normal)
        }.store(in: &cancellables)
    }
    

    // MARK: IBACtions
    // If user selcts same date, dont do anything
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date.stringFormat
        self.datePicket.isHidden = true
        self.favouriteIcon.isHidden = true
        self.searchBar.text = selectedDate
        self.viewModel?.fetchPictureDetails(forDate: selectedDate)
    }

    @IBAction func favouriteIconTapped(_ sender: Any) {
        self.viewModel?.addItemToFavouritePictures()
    }
}

extension NASAPictureOfTheDayViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.datePicket.isHidden = false
        self.view.layoutIfNeeded()
        return false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.datePicket.isHidden = true
        self.view.layoutIfNeeded()
        let selectedDate = self.datePicket.date.stringFormat
        self.searchBar.text = selectedDate
        self.favouriteIcon.isHidden = true
        self.viewModel?.fetchPictureDetails(forDate: selectedDate)
    }
}
