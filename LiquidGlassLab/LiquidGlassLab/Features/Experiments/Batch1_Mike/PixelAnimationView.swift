import SwiftUI
import UIKit

struct PixelAnimationView: View {
    @State private var selectedShape: AnimationShape = .circle
    
    var body: some View {
        ZStack {
            SquaresView(selectedShape: selectedShape)
                .drawingGroup() // Promote to Metal
            
            VStack {
                Spacer()
                HStack(spacing: 24) {
                    ShapeButton(shape: .circle, selected: selectedShape) { selectedShape = .circle }
                    ShapeButton(shape: .square, selected: selectedShape) { selectedShape = .square }
                    ShapeButton(shape: .diamond, selected: selectedShape) { selectedShape = .diamond }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .glass()
                .padding(.bottom, 40)
            }
        }
    }
}

struct ShapeButton: View {
    let shape: AnimationShape
    let selected: AnimationShape
    let action: () -> Void
    
    var icon: String {
        switch shape {
        case .circle: return "circle"
        case .square: return "square"
        case .diamond: return "diamond"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(selected == shape ? .white : .white.opacity(0.5))
                .frame(width: 50, height: 50)
                .background(selected == shape ? Color.blue.opacity(0.6) : Color.white.opacity(0.1))
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
        }
    }
}

struct SquaresView: UIViewRepresentable {
    var selectedShape: AnimationShape
    
    func makeUIView(context: Context) -> SquaresUIView {
        // Initialize with zero frame, will update in layout
        let view = SquaresUIView(frame: .zero)
        return view
    }
    
    func updateUIView(_ uiView: SquaresUIView, context: Context) {
        uiView.updateAnimationSettings(shape: selectedShape)
    }
}

class SquaresUIView: UIView {
    private var layers: [[CALayer]] = []
    private var timer: Timer?
    private var baseColumns: Int = 18 // Slightly reduced for performance
    private var dimension: CGFloat = 0
    private var ripples: [(center: (row: Int, col: Int), currentRadius: Int, maxRadius: Int, timestamp: TimeInterval, shape: AnimationShape)] = []
    private var rippleTimer: CADisplayLink?
    private var currentShape: AnimationShape = .circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        timer?.invalidate()
        rippleTimer?.invalidate()
    }
    
    private func setup() {
        backgroundColor = .clear // Transparent to let MeshGradient show? Actually this needs its own background
        // The original logic clears to "white". We want it to be transparent or semi-transparent?
        // Let's keep it transparent blocks appearing over a clear background.
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        isUserInteractionEnabled = true
        setupRippleTimer()
    }
    
    private func setupRippleTimer() {
        rippleTimer = CADisplayLink(target: self, selector: #selector(handleRippleTimer))
        rippleTimer?.add(to: .main, forMode: .common)
    }
    
    @objc private func handleRippleTimer() {
        let currentTime = CACurrentMediaTime()
        var ripplestoRemove: [Int] = []
        
        for (index, ripple) in ripples.enumerated() {
            if currentTime - ripple.timestamp >= 0.03 {
                let currentRadius = ripple.currentRadius
                if currentRadius < ripple.maxRadius {
                    createShapeRing(center: ripple.center, radius: currentRadius, shape: ripple.shape)
                    ripples[index].currentRadius += 1
                    ripples[index].timestamp = currentTime
                } else {
                    ripplestoRemove.append(index)
                }
            }
        }
        
        for index in ripplestoRemove.sorted(by: >) {
            ripples.remove(at: index)
        }
    }
    
    private func createLayers() {
        layers.forEach { row in
            row.forEach { $0.removeFromSuperlayer() }
        }
        layers.removeAll()
        
        guard bounds.width > 0, bounds.height > 0 else { return }
        
        dimension = bounds.width / CGFloat(baseColumns)
        let rows = Int(ceil(bounds.height / dimension))
        
        // Ensure we don't block the background
        backgroundColor = UIColor.clear
        
        for row in 0..<rows {
            var rowLayers: [CALayer] = []
            for col in 0..<baseColumns {
                let layer = CALayer()
                layer.frame = CGRect(x: CGFloat(col) * dimension,
                                   y: CGFloat(row) * dimension,
                                   width: dimension,
                                   height: dimension)
                // Default state: Transparent
                layer.backgroundColor = UIColor.clear.cgColor
                
                // Grid lines?
                layer.borderWidth = 0.5
                layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
                
                self.layer.addSublayer(layer)
                rowLayers.append(layer)
            }
            layers.append(rowLayers)
        }
    }
    
    private func createShapeRing(center: (row: Int, col: Int), radius: Int, shape: AnimationShape) {
        let positions = getShapePositions(center: center, radius: radius, shape: shape)
        
        for pos in positions {
            guard pos.row >= 0 && pos.row < layers.count,
                  pos.col >= 0 && pos.col < baseColumns else { continue } // Fix range check
            
            // Guard against out of bounds columns accessing the array
             if pos.col >= layers[pos.row].count { continue }

            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)

            // HSL Color
            let hue = CGFloat(radius) / 10.0
            let color = UIColor(
                hue: hue.truncatingRemainder(dividingBy: 1.0),
                saturation: 0.8,
                brightness: 1.0,
                alpha: 0.8 // Semi-transparent
            ).cgColor
            
            layers[pos.row][pos.col].backgroundColor = color
            
            CATransaction.commit()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                // Check bounds again to be safe
                if pos.row < self.layers.count && pos.col < self.layers[pos.row].count {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(0.3)
                    self.layers[pos.row][pos.col].backgroundColor = UIColor.clear.cgColor
                    CATransaction.commit()
                }
            }
        }
    }
    
    private func getShapePositions(center: (row: Int, col: Int), radius: Int, shape: AnimationShape) -> [(row: Int, col: Int)] {
        var positions: [(row: Int, col: Int)] = []
        for i in -radius...radius {
            for j in -radius...radius {
                switch shape {
                case .circle:
                    let distance = sqrt(Double(i * i + j * j))
                    if distance >= Double(radius) - 0.5 && distance < Double(radius) + 0.5 {
                        positions.append((row: center.row + i, col: center.col + j))
                    }
                case .square:
                    if abs(i) == radius || abs(j) == radius {
                        positions.append((row: center.row + i, col: center.col + j))
                    }
                case .diamond:
                    if abs(i) + abs(j) == radius {
                        positions.append((row: center.row + i, col: center.col + j))
                    }
                }
            }
        }
        return positions
    }
    
    private func startRipple(at point: CGPoint) {
        guard dimension > 0 else { return }
        let col = Int(point.x / dimension)
        let row = Int(point.y / dimension)
        
        guard row >= 0 && row < layers.count && col >= 0 && col < baseColumns else { return }
        
        let maxRadius = max(baseColumns, layers.count) / 2
        ripples.append((
            center: (row: row, col: col),
            currentRadius: 0,
            maxRadius: maxRadius,
            timestamp: 0,
            shape: currentShape
        ))
        
        // Immediate feedback at tap point
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        layers[row][col].backgroundColor = UIColor.white.cgColor // White flash
        CATransaction.commit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        startRipple(at: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        // Rate limit drag ripples?
        startRipple(at: point)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Only recreate if bounds changed significantly
        if bounds.width > 0 && bounds.height > 0 && layers.isEmpty {
            createLayers()
        }
    }
    
    func updateAnimationSettings(shape: AnimationShape) {
        currentShape = shape
    }
}

enum AnimationShape {
    case circle, square, diamond
}
