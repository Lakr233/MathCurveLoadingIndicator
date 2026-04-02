import SwiftUI

public struct MathCurveLoadingView: View {
    @Binding var curveType: CurveType
    @Binding var parameters: CurveParameters
    @Binding var color: Color

    public init(
        curveType: Binding<CurveType>,
        parameters: Binding<CurveParameters>,
        color: Binding<Color> = .constant(.primary)
    ) {
        _curveType = curveType
        _parameters = parameters
        _color = color
    }

    public var body: some View {
        AnimatedCurveViewRepresentable(
            curveType: curveType,
            parameters: parameters,
            color: color
        )
        .contentShape(Rectangle())
    }
}

extension MathCurveLoadingView {
    public init(
        curveType: CurveType = .originalThinking,
        parameters: CurveParameters? = nil,
        color: Color = .primary
    ) {
        let resolvedParameters = parameters ?? curveType.defaultParameters
        _curveType = .constant(curveType)
        _parameters = .constant(resolvedParameters)
        _color = .constant(color)
    }

    public init(
        curveType: Binding<CurveType>,
        color: Binding<Color> = .constant(.primary)
    ) {
        _curveType = curveType
        _parameters = .constant(curveType.wrappedValue.defaultParameters)
        _color = color
    }
}
