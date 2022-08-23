
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
              Text("类型:\(card.sportClass.rawValue)")
              Text("周期:\(card.sportPeriod.rawValue)")
              Text("连续性:\(card.sportDiscrete.rawValue)")
              Text("手势控制:\(card.isGestureController.description)")
          }.foregroundColor(color(sportClass: card.sportClass))
      }.aspectRatio(2/3, contentMode: .fit)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
      CardView(card: Card.default)
    }
}
