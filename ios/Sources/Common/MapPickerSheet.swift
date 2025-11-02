import MapKit

struct MapPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: Location?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 10.762622, longitude: 106.660172), // TP.HCM mặc định
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var locationName: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: selectedCoordinate.map { [ $0 ] } ?? []) { coord in
                    MapMarker(coordinate: coord, tint: .red)
                }
                .ignoresSafeArea(edges: .top)
                .onTapGesture(coordinateSpace: .local) { point in
                    let coord = convertTapToCoordinate(point)
                    selectedCoordinate = coord
                }

                VStack(spacing: 12) {
                    TextField("Place name", text: $locationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button {
                        if let coord = selectedCoordinate {
                            selectedLocation = Location(
                                name: locationName.isEmpty ? "Unnamed" : locationName,
                                lat: coord.latitude,
                                lng: coord.longitude
                            )
                            dismiss()
                        }
                    } label: {
                        Text("Confirm Location")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedCoordinate == nil ? Color.gray.opacity(0.4) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(selectedCoordinate == nil)

                    Button("Cancel") {
                        dismiss()
                    }
                    .padding(.bottom, 12)
                    .foregroundColor(.red)
                }
                .background(Color.white)
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func convertTapToCoordinate(_ point: CGPoint) -> CLLocationCoordinate2D {
        let mapView = MKMapView()
        return mapView.convert(point, toCoordinateFrom: nil)
    }
}
