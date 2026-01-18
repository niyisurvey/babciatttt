//
//  TaskPierogiDropView.swift
//  BabciaTobiasz
//
//  Draggable pierogi interaction for completing area tasks.
//

import SwiftUI

struct TaskPierogiDropCard: View {
    let tasks: [CleaningTask]
    let goldenChancePercent: Int
    let onDropTask: (CleaningTask) -> Void
    let onToggleTask: (CleaningTask) -> Void

    @Environment(\.dsTheme) private var theme

    private var dropAreaHeight: CGFloat {
        max(theme.grid.detailCardHeightLarge, theme.grid.pierogiPotSize + theme.grid.iconXL)
    }

    var body: some View {
        GlassCardView {
            VStack(spacing: theme.grid.listSpacing) {
                if tasks.isEmpty {
                    emptyState
                } else {
                    TaskPierogiDropView(
                        tasks: tasks,
                        goldenChancePercent: goldenChancePercent,
                        onDropTask: onDropTask
                    )
                        .frame(height: dropAreaHeight)

                    TaskListSummaryView(tasks: tasks, onToggleTask: onToggleTask)
                }
            }
            .padding(theme.grid.cardPadding)
        }
    }

    private var emptyState: some View {
        VStack(spacing: theme.grid.cardPaddingTight) {
            Text(String(localized: "areaDetail.tasks.empty"))
                .dsFont(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: dropAreaHeight)
    }
}

private struct TaskPierogiDropView: View {
    let tasks: [CleaningTask]
    let goldenChancePercent: Int
    let onDropTask: (CleaningTask) -> Void

    @Environment(\.dsTheme) private var theme
    @State private var items: [TaskPierogiItem] = []
    @State private var droppedCount = 0
    @State private var isFloating = false
    @State private var isPotArmed = false

    private enum PierogiAsset {
        static let normal = "Pierogi_Clay_Normal"
        static let golden = "Pierogi_Clay_Golden"
        static let bowl = "Bowl_Clay_Natural"
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let potCenter = CGPoint(x: size.width / 2, y: size.height / 2)
            let dropRadius = (theme.grid.pierogiPotSize / 2) + theme.grid.cardPaddingTight

            ZStack {
                potView(center: potCenter, isArmed: isPotArmed)

                ForEach(items) { item in
                    pierogiView(
                        item,
                        center: potCenter,
                        dropRadius: dropRadius,
                        container: size
                    )
                }
            }
            .coordinateSpace(name: "TaskPierogiDrop")
            .onAppear {
                setupItems(size: size, center: potCenter, dropRadius: dropRadius)
                withAnimation(theme.motion.fadeStandard.repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
            .onChange(of: taskIdSignature) { _, _ in
                setupItems(size: size, center: potCenter, dropRadius: dropRadius)
            }
            .onChange(of: taskCompletionSignature) { _, _ in
                syncCompletionStates(center: potCenter)
            }
            .onChange(of: size) { _, _ in
                setupItems(size: size, center: potCenter, dropRadius: dropRadius)
            }
        }
    }

    private var orderedTasks: [CleaningTask] {
        Array(tasks.sorted { $0.createdAt < $1.createdAt }.prefix(TaskPierogiDropLayout.maxTasks))
    }

    private var taskIdSignature: String {
        orderedTasks.map { $0.id.uuidString }.joined(separator: "|")
    }

    private var taskCompletionSignature: String {
        orderedTasks
            .map { "\($0.id.uuidString):\($0.isCompleted ? "1" : "0")" }
            .joined(separator: "|")
    }

    private func setupItems(size: CGSize, center: CGPoint, dropRadius: CGFloat) {
        items = makeItems(in: size, center: center, dropRadius: dropRadius, existingItems: items)
        updateDroppedCount()
    }

    private func syncCompletionStates(center: CGPoint) {
        var updated = items
        for index in updated.indices {
            guard let taskId = updated[index].taskId,
                  let task = orderedTasks.first(where: { $0.id == taskId }) else {
                continue
            }
            updated[index].isDropped = task.isCompleted
            if task.isCompleted {
                updated[index].position = center
            }
        }
        items = updated
        updateDroppedCount()
    }

    private func potView(center: CGPoint, isArmed: Bool) -> some View {
        let baseSize = theme.grid.pierogiPotSize
        let growth = CGFloat(droppedCount) * (theme.grid.pierogiPotGrowStep / theme.grid.pierogiPotSize)
        let scale = 1 + growth
        let glowColor = theme.palette.warmAccent

        return ZStack {
            Image(PierogiAsset.bowl)
                .resizable()
                .scaledToFit()
                .frame(width: baseSize, height: baseSize)
                .shadow(color: theme.palette.glassTint.opacity(0.2), radius: theme.grid.iconSmall, x: 0, y: theme.grid.iconSmall / 2)

            Circle()
                .stroke(glowColor, lineWidth: theme.grid.iconTiny)
                .frame(width: baseSize + theme.grid.iconLarge, height: baseSize + theme.grid.iconLarge)
                .opacity(isArmed ? theme.glass.glowOpacityHigh : theme.glass.glowOpacityLow)
                .scaleEffect(isArmed ? 1.05 : 0.95)
                .animation(theme.motion.fadeFast, value: isArmed)
        }
        .scaleEffect(scale)
        .position(center)
        .animation(theme.motion.listSpring, value: droppedCount)
    }

    private func pierogiView(
        _ item: TaskPierogiItem,
        center: CGPoint,
        dropRadius: CGFloat,
        container: CGSize
    ) -> some View {
        let floatOffset = floatingOffset(for: item)
        let opacity: Double = item.isPlaceholder ? 0.35 : (item.isDropped ? 0.75 : 1.0)
        let scale: CGFloat = item.isDropped ? 0.85 : 1.0
        let labelOffset = theme.grid.pierogiSize * 0.55

        let assetName = item.isGolden ? PierogiAsset.golden : PierogiAsset.normal
        return ZStack {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: theme.grid.pierogiSize, height: theme.grid.pierogiSize)
                .scaleEffect(scale)
                .saturation(item.isPlaceholder ? 0 : 1)
            .rotationEffect(item.rotation)

            if let title = item.taskTitle, item.isPlaceholder == false, item.isDropped == false {
                Text(title)
                    .dsFont(.caption, weight: .bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .padding(.horizontal, theme.grid.cardPaddingTight)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .offset(y: -labelOffset)
            }
        }
        .position(item.position)
        .offset(item.isDropped ? .zero : floatOffset)
        .opacity(opacity)
        .shadow(color: theme.palette.glassTint.opacity(0.2), radius: theme.grid.iconTiny, x: 0, y: theme.grid.iconTiny / 2)
        .animation(theme.motion.fadeStandard, value: isFloating)
        .animation(theme.motion.fadeStandard, value: item.isDropped)
        .gesture(item.canDrag ? dragGesture(for: item, center: center, dropRadius: dropRadius, container: container) : nil)
        .allowsHitTesting(item.canDrag)
    }

    private func dragGesture(
        for item: TaskPierogiItem,
        center: CGPoint,
        dropRadius: CGFloat,
        container: CGSize
    ) -> some Gesture {
        DragGesture(minimumDistance: theme.grid.buttonVerticalPadding, coordinateSpace: .named("TaskPierogiDrop"))
            .onChanged { value in
                updatePierogi(item.id) { pierogi in
                    pierogi.position = TaskPierogiDropLayout.clampedPosition(
                        value.location,
                        container: container,
                        theme: theme
                    )
                }
                isPotArmed = TaskPierogiDropLayout.distance(from: value.location, to: center) <= dropRadius
            }
            .onEnded { _ in
                defer { isPotArmed = false }
                let currentPosition = items.first(where: { $0.id == item.id })?.position ?? item.position
                let distance = TaskPierogiDropLayout.distance(from: currentPosition, to: center)
                if distance <= dropRadius {
                    dropPierogi(item.id, at: center)
                } else {
                    withAnimation(theme.motion.listSpring) {
                        updatePierogi(item.id) { pierogi in
                            pierogi.position = TaskPierogiDropLayout.clampedPosition(
                                currentPosition,
                                container: container,
                                theme: theme
                            )
                        }
                    }
                }
            }
    }

    private func dropPierogi(_ id: UUID, at center: CGPoint) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        guard let taskId = items[index].taskId,
              let task = orderedTasks.first(where: { $0.id == taskId }),
              task.isCompleted == false else { return }

        withAnimation(theme.motion.pressSpring) {
            updatePierogi(id) { pierogi in
                pierogi.position = center
                pierogi.isDropped = true
            }
        }
        updateDroppedCount()
        onDropTask(task)
    }

    private func updateDroppedCount() {
        droppedCount = items.filter(\.isDropped).count
    }

    private func makeItems(
        in size: CGSize,
        center: CGPoint,
        dropRadius: CGFloat,
        existingItems: [TaskPierogiItem]
    ) -> [TaskPierogiItem] {
        let tasks = orderedTasks
        let placeholders = max(0, TaskPierogiDropLayout.maxTasks - tasks.count)
        let stackOrigin = TaskPierogiDropLayout.stackAnchor(
            in: size,
            center: center,
            dropRadius: dropRadius,
            theme: theme
        )
        let taskSlots: [CleaningTask?] = tasks + Array(repeating: nil, count: placeholders)
        var items: [TaskPierogiItem] = []

        for (index, task) in taskSlots.enumerated() {
            let stackOffset = TaskPierogiDropLayout.stackOffsets[
                min(index, TaskPierogiDropLayout.stackOffsets.count - 1)
            ]
            let position = TaskPierogiDropLayout.clampedPosition(
                CGPoint(
                    x: stackOrigin.x + stackOffset.width,
                    y: stackOrigin.y - stackOffset.height
                ),
                container: size,
                theme: theme
            )
            let floatOffset = TaskPierogiDropLayout.floatOffsets[
                min(index, TaskPierogiDropLayout.floatOffsets.count - 1)
            ]
            let rotation = Angle(degrees: Double(6 - (index * 3)))
            let isDropped = task?.isCompleted ?? false
            let existingItem = existingItems.first(where: { $0.taskId == task?.id })
            let resolvedPosition = existingItem?.position ?? position
            items.append(
                TaskPierogiItem(
                    taskId: task?.id,
                    taskTitle: task?.title,
                    position: isDropped ? center : position,
                    isDropped: isDropped,
                    floatOffset: floatOffset,
                    rotation: rotation,
                    isPlaceholder: task == nil,
                    isGolden: TaskPierogiDropLayout.isGolden(
                        taskId: task?.id,
                        fallback: existingItem?.isGolden,
                        chancePercent: goldenChancePercent
                    )
                )
            )
            if let existingItem, isDropped == false {
                updateItemPosition(&items, for: existingItem.id, to: resolvedPosition)
            }
        }
        return items
    }

    private func floatingOffset(for item: TaskPierogiItem) -> CGSize {
        guard isFloating, item.isDropped == false else { return .zero }
        return item.floatOffset
    }

    private func updatePierogi(_ id: UUID, update: (inout TaskPierogiItem) -> Void) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        update(&items[index])
    }

    private func updateItemPosition(_ items: inout [TaskPierogiItem], for id: UUID, to position: CGPoint) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].position = position
    }

}

private struct TaskPierogiItem: Identifiable {
    let id: UUID
    let taskId: UUID?
    let taskTitle: String?
    var position: CGPoint
    var isDropped: Bool
    let floatOffset: CGSize
    let rotation: Angle
    let isPlaceholder: Bool
    let isGolden: Bool

    init(
        taskId: UUID?,
        taskTitle: String?,
        position: CGPoint,
        isDropped: Bool,
        floatOffset: CGSize,
        rotation: Angle,
        isPlaceholder: Bool,
        isGolden: Bool
    ) {
        self.id = taskId ?? UUID()
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.position = position
        self.isDropped = isDropped
        self.floatOffset = floatOffset
        self.rotation = rotation
        self.isPlaceholder = isPlaceholder
        self.isGolden = isGolden
    }

    var canDrag: Bool {
        taskId != nil && !isPlaceholder && !isDropped
    }
}

private enum TaskPierogiDropLayout {
    static let maxTasks = 5
    static let stackOffsets: [CGSize] = [
        CGSize(width: 0, height: 0),
        CGSize(width: 10, height: 6),
        CGSize(width: 20, height: 12),
        CGSize(width: 30, height: 18),
        CGSize(width: 40, height: 24)
    ]
    static let floatOffsets: [CGSize] = [
        CGSize(width: 0, height: 0),
        CGSize(width: 2, height: -3),
        CGSize(width: -2, height: 2),
        CGSize(width: 3, height: 1),
        CGSize(width: -3, height: -2)
    ]

    static func isGolden(taskId: UUID?, fallback: Bool?, chancePercent: Int) -> Bool {
        if let fallback { return fallback }
        guard let taskId else { return false }
        let clampedChance = max(0, min(chancePercent, 100))
        guard clampedChance > 0 else { return false }
        return stableSeed(for: taskId) % 100 < clampedChance
    }

    static func stackAnchor(
        in size: CGSize,
        center: CGPoint,
        dropRadius: CGFloat,
        theme: DesignSystemTheme
    ) -> CGPoint {
        let inset = theme.grid.cardPaddingTight + theme.grid.pierogiSize / 2
        let targetX = min(size.width * 0.28, center.x - dropRadius - theme.grid.iconLarge)
        let targetY = min(size.height - inset, center.y + dropRadius + theme.grid.iconSmall)
        return CGPoint(
            x: max(inset, targetX),
            y: max(inset, targetY)
        )
    }

    static func clampedPosition(
        _ position: CGPoint,
        container: CGSize,
        theme: DesignSystemTheme
    ) -> CGPoint {
        let inset = theme.grid.cardPaddingTight
        let minX = inset + theme.grid.pierogiSize / 2
        let maxX = container.width - inset - theme.grid.pierogiSize / 2
        let minY = inset + theme.grid.pierogiSize / 2
        let maxY = container.height - inset - theme.grid.pierogiSize / 2
        return CGPoint(
            x: min(max(position.x, minX), maxX),
            y: min(max(position.y, minY), maxY)
        )
    }

    static func distance(from point: CGPoint, to target: CGPoint) -> CGFloat {
        hypot(point.x - target.x, point.y - target.y)
    }

    private static func stableSeed(for taskId: UUID) -> Int {
        taskId.uuidString.utf8.reduce(0) { total, byte in
            (total + Int(byte)) % 1000
        }
    }
}

#Preview {
    TaskPierogiDropCard(tasks: [
        CleaningTask(title: "Clear visible surfaces"),
        CleaningTask(title: "Put loose items away"),
        CleaningTask(title: "Wipe one surface"),
        CleaningTask(title: "Collect trash"),
        CleaningTask(title: "Reset the area")
    ], goldenChancePercent: 10, onDropTask: { _ in }, onToggleTask: { _ in })
    .padding()
    .dsTheme(.default)
}
