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
let cgImage = try PPM.readImage(data: ppmData)
```

### Load raw PPM image data from a file

```swift
let imageData: PPM.ImageData = try PPM.read(fileURL: ppm1URL)
// width = imageData.width
// height = imageData.height
// rawRGBBytes = imageData.data 
```

## Write a PPM file

### Write a CGImage to a PPM file

NOTE: PPM doesn't support transparency, so any transparency information is lost.

```swift
let cgImage = CGImage(...)
let data = try PPM.writeImage(cgImage, format: .P3)
```

### Write raw RGB data to a PPM file

```swift
let imageData = PPM.ImageData(...)
try imageData.write(format: .P3, fileURL: <some_url>)
```

## Linux support

* Linux only supports very naive color conversions between RGB-CMYK-Gray.

### To build/test linux support using a mac

See: [Testing Swift packages on Linux using Docker](https://oleb.net/2020/swift-docker-linux/)

1. Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop) on your mac
2. Make sure that docker is running (or else the next command will fail with a weird or no error message)
3. Run the following command in the directory you want to mirror in your linux 
	
```bash
docker run --rm --privileged --interactive --tty --volume "$(pwd):/src" --workdir "/src" swift:latest
```

Now, from within the docker container, run 

```bash
swift build
swift test
```

Note that the /src directory in the Linux container is a direct mirror of the current directory on the host OS, not a copy. If you delete a file in /src in the Linux container, that file will be gone on the host OS, too.

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
