import Cocoa

let url = URL(string: "https://www.google.com/search?q=peace")!

let task = URLSession.shared.dataTask(with: url) {(data, response, error) in

    if error != nil || data == nil {
        print("Client error!")
        return
    }
    guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
        print("Server error!")
        return
    }
    print("The Response is : ",response)
}
task.resume()
