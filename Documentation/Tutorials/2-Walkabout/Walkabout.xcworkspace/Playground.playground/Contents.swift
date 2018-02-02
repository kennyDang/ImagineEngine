import Foundation
import PlaygroundSupport

var myCoolString = "What a cool string"

let someIndex = 2

let index = myCoolString.index(myCoolString.startIndex, offsetBy: someIndex + 2)
let substring = myCoolString[..<index]


