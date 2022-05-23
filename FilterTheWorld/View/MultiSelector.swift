

import SwiftUI



struct MultiSelector<T: Selectable, V: View>: View {
    @Binding var items: [T]
    var rowBuilder: (T) -> V

    var body: some View {
        List(items) { item in
            Button(action: { self.items.toggleSelected(item) }) {
                self.rowBuilder(item)
            }
        }
        
        .listStyle(PlainListStyle())
    }
}

protocol Selectable: Identifiable {
    var id: String { get }
    var selected: Bool { get set }
}



extension Array where Element: Selectable {
    mutating func toggleSelected(_ item: Element) {
        if let index = firstIndex(where: { $0.id == item.id }) {
            var mutable = item
            mutable.selected.toggle()
            self[index] = mutable
        }
    }
}

