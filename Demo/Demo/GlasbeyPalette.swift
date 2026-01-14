import CoreGraphics
import Foundation
import SwiftUI

// MARK: - Lab color
private struct Lab {
    let l: Double
    let a: Double
    let b: Double
}

// MARK: - sRGB → linear
private func srgbToLinear(_ c: Double) -> Double {
    if c <= 0.04045 {
        return c / 12.92
    } else {
        return pow((c + 0.055) / 1.055, 2.4)
    }
}

// MARK: - linear → sRGB
private func linearToSrgb(_ c: Double) -> Double {
    if c <= 0.0031308 {
        return 12.92 * c
    } else {
        return 1.055 * pow(c, 1.0 / 2.4) - 0.055
    }
}

// MARK: - RGB → Lab (D65)
private func rgbToLab(r: Double, g: Double, b: Double) -> Lab {
    let r = srgbToLinear(r)
    let g = srgbToLinear(g)
    let b = srgbToLinear(b)

    // sRGB → XYZ (D65)
    let x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
    let y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
    let z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041

    // Normalize for D65 white point
    let xn = x / 0.95047
    let yn = y / 1.00000
    let zn = z / 1.08883

    func f(_ t: Double) -> Double {
        t > 0.008856 ? pow(t, 1.0 / 3.0) : (7.787 * t + 16.0 / 116.0)
    }

    let fx = f(xn)
    let fy = f(yn)
    let fz = f(zn)

    return Lab(
        l: 116.0 * fy - 16.0,
        a: 500.0 * (fx - fy),
        b: 200.0 * (fy - fz)
    )
}

// MARK: - Lab distance (ΔE76)
private func labDistance(_ a: Lab, _ b: Lab) -> Double {
    let dl = a.l - b.l
    let da = a.a - b.a
    let db = a.b - b.b
    return sqrt(dl * dl + da * da + db * db)
}

// MARK: - Glasbey palette
struct GlasbeyPalette {

    /// Generate a Glasbey-style palette
    /// - Parameters:
    ///   - count: Number of colors desired
    ///   - candidateResolution: Grid resolution per RGB axis (e.g. 16 → 4096 candidates)
    static func generate(
        count: Int,
        candidateResolution: Int = 16
    ) -> [CGColor] {

        precondition(candidateResolution >= 4)

        // Build candidate RGB space
        var candidates: [(r: Double, g: Double, b: Double, lab: Lab)] = []

        let step = 1.0 / Double(candidateResolution - 1)

        for ri in 0..<candidateResolution {
            for gi in 0..<candidateResolution {
                for bi in 0..<candidateResolution {
                    let r = Double(ri) * step
                    let g = Double(gi) * step
                    let b = Double(bi) * step
                    let lab = rgbToLab(r: r, g: g, b: b)
                    candidates.append((r, g, b, lab))
                }
            }
        }

        // Start with black and white anchors
        var selected: [(r: Double, g: Double, b: Double, lab: Lab)] = [
            (0, 0, 0, rgbToLab(r: 0, g: 0, b: 0)),
            (1, 1, 1, rgbToLab(r: 1, g: 1, b: 1))
        ]

        while selected.count < count + 2 {
            var bestCandidate: (Double, Double, Double, Lab)?
            var bestDistance = -Double.infinity

            for c in candidates {
                var minDist = Double.infinity

                for s in selected {
                    let d = labDistance(c.lab, s.lab)
                    if d < minDist {
                        minDist = d
                    }
                }

                if minDist > bestDistance {
                    bestDistance = minDist
                    bestCandidate = (c.r, c.g, c.b, c.lab)
                }
            }

            guard let chosen = bestCandidate else { break }
            selected.append(chosen)
        }

        // Drop the initial black & white anchors
        let colors = selected.dropFirst(2).prefix(count)

        return colors.map {
            CGColor(
                red: CGFloat($0.r),
                green: CGFloat($0.g),
                blue: CGFloat($0.b),
                alpha: 1.0
            )
        }
    }
}

// MARK: - Cached palette

private let glasbeyColors: [CGColor] = GlasbeyPalette.generate(count: 64)

extension Color {
    init(glasbeyIndex index: Int) {
        self = Color(cgColor: glasbeyColors[index % glasbeyColors.count])
    }
}
