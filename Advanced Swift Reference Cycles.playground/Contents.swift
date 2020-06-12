import Foundation

class Window
{
    weak var rootView: View?
    var onRotate: (() -> ())? = nil

    deinit {
        print("Deinit Window")
    }
}

class View
{
    weak var window: Window?

    init(window: Window) {
        self.window = window
    }

    deinit {
        print("Deinit View")
    }
}

var window: Window? = Window()
var view: View? = View(window: window!)
window?.onRotate = {
    print("We now also need to update the view: \(view)")
}
window?.onRotate!()
view = nil
window = nil
