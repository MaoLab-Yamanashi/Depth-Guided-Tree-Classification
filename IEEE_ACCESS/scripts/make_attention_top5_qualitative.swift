import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct Slice {
    let top: Int
    let height: Int
}

let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
let repoRoot = scriptURL
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()

let inputURL = repoRoot
    .appendingPathComponent("new_experiments_result")
    .appendingPathComponent("AttentionLocalization/UrbanStreetTree/sampling_multiseed/samp_seed_42/figures")
    .appendingPathComponent("multi_species_attention_heatmaps_all_classes.png")
let outputURL = repoRoot
    .appendingPathComponent("IEEE_ACCESS/figures")
    .appendingPathComponent("fig26_attention_localization_top5.png")

guard
    let imageSource = CGImageSourceCreateWithURL(inputURL as CFURL, nil),
    let source = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
else {
    fatalError("Could not read source image: \(inputURL.path)")
}

// Pixel coordinates are measured from the top edge of the all-class source image.
// The retained rows are Flowering cherry, Ginkgo, Lagerstroemia, Prunus, and Platanus.
let slices = [
    Slice(top: 0, height: 130),       // title and column headers
    Slice(top: 683, height: 553),     // Flowering cherry
    Slice(top: 1236, height: 553),    // Ginkgo
    Slice(top: 2344, height: 553),    // Lagerstroemia
    Slice(top: 4559, height: 553),    // Prunus
    Slice(top: 4005, height: 553)     // Platanus
]

let outputWidth = source.width
let outputHeight = slices.reduce(0) { $0 + $1.height }

guard let context = CGContext(
    data: nil,
    width: outputWidth,
    height: outputHeight,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Could not create output graphics context")
}

context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
context.fill(CGRect(x: 0, y: 0, width: outputWidth, height: outputHeight))
context.interpolationQuality = CGInterpolationQuality.none

var destinationTop = 0
for slice in slices {
    let sourceRect = CGRect(
        x: 0,
        y: slice.top,
        width: outputWidth,
        height: slice.height
    )
    guard let cropped = source.cropping(to: sourceRect) else {
        fatalError("Could not crop source row at top=\(slice.top)")
    }
    let destinationRect = CGRect(
        x: 0,
        y: outputHeight - destinationTop - slice.height,
        width: outputWidth,
        height: slice.height
    )
    context.draw(cropped, in: destinationRect)
    destinationTop += slice.height
}

guard let output = context.makeImage() else {
    fatalError("Could not create output image")
}
guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
) else {
    fatalError("Could not create PNG destination")
}
CGImageDestinationAddImage(destination, output, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("Could not write output PNG")
}
print(outputURL.path)
