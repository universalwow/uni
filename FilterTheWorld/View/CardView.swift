
import SwiftUI

struct CardView: View {
    var card: Card
    var body: some View {
      ZStack {
        Rectangle().fill(card.backColor)
          
          VStack(alignment: .trailing, spacing: 10) {
              Text(card.content).font(.largeTitle)
              Text(card.sportClass.rawValue)
          }
      }.aspectRatio(2/3, contentMode: .fit)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
      CardView(card: Card.default)
    }
}
