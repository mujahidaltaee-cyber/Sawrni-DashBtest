class SawrniDeliveryApiPaths {
  static String providerUpload(int bookingId) => '/api/v1/mobile/delivery/provider/bookings/$bookingId/upload';
  static String customerDeliveries(int bookingId) => '/api/v1/mobile/delivery/customer/bookings/$bookingId/deliveries';
  static String signedAccess(int deliveryId) => '/api/v1/mobile/delivery/customer/deliveries/$deliveryId/signed-access';
}
