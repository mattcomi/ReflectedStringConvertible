// Copyright © 2016 Matt Comi. All rights reserved.

import XCTest
@testable import ReflectedStringConvertible

let expectedReflectedBaseClassDescription = """
{
  "a" : "test",
  "b" : 1,
  "c" : 1.2,
  "d" : true,
  "e" : "second",
  "f" : "(\\"tuple\\", 123)"
}
"""

let expectedReflectedDerivedClassDescription = """
{
  "a" : "test",
  "b" : 1,
  "c" : 3,
  "d" : false,
  "e" : "attributedThird(attribute: 123)",
  "f" : "(\\"tuple\\", 123)",
  "g" : [
    1,
    2,
    3
  ]
}
"""

let expectedReflectedClassWithNonReflectingClassDescription = """
{
  "nonReflectingClass" : "ReflectedStringConvertibleTests.NonReflectingClass"
}
"""

let expectedReflectedClassWithReflectingClassDescription = """
{
  "reflectingClass" : {
    "a" : "reflecting"
  }
}
"""

let expectedReflectedClassWithArrayDescription = """
{
  "array" : [
    "a",
    123,
    1.2,
    {
      "a" : "base",
      "b" : 1,
      "c" : 2,
      "d" : false,
      "e" : "second",
      "f" : "(\\"tuple\\", 123)"
    },
    [
      5,
      6,
      {
        "a" : "derived",
        "b" : 1,
        "c" : 2,
        "d" : false,
        "e" : "second",
        "f" : "(\\"tuple\\", 456)",
        "g" : [
          1,
          2,
          3
        ]
      }
    ]
  ]
}
"""

let expectedReflectedClassWithDictionaryDescription = """
{
  "dictionary" : {
    "a" : 1,
    "b" : 1.5,
    "c" : true,
    "d" : "second",
    "e" : {
      "a" : "base",
      "b" : 10,
      "c" : 20,
      "d" : true,
      "e" : "attributedThird(attribute: 30)",
      "f" : "(\\"tuple\\", 123)"
    },
    "nestedArray" : [
      "nestedArrayItem",
      true,
      false
    ],
    "nestedDictionary" : {
      "1" : "one",
      "2" : "two",
      "3" : "three"
    }
  }
}
"""

let expectedReflectedClassWithSetDescription = """
{
  "set" : [
    1,
    2,
    3
  ]
}
"""

class ReflectedStringConvertibleTests: XCTestCase {
  /// Test the basics.
  func testBasic() {
    let baseClass = BaseClass(a: "test", b: 1, c: 1.2, d: true, e: .second, f: ("tuple", 123))
    
    XCTAssertEqual(String(describing: baseClass), "BaseClass(a: \"test\", b: 1, c: 1.2, d: true, e: second, f: (\"tuple\", 123))")

    XCTAssertEqual(baseClass.reflectedDescription(.normal), String(describing: baseClass))
    
    let jsonDescription = baseClass.reflectedDescription(.json)
    XCTAssertEqual(jsonDescription, expectedReflectedBaseClassDescription)
  }

  /// Test that superclass properties are included.
  func testSuperclass() {
    let derivedClass =
      DerivedClass(a: "test", b: 1, c: 3, d: false, e: .attributedThird(attribute: 123), f: ("tuple", 123), g: [1,2,3])
    
    let expectedDerivedClassDescription =
      "DerivedClass(a: \"test\", b: 1, c: 3.0, d: false, e: attributedThird(attribute: 123), f: (\"tuple\", 123), g: [1, 2, 3])"
    
    XCTAssertEqual(derivedClass.description, expectedDerivedClassDescription)

    XCTAssertEqual(derivedClass.reflectedDescription(.json), expectedReflectedDerivedClassDescription)
  }

  /// Test that classes with class members that do not conform to ReflectedStringConvertible are treated properly.
  func testClassWithNonReflectingClass() {
    let classWithNonReflectingClass = ClassWithNonReflectingClass(nonReflectingClass: NonReflectingClass(number: 123))
    
    XCTAssertEqual(classWithNonReflectingClass.reflectedDescription(.normal),
      "ClassWithNonReflectingClass(nonReflectingClass: ReflectedStringConvertibleTests.NonReflectingClass)")
    
    XCTAssertEqual(
      classWithNonReflectingClass.reflectedDescription(.json),
      expectedReflectedClassWithNonReflectingClassDescription)
  }

  /// Test that classes with class members that conform to ReflectedStringConvertible are treated properly.
  func testClassWithReflectingClass() {
    let classWithReflectingClass = ClassWithReflectingClass(reflectingClass: ReflectingClass(a: "reflecting"))
    
    XCTAssertEqual(classWithReflectingClass.description,
      "ClassWithReflectingClass(reflectingClass: ReflectingClass(a: \"reflecting\"))")
    
    XCTAssertEqual(classWithReflectingClass.reflectedDescription(.json),
      expectedReflectedClassWithReflectingClassDescription)
    
    class SomeClass: ReflectedStringConvertible {
      let array: [Any] = [1, 2.0, true, "test"]
      let bool: Bool = true
      let tuple: (String, Int) = ("test", 123)
      
      init() {}
    }
  }

  /// Test the behavior of arrays.
  func testArray() {
    let baseClass = BaseClass(a: "base", b: 1, c: 2, d: false, e: .second, f: ("tuple", 123))
    let derivedClass = DerivedClass(a: "derived", b: 1, c: 2, d: false, e: .second, f: ("tuple", 456), g: [1, 2, 3])
    
    var array: [Any] = ["a", 123, 1.2, baseClass]
    let nestedArray: [Any] = [5, 6, derivedClass]
  
    array.append(nestedArray)
    
    let classWithArray = ClassWithArray(array: array)

    let expectedClassWithArrayDescription =
      "ClassWithArray(array: [\"a\", 123, 1.2, BaseClass(a: \"base\", b: 1, c: 2.0, d: false, e: second, f: (\"tuple\", 123)), [5, 6, DerivedClass(a: \"derived\", b: 1, c: 2.0, d: false, e: second, f: (\"tuple\", 456), g: [1, 2, 3])]])"
    
    XCTAssertEqual(classWithArray.description, expectedClassWithArrayDescription)
    XCTAssertEqual(classWithArray.reflectedDescription(.json), expectedReflectedClassWithArrayDescription)
  }

  // Test the behavior of dictionaries.
  func testDictionary() throws {
    let baseClass =
      BaseClass(a: "base", b: 10, c: 20, d: true, e: .attributedThird(attribute: 30), f: ("tuple", 123))
    
    var dictionary: [String: Any] = ["a": 1, "b": 1.5, "c": true, "d": Enum.second, "e": baseClass]
    
    let nestedArray: [Any] = ["nestedArrayItem", true, false]
    let nestedDictionary: [Int: Any] = [1: "one", 2: "two", 3: "three"]
    
    dictionary["nestedArray"] = nestedArray
    dictionary["nestedDictionary"] = nestedDictionary

    let classWithDictionary = ClassWithDictionary(dictionary: dictionary)
    let jsonDescription = classWithDictionary.reflectedDescription(.json)
    XCTAssertEqual(jsonDescription, expectedReflectedClassWithDictionaryDescription)
  }
}

enum Enum {
  case first
  case second
  case attributedThird(attribute: Int)
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
