import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

final class AuthorContentBuilder {
    private struct WorkChildListModel: Equatable {
        let id: String
        let isExpanded: Bool
    }

    private struct SectionModel {
        let name: String
        let count: Int
        let makeListItems: () -> Void
    }

    // MARK: -

    var onDescriptionTap: ((AuthorModel) -> Void)?
    var onExpandOrCollapse: (() -> Void)?
    var onChildWorkTap: ((Int) -> Void)?
    var onAwardsTap: ((AuthorModel) -> Void)?

    // MARK: -

    func makeListItemsFrom(state: DataState<AuthorInteractor.DataModel>) -> [ListItem] {
        switch state {
        case .initial:
            return []
        case .loading:
            return [ListItem(id: "author_loading", layoutSpec: SpinnerLayoutSpec())]
        case .error:
            return [] // TODO:
        case let .idle(data):
            return makeListItemsFrom(data: data)
        }
    }

    private func makeListItemsFrom(data: AuthorInteractor.DataModel) -> [ListItem] {
        var items: [ListItem] = []

        // header

        do {
            let item = ListItem(id: "author_header", layoutSpec: AuthorHeaderLayoutSpec(model: data.author))

            items.append(item)
        }

        // sections

        var sections: [SectionModel] = []

        let info = [data.author.bio, data.author.notes].compactAndJoin("\n")

        if !info.isEmpty {
            let section = SectionModel(name: "Биография", count: 0) {
                let item = ListItem(
                    id: "author_bio",
                    layoutSpec: FLTextPreviewLayoutSpec(model: info)
                )

                item.didSelect = { [weak self] cell, _ in
                    CellSelection.scale(cell: cell, action: {
                        self?.onDescriptionTap?(data.author)
                    })
                }

                items.append(item)
            }

            sections.append(section)
        }

        if !data.author.awards.isEmpty {
            let section = SectionModel(name: "Премии", count: data.author.awards.count) {
                let item = ListItem(
                    id: "author_awards",
                    layoutSpec: AwardIconsLayoutSpec(model: data.author.awards)
                )

                item.didSelect = { [weak self] cell, _ in
                    CellSelection.scale(cell: cell, action: {
                        self?.onAwardsTap?(data.author)
                    })
                }

                items.append(item)
            }

            sections.append(section)
        }

        if data.contentRoot.count > 0 {
            let section = SectionModel(name: "Произведения", count: 0) {
                data.contentRoot.traverseContent { node in
                    guard let work = node.model else {
                        return
                    }

                    let nodeId = "child_node_" + String(node.id)

                    let item = ListItem(
                        id: nodeId,
                        model: WorkChildListModel(
                            id: nodeId,
                            isExpanded: node.isExpanded
                        ),
                        layoutSpec: ChildWorkLayoutSpec(model: ChildWorkLayoutModel(
                            work: work,
                            count: node.children.count,
                            isExpanded: node.isExpanded,
                            expandCollapseAction: node.count > 0 ? ({ [weak self] in
                                node.isExpanded = !node.isExpanded

                                self?.onExpandOrCollapse?()
                            }) : nil
                        ))
                    )

                    if work.id > 0 {
                        item.didSelect = { [weak self] cell, _ in
                            CellSelection.alpha(cell: cell, action: {
                                self?.onChildWorkTap?(work.id)
                            })
                        }
                    }

                    items.append(item)

                    items.append(ListItem(
                        id: nodeId + "_separator",
                        layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                    ))
                }

                items.removeLast()
            }

            sections.append(section)
        }

        sections.enumerated().forEach { (index, section) in
            items.append(ListItem(
                id: section.name + "_separator",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))

            items.append(ListItem(
                id: section.name + "_title",
                layoutSpec: ListSectionTitleLayoutSpec(model: (section.name, section.count))
            ))

            section.makeListItems()
        }

        return items
    }
}
