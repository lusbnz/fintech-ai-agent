import SwiftUI
import MapKit
import CoreLocation

struct MapPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: Location?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 21.0169, longitude: 105.7839),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    @State private var locationName: String = ""
    @State private var isLoading = true
    @State private var errorText: String?

    var body: some View {
        ZStack {
            // 🗺 Map full-screen, subtle blur transition
            Map(coordinateRegion: $region, showsUserLocation: true)
                .ignoresSafeArea()
                .task { await centerOnUserLocation() }
                .overlay(alignment: .topLeading) {
                    // Dismiss floating button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .padding()
                    }
                }

            // 🎯 Floating marker pin
            VStack {
                Spacer()
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.red, .white)
                    .symbolRenderingMode(.palette)
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .padding(.bottom, 50)
            }

            // 🧾 Floating bottom sheet (Glass style)
            VStack(spacing: 10) {
                Spacer()

                VStack(spacing: 12) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 40, height: 4)
                        .padding(.top, 6)

                    Text("Confirm this location?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)

                    TextField("Enter a place name (optional)", text: $locationName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button {
                        let coord = region.center
                        selectedLocation = Location(
                            name: locationName.isEmpty ? "Unnamed" : locationName,
                            lat: coord.latitude,
                            lng: coord.longitude
                        )
                        dismiss()
                    } label: {
                        Label("Confirm Location", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.gradient)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding(.horizontal)
                            .shadow(color: .blue.opacity(0.2), radius: 6, y: 4)
                    }

                    if let error = errorText {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(radius: 10)
                .padding()
            }

            if isLoading {
                ProgressView("Locating...")
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Helpers
    private func centerOnUserLocation() async {
        do {
            let location = try await getUserLocation()
            region.center = location.coordinate
            isLoading = false
        } catch {
            errorText = "Unable to get location"
            isLoading = false
        }
    }

    private func getUserLocation() async throws -> CLLocation {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        guard let loc = manager.location else {
            throw NSError(domain: "LocationError", code: -1)
        }
        return loc
    }
}
