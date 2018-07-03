# swift-csv

`swift-csv` is a stream based CSV library written in Swift. It uses `InputStream` to parse a CSV file and `OutputStream` to write CSV data to a file.
This way it doesn't keep everything in memory while working with big CSV files. It also supports [BOM](https://en.wikipedia.org/wiki/Byte_order_mark) for UTF-8, UTF-16 and UTF-32 text encodings.

`swift-csv` is battle tested in the CSV import and export of [Finances](https://hochgatterer.me/finances/).

# Features

- Stream based CSV parser and writer
- Complete documentation
- Unit tested

# Usage

## Parser

```swift
let stream = InputStream(...)

// Define the delimeter and encoding of the CSV file
let configuration = CSV.Configuration(delimiter: ",", encoding: .utf8)

let parser = CSV.Parser(inputStream: stream, configuration: configuration)
try parser.parse()
```

If you don't know the delimiter and encoding of the data, you can automatically detect it.

```swift
let url = ...
guard let configuration = CSV.Configuration.detectConfigurationForContentsOfURL(url) else {
	return
}
```

### Example

Parsing this CSV file

```
a,b
1,"ha ""ha"" ha"
3,4
```

will result in the following delegate calls.

```
parserDidBeginDocument
parser(_:didBeginLineAt:) 0
parser(_:didReadFieldAt:value:) a
parser(_:didReadFieldAt:value:) b
parser(_:didEndLineAt:) 0
parser(_:didBeginLineAt:) 1
parser(_:didReadFieldAt:value:) 1
parser(_:didReadFieldAt:value:) ha "ha" ha
parser(_:didEndLineAt:) 1
parser(_:didBeginLineAt:) 2
parser(_:didReadFieldAt:value:) 3
parser(_:didReadFieldAt:value:) 4
parser(_:didEndLineAt:) 2
parserDidEndDocument
```

## Writer

```swift
let stream = OutputStream(...)
let configuration = CSV.Configuration(delimiter: ",", encoding: .utf8)

let writer = CSV.Writer(outputStream: stream, configuration: configuration)
try writer.writeLine(of: ["a", "b", "c"])
try writer.writeLine(of: ["1", "2", "3"])
```

The code above produces the following output.

```
a,b,c
1,2,3
```

# TODOs

- [ ] Support comments in CSV file

# Contact

Matthias Hochgatterer

Github: [https://github.com/brutella/](https://github.com/brutella/)

Twitter: [https://twitter.com/brutella](https://twitter.com/brutella)


# License

swift-csv is available under the MIT license. See the LICENSE file for more info.
