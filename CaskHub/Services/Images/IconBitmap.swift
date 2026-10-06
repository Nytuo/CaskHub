//
//  IconBitmap.swift
//  CaskHub
//
//  Created by Ali Elsokary on 05/10/2026.
//

import AppKit
import SwiftUI

nonisolated enum IconBitmap {
    private struct PixelBounds {
        var minX = Int.max, minY = Int.max, maxX = -1, maxY = -1

        mutating func include(_ column: Int, _ row: Int) {
            minX = min(minX, column)
            minY = min(minY, row)
            maxX = max(maxX, column)
            maxY = max(maxY, row)
        }

        var rect: CGRect? {
            maxX < 0 ? nil : CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        }
    }

    // Largest on-screen icon is the 76pt hero at 2x.
    private static let pixelCap: CGFloat = 160

    private static func alphaBounds(
        _ pixels: UnsafePointer<UInt8>, width: Int, height: Int
    ) -> (visible: PixelBounds, body: PixelBounds) {
        var visible = PixelBounds(), body = PixelBounds()
        for row in 0..<height {
            for column in 0..<width {
                let alpha = pixels[(row * width + column) * 4 + 3]
                guard alpha > 8 else { continue }
                visible.include(column, row)
                if alpha > 128 { body.include(column, row) }
            }
        }
        return (visible, body)
    }

    static func normalized(_ image: NSImage) -> NSImage {
        guard let source = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return image }
        let width = source.width, height = source.height
        guard let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ), let data = context.data else { return image }
        context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
        let pixels = data.assumingMemoryBound(to: UInt8.self)
        let (visible, body) = alphaBounds(pixels, width: width, height: height)
        guard let visibleRect = visible.rect else { return image }
        // Crop to the solid body so drop shadows do not shrink the icon. Translucent icons keep full bounds.
        let crop = body.rect.flatMap {
            max($0.width, $0.height) >= 0.8 * max(visibleRect.width, visibleRect.height) ? $0 : nil
        } ?? visibleRect
        if crop == body.rect { eraseSourceShadow(pixels, byteCount: height * context.bytesPerRow) }
        guard let raster = context.makeImage(), let cropped = raster.cropping(to: crop) else { return image }
        let scale = min(1, pixelCap / max(crop.width, crop.height))
        let size = CGSize(width: (crop.width * scale).rounded(), height: (crop.height * scale).rounded())
        guard scale < 1, let target = CGContext(
            data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: context.bitmapInfo.rawValue
        ) else { return NSImage(cgImage: cropped, size: crop.size) }
        target.interpolationQuality = .high
        target.draw(cropped, in: CGRect(origin: .zero, size: size))
        guard let scaled = target.makeImage() else { return NSImage(cgImage: cropped, size: crop.size) }
        return NSImage(cgImage: scaled, size: size)
    }

    // Transparent margin around the icon body, as a fraction of its longest side.
    static let shadowInset: CGFloat = 0.075

    // The rectangular body crop leaves the source's own shadow in the corners.
    private static func eraseSourceShadow(_ pixels: UnsafeMutablePointer<UInt8>, byteCount: Int) {
        for offset in stride(from: 0, to: byteCount, by: 4) {
            let alpha = pixels[offset + 3]
            guard alpha <= 128, max(pixels[offset], pixels[offset + 1], pixels[offset + 2]) < alpha / 3 else { continue }
            (pixels + offset).update(repeating: 0, count: 4)
        }
    }

    static func shadowed(_ image: NSImage) -> NSImage {
        guard let body = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return image }
        let size = CGSize(width: body.width, height: body.height)
        let side = max(size.width, size.height)
        let margin = (side * shadowInset).rounded()
        guard let canvas = CGContext(
            data: nil, width: Int(size.width + margin * 2), height: Int(size.height + margin * 2),
            bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }
        let rect = CGRect(origin: CGPoint(x: margin, y: margin), size: size)
        let corners = Path(
            roundedRect: rect, cornerRadius: min(size.width, size.height) * 0.2, style: .continuous
        ).cgPath
        // Cast the shadow from an off-canvas copy so none of it sits under a translucent icon.
        let offCanvas = CGFloat(canvas.width)
        canvas.saveGState()
        canvas.setShadow(
            offset: CGSize(width: offCanvas, height: -side * 0.01), blur: side * 0.05,
            color: CGColor(gray: 0, alpha: 0.16)
        )
        canvas.translateBy(x: -offCanvas, y: 0)
        canvas.beginTransparencyLayer(auxiliaryInfo: nil)
        canvas.addPath(corners)
        canvas.clip()
        for _ in 0..<3 { canvas.draw(body, in: rect) }
        canvas.endTransparencyLayer()
        canvas.restoreGState()
        canvas.addPath(corners)
        canvas.clip()
        canvas.setBlendMode(.destinationOut)
        for _ in 0..<3 { canvas.draw(body, in: rect) }
        canvas.setBlendMode(.normal)
        canvas.draw(body, in: rect)
        guard let shadowed = canvas.makeImage() else { return image }
        return NSImage(cgImage: shadowed, size: CGSize(width: shadowed.width, height: shadowed.height))
    }
}
