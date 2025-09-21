// Central enum for unified printer status so multiple files reference same library.

enum PrinterUnifiedStatus {
  disconnected,
  connecting,
  connectedBle,
  connectedClassic,
  error,
}
