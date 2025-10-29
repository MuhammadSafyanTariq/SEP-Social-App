class PdfModel {
  final String? message;
  final String? pdfUrl;

  PdfModel({ this.message,  this.pdfUrl});

  // Factory method to create a PdfModel instance from a JSON map
  factory PdfModel.fromJson(Map<String, dynamic> json) {
    return PdfModel(
      message: json['message'],
      pdfUrl: json['pdfUrl'],
    );
  }

  // Method to convert PdfModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'pdfUrl': pdfUrl,
    };
  }
}
