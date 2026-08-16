import ElementaryUI
import Reactivity
import Testing

/// The SVG counterparts of the style modifier tests in `DOMStyleTests`.
struct SVGStyleTests {
    @Test
    func setsOpacityOnNestedSVGElements() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).opacity(0.5)
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "opacity", value: "0.5")))
    }

    @Test
    func setsTransformsOnNestedSVGElements() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.g {
                    SVG.circle(.cx(4), .cy(5), .r(6)).offset(x: 10, y: 20)
                }
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains { if case .setStyle(node: "<circle>", name: "transform", _) = $0 { true } else { false } })
    }

    @Test
    func setsFiltersOnNestedSVGElements() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).blur(radius: 3)
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains { if case .setStyle(node: "<rect>", name: "filter", _) = $0 { true } else { false } })
    }

    @Test
    func stacksStyleAndEventModifiersOnOneSVGElement() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1))
                    .opacity(0.25)
                    .scaleEffect(2)
                    .onClick { _ in }
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "opacity", value: "0.25")))
        #expect(dom.ops.contains { if case .setStyle(node: "<rect>", name: "transform", _) = $0 { true } else { false } })
        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "click")))
    }
}
