public final class OpacityModifier: DOMElementModifier {
    public typealias Value = CSSOpacity

    let upstream: OpacityModifier?
    let layerNumber: Int

    var value: CSSValueSource<CSSOpacity>

    public init(value: consuming Value, upstream: borrowing DOMElementModifiers) {
        self.value = CSSValueSource(value: value)
        self.upstream = upstream[OpacityModifier.key]
        self.layerNumber = (self.upstream?.layerNumber ?? 0) + 1
    }

    public func updateValue(_ value: consuming Value, _ context: inout _TransactionContext) {
        self.value.updateValue(value, &context)
    }

    @_spi(Benchmarking) public func mount(_ node: DOM.Node, _ context: inout _MountContext) -> AnyUnmountable {
        AnyUnmountable(MountedStyleModifier(node, makeLayers(&context), &context))
    }

    private func makeLayers(_ context: inout _MountContext) -> [CSSValueSource<CSSOpacity>.Instance] {
        if var layers = upstream.map({ $0.makeLayers(&context) }) {
            layers.append(value.makeInstance())
            return layers
        } else {
            return [value.makeInstance()]
        }
    }
}
