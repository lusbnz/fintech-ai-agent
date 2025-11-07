import SwiftUI
import MapKit

struct MapFullScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var pins: [CLLocationCoordinate2D] = []
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 🗺️ Map full screen, không safe area
            MapFullView(pins: $pins, userLocation: locationManager.currentLocation)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    locationManager.requestLocationPermission()
                }

            // 🔙 Nút Back
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .padding(.leading, 16)
            .padding(.top, 20)

            // 📍 Nút "Vị trí của tôi"
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if let coordinate = locationManager.currentLocation?.coordinate {
                            NotificationCenter.default.post(
                                name: .centerMapOnUser,
                                object: coordinate
                            )
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}
