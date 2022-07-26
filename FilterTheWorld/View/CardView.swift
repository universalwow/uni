
import SwiftUI

struct CardView: View {
    var card: Card
    
    func color(sportClass: SportClass) -> Color {
        switch sportClass {
            
        case .Counter:
            return .red
        case .Timer:
            return .yellow
        case .TimeCounter:
            return .blue
        case .None:
            return .white
        }
    }
    
    var body: some View {
      ZStack {
        Rectangle().fill(card.backColor)
          
          VStack(alignment: .trailing, spacing: 10) {
              Text(card.content).font(.largeTitle)
              Text(card.sportClass.rawValue)
              Text(card.sportPeriod.rawValue)
          }.foregroundColor(color(sportClass: card.sportClass))
      }.aspectRatio(2/3, contentMode: .fit)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
      CardView(card: Card.default)
    }
}
