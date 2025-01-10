import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportCsv: View {
  @Binding var showingExport: Bool
  
  @Query(sort: \BudgetModel.startDate) private var budgets: [BudgetModel]
  
  @State private var selection = Set<UUID>()
  @State private var showingExportFile = false
  
  var body: some View {
    NavigationView {
      VStack {
        List(budgets) { budget in
          Toggle(isOn: Binding<Bool>.init(get: {
            selection.contains(budget.uuid)
          }, set: { newValue in
            if newValue {
              selection.insert(budget.uuid)
            } else {
              selection.remove(budget.uuid)
            }
          })) {
            Text(budget.name)
          }
          .toggleStyle(CheckmarkToggleStyle())
        }
      }
      
      .navigationTitle("Export budgets as CSV")
      .navigationBarTitleDisplayMode(.inline)
      
      .toolbar {
        ToolbarItem {
          Button(action: { showingExportFile.toggle() }, label: {
            Text("Export")
          })
          .disabled(selection.isEmpty)
        }
        
        ToolbarItem(placement: .navigation, content: {
          Button(action: { showingExport = false }) { Text("Cancel") }
        })
        
        ToolbarItem(placement: .bottomBar) {
          Button {
            selectAll(selection.isEmpty)
          } label: {
            Text(selection.isEmpty ? "Select all" : "Deselect all")
          }
        }
      }
      
      .onAppear {
        selectAll(true)
      }
      
      .fileExporter(
        isPresented: $showingExportFile,
        document: getDocumentToExport(),
        contentType: UTType.commaSeparatedText
      ) { result in
        switch result {
        case .success:
          showingExport = false
        case .failure:
          print("TODO: Show error dialog")
        }
      }
    }
  }

  private func selectAll(_ select: Bool) {
    if select {
      budgets.map(\.uuid).forEach { selection.insert($0) }
    } else {
      selection.removeAll()
    }
  }
  
  private func getDocumentToExport() -> some FileDocument {
    CsvDocument(
      initialText: CsvEncoder.encode(
        budgets.filter { selection.contains($0.uuid) }))
  }
}

private struct CheckmarkToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      HStack {
        configuration.label
        Spacer()
        Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
      }
    }
    .buttonStyle(.plain)
  }
}

private struct CsvDocument: FileDocument {
  // tell the system we support only plain text
  static var readableContentTypes = [UTType.commaSeparatedText]
  static var writableContentTypes = [UTType.commaSeparatedText]

  // by default our document is empty
  var text = ""

  // a simple initializer that creates new, empty documents
  init(initialText: String = "") {
      text = initialText
  }

  // this initializer loads data that has been saved previously
  init(configuration: ReadConfiguration) throws {
      if let data = configuration.file.regularFileContents {
          text = String(decoding: data, as: UTF8.self)
      }
  }

  // this will be called when the system wants to write our data to disk
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
      let data = Data(text.utf8)
      return FileWrapper(regularFileWithContents: data)
  }
}


#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: BudgetModel.self, configurations: config)
  
  container.mainContext.insert(BudgetModel(
    name: "Current",
    notes: "",
    amount: 100,
    firstDay: .today,
    lastDay: .today.adding(days: 30),
    expenses: []))
  container.mainContext.insert(BudgetModel(
    name: "Upcoming",
    notes: "",
    amount: 100,
    firstDay: .today.adding(days: 31),
    lastDay: .today.adding(days: 61),
    expenses: []))
  
  for _ in 0 ... 5 {
    container.mainContext.insert(BudgetModel(
      name: "Past",
      notes: "",
      amount: 100,
      firstDay: .today.adding(days: -61),
      lastDay: .today.adding(days: -31),
      expenses: [
        ExpenseModel(name: "", notes: "", amount: 400, date: .now)
      ]))
  }
  
  
  return ExportCsv(showingExport: .constant(true))
    .modelContainer(container)
    .environmentObject(CurrentDate())
    .environmentObject(WhatsNewController())
    .environmentObject(NavigationState())
}
