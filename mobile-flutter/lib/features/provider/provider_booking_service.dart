import '../../core/network/sawrni_api_client.dart';
import '../../core/session/sawrni_session.dart';
import 'provider_booking_model.dart';

class ProviderBookingService {
  ProviderBookingService()
      : _client = SawrniApiClient(
          baseUrl: SawrniSession.apiBaseUrl,
          bearerToken: SawrniSession.token,
        );

  final SawrniApiClient _client;

  Future<List<ProviderBooking>> fetchIncomingBookings() async {
    final data = await _client.getJson('/mobile/provider/bookings');
    final rows = (data['rows'] as List? ?? const []);
    return rows
        .whereType<Map>()
        .map((row) => ProviderBooking.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<ProviderBooking> fetchBookingDetails(int id) async {
    final data = await _client.getJson('/mobile/provider/bookings/$id');
    return ProviderBooking.fromJson(Map<String, dynamic>.from(data['row'] as Map));
  }

  Future<void> acceptBooking(int id) async {
    await _client.postJson('/mobile/provider/bookings/$id/accept', {});
  }

  Future<void> rejectBooking(int id, String reason) async {
    await _client.postJson('/mobile/provider/bookings/$id/reject', {
      'reason': reason,
    });
  }
}
