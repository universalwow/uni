
import SwiftUI

struct CardView: View {
    var card: Card
    var body: some View {
      ZStack {
        Rectangle().fill(card.backColor)
        Text(card.content)
      }.aspectRatio(2/3, contentMode: .fit)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
      CardView(card: Card.default)
    }
}
