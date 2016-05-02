
// Copyright © 2016 Matt Comi. All rights reserved.

import XCTest
@testable import ReflectedStringConvertible

class ReflectedStringConvertibleTests: XCTestCase {
  func contentsOfFile(path: String) -> String {
    let bundle = NSBundle(forClass: self.dynamicType)
    return try! String(contentsOfFile: bundle.pathForResource(path, ofType: nil)!)
  }
  
  /// Test the basics.
  func testBasic() {
    let baseClass = BaseClass(a: "test", b: 1, c: 2.1, d: true, e: .Second, f: ("tuple", 123))
    
    XCTAssertEqual(String(baseClass), "BaseClass(a: \"test\", b: 1, c: 2.1, d: true, e: Second, f: (\"tuple\", 123))")
    
    XCTAssertEqual(baseClass.reflectedDescription(.Normal), String(baseClass))
    
    XCTAssertEqual(baseClass.reflectedDescription(.JSON), contentsOfFile("expectedBaseClass.json"))
  }
  
  /// Test that superclass properties are included.
  func testSuperclass() {
    let derivedClass =
      DerivedClass(a: "test", b: 1, c: 3, d: false, e: .AttributedThird(attribute: 123), f: ("tuple", 123), g: [1,2,3])
    
    let expectedDerivedClassDescription =
      "DerivedClass(g: [1, 2, 3], a: \"test\", b: 1, c: 3.0, d: false, e: AttributedThird(123), f: (\"tuple\", 123))"
    
    XCTAssertEqual(derivedClass.description, expectedDerivedClassDescription)
    
    XCTAssertEqual(derivedClass.reflectedDescription(.JSON), contentsOfFile("expectedDerivedClass.json"))
  }
  
  /// Test that classes with class members that do not conform to ReflectedStringConvertible are treated properly.
  func testClassWithNonReflectingClass() {
    let classWithNonReflectingClass = ClassWithNonReflectingClass(nonReflectingClass: NonReflectingClass(number: 123))
    
    XCTAssertEqual(classWithNonReflectingClass.reflectedDescription(.Normal),
      "ClassWithNonReflectingClass(nonReflectingClass: ReflectedStringConvertibleTests.NonReflectingClass)")
    
    XCTAssertEqual(
      classWithNonReflectingClass.reflectedDescription(.JSON),
      contentsOfFile("expectedClassWithNonReflectingClass.json"))
  }
  
  /// Test that classes with class members that conform to ReflectedStringConvertible are treated properly.
  func testClassWithReflectingClass() {
    let classWithReflectingClass = ClassWithReflectingClass(reflectingClass: ReflectingClass(a: "reflecting"))
    
    XCTAssertEqual(classWithReflectingClass.description,
      "ClassWithReflectingClass(reflectingClass: ReflectingClass(a: \"reflecting\"))")
    
    XCTAssertEqual(classWithReflectingClass.reflectedDescription(.JSON),
      contentsOfFile("expectedClassWithReflectingClass.json"))
    
    class SomeClass: ReflectedStringConvertible {
      let array: [Any] = [1, 2.0, true, "test"]
      let bool: Bool = true
      let tuple: (String, Int) = ("test", 123)
      
      init() {}
    }
  }
  
  /// Test the behavior of arrays.
  func testArray() {
    let baseClass = BaseClass(a: "base", b: 1, c: 2, d: false, e: .Second, f: ("tuple", 123))
    let derivedClass = DerivedClass(a: "derived", b: 1, c: 2, d: false, e: .Second, f: ("tuple", 456), g: [1, 2, 3])
    
    var array: [Any] = ["a", 123, 1.2, baseClass]
    let nestedArray: [Any] = [5, 6, derivedClass]
  
    array.append(nestedArray)
    
    let classWithArray = ClassWithArray(array: array)

    let expectedClassWithArrayDescription =
      "ClassWithArray(array: [\"a\", 123, 1.2, BaseClass(a: \"base\", b: 1, c: 2.0, d: false, e: Second, f: (\"tuple\", 123)), [5, 6, DerivedClass(g: [1, 2, 3], a: \"derived\", b: 1, c: 2.0, d: false, e: Second, f: (\"tuple\", 456))]])"
    
    XCTAssertEqual(classWithArray.description, expectedClassWithArrayDescription)
    XCTAssertEqual(classWithArray.reflectedDescription(.JSON), contentsOfFile("expectedClassWithArray.json"))
  }
  
  // Test the behavior of dictionaries.
  func testDictionary() {
    let baseClass =
      BaseClass(a: "base", b: 10, c: 20, d: true, e: .AttributedThird(attribute: 30), f: ("tuple", 123))
    
    var dictionary: [String: Any] = ["a": 1, "b": 1.5, "c": true, "d": Enum.Second, "e": baseClass]
    
    let nestedArray: [Any] = ["nestedArrayItem", true, false]
    let nestedDictionary: [Int: Any] = [1: "one", 2: "two", 3: "three"]
    
    dictionary["nestedArray"] = nestedArray
    dictionary["nestedDictionary"] = nestedDictionary

    let classWithDictionary = ClassWithDictionary(dictionary: dictionary)
    
    XCTAssertEqual(
      classWithDictionary.description,
      "ClassWithDictionary(dictionary: [\"b\": 1.5, \"nestedArray\": [\"nestedArrayItem\", true, false], \"a\": 1, \"c\": true, \"e\": BaseClass(a: \"base\", b: 10, c: 20.0, d: true, e: AttributedThird(30), f: (\"tuple\", 123)), \"d\": ReflectedStringConvertibleTests.Enum.Second, \"nestedDictionary\": [2: \"two\", 3: \"three\", 1: \"one\"]])")
    
    XCTAssertEqual(classWithDictionary.reflectedDescription(.JSON), contentsOfFile("expectedClassWithDictionary.json"))
  }
  
  // Test the behavior of sets.
  func testSet() {
    var set = Set<Int>()
    
    set.insert(1)
    set.insert(2)
    set.insert(3)
    
    let classWithSet = ClassWithSet(set: set)
    
    XCTAssertEqual(classWithSet.description, "ClassWithSet(set: [2, 3, 1])")
    XCTAssertEqual(classWithSet.reflectedDescription(.JSON), contentsOfFile("expectedClassWithSet.json"))
  }
}

enum Enum {
  case First
  case Second
  case AttributedThird(attribute: Int)
}

class NonReflectingClass {
  let number: Int
  
  init(number: Int) {
    self.number = number
  }
}

class ReflectingClass: ReflectedStringConvertible {
  let a: String
  
  init(a: String) {
    self.a = a
  }
}

class BaseClass: ReflectedStringConvertible {
  let a: String
  let b: Int
  let c: Double
  let d: Bool
  let e: Enum
  let f: (String, Int)
  
  init(a: String, b: Int, c: Double, d: Bool, e: Enum, f: (String, Int)) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = e
    self.f = f
  }
}

class DerivedClass: BaseClass {
  let g: [Int]
  
  init(a: String, b: Int, c: Double, d: Bool, e: Enum, f: (String, Int), g: [Int]) {
    self.g = g
    super.init(a: a, b: b, c: c, d: d, e:e, f:f)
  }
}

class ClassWithReflectingClass: ReflectedStringConvertible {
  let reflectingClass: ReflectingClass
  
  init(reflectingClass: ReflectingClass) {
    self.reflectingClass = reflectingClass
  }
}

class ClassWithNonReflectingClass: ReflectedStringConvertible {
  let nonReflectingClass: NonReflectingClass
  
  init(nonReflectingClass: NonReflectingClass) {
    self.nonReflectingClass = nonReflectingClass
  }
}

class ClassWithArray: ReflectedStringConvertible {
  let array: [Any]
  
  init(array: [Any]) {
    self.array = array
  }
}

class ClassWithDictionary: ReflectedStringConvertible {
  let dictionary: [String: Any]
  
  init(dictionary: [String: Any]) {
    self.dictionary = dictionary
  }
}

class ClassWithSet: ReflectedStringConvertible {
  let set: Set<Int>
  
  init(set: Set<Int>) {
    self.set = set
  }
}