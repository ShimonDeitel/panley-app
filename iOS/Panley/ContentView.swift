import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: ItemEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    Button(action: { editingEntry = entry }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.name)").font(Theme.headingFont)
                            Text("\(entry.quantity)").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                    .buttonStyle(.plain)
                }
                .onDelete(perform: store.delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Panley - Pantry Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if store.canAddMore {
                            showingAddSheet = true
                        } else {
                            showingPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .overlay {
                if store.entries.isEmpty {
                    ContentUnavailableView("No Items Yet", systemImage: "tray", description: Text("Tap + to add your first item."))
                }
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    let existing: ItemEntry?
    let onSave: (ItemEntry) -> Void

    @State private var name: String
    @State private var quantity: Int
    @State private var expiryDate: Date
    @State private var location: String

    init(entry: ItemEntry?, onSave: @escaping (ItemEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _name = State(initialValue: entry?.name ?? "")
        _quantity = State(initialValue: entry?.quantity ?? 0)
        _expiryDate = State(initialValue: entry?.expiryDate ?? Date())
        _location = State(initialValue: entry?.location ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_nameField")
                Stepper("Quantity: \(quantity)", value: $quantity, in: 0...9999)
                DatePicker("ExpiryDate", selection: $expiryDate, displayedComponents: .date)
                TextField("Location", text: $location)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_locationField")
            }
            .navigationTitle(existing == nil ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
    }

    private func save() {
        let id = existing?.id ?? UUID()
        let entry = ItemEntry(id: id, name: name, quantity: quantity, expiryDate: expiryDate, location: location)
        onSave(entry)
    }
}
