import SwiftUI
import MapKit
import CoreLocation

// MARK: - Identifiable Annotation
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - MapPickerSheet
struct MapPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: Location?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 21.0169, longitude: 105.7839),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    )
    
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var locationName: String = ""
    @State private var isLoadingLocation = true
    @State private var isGeocoding = false
    @State private var showPermissionAlert = false
    
    @State private var locationManager = CLLocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    private let geocoder = CLGeocoder()
    
    var body: some View {
        ZStack {
            // MARK: - Map
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $userTrackingMode,
                annotationItems: selectedCoordinate.map { [MapAnnotationItem(coordinate: $0)] } ?? []) { item in
                MapPin(coordinate: item.coordinate, tint: .red)
            }
            .ignoresSafeArea()
            .onTapGesture { point in
                let coordinate = region.coordinate(for: point, in: UIScreen.main.bounds.size)
                handleMapTap(at: coordinate)
            }
            .task {
                await requestLocationPermissionAndCenter()
            }
            
            // MARK: - Close Button
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(radius: 3)
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            
            // MARK: - Center Pin
            VStack {
                Spacer()
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.red, .white)
                    .symbolRenderingMode(.palette)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
                    .offset(y: -60)
                Spacer().frame(height: 140)
            }
            .allowsHitTesting(false)
            
            // MARK: - Bottom Sheet
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    Text("Chọn vị trí")
                        .font(.system(size: 18, weight: .semibold))
                    
                    // Address Display
                    if isGeocoding {
                        HStack {
                            ProgressView().scaleEffect(0.8)
                            Text("Đang tìm địa chỉ...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else if !locationName.isEmpty {
                        Text(locationName)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                    } else if selectedCoordinate != nil {
                        Text("Đang xác định địa chỉ...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Chọn vị trí trên bản đồ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Confirm Button
                    Button {
                        confirmLocation()
                    } label: {
                        Label("Xác nhận vị trí", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.blue, .blue.opacity(0.85)],
                                              startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                    }
                    .disabled(selectedCoordinate == nil || isGeocoding)
                    .opacity((selectedCoordinate == nil || isGeocoding) ? 0.6 : 1.0)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
                .padding(.horizontal)
                .padding(.bottom, -10)
            }
            
            // MARK: - Loading
            if isLoadingLocation {
                VStack(spacing: 12) {
                    ProgressView().scaleEffect(1.2)
                    Text("Đang định vị...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
            }
        }
        .navigationBarHidden(true)
        
        // MARK: - Permission Alert
        .alert("Cấp quyền vị trí", isPresented: $showPermissionAlert) {
            Button("Mở Cài đặt") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Hủy", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Ứng dụng cần quyền vị trí để hiển thị vị trí hiện tại của bạn. Vui lòng cấp quyền trong Cài đặt.")
        }
    }
    
    // MARK: - Handle Tap
    private func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedCoordinate = coordinate
            region.center = coordinate
        }
        reverseGeocode(coordinate: coordinate)
    }
    
    // MARK: - Reverse Geocode
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        isGeocoding = true
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            isGeocoding = false
            if let placemark = placemarks?.first {
                let address = [
                    placemark.subThoroughfare,
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
                
                locationName = address.isEmpty ? "Vị trí đã chọn" : address
            } else {
                locationName = "Vị trí đã chọn"
            }
        }
    }
    
    // MARK: - Request Permission & Center
    private func requestLocationPermissionAndCenter() async {
        locationManager.requestWhenInUseAuthorization()
        
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            await centerOnUser()
        case .denied, .restricted:
            isLoadingLocation = false
            showPermissionAlert = true
        case .notDetermined:
            // Đã request → chờ callback → sẽ tự gọi lại
            await Task.yield()
            await requestLocationPermissionAndCenter()
        @unknown default:
            isLoadingLocation = false
            showPermissionAlert = true
        }
    }
    
    private func centerOnUser() async {
        guard let userLocation = locationManager.location else {
            isLoadingLocation = false
            region.center = CLLocationCoordinate2D(latitude: 21.0169, longitude: 105.7839)
            return
        }
        
        let coord = userLocation.coordinate
        withAnimation {
            region.center = coord
            selectedCoordinate = coord
        }
        
        isLoadingLocation = false
        reverseGeocode(coordinate: coord)
    }
    
    // MARK: - Confirm
    private func confirmLocation() {
        guard let coord = selectedCoordinate else { return }
        let finalName = locationName.isEmpty ? "Vị trí đã chọn" : locationName
        
        selectedLocation = Location(
            name: finalName,
            lat: coord.latitude,
            lng: coord.longitude
        )
        dismiss()
    }
}

// MARK: - Tap to Coordinate
extension MKCoordinateRegion {
    func coordinate(for point: CGPoint, in viewSize: CGSize) -> CLLocationCoordinate2D {
        let centerX = viewSize.width / 2
        let centerY = viewSize.height / 2
        let x = (point.x - centerX) / viewSize.width
        let y = (point.y - centerY) / viewSize.height
        
        let newLongitude = center.longitude + x * span.longitudeDelta
        let newLatitude = center.latitude - y * span.latitudeDelta
        
        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
}
