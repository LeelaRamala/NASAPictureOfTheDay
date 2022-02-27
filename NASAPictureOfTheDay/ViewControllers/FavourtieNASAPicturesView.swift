//
//  FavourtiePictures.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 26/02/22.
//

import SwiftUI

struct FavourtieNASAPicturesView: View {
    @EnvironmentObject var favouritePictureDetails: NASAPictureDetailsViewModel
    
    var body: some View {
        if favouritePictureDetails.favouritePictures.isEmpty {
            NavigationView {
                Label("No favourites added to display!", systemImage: "list.star")
                    .navigationTitle("Favourites")
            }
        } else {
            NavigationView {
                List(favouritePictureDetails.favouritePictures) {
                        FavouritePictureRowView(viewModel: $0)
                    }
                    .navigationTitle("Favourites")
            }
        }
    }
}


struct FavouritePictureRowView: View {
     var viewModel: PictureDetailViewModel
    
     var uiImage: UIImage? {
         guard let imageData = viewModel.imageData else { return nil }
         return UIImage(data: imageData)
     }

    var body: some View {
        HStack {
            
            if let uiImageValue = uiImage {
                Image(uiImage: uiImageValue)
                    .resizable()
                    .frame(width: 30.0, height: 30.0)
            } else {
                Image(systemName: "photo.fille")
            }
            
            VStack(alignment: .leading) {
                Text(viewModel.title).font(.headline).lineLimit(1)
                Text(viewModel.date).font(Font.footnote)
            }
        }
    }
}


struct FavourtiePictures_Previews: PreviewProvider {
    static var previews: some View {
        FavourtieNASAPicturesView()
    }
}


