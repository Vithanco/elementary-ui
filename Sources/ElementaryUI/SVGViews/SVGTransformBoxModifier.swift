// SVG resolves transform-origin against the nearest viewBox rather than the element,
// and defaults it to 0 0, so an untouched rotate() or scale() pivots on the viewBox
// origin. These two properties restore the HTML meaning - the element's own box,
// centred - so the shared CSS the transform modifiers emit means the same thing in
// both namespaces.
final class SVGTransformBoxModifier: DOMElementModifier, Unmountable {
    typealias Value = Void

    init(value: consuming Void, upstream: borrowing DOMElementModifiers) {}

    func updateValue(_ value: consuming Void, _ context: inout _TransactionContext) {}

    func mount(_ node: DOM.Node, _ context: inout _MountContext) -> AnyUnmountable {
        context.dom.setStyleProperty(node, name: "transform-box", value: "fill-box")
        context.dom.setStyleProperty(node, name: "transform-origin", value: "50% 50%")
        return AnyUnmountable(self)
    }

    func unmount(_ context: inout _CommitContext) {}
}
