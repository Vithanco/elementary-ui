// The `View` event modifiers, mirrored for SVG content.
//
// Declarations only — every one of these forwards to the same `DOMEffectView` and
// the same modifier stack that `View` uses. The duplication is forced by the
// return type: `some View<Tag>` and `some SVGView<Tag>` are different opaque
// types, so one shared extension on `MarkupContent & _Mountable` cannot serve
// both without making `DOMEffectView` public API.

public extension SVGView {
    // TODO: embedded - see the matching note on `View`; kept in step deliberately.
    consuming func _onEvent<Config: _DOMEventHandlerConfig>(
        _ type: Config.Type,
        handler: @escaping (Config.Event) -> Void
    ) -> some SVGView<Tag> {
        DOMEffectView<EventHandlerModifier<Config>, Self>(value: handler, wrapped: self)
    }

    consuming func _onEvent<Config: _DOMEventConfig>(
        _ type: Config.Type,
        handler: @escaping () -> Void
    ) -> some SVGView<Tag> {
        DOMEffectView<EventActionModifier<Config>, Self>(value: handler, wrapped: self)
    }

    /// Adds a handler for click events with event details.
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` when clicked.
    /// - Returns: SVG content that responds to click events.
    consuming func onClick(_ handler: @escaping (MouseEvent) -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.Click.self, handler: handler)
    }

    /// Adds a handler for click events.
    ///
    /// - Parameter handler: A closure invoked when the element is clicked.
    /// - Returns: SVG content that responds to click events.
    consuming func onClick(_ handler: @escaping () -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.Click.self, handler: handler)
    }
}
