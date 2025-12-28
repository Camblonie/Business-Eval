//
//  AddBusinessImageView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddBusinessImageView: View {
    let business: Business
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var captions: [String] = []
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image Picker
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Select Images")
                            .font(.headline)
                        
                        Text("Choose up to 10 images")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .onChange(of: selectedItems) {
                    loadImages(from: selectedItems)
                }
                
                // Selected Images Preview
                if !selectedImages.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                VStack(spacing: 8) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 120)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    TextField("Caption (optional)", text: index < captions.count ? $captions[index] : .constant(""))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Images")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveImages()
                        dismiss()
                    }
                    .disabled(selectedImages.isEmpty || isProcessing)
                }
            }
            .overlay(
                isProcessing ? ProgressView("Processing...") : nil
            )
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        isProcessing = true
        selectedImages.removeAll()
        captions.removeAll()
        
        Task {
            var loadedImages: [UIImage] = []
            var loadedCaptions: [String] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loadedImages.append(image)
                    loadedCaptions.append("")
                }
            }
            
            await MainActor.run {
                selectedImages = loadedImages
                captions = loadedCaptions
                isProcessing = false
            }
        }
    }
    
    private func saveImages() {
        for (index, image) in selectedImages.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let caption = index < captions.count ? captions[index] : nil
                let businessImage = BusinessImage(
                    imageData: imageData,
                    caption: caption?.isEmpty == true ? nil : caption,
                    business: business
                )
                modelContext.insert(businessImage)
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
    
    return AddBusinessImageView(business: business)
        .modelContainer(for: [Business.self, BusinessImage.self], inMemory: true)
}
