# ReflectedStringConvertible
A protocol that allows any class to be printed as if it were a struct.

Consider this class:

```swift
class Person {
  var name: String
  var age: Int
  
  init(name: String, age: Int) {
    self.name = name
    self.age = age
  }
}
```

If we were to instantiate and print it:

```swift
let matt = Person(name: "Matt", age: 32)
print(matt)
```

It would output:

```swift
Person
```

When outputting classes, if a string representation isn't provided, Swift uses Ad-Hoc printing. For classes, this means just the class name.

If `Person` were a struct however, we'd see something very different:

```swift
Person(name: "Matt", age: 32)
```

To get this kind of output from any class, just conform to `ReflectedStringConvertible`. There's nothing to implement, the implementation is provided by a protocol extension.

```swift
class Person: ReflectedStringConvertible {
  var name: String
  var age: Int
  var social: Social
  
  init(name: String, age: Int) {
    self.name = name
    self.age = age
  }
}

let matt = Person(name: "Matt", age: 32)

print(matt)
```

Outputs:

```
Person(name: Matt, age: 32)
```

Just like a struct.
