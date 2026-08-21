enum UserPreferenceField {
  country('country'),
  currency('currency'),
  language('language');

  const UserPreferenceField(this.wireName);

  final String wireName;
}
