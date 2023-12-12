class Theraphy {
  String title;
  String fieldscript;
  String fieldurzadzenie;
  String bodyvalue;

  Theraphy(
      {this.title = "",
      this.bodyvalue = "",
      this.fieldscript = "",
      this.fieldurzadzenie = ""});

  factory Theraphy.empty() {
    return Theraphy(
        title: "", bodyvalue: "", fieldscript: "", fieldurzadzenie: "");
  }

  factory Theraphy.fromRest(Map<String, dynamic> json) {
    return Theraphy(
      title: json['title'][0]['value'],
      bodyvalue: json['body'][0]['value'],
      fieldscript: json['field_skrypt'][0]['value'],
      fieldurzadzenie: json['field_urzadzenie'][0]['value'],
    );
  }

  factory Theraphy.fromMap(Map<String, dynamic> json) => Theraphy(
        title: json['title'],
        bodyvalue: json['bodyvalue'],
        fieldscript: json['fieldscript'],
        fieldurzadzenie: json['fieldurzadzenie'],
      );

  Map<String, dynamic> toMap() => {
        'title': this.title,
        "bodyvalue": this.bodyvalue,
        "fieldscript": this.fieldscript,
        "fieldurzadzenie": this.fieldurzadzenie,
      };
}
