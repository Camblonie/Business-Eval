//
//  BusinessImagesView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI

struct BusinessImagesView: View {
    let business: Business
    @State private var selectedImage: BusinessImage?
    @State private var showingAddImages = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Business Images")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingAddImages = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            
            // Images count badge
            HStack {
                Text("\(business.images.count) image\(business.images.count == 1 ? "" : "s")")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                
                Spacer()
            }
            
            // Images Grid
            if business.images.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No images added")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Add Images") {
                        showingAddImages = true
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(business.images.sorted(by: { $0.createdAt > $1.createdAt })) { image in
                            BusinessImageCell(image: image) {
                                selectedImage = image
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingAddImages) {
            AddBusinessImageView(business: business)
        }
        .sheet(item: $selectedImage) { image in
            ImageDetailView(image: image)
        }
    }
}

struct BusinessImageCell: View {
    let image: BusinessImage
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            if let uiImage = image.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(8)
                    .onTapGesture {
                        onTap()
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            if let caption = image.caption, !caption.isEmpty {
                Text(caption)
                    .font(.caption2)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            
            Text(image.createdAt, style: .short)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct ImageDetailView: View {
    let image: BusinessImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if let uiImage = image.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                        )
                }
                
                if let caption = image.caption, !caption.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                        
                        Text("Caption")
                            .font(.headline)
                        
                        Text(caption)
                            .font(.body)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Image Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let business = Business(
        name: "Test Business",
        industry: "Technology",
        location: "San Francisco, CA",
        askingPrice: 500000,
        annualRevenue: 1000000,
        annualProfit: 200000,
        numberOfEmployees: 10,
        yearsEstablished: 5,
        businessDescription: "A test business for demonstration purposes."
    )
    
    return BusinessImagesView(business: business)
        .modelContainer(for: [Business.self, BusinessImage.self], inMemory: true)
}
