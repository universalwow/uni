import Foundation

typealias DispatcherIdentifier = String


class Dispatcher {
    private var items = [DispatcherIdentifier: DispatchWorkItem]()

    private let queue: DispatchQueue

    deinit {
        cancelAllActions()
    }

    init(_ queue: DispatchQueue = .main) {
        self.queue = queue
    }

    func schedule(after timeInterval: TimeInterval,
                  with identifier: DispatcherIdentifier,
                  on queue: DispatchQueue? = nil,
                  action: @escaping () -> Void) {
      
      if self.items.contains(where: {key, _ in
        key == identifier
      }) {
        print("当前提示存在...")
        return
      }
        
//        cancelAction(with: identifier)

        print("Scheduled \(identifier)")
        let item = DispatchWorkItem(block: action)
        item.notify(queue: self.queue, execute: {
          if !item.isCancelled {
            print("remove \(identifier)")
            self.items.removeValue(forKey: identifier)

          }
        })
        items[identifier] = item
        (queue ?? self.queue).asyncAfter(deadline: .now() + timeInterval, execute: item)
    }

    @discardableResult
    func cancelAction(with identifier: DispatcherIdentifier) -> Bool {
        guard let item = items[identifier] else {
            return false
        }

        defer {
          items[identifier] = nil
          self.items.removeValue(forKey: identifier)
          print("Canceled \(identifier)")
          
        }

        guard !item.isCancelled else {
            return false
        }
      
        item.cancel()
        return true
    }

    func cancelAllActions() {
        items.keys.forEach {
            items[$0]?.cancel()
            items[$0] = nil
            items.removeValue(forKey: $0)
        }
    }
  
  
}
