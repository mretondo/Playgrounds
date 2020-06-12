public class Node<T> {
  var value: T
  var next: Node<T>?
  weak var previous: Node<T>?

  init(value: T) {
    self.value = value
  }
}

public class LinkedList<T> {
  fileprivate var head: Node<T>?
  private var tail: Node<T>?

  public var isEmpty: Bool {
    return head == nil
  }

  public var first: Node<T>? {
    return head
  }

  public var last: Node<T>? {
    return tail
  }

  public func append(value: T) {
    let newNode = Node(value: value)
    if let tailNode = tail {
      newNode.previous = tailNode
      tailNode.next = newNode
    } else {
      head = newNode
    }
    tail = newNode
  }

  public func nodeAt(index: Int) -> Node<T>? {
    if index >= 0 {
      var node = head
      var i = index
      while node != nil {
        if i == 0 { return node }
        i -= 1
        node = node!.next
      }
    }
    return nil
  }

  public func removeAll() {
    head = nil
    tail = nil
  }

  public func remove(node: Node<T>) -> T {
    let prev = node.previous
    let next = node.next

    if let prev = prev {
      prev.next = next
    } else {
      head = next
    }
    next?.previous = prev

    if next == nil {
      tail = prev
    }

    node.previous = nil
    node.next = nil
    
    return node.value
  }
}

extension LinkedList: CustomStringConvertible {
  public var description: String {
    var text = "["
    var node = head

    while node != nil {
      text += "\(node!.value)"
      node = node!.next
      if node != nil { text += ", " }
    }
    return text + "]"
  }
}


let companies = LinkedList<String>()
let names: [String] = ["Apple", "Microsoft", "Sony", "Lenovo", "Asus"]//.shuffled()
// add to linked list
for name in names {
    companies.append(value: name)
}
print(companies)

let numbers = LinkedList<Int>()
let nums = [100, 5, 53, 98, 29]//.shuffled()
// add to linked list
for num in nums {
    numbers.append(value: num)
}
print(numbers)

print()
var index = 0
while let node = companies.nodeAt(index: index) {
    print("\(node.value)")
    index += 1
}

print()

index = 0
while let node = numbers.nodeAt(index: index) {
    print("\(node.value)")
    index += 1
}

//
// LinkedList of tuples
//
print()
let tuples = LinkedList<(String, Int)>()

// add to linked list
for name in names {
    for num in nums {
        tuples.append(value: (name, num))
    }
}

print()
index = 0
while let node = tuples.nodeAt(index: index) {
    print("Name: \(node.value.0)  Num: \(node.value.1)")
    index += 1
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled i.e. random.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
