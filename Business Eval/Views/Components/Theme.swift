//
//  Theme.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/1/26.
//
//  Centralized design system for consistent UI styling throughout the app.
//  Based on patterns from the Businesses tab.
//

import SwiftUI

// MARK: - App Theme
/// Central theme configuration for the Business Eval app
struct AppTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary semantic colors
        static let primary = Color.blue
        static let secondary = Color(.secondaryLabel)
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.systemGray6)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // Financial colors
        static let money = Color.green
        static let revenue = Color.blue
        static let profit = Color.purple
        static let margin = Color.orange
        
        // Status colors for BusinessStatus
        static func statusColor(for status: BusinessStatus) -> Color {
            switch status {
            case .new: return .blue
            case .researching: return .orange
            case .contacted: return .purple
            case .underReview: return .yellow
            case .offerMade: return .green
            case .negotiating: return .red
            case .dueDiligence: return .indigo
            case .closed: return .primary
            case .rejected: return .red
            case .notInterested: return .gray
            }
        }
        
        // Confidence level colors for valuations
        static func confidenceColor(for level: ConfidenceLevel) -> Color {
            switch level {
            case .low: return .red
            case .medium: return .orange
            case .high: return .green
            case .veryHigh: return .blue
            }
        }
        
        // Correspondence direction colors
        static let inbound = Color.green
        static let outbound = Color.orange
        
        // Action colors
        static let destructive = Color.red
        static let success = Color.green
        static let warning = Color.orange
        static let info = Color.blue
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        
        // Card internal padding
        static let cardPadding: CGFloat = 16
        
        // Section spacing in ScrollViews
        static let sectionSpacing: CGFloat = 20
        
        // Row vertical padding
        static let rowVerticalPadding: CGFloat = 4
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let pill: CGFloat = 20
    }
    
    // MARK: - Fonts
    struct Fonts {
        // Titles
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.bold)
        static let title3 = Font.title3.weight(.semibold)
        
        // Headers
        static let headline = Font.headline.weight(.bold)
        static let subheadline = Font.subheadline
        static let subheadlineMedium = Font.subheadline.weight(.medium)
        
        // Body
        static let body = Font.body
        static let bodyMedium = Font.body.weight(.medium)
        
        // Captions
        static let caption = Font.caption
        static let captionMedium = Font.caption.weight(.medium)
    }
    
    // MARK: - Badge Styling
    struct Badge {
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 2
        static let largeHorizontalPadding: CGFloat = 12
        static let largeVerticalPadding: CGFloat = 6
        static let backgroundOpacity: Double = 0.2
    }
    
    // MARK: - Icon Sizes
    struct IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 40
    }
    
    // MARK: - Shadows
    /// Shadow depth levels for visual hierarchy
    struct Shadows {
        static let light = Shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        static let heavy = Shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Gradients
    /// Predefined gradients for visual interest
    struct Gradients {
        // Primary gradient for hero sections
        static let primary = LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Success gradient for positive metrics
        static let success = LinearGradient(
            colors: [Color.green, Color.green.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Warning gradient for attention items
        static let warning = LinearGradient(
            colors: [Color.orange, Color.orange.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Subtle card gradient for elevated cards
        static let cardElevated = LinearGradient(
            colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Header gradient overlay
        static let headerOverlay = LinearGradient(
            colors: [Color.black.opacity(0.3), Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Shadow Helper Struct
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Shadow Modifier
/// Applies shadow with specified depth level
struct ShadowModifier: ViewModifier {
    let shadow: Shadow
    
    func body(content: Content) -> some View {
        content
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    /// Applies light shadow for subtle elevation
    func shadowLight() -> some View {
        modifier(ShadowModifier(shadow: AppTheme.Shadows.light))
    }
    
    /// Applies medium shadow for moderate elevation
    func shadowMedium() -> some View {
        modifier(ShadowModifier(shadow: AppTheme.Shadows.medium))
    }
    
    /// Applies heavy shadow for strong elevation
    func shadowHeavy() -> some View {
        modifier(ShadowModifier(shadow: AppTheme.Shadows.heavy))
    }
}

// MARK: - Card View Modifier
/// Applies consistent card styling used throughout the app
struct CardStyle: ViewModifier {
    let elevated: Bool
    
    init(elevated: Bool = false) {
        self.elevated = elevated
    }
    
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.cardPadding)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
            .shadow(
                color: elevated ? AppTheme.Shadows.medium.color : AppTheme.Shadows.light.color,
                radius: elevated ? AppTheme.Shadows.medium.radius : AppTheme.Shadows.light.radius,
                x: 0,
                y: elevated ? AppTheme.Shadows.medium.y : AppTheme.Shadows.light.y
            )
    }
}

extension View {
    /// Applies the standard card styling (padding, background, corner radius, light shadow)
    func cardStyle() -> some View {
        modifier(CardStyle(elevated: false))
    }
    
    /// Applies elevated card styling with stronger shadow
    func elevatedCardStyle() -> some View {
        modifier(CardStyle(elevated: true))
    }
}

// MARK: - Hero Card Modifier
/// Applies gradient background for hero/overview sections
struct HeroCardStyle: ViewModifier {
    let gradient: LinearGradient
    
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.cardPadding)
            .background(gradient)
            .cornerRadius(AppTheme.CornerRadius.large)
            .shadow(
                color: AppTheme.Shadows.medium.color,
                radius: AppTheme.Shadows.medium.radius,
                x: 0,
                y: AppTheme.Shadows.medium.y
            )
    }
}

extension View {
    /// Applies hero card styling with primary gradient
    func heroCardStyle() -> some View {
        modifier(HeroCardStyle(gradient: AppTheme.Gradients.primary))
    }
    
    /// Applies hero card styling with custom gradient
    func heroCardStyle(gradient: LinearGradient) -> some View {
        modifier(HeroCardStyle(gradient: gradient))
    }
}

// MARK: - Divider Style
/// Custom themed divider
struct ThemedDivider: View {
    let color: Color
    let height: CGFloat
    
    init(color: Color = Color(.separator), height: CGFloat = 0.5) {
        self.color = color
        self.height = height
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
    }
}

// MARK: - Accent Button Style
/// Button style for primary call-to-action buttons
struct AccentButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = AppTheme.Colors.primary) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.subheadlineMedium)
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(color)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AppAnimations.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
/// Button style for secondary actions
struct SecondaryButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = AppTheme.Colors.primary) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.subheadlineMedium)
            .foregroundColor(color)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(color.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AppAnimations.buttonPress, value: configuration.isPressed)
    }
}

extension View {
    /// Applies accent button styling for primary CTAs
    func accentButtonStyle(color: Color = AppTheme.Colors.primary) -> some View {
        self.buttonStyle(AccentButtonStyle(color: color))
    }
    
    /// Applies secondary button styling
    func secondaryButtonStyle(color: Color = AppTheme.Colors.primary) -> some View {
        self.buttonStyle(SecondaryButtonStyle(color: color))
    }
}

// MARK: - Themed Metric Card View
/// Card for displaying key metrics with visual emphasis
struct ThemedMetricCard: View {
    let title: String
    let value: String
    let icon: String?
    let color: Color
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up, down, neutral
    }
    
    init(
        title: String,
        value: String,
        icon: String? = nil,
        color: Color = AppTheme.Colors.primary,
        trend: TrendDirection? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Spacer()
                
                if let trend = trend {
                    Image(systemName: trendIcon(for: trend))
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(trendColor(for: trend))
                }
            }
            
            Text(value)
                .font(AppTheme.Fonts.title2)
                .foregroundColor(color)
        }
        .padding(AppTheme.Spacing.md)
        .background(color.opacity(0.08))
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    private func trendIcon(for direction: TrendDirection) -> String {
        switch direction {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }
    
    private func trendColor(for direction: TrendDirection) -> Color {
        switch direction {
        case .up: return AppTheme.Colors.success
        case .down: return AppTheme.Colors.destructive
        case .neutral: return AppTheme.Colors.secondary
        }
    }
}

// MARK: - Section Divider
/// Visual separator between major sections
struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, Color(.separator), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.vertical, AppTheme.Spacing.sm)
    }
}

// MARK: - List Row with Divider Modifier
/// Adds a divider below list rows
struct ListRowDividerModifier: ViewModifier {
    let showDivider: Bool
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            
            if showDivider {
                ThemedDivider()
                    .padding(.leading, AppTheme.Spacing.lg)
            }
        }
    }
}

extension View {
    /// Adds a divider below the view
    func withDivider(_ show: Bool = true) -> some View {
        modifier(ListRowDividerModifier(showDivider: show))
    }
}

// MARK: - Status Badge View
/// Reusable badge component for displaying status with consistent styling
struct StatusBadge: View {
    let text: String
    let color: Color
    let size: BadgeSize
    
    enum BadgeSize {
        case small
        case large
    }
    
    init(_ text: String, color: Color, size: BadgeSize = .small) {
        self.text = text
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Fonts.caption)
            .padding(.horizontal, size == .large ? AppTheme.Badge.largeHorizontalPadding : AppTheme.Badge.horizontalPadding)
            .padding(.vertical, size == .large ? AppTheme.Badge.largeVerticalPadding : AppTheme.Badge.verticalPadding)
            .background(color.opacity(AppTheme.Badge.backgroundOpacity))
            .foregroundColor(color)
            .cornerRadius(size == .large ? AppTheme.CornerRadius.large : AppTheme.CornerRadius.medium)
    }
}

// MARK: - Business Status Badge
/// Convenience view for BusinessStatus badges
struct BusinessStatusBadge: View {
    let status: BusinessStatus
    let size: StatusBadge.BadgeSize
    
    init(_ status: BusinessStatus, size: StatusBadge.BadgeSize = .small) {
        self.status = status
        self.size = size
    }
    
    var body: some View {
        StatusBadge(status.rawValue, color: AppTheme.Colors.statusColor(for: status), size: size)
    }
}

// MARK: - Confidence Badge
/// Convenience view for ConfidenceLevel badges
struct ConfidenceBadge: View {
    let level: ConfidenceLevel
    
    init(_ level: ConfidenceLevel) {
        self.level = level
    }
    
    var body: some View {
        StatusBadge(level.rawValue, color: AppTheme.Colors.confidenceColor(for: level))
    }
}

// MARK: - Count Badge
/// Small badge showing a count number
struct CountBadge: View {
    let count: Int
    let color: Color
    
    init(_ count: Int, color: Color = AppTheme.Colors.primary) {
        self.count = count
        self.color = color
    }
    
    var body: some View {
        Text("\(count)")
            .font(AppTheme.Fonts.caption)
            .padding(.horizontal, AppTheme.Badge.horizontalPadding)
            .padding(.vertical, AppTheme.Badge.verticalPadding)
            .background(color.opacity(AppTheme.Badge.backgroundOpacity))
            .foregroundColor(color)
            .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - Section Header View
/// Reusable section header with optional action button and count badge
struct SectionHeader: View {
    let title: String
    let icon: String?
    let count: Int?
    let countColor: Color
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        _ title: String,
        icon: String? = nil,
        count: Int? = nil,
        countColor: Color = AppTheme.Colors.primary,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.count = count
        self.countColor = countColor
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            Text(title)
                .font(AppTheme.Fonts.headline)
            
            if let count = count {
                CountBadge(count, color: countColor)
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .font(AppTheme.Fonts.caption)
            }
        }
    }
}

// MARK: - Detail Row View (Themed)
/// Reusable row for displaying label-value pairs
struct ThemedDetailRow: View {
    let label: String
    let value: String
    let icon: String?
    let valueColor: Color
    let isURL: Bool
    
    init(
        label: String,
        value: String,
        icon: String? = nil,
        valueColor: Color = .secondary,
        isURL: Bool = false
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.valueColor = valueColor
        self.isURL = isURL
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Label(label, systemImage: icon)
                    .font(AppTheme.Fonts.subheadline)
            } else {
                Text(label)
                    .font(AppTheme.Fonts.subheadline)
            }
            
            Spacer()
            
            if isURL, let url = URL(string: value) {
                Link("View Listing", destination: url)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.primary)
            } else {
                Text(value)
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(valueColor)
            }
        }
    }
}

// MARK: - Financial Row View (Themed)
/// Reusable row for displaying financial values with consistent formatting
struct ThemedFinancialRow: View {
    let label: String
    let value: Double
    let color: Color
    let isPercentage: Bool
    
    init(label: String, value: Double, color: Color = AppTheme.Colors.money, isPercentage: Bool = false) {
        self.label = label
        self.value = value
        self.color = color
        self.isPercentage = isPercentage
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Fonts.subheadline)
            
            Spacer()
            
            Text(formattedValue)
                .font(AppTheme.Fonts.subheadlineMedium)
                .foregroundColor(color)
        }
    }
    
    private var formattedValue: String {
        if isPercentage {
            return String(format: "%.1f%%", value)
        } else {
            return formatCurrency(value)
        }
    }
    
    /// Formats currency with K/M suffixes for large numbers
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
}

// MARK: - Action Button View
/// Reusable action button with icon, used in detail views - includes tap animation
struct ThemedActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            .padding()
            .background(AppTheme.Colors.background)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Empty State View
/// Reusable empty state component with icon, message, and optional action
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: AppTheme.IconSize.xlarge))
                .foregroundColor(.gray)
            
            Text(title)
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text(message)
                .font(AppTheme.Fonts.subheadline)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Search Bar Style Modifier
/// Applies consistent search bar styling
struct SearchBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

extension View {
    func searchBarStyle() -> some View {
        modifier(SearchBarStyle())
    }
}

// MARK: - Tab Selector View
/// Reusable segmented tab selector used in Owners, Brokers, Correspondence views
struct TabSelector<T: Hashable & RawRepresentable>: View where T.RawValue == String, T: CaseIterable {
    @Binding var selectedTab: T
    
    var body: some View {
        HStack {
            ForEach(Array(T.allCases), id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.rawValue)
                        .font(AppTheme.Fonts.subheadlineMedium)
                        .foregroundColor(selectedTab == tab ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .fill(selectedTab == tab ? AppTheme.Colors.primary.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
}

// MARK: - Animation Constants
/// Centralized animation timing and curves for consistent motion throughout the app
struct AppAnimations {
    // Standard durations
    static let fast: Double = 0.15
    static let normal: Double = 0.25
    static let slow: Double = 0.4
    
    // Spring animations for natural feel
    static let springResponse: Double = 0.4
    static let springDamping: Double = 0.7
    
    // Stagger delay for list items
    static let staggerDelay: Double = 0.05
    
    // Standard animations
    static let defaultAnimation = Animation.easeInOut(duration: normal)
    static let quickAnimation = Animation.easeOut(duration: fast)
    static let springAnimation = Animation.spring(response: springResponse, dampingFraction: springDamping)
    
    // Interactive spring for button presses
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.6)
}

// MARK: - Fade In Animation Modifier
/// Animates view appearance with fade and optional slide
struct FadeInModifier: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    let slideOffset: CGFloat
    
    init(delay: Double = 0, slideOffset: CGFloat = 10) {
        self.delay = delay
        self.slideOffset = slideOffset
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : slideOffset)
            .onAppear {
                withAnimation(AppAnimations.defaultAnimation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Applies fade-in animation when view appears
    func fadeIn(delay: Double = 0, slideOffset: CGFloat = 10) -> some View {
        modifier(FadeInModifier(delay: delay, slideOffset: slideOffset))
    }
}

// MARK: - Staggered List Animation Modifier
/// Animates list items with staggered delay based on index
struct StaggeredAppearanceModifier: ViewModifier {
    @State private var isVisible = false
    let index: Int
    let baseDelay: Double
    
    init(index: Int, baseDelay: Double = 0) {
        self.index = index
        self.baseDelay = baseDelay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 15)
            .scaleEffect(isVisible ? 1 : 0.95)
            .onAppear {
                let delay = baseDelay + (Double(index) * AppAnimations.staggerDelay)
                withAnimation(AppAnimations.springAnimation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Applies staggered appearance animation for list items
    func staggeredAppearance(index: Int, baseDelay: Double = 0) -> some View {
        modifier(StaggeredAppearanceModifier(index: index, baseDelay: baseDelay))
    }
}

// MARK: - Scale Button Style
/// Button style that provides subtle scale feedback on press
struct ScaleButtonStyle: ButtonStyle {
    let scaleAmount: CGFloat
    
    init(scaleAmount: CGFloat = 0.97) {
        self.scaleAmount = scaleAmount
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(AppAnimations.buttonPress, value: configuration.isPressed)
    }
}

extension View {
    /// Applies scale animation on tap
    func scaleOnTap(amount: CGFloat = 0.97) -> some View {
        self.buttonStyle(ScaleButtonStyle(scaleAmount: amount))
    }
}

// MARK: - Animated Card Style Modifier
/// Card style with fade-in animation on appearance
struct AnimatedCardStyle: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    init(delay: Double = 0) {
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.cardPadding)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(AppAnimations.springAnimation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Applies card styling with fade-in animation
    func animatedCardStyle(delay: Double = 0) -> some View {
        modifier(AnimatedCardStyle(delay: delay))
    }
}

// MARK: - Pulse Animation Modifier
/// Subtle pulse animation for drawing attention to elements
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let duration: Double
    
    init(duration: Double = 1.5) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.02 : 1.0)
            .opacity(isPulsing ? 1 : 0.9)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    /// Applies subtle pulse animation
    func pulse(duration: Double = 1.5) -> some View {
        modifier(PulseModifier(duration: duration))
    }
}

// MARK: - Shimmer Loading Effect
/// Shimmer effect for loading states
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Applies shimmer loading effect
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Badge Animation Modifier
/// Animates badge changes with scale effect
struct BadgeAnimationModifier: ViewModifier {
    let value: String
    @State private var animationTrigger = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(animationTrigger ? 1.0 : 1.15)
            .onChange(of: value) { _, _ in
                animationTrigger = false
                withAnimation(AppAnimations.springAnimation) {
                    animationTrigger = true
                }
            }
            .onAppear {
                animationTrigger = true
            }
    }
}

extension View {
    /// Animates badge when value changes
    func animateBadgeChange(value: String) -> some View {
        modifier(BadgeAnimationModifier(value: value))
    }
}

// MARK: - Slide Transition Modifier
/// Custom slide transition for navigation
struct SlideTransitionModifier: ViewModifier {
    let edge: Edge
    
    func body(content: Content) -> some View {
        content
            .transition(.asymmetric(
                insertion: .move(edge: edge).combined(with: .opacity),
                removal: .move(edge: edge == .trailing ? .leading : .trailing).combined(with: .opacity)
            ))
    }
}

extension View {
    /// Applies slide transition from specified edge
    func slideTransition(from edge: Edge = .trailing) -> some View {
        modifier(SlideTransitionModifier(edge: edge))
    }
}

// MARK: - Tap Feedback Modifier
/// Provides visual feedback on tap with scale animation
struct TapFeedbackModifier: ViewModifier {
    @State private var isTapped = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isTapped ? 0.96 : 1.0)
            .opacity(isTapped ? 0.8 : 1.0)
            .onTapGesture {
                withAnimation(AppAnimations.quickAnimation) {
                    isTapped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(AppAnimations.quickAnimation) {
                        isTapped = false
                    }
                    action()
                }
            }
    }
}

extension View {
    /// Applies tap feedback animation with action
    func tapFeedback(action: @escaping () -> Void) -> some View {
        modifier(TapFeedbackModifier(action: action))
    }
}

// MARK: - Animated Status Badge
/// Status badge with animation on value change
struct AnimatedStatusBadge: View {
    let text: String
    let color: Color
    let size: StatusBadge.BadgeSize
    
    init(_ text: String, color: Color, size: StatusBadge.BadgeSize = .small) {
        self.text = text
        self.color = color
        self.size = size
    }
    
    var body: some View {
        StatusBadge(text, color: color, size: size)
            .animateBadgeChange(value: text)
    }
}

// MARK: - Previews
#Preview("Status Badges") {
    VStack(spacing: 20) {
        HStack {
            BusinessStatusBadge(.new)
            BusinessStatusBadge(.researching)
            BusinessStatusBadge(.offerMade)
        }
        
        HStack {
            ConfidenceBadge(.low)
            ConfidenceBadge(.medium)
            ConfidenceBadge(.high)
            ConfidenceBadge(.veryHigh)
        }
        
        CountBadge(5, color: .blue)
    }
    .padding()
}

#Preview("Section Header") {
    VStack(spacing: 20) {
        SectionHeader("Financial Summary", icon: "dollarsign.circle")
        SectionHeader("Correspondence", count: 5, countColor: .blue, actionTitle: "View All") {}
        SectionHeader("Valuations", count: 3, countColor: .green)
    }
    .padding()
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "building.2",
        title: "No businesses yet",
        message: "Add your first business to get started",
        actionTitle: "Add Business"
    ) {}
}
