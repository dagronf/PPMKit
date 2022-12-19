# PPMKit

Simple read/write PPM files (P3/P6) in Swift (macOS, iOS, tvOS, watchOS, Linux).

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/PPMKit" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Read a PPM file

### Load a PPM file as a CGImage

```swift
let ppmData = Data(...)
let cgImage = try PPM.load(ppmData)
```

### Load raw PPM image data from a file

```swift
let imageData = try PPM.readFileURL(ppm1URL)
// width = imageData.width
// height = imageData.height
// rawRGBBytes = imageData.data 
```

## Write a PPM file

### Write a CGImage to a PPM file

NOTE: PPM doesn't support transparency, so any transparency information is lost.

```swift
let cgImage = CGImage(...)
let data = try PPM.write(cgImage, format: .P3)
```

### Write raw RGB data to a PPM file

```swift
let imageData = PPM.ImageData(...)
let data = try PPM.writeData(data: imageData, format: .P3)
```

# License

```
MIT License

Copyright (c) 2022 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
