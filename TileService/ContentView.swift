//TileMaster Pro is the ultimate app for tile service providers, offering seamless management of services, customers, orders, and inventory. Easily add and edit tile services, track customer orders. Streamline your business operations, stay organized, and deliver top-quality service with TileMaster Pro. Perfect for both solo contractors and larger teams.

import SwiftUI

// MARK: - Models

struct TileService: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var type: String
    var cost: Double
    var timeRequired: String
    var description: String
    var material: String
    var laborCost: Double
    var totalCost: Double {
        return cost + laborCost
    }
    
    static func == (lhs: TileService, rhs: TileService) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Customer: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var contactInfo: String
    var address: String
    var orderHistory: [Order] = []
    
    static func == (lhs: Customer, rhs: Customer) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Order: Identifiable, Codable, Equatable {
    var id = UUID()
    var serviceName: String
    var quantity: Int
    var totalCost: Double
    var customerName: String
    var orderDate: Date
    var status: String
    var paymentStatus: String
    
    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Managers

class TileServiceManager: ObservableObject {
    @Published var services: [TileService] = [] {
        didSet {
            saveServices()
        }
    }
    
    init() {
        loadServices()
    }
    
    func addService(_ service: TileService) {
        services.append(service)
    }
    
    func updateService(_ service: TileService) {
        if let index = services.firstIndex(where: { $0.id == service.id }) {
            services[index] = service
        }
    }
    
    func deleteService(at offsets: IndexSet) {
        services.remove(atOffsets: offsets)
    }
    
    private func loadServices() {
        if let data = UserDefaults.standard.data(forKey: "services"),
           let decoded = try? JSONDecoder().decode([TileService].self, from: data) {
            services = decoded
        }
    }
    
    private func saveServices() {
        if let encoded = try? JSONEncoder().encode(services) {
            UserDefaults.standard.set(encoded, forKey: "services")
        }
    }
}

class CustomerManager: ObservableObject {
    @Published var customers: [Customer] = [] {
        didSet {
            saveCustomers()
        }
    }
    
    init() {
        loadCustomers()
    }
    
    func addCustomer(_ customer: Customer) {
        customers.append(customer)
    }
    
    func updateCustomer(_ customer: Customer) {
        if let index = customers.firstIndex(where: { $0.id == customer.id }) {
            customers[index] = customer
        }
    }
    
    func deleteCustomer(at offsets: IndexSet) {
        customers.remove(atOffsets: offsets)
    }
    
    private func loadCustomers() {
        if let data = UserDefaults.standard.data(forKey: "customers"),
           let decoded = try? JSONDecoder().decode([Customer].self, from: data) {
            customers = decoded
        }
    }
    
    private func saveCustomers() {
        if let encoded = try? JSONEncoder().encode(customers) {
            UserDefaults.standard.set(encoded, forKey: "customers")
        }
    }
}

class OrderManager: ObservableObject {
    @Published var orders: [Order] = [] {
        didSet {
            saveOrders()
        }
    }
    
    init() {
        loadOrders()
    }
    
    func addOrder(_ order: Order) {
        orders.append(order)
    }
    
    func updateOrder(_ order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
        }
    }
    
    func deleteOrder(at offsets: IndexSet) {
        orders.remove(atOffsets: offsets)
    }
    
    private func loadOrders() {
        if let data = UserDefaults.standard.data(forKey: "orders"),
           let decoded = try? JSONDecoder().decode([Order].self, from: data) {
            orders = decoded
        }
    }
    
    private func saveOrders() {
        if let encoded = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(encoded, forKey: "orders")
        }
    }
}

// MARK: - Views

struct ContentView: View {
    @StateObject private var tileServiceManager = TileServiceManager()
    @StateObject private var customerManager = CustomerManager()
    @StateObject private var orderManager = OrderManager()
    
    var body: some View {
        TabView {
            TileServiceListView()
                .tabItem {
                    Label("Services", systemImage: "square.grid.2x2.fill")
                }
                .environmentObject(tileServiceManager)
            
            CustomerListView()
                .tabItem {
                    Label("Customers", systemImage: "person.3.fill")
                }
                .environmentObject(customerManager)
                .environmentObject(orderManager)
            
            OrderListView()
                .tabItem {
                    Label("Orders", systemImage: "cart.fill")
                }
                .environmentObject(orderManager)
                .environmentObject(customerManager)
        }
        .accentColor(.orange)
    }
}

// MARK: - Tile Service List View

struct TileServiceListView: View {
    @EnvironmentObject var tileServiceManager: TileServiceManager
    @State private var showingAddTileServiceView = false
    @State private var tileServiceToEdit: TileService?
    @State private var showDeleteConfirmation = false
    @State private var tileServiceToDelete: TileService?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tileServiceManager.services) { service in
                    NavigationLink(destination: EditTileServiceView(service: binding(for: service))) {
                        VStack(alignment: .leading) {
                            Text(service.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(service.type)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("Material: \(service.material)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Labor Cost: $\(service.laborCost, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Service Cost: $\(service.cost, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Total Cost: $\(service.totalCost, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("Time Required: \(service.timeRequired)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                    .contextMenu {
                        Button("Edit") {
                            tileServiceToEdit = service
                        }
                        Button("Delete", role: .destructive) {
                            tileServiceToDelete = service
                            showDeleteConfirmation = true
                        }
                    }
                }
                .onDelete(perform: tileServiceManager.deleteService)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Tile Services")
            .navigationBarItems(trailing: Button(action: {
                showingAddTileServiceView = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            })
            .sheet(isPresented: $showingAddTileServiceView) {
                AddTileServiceView()
                    .environmentObject(tileServiceManager)
            }
            .sheet(item: $tileServiceToEdit) { service in
                EditTileServiceView(service: binding(for: service))
                    .environmentObject(tileServiceManager)
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this service? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let service = tileServiceToDelete, let index = tileServiceManager.services.firstIndex(of: service) {
                            tileServiceManager.services.remove(at: index)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func binding(for service: TileService) -> Binding<TileService> {
        guard let index = tileServiceManager.services.firstIndex(where: { $0.id == service.id }) else {
            fatalError("Service not found")
        }
        return $tileServiceManager.services[index]
    }
}

// MARK: - Add Tile Service View

struct AddTileServiceView: View {
    @EnvironmentObject var tileServiceManager: TileServiceManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var type = ""
    @State private var cost = ""
    @State private var timeRequired = ""
    @State private var description = ""
    @State private var material = ""
    @State private var laborCost = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tile Service Details")) {
                    TextField("Name", text: $name)
                    TextField("Type", text: $type)
                    TextField("Material", text: $material)
                    TextField("Service Cost", text: $cost)
                        .keyboardType(.decimalPad)
                    TextField("Labor Cost", text: $laborCost)
                        .keyboardType(.decimalPad)
                    TextField("Time Required", text: $timeRequired)
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Add Tile Service")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                guard let serviceCost = Double(cost), let laborCost = Double(laborCost) else { return }
                let newService = TileService(name: name, type: type, cost: serviceCost, timeRequired: timeRequired, description: description, material: material, laborCost: laborCost)
                tileServiceManager.addService(newService)
                presentationMode.wrappedValue.dismiss()
            }.disabled(name.isEmpty || type.isEmpty || cost.isEmpty || timeRequired.isEmpty || material.isEmpty || laborCost.isEmpty))
        }
    }
}

// MARK: - Edit Tile Service View

struct EditTileServiceView: View {
    @Binding var service: TileService
    @EnvironmentObject var tileServiceManager: TileServiceManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Tile Service Details")) {
                TextField("Name", text: $service.name)
                TextField("Type", text: $service.type)
                TextField("Material", text: $service.material)
                TextField("Service Cost", value: $service.cost, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                TextField("Labor Cost", value: $service.laborCost, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                TextField("Time Required", text: $service.timeRequired)
                TextField("Description", text: $service.description)
            }
        }
        .navigationTitle("Edit Tile Service")
        .navigationBarItems(trailing: Button("Save") {
            presentationMode.wrappedValue.dismiss()
        }.disabled(service.name.isEmpty || service.type.isEmpty || service.material.isEmpty || service.cost == 0.0 || service.laborCost == 0.0 || service.timeRequired.isEmpty))
    }
}

// MARK: - Customer List View

struct CustomerListView: View {
    @EnvironmentObject var customerManager: CustomerManager
    @State private var showingAddCustomerView = false
    @State private var customerToEdit: Customer?
    @State private var showDeleteConfirmation = false
    @State private var customerToDelete: Customer?

    var body: some View {
        NavigationView {
            List {
                ForEach(customerManager.customers) { customer in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(customer.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(customer.contactInfo)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(customer.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Menu {
                            Button(action: {
                                customerToEdit = customer
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(role: .destructive, action: {
                                customerToDelete = customer
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .padding(.leading, 8)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: handleDelete)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Customers")
            .navigationBarItems(trailing: Button(action: {
                showingAddCustomerView = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            })
            .sheet(isPresented: $showingAddCustomerView) {
                AddCustomerView()
                    .environmentObject(customerManager)
            }
            .sheet(item: $customerToEdit) { customer in
                EditCustomerView(customer: binding(for: customer))
                    .environmentObject(customerManager)
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this customer? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let customer = customerToDelete, let index = customerManager.customers.firstIndex(of: customer) {
                            customerManager.customers.remove(at: index)
                        }
                        showDeleteConfirmation = false
                    },
                    secondaryButton: .cancel {
                        showDeleteConfirmation = false
                    }
                )
            }
        }
    }
    
    private func binding(for customer: Customer) -> Binding<Customer> {
        guard let index = customerManager.customers.firstIndex(where: { $0.id == customer.id }) else {
            fatalError("Customer not found")
        }
        return $customerManager.customers[index]
    }

    private func handleDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            customerToDelete = customerManager.customers[index]
            showDeleteConfirmation = true
        }
    }
}

struct AddCustomerView: View {
    @EnvironmentObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var contactInfo = ""
    @State private var address = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Details")) {
                    TextField("Name", text: $name)
                    TextField("Contact Info", text: $contactInfo)
                    TextField("Address", text: $address)
                }
            }
            .navigationTitle("Add Customer")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                let newCustomer = Customer(name: name, contactInfo: contactInfo, address: address)
                customerManager.addCustomer(newCustomer)
                presentationMode.wrappedValue.dismiss()
            }.disabled(name.isEmpty || contactInfo.isEmpty || address.isEmpty))
        }
    }
}

struct EditCustomerView: View {
    @Binding var customer: Customer
    @EnvironmentObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Customer Details")) {
                TextField("Name", text: $customer.name)
                TextField("Contact Info", text: $customer.contactInfo)
                TextField("Address", text: $customer.address)
            }
        }
        .navigationTitle("Edit Customer")
        .navigationBarItems(trailing: Button("Save") {
            presentationMode.wrappedValue.dismiss()
        }.disabled(customer.name.isEmpty || customer.contactInfo.isEmpty || customer.address.isEmpty))
    }
}

// MARK: - Order List View

struct OrderListView: View {
    @EnvironmentObject var orderManager: OrderManager
    @EnvironmentObject var customerManager: CustomerManager
    @State private var showingAddOrderView = false
    @State private var orderToEdit: Order?
    @State private var showDeleteConfirmation = false
    @State private var orderToDelete: Order?

    var body: some View {
        NavigationView {
            List {
                ForEach(orderManager.orders) { order in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(order.serviceName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            HStack {
                                Text("Total: $\(order.totalCost, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Quantity: \(order.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("Customer: \(order.customerName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(order.orderDate, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Menu {
                            Button(action: {
                                orderToEdit = order
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: {
                                orderToDelete = order
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .padding(.leading, 8)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: handleDelete)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Orders")
            .navigationBarItems(trailing: Button(action: {
                showingAddOrderView = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            })
            .sheet(isPresented: $showingAddOrderView) {
                AddOrderView()
                    .environmentObject(orderManager)
                    .environmentObject(customerManager)
            }
            .sheet(item: $orderToEdit) { order in
                EditOrderView(order: binding(for: order))
                    .environmentObject(orderManager)
                    .environmentObject(customerManager)
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this order? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let order = orderToDelete, let index = orderManager.orders.firstIndex(of: order) {
                            orderManager.orders.remove(at: index)
                        }
                        showDeleteConfirmation = false
                    },
                    secondaryButton: .cancel {
                        showDeleteConfirmation = false
                    }
                )
            }
        }
    }
    
    private func binding(for order: Order) -> Binding<Order> {
        guard let index = orderManager.orders.firstIndex(where: { $0.id == order.id }) else {
            fatalError("Order not found")
        }
        return $orderManager.orders[index]
    }

    private func handleDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            orderToDelete = orderManager.orders[index]
            showDeleteConfirmation = true
        }
    }
}

struct AddOrderView: View {
    @EnvironmentObject var orderManager: OrderManager
    @EnvironmentObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var serviceName = ""
    @State private var quantity = ""
    @State private var customerName = ""
    @State private var status = "Pending"
    @State private var paymentStatus = "Unpaid"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Order Details")) {
                    TextField("Service Name", text: $serviceName)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    Picker("Customer", selection: $customerName) {
                        ForEach(customerManager.customers.map { $0.name }, id: \.self) { name in
                            Text(name)
                        }
                    }
                    Picker("Order Status", selection: $status) {
                        Text("Pending").tag("Pending")
                        Text("Completed").tag("Completed")
                    }
                    Picker("Payment Status", selection: $paymentStatus) {
                        Text("Unpaid").tag("Unpaid")
                        Text("Paid").tag("Paid")
                    }
                }
            }
            .navigationTitle("Add Order")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                guard let orderQuantity = Int(quantity) else { return }
                
                let totalCost = Double(orderQuantity) * 100.0 // Assuming a flat rate per service for simplicity
                let newOrder = Order(serviceName: serviceName, quantity: orderQuantity, totalCost: totalCost, customerName: customerName, orderDate: Date(), status: status, paymentStatus: paymentStatus)
                
                // Add the new order to the order manager
                orderManager.addOrder(newOrder)
                
                presentationMode.wrappedValue.dismiss()
            }.disabled(serviceName.isEmpty || quantity.isEmpty || customerName.isEmpty))
        }
    }
}

struct EditOrderView: View {
    @Binding var order: Order
    @EnvironmentObject var orderManager: OrderManager
    @EnvironmentObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var quantity = ""

    var body: some View {
        Form {
            Section(header: Text("Order Details")) {
                TextField("Service Name", text: $order.serviceName)
                TextField("Quantity", text: $quantity)
                    .keyboardType(.numberPad)
                    .onAppear {
                        quantity = String(order.quantity)
                    }
                Picker("Customer", selection: $order.customerName) {
                    ForEach(customerManager.customers.map { $0.name }, id: \.self) { name in
                        Text(name)
                    }
                }
                Picker("Order Status", selection: $order.status) {
                    Text("Pending").tag("Pending")
                    Text("Completed").tag("Completed")
                }
                Picker("Payment Status", selection: $order.paymentStatus) {
                    Text("Unpaid").tag("Unpaid")
                    Text("Paid").tag("Paid")
                }
            }
        }
        .navigationTitle("Edit Order")
        .navigationBarItems(trailing: Button("Save") {
            guard let orderQuantity = Int(quantity) else { return }
            order.quantity = orderQuantity
            order.totalCost = Double(orderQuantity) * 100.0 // Assuming a flat rate per service for simplicity
            presentationMode.wrappedValue.dismiss()
        }.disabled(order.serviceName.isEmpty || quantity.isEmpty || order.customerName.isEmpty))
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
