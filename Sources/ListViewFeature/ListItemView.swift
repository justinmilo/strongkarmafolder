//
//  EntryCellView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Models
import EditEntryViewFeature

struct ListItemView : View {
   var store: Store<EditState,EditAction>
  
  var body : some View {
   WithViewStore(self.store ) { viewStore in
    VStack(alignment: HorizontalAlignment.leading, spacing: nil) {
      HStack{
          Text(viewStore.meditation.title)
          Spacer()
          Text(viewStore.meditation.durationFormatted ?? "Empty")
              .font(.footnote)
              .foregroundColor(.gray)
        
      }
      date(from:viewStore.meditation.date).map{
        Text(formattedDate(from: $0))
          .foregroundColor(.gray)
      }
      if viewStore.meditation.entry != "" {
        Spacer()
        Text(viewStore.meditation.entry)
          .foregroundColor(.gray)
      }
      Spacer()
    }
   }
   }
}

//
//struct EntryCellView_Previews: PreviewProvider {
//    static var previews: some View {
//      ListItemView(store: Meditation.dummy)
//    }
//}
