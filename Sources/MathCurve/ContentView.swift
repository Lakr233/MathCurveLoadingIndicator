//
//  ContentView.swift
//  MatchCurve
//
//  Created by 秋星桥 on 2026/04/02.
//

import MathCurveLoadingIndicator
import SwiftUI

struct ContentView: View {
    @State private var selectedCurve: CurveType?

    private let columns = [GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(CurveType.allCases, id: \.rawValue) { curve in
                    CurveCell(curve: curve) {
                        selectedCurve = curve
                    }
                }
            }
            .padding(20)
        }
        .sheet(item: $selectedCurve) { curve in
            CurveDetailSheet(initialCurve: curve)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct CurveCell: View {
    let curve: CurveType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                MathCurveLoadingView(
                    curveType: curve,
                    color: curveColor(for: curve)
                )
                .frame(width: 56, height: 56)
                .allowsHitTesting(false)

                Text(curve.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct CurveDetailSheet: View {
    let initialCurve: CurveType
    @Environment(\.dismiss) private var dismiss

    @State private var color: Color
    @State private var speed: Double = 1.0
    @State private var strokeWidth: Double = 5.0
    @State private var particleCount: Double = 64

    private var curveType: CurveType { initialCurve }

    init(initialCurve: CurveType) {
        self.initialCurve = initialCurve
        _color = State(initialValue: curveColor(for: initialCurve))
        let p = initialCurve.defaultParameters
        _strokeWidth = State(initialValue: p.strokeWidth)
        _particleCount = State(initialValue: Double(p.particleCount))
    }

    private var parameters: CurveParameters {
        let base = curveType.defaultParameters
        return CurveParameters(
            particleCount: Int(particleCount),
            trailSpan: base.trailSpan,
            durationMs: base.durationMs / speed,
            pulseDurationMs: base.pulseDurationMs / speed,
            rotationDurationMs: base.rotationDurationMs / speed,
            strokeWidth: strokeWidth
        )
    }

    private let palette: [Color] = [
        .red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .primary,
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 4) {
                Text(curveType.name)
                    .font(.headline)
                Text(curveSubtitle(for: curveType))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 8)

            // Preview
            MathCurveLoadingView(
                curveType: curveType,
                parameters: parameters,
                color: color
            )
            .frame(width: 140, height: 140)

            // Color picker
            HStack(spacing: 8) {
                ForEach(palette, id: \.self) { c in
                    Circle()
                        .fill(c)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle().strokeBorder(
                                .primary.opacity(color == c ? 0.5 : 0), lineWidth: 2
                            )
                        )
                        .onTapGesture { color = c }
                }
            }

            // Sliders
            VStack(spacing: 12) {
                sliderRow("Speed", value: $speed, range: 0.25 ... 4.0, format: "%.1fx")
                sliderRow("Stroke", value: $strokeWidth, range: 1 ... 10, format: "%.1f")
                sliderRow("Particles", value: $particleCount, range: 12 ... 140, step: 1, format: "%.0f")
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)

            Button("Done") { dismiss() }
                .keyboardShortcut(.defaultAction)
                .padding(.bottom, 8)
        }
        .padding(.top, 4)
    }

    private func sliderRow(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double? = nil,
        format: String
    ) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            Group {
                if let step {
                    Slider(value: value, in: range, step: step)
                } else {
                    Slider(value: value, in: range)
                }
            }
            Text(String(format: format, value.wrappedValue))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.tertiary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

extension CurveType: @retroactive Identifiable {
    public var id: Int { rawValue }
}

private func curveColor(for curve: CurveType) -> Color {
    let hue = Double(curve.rawValue) / Double(CurveType.allCases.count)
    return Color(hue: hue, saturation: 0.65, brightness: 0.85)
}

private func curveSubtitle(for curve: CurveType) -> String {
    switch curve {
    case .originalThinking: "Custom Rose Trail"
    case .roseOrbit: "r = cos(k\u{03B8})"
    case .lissajousDrift: "x = sin(at), y = sin(bt)"
    case .lemniscateBloom: "Bernoulli Lemniscate"
    case .hypotrochoidLoop: "Inner Spirograph"
    case .butterflyPhase: "Butterfly Curve"
    case .cardioidGlow: "Cardioid"
    case .spiralSearch: "Archimedean Spiral"
    case .nautilusDrift: "Logarithmic Spiral"
    case .astroidStar: "Astroid"
    case .superellipseMorph: "Superellipse"
    case .hypocycloidCrest: "Hypocycloid"
    case .cassiniBloom: "Cassini Oval"
    case .nephroidTide: "Nephroid"
    case .deltoidDrift: "Deltoid"
    case .epitrochoidHalo: "Epitrochoid"
    case .fourierFlow: "Fourier Curve"
    }
}

#Preview {
    ContentView()
}
