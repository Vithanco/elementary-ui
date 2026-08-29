import ElementaryUI
import Reactivity
import Testing

/// The SVG counterparts of the style modifier tests in `DOMStyleTests`.
///
/// Serialized like `TransitionMountRootTests`: withAnimation leaks across tests run in parallel.
@Suite(.serialized)
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

        #expect(dom.ops.contains(.setStyle(node: "<circle>", name: "transform", value: "translate(10.0px, 20.0px)")))
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

        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "filter", value: "blur(3.0px)")))
    }

    @Test
    func stacksStyleAndEventModifiersOnOneSVGElement() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1))
                    .opacity(0.25)
                    .offset(x: 3, y: 4)
                    .onClick { _ in }
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "opacity", value: "0.25")))
        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "transform", value: "translate(3.0px, 4.0px)")))
        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "click")))
    }

    @Test
    func setsSaturationOnNestedSVGElements() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).saturation(1.5)
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "filter", value: "saturate(1.5)")))
    }

    @Test
    func setsBrightnessOnNestedSVGElements() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).brightness(0.25)
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "filter", value: "brightness(0.25)")))
    }

    @Test
    func patchesOpacityOnNestedSVGElements() {
        let state = ToggleState()
        let ops = patchOps {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).opacity(state.value ? 1 : 0.5)
            }
        } toggle: {
            state.toggle()
        }

        #expect(ops == [.setStyle(node: "<rect>", name: "opacity", value: "1.0")])
    }

    @Test
    func patchesOffsetOnNestedSVGElements() {
        let state = ToggleState()
        let ops = patchOps {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).offset(x: state.value ? 7 : 1, y: 2)
            }
        } toggle: {
            state.toggle()
        }

        #expect(ops == [.setStyle(node: "<rect>", name: "transform", value: "translate(7.0px, 2.0px)")])
    }

    @Test
    func patchesFilterOnNestedSVGElements() {
        let state = ToggleState()
        let ops = patchOps {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).blur(radius: state.value ? 8 : 2)
            }
        } toggle: {
            state.toggle()
        }

        #expect(ops == [.setStyle(node: "<rect>", name: "filter", value: "blur(8.0px)")])
    }

    @Test
    func stacksMultipleFiltersIntoOneProperty() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1))
                    .blur(radius: 2)
                    .saturation(1.5)
            }
        }
        dom.runNextFrame()

        let filters = dom.ops.compactMap { op -> String? in
            if case let .setStyle(node: "<rect>", name: "filter", value: v) = op { v } else { nil }
        }
        #expect(filters.last?.contains("blur(2.0px)") == true)
        #expect(filters.last?.contains("saturate(1.5)") == true)
    }

    @Test
    func stacksMultipleTransformsIntoOneProperty() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1))
                    .offset(x: 1, y: 2)
                    .offset(x: 10, y: 20)
            }
        }
        dom.runNextFrame()

        let transforms = dom.ops.compactMap { op -> String? in
            if case let .setStyle(node: "<rect>", name: "transform", value: v) = op { v } else { nil }
        }
        #expect(transforms.last?.contains("translate(1.0px, 2.0px)") == true)
        #expect(transforms.last?.contains("translate(10.0px, 20.0px)") == true)
    }

    @Test
    func appliesStylesToAnSVGContainer() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.g {
                    SVG.rect(.x(0), .y(0), .width(1), .height(1))
                }
                .opacity(0.75)
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.setStyle(node: "<g>", name: "opacity", value: "0.75")))
    }

    @Test
    func animatesOpacityChangesInAnAnimatedTransaction() {
        let state = ToggleState()
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).opacity(state.value ? 1 : 0.5)
            }
        }
        dom.runNextFrame()
        #expect(dom.startedAnimationCount == 0)

        withAnimation(.linear(duration: 0.35)) {
            state.toggle()
        }
        dom.runNextFrame()

        #expect(dom.startedAnimationCount == 1)
    }

    @Test
    func animatesTransformChangesInAnAnimatedTransaction() {
        let state = ToggleState()
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).offset(x: state.value ? 9 : 1, y: 0)
            }
        }
        dom.runNextFrame()

        withAnimation(.linear(duration: 0.35)) {
            state.toggle()
        }
        dom.runNextFrame()

        #expect(dom.startedAnimationCount == 1)
    }

    @Test
    func doesNotAnimateOutsideAnAnimatedTransaction() {
        let state = ToggleState()
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1)).opacity(state.value ? 1 : 0.5)
            }
        }
        dom.runNextFrame()

        state.toggle()
        dom.runNextFrame()

        #expect(dom.startedAnimationCount == 0)
        #expect(dom.ops.contains(.setStyle(node: "<rect>", name: "opacity", value: "1.0")))
    }
}

@Reactive
private class ToggleState {
    var value = false

    func toggle() {
        value.toggle()
    }
}
