[![](https://travis-ci.org/mattcomi/ReflectedStringConvertible.svg?branch=master)](https://travis-ci.org/mattcomi/ReflectedStringConvertible)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/cocoapods/v/ReflectedStringConvertible.svg?style=flat)](https://cocoapods.org/pods/ReflectedStringConvertible)
[![Platform](https://img.shields.io/cocoapods/p/ReflectedStringConvertible.svg?style=flat)](http://cocoadocs.org/docsets/ReflectedStringConvertible)

# ReflectedStringConvertible
A protocol that extends `CustomStringConvertible` and uses reflection to add a
detailed textual representation to any class. Two styles are supported:

1. `normal`: Similar to Swift's default textual representation of structs.
2. `json`: Pretty JSON representation.

## Installation

### Cocoapods

Add the following to your Podfile:

```
pod 'ReflectedStringConvertible'
```

### Carthage

Add the following to your Cartfile:

```
github "mattcomi/ReflectedStringConvertible"
```

## Usage

Simply import `ReflectedStringConvertible` and conform to the
`ReflectedStringConvertible` protocol:

```swift
import ReflectedStringConvertible

class YourClass: ReflectedStringConvertible {
  // that's all.
}
```

For example:

```swift
class Person: ReflectedStringConvertible {
  var name: String
  var age: Int

  init(name: String, age: Int) {
    self.name = name
    self.age = age
  }
}
```

`print(Person(name: "Matt", age: 33))` outputs:

```
Person(name: "Matt", age: 33)
```

A style may be specified with `reflectedDescription(style:)`. The default style is `normal`. That is, calling `description` is the same as calling `reflectedDescription(.normal)`.

For example, `print(Person(name: "Matt", age: 33).reflectedDescription(.json))` outputs:

```
{
  "age" : 33,
  "name" : "Matt"
}
```

Refer to the  [API Documentation](http://cocoadocs.org/docsets/ReflectedStringConvertible) for further information.

## Features

### `ReflectedStringConvertible` stored properties

`ReflectedStringConvertible` objects with `ReflectedStringConvertible` stored properties are handled correctly:

```swift
class Movie: ReflectedStringConvertible {
  var title: String
  var year: Int

  // another ReflectedStringConvertible
  var director: Person

  init(title: String, year: Int, director: Person) {
    self.title = title
    self.year = year
    self.director = director
  }
}

let george = Person(name: "George Miller", age: 71)
let movie = Movie(title: "Mad Max", year: 2015, director: george)
```

`print(movie.reflectedDescription(.normal))` (or just `print(movie)`) outputs:

```
Movie(title: "Mad Max", year: 2015, director: Person(name: "George Miller", age: 71))
```

And `print(movie.reflectedDescription(.json))` outputs:

```
{
  "title" : "Mad Max",
  "year" : 2015,
  "director" : {
    "age" : 71,
    "name" : "George Miller"
  }
}
```

### Collections

`ReflectedStringConvertible` objects within `Array`, `Dictionary` and `Set` collections are handled correctly:

```swift
class Series: ReflectedStringConvertible {
  var title: String
  var cast: [Person]

  init(title: String, cast: [Person]) {
    self.cast = cast
  }
}

var cast = [Person]()

cast.append(Person(name: "Justin Theroux", age: 44))
cast.append(Person(name: "Carrie Coon", age: 35))

let series = Series(title: "The Leftovers", cast: cast)
```

`print(series)` outputs:

```
TVShow(title: "The Leftovers", cast: [Person(name: "Justin Theroux", age: 44), Person(name: "Carrie Coon", age: 35)])
```

`print(series.reflectedDescription(.json))` outputs:

```
{
  "title" : "The Leftovers",
  "cast" : [
    {
      "age" : 44,
      "name" : "Justin Theroux"
    },
    {
      "age" : 35,
      "name" : "Carrie Coon"
    }
  ]
}
```

## Credits

Developed by Matt Comi ([@mattcomi](http://twitter.com/mattcomi))
